#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

dotfile::load_machine_files() {
  local kernel
  kernel="$(uname -s)"
  local hostname
  hostname="$(uname -n)"

  # shellcheck source=machines/linux.sh
  local kernel_file="${DOTFILE_PATH}/machines/${kernel}.sh"
  # shellcheck source=machines/lo.sh
  local hostname_file="${DOTFILE_PATH}/machines/${hostname}.sh"

  if [[ -e "${kernel_file}" ]]; then
    info "Loading kernel file ${kernel_file}"

    # shellcheck disable=SC1090
    source "${kernel_file}"
  else
    debug "Skipping kernel file"
  fi

  if [[ "${kernel,,}" == "linux" ]]; then
    local os
    os="$(cat /etc/os-release | grep "^ID" | cut -d"=" -f2)"
    # shellcheck source=machines/arch.sh
    local os_file="${DOTFILE_PATH}/machines/${os}.sh"

    if [[ -e "${os_file}" ]]; then
      info "Loading os file ${os_file}"

      # shellcheck disable=SC1090
      source "${os_file}"
    else
      debug "Skipping os file"
    fi
  fi

  if [[ -e "${hostname_file}" ]]; then
    info "Loading hostname file ${hostname_file}"

    # shellcheck disable=SC1090
    source "${hostname_file}"
  else
    debug "Skipping hostname file"
  fi
}

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
