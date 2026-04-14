#!/usr/bin/env bash

detect_scope() {
  load_detected_scope
  dotfiles_log_info "detected scope os=${DOTFILES_OS} distro=${DOTFILES_DISTRO} host=${DOTFILES_HOST}"
  printf 'os=%s\ndistro=%s\nhost=%s\n' "$DOTFILES_OS" "$DOTFILES_DISTRO" "$DOTFILES_HOST"
}

load_detected_scope() {
  local os distro host
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  host="${HOSTNAME:-$(uname -n)}"
  host="${host%%.*}"
  distro="unknown"

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    distro="${ID:-unknown}"
  fi

  DOTFILES_OS="$os"
  DOTFILES_DISTRO="$distro"
  DOTFILES_HOST="$host"
  export DOTFILES_OS DOTFILES_DISTRO DOTFILES_HOST
}
