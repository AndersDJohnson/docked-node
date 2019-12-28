#!/usr/bin/env bash

docked-node() {
  # shellcheck disable=SC1090,SC2128
  "$(dirname "$BASH_SOURCE")/docked-node.sh" "$@"
}

# shellcheck disable=SC2053
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f docked-node
else
  docked-node "${@}"
  exit $?
fi
