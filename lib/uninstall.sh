#!/usr/bin/env bash

dotfiles_restore_backup() {
  local backup="$1"
  local target="$2"

  [[ -e "$backup" || -L "$backup" ]] || return 0
  dotfiles_ensure_parent "$target"
  rm -rf -- "$target"
  mv -- "$backup" "$target"
}

run_uninstall() {
  local -a records=()
  local kind path extra record

  dotfiles_log_info "starting uninstall"

  while IFS= read -r record; do
    [[ -n "$record" ]] || continue
    records+=("$record")
  done < <(manifest_records)

  for record in "${records[@]}"; do
    IFS='|' read -r kind path extra <<<"$record"
    case "$kind" in
      link|copy)
        if [[ -e "$path" || -L "$path" ]]; then
          rm -rf -- "$path"
        fi
        ;;
      rc)
        dotfiles_rc_remove_block "$path"
        ;;
      mkdir)
        rmdir --ignore-fail-on-non-empty -- "$path" 2>/dev/null || true
        ;;
    esac
  done

  for record in "${records[@]}"; do
    IFS='|' read -r kind path extra <<<"$record"
    case "$kind" in
      backup)
        dotfiles_restore_backup "$path" "$extra"
        ;;
    esac
  done

  : >"$(manifest_path)"
  dotfiles_log_info "uninstall complete"
}
