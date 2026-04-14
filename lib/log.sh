#!/usr/bin/env bash

dotfiles_log_path() {
  printf '%s\n' "$(dotfiles_state_dir)/dotfiles.log"
}

dotfiles_log_level_rank() {
  case "$1" in
    debug) printf '%s\n' 0 ;;
    info) printf '%s\n' 1 ;;
    warn) printf '%s\n' 2 ;;
    error) printf '%s\n' 3 ;;
    *) printf '%s\n' 1 ;;
  esac
}

dotfiles_should_log() {
  local current requested
  current="$(dotfiles_log_level_rank "${DOTFILES_LOG_LEVEL:-info}")"
  requested="$(dotfiles_log_level_rank "$1")"
  [[ "$requested" -ge "$current" ]]
}

dotfiles_log() {
  local level="$1"
  shift

  dotfiles_should_log "$level" || return 0
  ensure_dir "$(dirname -- "$(dotfiles_log_path)")"
  printf '%s [%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$level" "$*" >>"$(dotfiles_log_path)"
  printf 'dotfiles: [%s] %s\n' "$level" "$*" >&2
}

dotfiles_log_info() { dotfiles_log info "$@"; }
dotfiles_log_warn() { dotfiles_log warn "$@"; }
dotfiles_log_debug() { dotfiles_log debug "$@"; }
