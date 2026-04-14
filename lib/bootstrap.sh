#!/usr/bin/env bash

dotfiles_source_shell_dir() {
  local dir="$1"
  local file

  [[ -d "$dir" ]] || return 0
  shopt -s nullglob
  for file in "$dir"/*.sh; do
    [[ -f "$file" ]] || continue
    . "$file"
  done
}

dotfiles_run_tree() {
  local tree="$1"
  local scope_root file

  while IFS= read -r scope_root; do
    [[ -n "$scope_root" && -d "$scope_root" ]] || continue
    while IFS= read -r file; do
      [[ -f "$file" ]] || continue
      case "$(basename -- "$file")" in
        README.md|.gitkeep) continue ;;
      esac
      if [[ -x "$file" ]]; then
        "$file"
      else
        bash "$file"
      fi
    done < <(dotfiles_list_files "$scope_root")
  done < <(scope_dirs_low_to_high "$tree")
}

run_bootstrap() {
  load_detected_scope
  DOTFILES_ROOT="$(dotfiles_repo_root)"
  export DOTFILES_OS DOTFILES_DISTRO DOTFILES_HOST DOTFILES_ROOT
  dotfiles_source_shell_dir "$ROOT_DIR/shell/distro/$DOTFILES_DISTRO"
  dotfiles_log_info "starting bootstrap"
  dotfiles_run_tree bootstrap
  dotfiles_log_info "bootstrap complete"
}
