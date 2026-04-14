#!/usr/bin/env bash

dotfiles_config_root() {
  printf '%s\n' "$ROOT_DIR/config"
}

dotfiles_backup_target_for() {
  local target="$1"
  printf '%s.dotfiles.backup\n' "$target"
}

dotfiles_backup_existing() {
  local target="$1"
  local backup

  [[ -e "$target" || -L "$target" ]] || return 0

  backup="$(dotfiles_backup_target_for "$target")"
  if [[ -e "$backup" || -L "$backup" ]]; then
    backup="${backup}.$(date +%s)"
  fi

  dotfiles_ensure_parent "$backup"
  dotfiles_log_info "backing up ${target} -> ${backup}"
  mv -- "$target" "$backup"
  manifest_add_record backup "$backup" "$target"
}

dotfiles_link_relative() {
  local source="$1"
  local target="$2"
  local target_dir rel

  target_dir="$(dirname -- "$target")"
  dotfiles_ensure_parent "$target"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink -- "$target")" == "$(dotfiles_realpath_relative "$source" "$target_dir")" ]]; then
      dotfiles_log_debug "link already present: $target"
      manifest_add_record link "$target" "$source"
      return 0
    fi
  fi

  dotfiles_backup_existing "$target"
  rel="$(dotfiles_realpath_relative "$source" "$target_dir")"
  dotfiles_log_info "linking ${target} -> ${rel}"
  ln -s -- "$rel" "$target"
  manifest_add_record link "$target" "$source"
}

dotfiles_collect_config_targets() {
  local -A chosen=()
  local scope_root file rel

  while IFS= read -r scope_root; do
    [[ -n "$scope_root" && -d "$scope_root" ]] || continue
    while IFS= read -r file; do
      rel="${file#"$scope_root"/}"
      chosen["$rel"]="$file"
    done < <(dotfiles_list_files "$scope_root")
  done < <(scope_dirs_low_to_high config)

  printf '%s\n' "${!chosen[@]}" | sort | while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    printf '%s\t%s\n' "$rel" "${chosen[$rel]}"
  done
}

run_install() {
  local rel source target

  dotfiles_log_info "starting install"

  while IFS=$'\t' read -r rel source; do
    [[ -n "$rel" && -n "$source" ]] || continue
    target="$HOME/$rel"
    dotfiles_link_relative "$source" "$target"
  done < <(dotfiles_collect_config_targets)

  dotfiles_log_info "install complete"
}
