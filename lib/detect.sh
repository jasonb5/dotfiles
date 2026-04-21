#!/usr/bin/env bash

detect_scope() {
  load_detected_scope
  dotfiles_log_info "detected scope os=${DOTFILES_OS} distro=${DOTFILES_DISTRO} groups=${DOTFILES_GROUPS:-} host=${DOTFILES_HOST}"
  printf 'os=%s\ndistro=%s\ngroup=%s\ngroups=%s\nhost=%s\n' "$DOTFILES_OS" "$DOTFILES_DISTRO" "${DOTFILES_GROUP:-}" "${DOTFILES_GROUPS:-}" "$DOTFILES_HOST"
}

load_detected_scope() {
  local os distro host group groups
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  host="${HOSTNAME:-$(uname -n)}"
  host="${host%%.*}"
  distro="unknown"
  group="${DOTFILES_GROUP:-}"
  groups="${DOTFILES_GROUPS:-}"

  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    distro="${ID:-unknown}"
  fi

  if [[ -z "$groups" ]]; then
    local -a matched_groups=()
    local matched_group
    while IFS= read -r matched_group; do
      [[ -n "$matched_group" ]] || continue
      matched_groups+=("$matched_group")
    done < <(dotfiles_groups_for_host "$host")

    if (( ${#matched_groups[@]} > 0 )); then
      group="${matched_groups[0]}"
      groups="$(IFS=,; printf '%s' "${matched_groups[*]}")"
    fi
  fi

  DOTFILES_OS="$os"
  DOTFILES_DISTRO="$distro"
  DOTFILES_GROUP="$group"
  DOTFILES_GROUPS="$groups"
  DOTFILES_HOST="$host"
  export DOTFILES_OS DOTFILES_DISTRO DOTFILES_GROUP DOTFILES_GROUPS DOTFILES_HOST
}
