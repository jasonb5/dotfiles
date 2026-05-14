#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing common Arch packages"
common_packages=(
  neovim
  tree
  less
  screen
  tmux
  fzf
  fd
  ripgrep
  yazi
)

sudo pacman -S --needed --noconfirm "${common_packages[@]}"

dotfiles_log_info "common Arch packages installed"
