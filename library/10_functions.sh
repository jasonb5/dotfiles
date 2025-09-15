#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

command_exists() {
  command -v "${1}" > /dev/null 2>&1

  return $?
}

safe_source() {
  local file="${1}"

  if [[ -n "${file}" ]] && [[ -e "${file}" ]]; then
    info "Sourcing \"${file}\""

    source "${file}"
  fi
}

kernel_file() {
  echo "${DOTFILE_PATH}/machines/$(uname -s | tr '[:upper:]' '[:lower:]').sh"
}

os_file() {
  if [[ -e "/etc/os-release" ]]; then
    echo "${DOTFILE_PATH}/machines/$(cat /etc/os-release | grep '^ID' | cut -d'=' -f2).sh"
  else
    echo ""
  fi
}

hostname_file() {
  echo "${DOTFILE_PATH}/machines/${HOSTNAME:-"$(uname -n)"}.sh"
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
