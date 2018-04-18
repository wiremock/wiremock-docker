#!/bin/bash

. smoke.sh

assert_bash_ok() {
  if [[ $1 -eq 0 ]]; then
    _smoke_success "Bash return ok"
  else
    _smoke_fail "Bash return error"
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
