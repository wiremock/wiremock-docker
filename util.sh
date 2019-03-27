#!/bin/bash

. smoke.sh

assert_bash_ok() {
  if [[ $1 -eq 0 ]]; then
    _smoke_success "Bash return ok"
  else
    _smoke_fail "Bash return error"
  fi
}

assert_equal() {
  if [ "$1" = "$2" ]; then
    _smoke_success "$1 = $2"
  else
    _smoke_fail "$1 != $2"
  fi
}

title() {
  echo ""
  message "${bold}$1${normal}"
  echo ""
}

message() {
  TEXT="$1"
  echo "$TEXT"
}
