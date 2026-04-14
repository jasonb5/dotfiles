#!/usr/bin/env bash

manifest_path() {
  printf '%s\n' "${DOTFILES_MANIFEST:-$HOME/.local/state/dotfiles/manifest}"
}

manifest_init() {
  ensure_dir "$(dirname -- "$(manifest_path)")"
  touch "$(manifest_path)"
}

manifest_has_line() {
  local line="$1"
  grep -Fxq -- "$line" "$(manifest_path)"
}

manifest_add_line() {
  manifest_init
  local line="$1"
  manifest_has_line "$line" || printf '%s\n' "$line" >>"$(manifest_path)"
}

manifest_add_record() {
  local kind="$1"
  local path="$2"
  local extra="${3:-}"
  manifest_add_line "${kind}|${path}|${extra}"
}

manifest_records() {
  manifest_init
  while IFS= read -r line; do
    printf '%s\n' "$line"
  done <"$(manifest_path)"
}
