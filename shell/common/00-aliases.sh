unalias -a 2>/dev/null || true

alias cddot='cd "$DOTFILES_ROOT"'

dotfile() {
  "${DOTFILES_ROOT:?}/dotfiles" "$@"
}
