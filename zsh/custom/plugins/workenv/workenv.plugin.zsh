if [[ -z $WORKENV_AUTH_FILE ]]; then
  WORKENV_AUTH_FILE=~/.workenv_authorized
fi

if [[ -z $WORKENV_ENTER ]]; then
  WORKENV_ENTER=".workenv"
fi

if [[ -z $WORKENV_LEAVE ]]; then
  WORKENV_LEAVE=".workenv-leave"
fi

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
  _WORKENV_OLDPATH="$OLDPWD"
  _WORKENV_NEWPATH="$(pwd)"

  while [[ ! "$_WORKENV_NEWPATH" == "$_WORKENV_OLDPATH"* ]]; do
    if [[ -f "$_WORKENV_OLDPATH/$WORKENV_LEAVE" ]]; then
      workenv_check_and_exec "$_WORKENV_OLDPATH/$WORKENV_LEAVE"
    fi
    _WORKENV_OLDPATH="$(dirname $_WORKENV_OLDPATH)"
  done

  if [[ $_WORKENV_OLDPATH == '/' ]]; then
    _WORKENV_OLDPATH=''
  fi

  while [[ ! "$_WORKENV_OLDPATH" == "$_WORKENV_NEWPATH" ]]; do
    _WORKENV_OLDPATH="$_WORKENV_OLDPATH$(echo -n '/'; echo ${_WORKENV_NEWPATH#${_WORKENV_OLDPATH}} | tr \/ "\n" | sed -n '2p' )"
    if [[ -f "$_WORKENV_OLDPATH/$WORKENV_ENTER" ]]; then
      workenv_check_and_exec "$_WORKENV_OLDPATH/$WORKENV_ENTER"
    fi
  done
}

if [[ -f "./$WORKENV_ENTER" ]]; then
  workenv_check_and_exec "./$WORKENV_ENTER"
fi

() {
  local OLDPWD='/'
  workenv_init
}
chpwd_functions+=( workenv_init )
