#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

log_date() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z')"
}

error() {
  echo "[$(log_date)]: $*" >&2
}

debug() {
  [[ -z "${DEBUG}" ]] && [[ "${DEBUG}" == "true" ]] && info "${*}"
}

info() {
  echo "[$(log_date)]: $*" >&1
}
