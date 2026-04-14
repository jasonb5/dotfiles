#!/usr/bin/env bash

dotfiles_repo_root() {
  printf '%s\n' "${ROOT_DIR:-${DOTFILES_ROOT:-}}"
}

dotfiles_home() {
  printf '%s\n' "$HOME"
}

dotfiles_state_dir() {
  printf '%s\n' "${DOTFILES_STATE_DIR:-$HOME/.local/state/dotfiles}"
}

dotfiles_backup_dir() {
  printf '%s\n' "$(dotfiles_state_dir)/backups"
}

die() {
  printf 'dotfiles: %s\n' "$*" >&2
  exit 1
}

ensure_dir() {
  mkdir -p -- "$1"
}

dotfiles_realpath_relative() {
  local source="$1"
  local target_dir="$2"

  realpath --relative-to "$target_dir" "$source"
}

dotfiles_ensure_parent() {
  ensure_dir "$(dirname -- "$1")"
}

dotfiles_write_file() {
  local path="$1"
  dotfiles_ensure_parent "$path"
  : >"$path"
}
