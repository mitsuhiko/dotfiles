if [[ -z $WORKENV_AUTH_FILE ]]; then
  WORKENV_AUTH_FILE=~/.workenv_authorized
fi

# Allow disabling the workenv logic.  This is done for shell scripts
# that want to cd around and can cause confusion.
WORKENV_ENABLED=1

function workenv_check_and_run() {
  echo "$fg_no_bold[red]WARNING$reset_color"
  echo "This is the first time you are about to source a work env file"
  echo -e "  file: $1"
  echo
  echo -e "$fg_no_bold[green]----------------$reset_color"
  cat $1
  echo -e "$fg_no_bold[green]----------------$reset_color"
  echo
  echo -n "Are you sure you want to allow this? (yN) "
  read answer
  if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
    echo "$1:$2" >> $WORKENV_AUTH_FILE
    envfile=$1
    shift
    source $envfile
  fi
}

function workenv_check_and_exec() {
  if which shasum &> /dev/null; then
    hash=$(shasum "$1" | cut -d' ' -f 1)
  else
    hash=$(sha1sum "$1" | cut -d' ' -f 1)
  fi
  if grep -sq "$1:$hash" "$WORKENV_AUTH_FILE"; then
    envfile=$1
    shift
    source $envfile
  else
    workenv_check_and_run $1 $hash
  fi
}

function workenv_init() {
  if [[ ! "$WORKENV_ENABLED" == "1" ]]; then
    return
  fi
  _WORKENV_OLDPATH="$OLDPWD"
  _WORKENV_NEWPATH="$(pwd)"

  while [[ ! "$_WORKENV_NEWPATH" == "$_WORKENV_OLDPATH"* ]]; do
    if [[ -f "$_WORKENV_OLDPATH/.workenv-leave" ]]; then
      workenv_check_and_exec "$_WORKENV_OLDPATH/.workenv-leave"
    fi
    _WORKENV_OLDPATH="$(dirname $_WORKENV_OLDPATH)"
  done

  if [[ $_WORKENV_OLDPATH == '/' ]]; then
    _WORKENV_OLDPATH=''
  fi

  while [[ ! "$_WORKENV_OLDPATH" == "$_WORKENV_NEWPATH" ]]; do
    _WORKENV_OLDPATH="$_WORKENV_OLDPATH$(echo -n '/'; echo ${_WORKENV_NEWPATH#${_WORKENV_OLDPATH}} | tr \/ "\n" | sed -n '2p' )"
    if [[ -f "$_WORKENV_OLDPATH/.workenv" ]]; then
      workenv_check_and_exec "$_WORKENV_OLDPATH/.workenv"
    fi
  done
}

if [[ -f "./.workenv" ]]; then
  workenv_check_and_exec "./.workenv"
fi

() {
  local OLDPWD='/'
  workenv_init
}
chpwd_functions+=( workenv_init )


# Helpers that make working with workenv more fun

_WORKENV_ACTIVE_VIRTUALENVS=()

function workenv_enable_virtualenv() {
  WORKENV_ENABLED=0
  local OLD_ENV=$_WORKENV_ACTIVE_VIRTUALENVS[-1]
  if [[ ! -z $OLD_ENV ]]; then
    _workenv_disable_virtualenv
  fi
  _WORKENV_ACTIVE_VIRTUALENVS+=($1)
  _workenv_enable_virtualenv "$1"
  WORKENV_ENABLED=1
}

function workenv_disable_virtualenv() {
  WORKENV_ENABLED=0
  _workenv_disable_virtualenv
  local OLD_ENV=$_WORKENV_ACTIVE_VIRTUALENVS[-2]
  _WORKENV_ACTIVE_VIRTUALENVS=($_WORKENV_ACTIVE_VIRTUALENVS[1,-2])
  if [[ ! -z $OLD_ENV ]]; then
    _workenv_enable_virtualenv "$OLD_ENV"
  fi
  WORKENV_ENABLED=1
}


function _workenv_enable_virtualenv() {
  echo -n "Enabling virtualenv $1 ... "
  if [[ "${1#*:/}" != "$1" ]]; then
    source "$1/bin/activate"
  else
    workon $1
  fi
  echo -e "$fg_no_bold[green]Done$reset_color"
}

function _workenv_disable_virtualenv() {
  local ENV_NAME=$_WORKENV_ACTIVE_VIRTUALENVS[-1]
  echo -n "Disabling virtualenv $ENV_NAME ... "
  deactivate 2> /dev/null
  echo -e "$fg_no_bold[green]Done$reset_color"
}
