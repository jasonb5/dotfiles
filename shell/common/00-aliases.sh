unalias -a 2>/dev/null || true

alias cddot='cd "$DOTFILES_ROOT"'
alias webex-kitty='${DOTFILES_ROOT:?}/scripts/distro/arch/labwc-run kitty'
alias webex-firefox='${DOTFILES_ROOT:?}/scripts/distro/arch/labwc-run env MOZ_ENABLE_WAYLAND=1 firefox --no-remote -P webex'

dotfile() {
  "${DOTFILES_ROOT:?}/dotfiles" "$@"
}
