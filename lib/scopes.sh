#!/usr/bin/env bash

scope_priority() {
  printf '%s\n' host group distro os common
}

dotfiles_group_rules_file() {
  printf '%s\n' "${DOTFILES_GROUP_RULES_FILE:-$ROOT_DIR/lib/group-rules}"
}

dotfiles_group_rules() {
  local rules_file

  rules_file="$(dotfiles_group_rules_file)"
  [[ -r "$rules_file" ]] || return 0

  cat -- "$rules_file"
}

dotfiles_groups_for_host() {
  local host="$1"
  local group pattern
  declare -A seen=()

  while IFS=: read -r group pattern; do
    [[ -n "$group" && -n "$pattern" ]] || continue
    if [[ "$host" =~ $pattern && -z "${seen[$group]:-}" ]]; then
      seen["$group"]=1
      printf '%s\n' "$group"
    fi
  done < <(dotfiles_group_rules)
}

dotfiles_scope_value() {
  local scope="$1"

  case "$scope" in
    host) printf '%s\n' "${DOTFILES_HOST:-}" ;;
    group) printf '%s\n' "${DOTFILES_GROUP:-}" ;;
    distro) printf '%s\n' "${DOTFILES_DISTRO:-}" ;;
    os) printf '%s\n' "${DOTFILES_OS:-}" ;;
    common) printf '%s\n' common ;;
    *) return 1 ;;
  esac
}

scope_dir() {
  local tree="$1"
  local scope="$2"
  local value="${3:-}"

  if [[ -z "$value" ]]; then
    value="$(dotfiles_scope_value "$scope")"
  fi
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
  local group

  printf '%s\n' \
    "$(scope_dir "$tree" common)" \
    "$(scope_dir "$tree" os)" \
    "$(scope_dir "$tree" distro)"

  while IFS= read -r group; do
    [[ -n "$group" ]] || continue
    scope_dir "$tree" group "$group"
  done < <(dotfiles_groups_for_host "${DOTFILES_HOST:-}")

  printf '%s\n' "$(scope_dir "$tree" host)"
}

scope_dirs_high_to_low() {
  local tree="$1"
  local -a groups=()
  local group

  while IFS= read -r group; do
    [[ -n "$group" ]] || continue
    groups+=("$group")
  done < <(dotfiles_groups_for_host "${DOTFILES_HOST:-}")

  printf '%s\n' "$(scope_dir "$tree" host)"

  for ((i=${#groups[@]} - 1; i >= 0; i--)); do
    scope_dir "$tree" group "${groups[$i]}"
  done

  printf '%s\n' \
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
  printf 'DOTFILES_OS=%s\nDOTFILES_DISTRO=%s\nDOTFILES_GROUP=%s\nDOTFILES_GROUPS=%s\nDOTFILES_HOST=%s\nDOTFILES_ROOT=%s\n' \
    "$DOTFILES_OS" "$DOTFILES_DISTRO" "${DOTFILES_GROUP:-}" "${DOTFILES_GROUPS:-}" "$DOTFILES_HOST" "$(dotfiles_repo_root)"
}
