#!/usr/bin/env bash

scope_priority() {
  printf '%s\n' host distro os common
}

dotfiles_scope_value() {
  local scope="$1"

  case "$scope" in
    host) printf '%s\n' "${DOTFILES_HOST:-}" ;;
    distro) printf '%s\n' "${DOTFILES_DISTRO:-}" ;;
    os) printf '%s\n' "${DOTFILES_OS:-}" ;;
    common) printf '%s\n' common ;;
    *) return 1 ;;
  esac
}

scope_dir() {
  local tree="$1"
  local scope="$2"
  local value

  value="$(dotfiles_scope_value "$scope")"
  [[ -n "$value" ]] || return 0

  case "$tree" in
    bootstrap)
      if [[ "$scope" == common ]]; then
        printf '%s/%s/%s\n' "$ROOT_DIR" "$tree" "$value"
      else
        printf '%s/%s/%s/%s\n' "$ROOT_DIR" "$tree" "$scope" "$value"
      fi
      ;;
    *)
      if [[ "$scope" == common ]]; then
        printf '%s/%s/%s\n' "$ROOT_DIR" "$tree" "$value"
      else
        printf '%s/%s/%s/%s\n' "$ROOT_DIR" "$tree" "$scope" "$value"
      fi
      ;;
  esac
}

scope_dirs_low_to_high() {
  local tree="$1"
  printf '%s\n' \
    "$(scope_dir "$tree" common)" \
    "$(scope_dir "$tree" os)" \
    "$(scope_dir "$tree" distro)" \
    "$(scope_dir "$tree" host)"
}

scope_dirs_high_to_low() {
  local tree="$1"
  printf '%s\n' \
    "$(scope_dir "$tree" host)" \
    "$(scope_dir "$tree" distro)" \
    "$(scope_dir "$tree" os)" \
    "$(scope_dir "$tree" common)"
}

dotfiles_is_ignored_file() {
  case "$(basename -- "$1")" in
    README.md|.gitkeep) return 0 ;;
  esac
  return 1
}

dotfiles_list_files() {
  local root="$1"
  local file

  shopt -s nullglob dotglob globstar
  for file in "$root"/**/*; do
    [[ -f "$file" ]] || continue
    dotfiles_is_ignored_file "$file" && continue
    printf '%s\n' "$file"
  done
}

dotfiles_scope_env() {
  load_detected_scope
  printf 'DOTFILES_OS=%s\nDOTFILES_DISTRO=%s\nDOTFILES_HOST=%s\nDOTFILES_ROOT=%s\n' \
    "$DOTFILES_OS" "$DOTFILES_DISTRO" "$DOTFILES_HOST" "$(dotfiles_repo_root)"
}
