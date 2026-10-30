#!/usr/bin/env bash

docked-node() {
  "$(dirname "${BASH_SOURCE[0]}")/docked-node.sh" "$@"
}

if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
  export -f docked-node
else
  docked-node "${@}"
  exit $?
fi
