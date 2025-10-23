#!/usr/bin/env bash

command_exists() {
  command -v "${1}" > /dev/null 2>&1

  return $?
}

log_date() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z')"
}

error() {
  echo "[$(log_date)][ERR]: $*" >&2
}

debug() {
  [[ -n "${DEBUG}" ]] && [[ "${DEBUG}" == "true" ]] && echo "[$(log_date)][DEBUG]: $*" >&1
}

info() {
  echo "[$(log_date)][INFO]: $*" >&1
}
