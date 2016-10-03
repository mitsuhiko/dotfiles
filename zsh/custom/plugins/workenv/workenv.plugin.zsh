if [[ -z $WORKENV_AUTH_FILE ]]; then
  WORKENV_AUTH_FILE=~/.workenv_authorized
fi

# Allow disabling the workenv logic.  This is done for shell scripts
# that want to cd around and can cause confusion.
WORKENV_ENABLED=1

function workenv_check_and_run() {
  echo
  echo "$fg_no_bold[red]WARNING$reset_color"
  echo "This is the first time you are about to source a workenv file"
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
    echo "Trusting workenv file."
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
_WORKENV_ACTIVE_PATHS=()

# Enables a given virtualenv
function workenv_enable_virtualenv() {
  local VENV="$1"
  if [[ "${VENV#*/}" != "$1" ]]; then
    VENV="${VENV:A}"
  fi
  WORKENV_ENABLED=0
  local OLD_ENV=$_WORKENV_ACTIVE_VIRTUALENVS[-1]
  if [[ ! -z $OLD_ENV ]]; then
    _workenv_disable_virtualenv
  fi
  _WORKENV_ACTIVE_VIRTUALENVS+=($VENV)
  _workenv_enable_virtualenv "$VENV"
  WORKENV_ENABLED=1
}

# Disables the currently active virtualenv
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

# Prepends a path to PATH
function workenv_path_prepend() {
  _WORKENV_ACTIVE_PATHS+=($PATH)
  export PATH="${1:A}:$PATH"
}

# Appends a path to PATH
function workenv_path_append() {
  _WORKENV_ACTIVE_PATHS+=($PATH)
  export PATH="$PATH:${1:A}"
}

# Resets the PATH to what it was before
function workenv_path_reset() {
  local OLD_PATH=$_WORKENV_ACTIVE_PATHS[-1]
  _WORKENV_ACTIVE_PATHS=($_WORKENV_ACTIVE_PATHS[1,-2])
  export PATH="$OLD_PATH"
}


function _workenv_enable_virtualenv() {
  echo -n "Enabling virtualenv $1 ... "
  if [[ "${1#*/}" != "$1" ]]; then
    if [ -f "$1/bin/activate" ]; then
      source "$1/bin/activate"
    else
      echo -e "$fg_no_bold[red]Not Found$reset_color"
      return
    fi
  else
    workon $1
  fi
  echo -e "$fg_no_bold[green]Done$reset_color"
}

function _workenv_disable_virtualenv() {
  local ENV_NAME=$_WORKENV_ACTIVE_VIRTUALENVS[-1]
  echo -n "Disabling virtualenv $ENV_NAME ... "
  if deactivate 2> /dev/null; then
    echo -e "$fg_no_bold[green]Done$reset_color"
  else
    echo -e "$fg_no_bold[red]Not Found$reset_color"
  fi
}
