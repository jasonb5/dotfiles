#!/usr/bin/env bash

dotfiles_rc_start_marker() {
  printf '%s\n' '# >>> dotfiles shell >>>'
}

dotfiles_rc_end_marker() {
  printf '%s\n' '# <<< dotfiles shell <<<'
}

dotfiles_rc_block() {
  local repo_root="$1"
  cat <<EOF
# >>> dotfiles shell >>>
DOTFILES_ROOT="${repo_root}"
export DOTFILES_ROOT
. "${repo_root}/lib/detect.sh"
load_detected_scope
source_shell_dir() {
  local dir="\$1"
  local file
  [[ -d "\$dir" ]] || return 0
  shopt -s nullglob
  for file in "\$dir"/*.sh; do
    [[ -f "\$file" ]] || continue
    . "\$file"
  done
}
source_shell_dir "\${DOTFILES_ROOT}/shell/common"
source_shell_dir "\${DOTFILES_ROOT}/shell/os/\${DOTFILES_OS}"
source_shell_dir "\${DOTFILES_ROOT}/shell/distro/\${DOTFILES_DISTRO}"
source_shell_dir "\${DOTFILES_ROOT}/shell/host/\${DOTFILES_HOST}"
# <<< dotfiles shell <<<
EOF
}

dotfiles_rc_remove_block() {
  local rcfile="$1"
  local tmp inside line

  [[ -f "$rcfile" || -L "$rcfile" ]] || return 0
  tmp="$(mktemp)"
  inside=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == '# >>> dotfiles shell >>>' ]]; then
      inside=1
      continue
    fi
    if [[ "$line" == '# <<< dotfiles shell <<<' ]]; then
      inside=0
      continue
    fi
    [[ "$inside" -eq 1 ]] && continue
    printf '%s\n' "$line" >>"$tmp"
  done <"$rcfile"

  mv -- "$tmp" "$rcfile"
}

inject_shell_rc() {
  local rcfile="${1:-$HOME/.bashrc}"
  local repo_root

  repo_root="$(dotfiles_repo_root)"
  [[ -n "$repo_root" ]] || die 'cannot determine repository root'
  dotfiles_log_info "injecting shell rc into ${rcfile}"

  if [[ ! -e "$rcfile" ]]; then
    : >"$rcfile"
  fi

  if ! grep -Fxq -- '# >>> dotfiles shell >>>' "$rcfile"; then
    dotfiles_rc_block "$repo_root" >>"$rcfile"
  fi

  manifest_add_record rc "$rcfile" dotfiles-shell
}
