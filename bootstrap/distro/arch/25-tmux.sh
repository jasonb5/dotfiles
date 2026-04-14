#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v tmux >/dev/null 2>&1; then
  dotfiles_log_info "tmux already installed"
  exit 0
fi

dotfiles_log_info "installing tmux"
sudo pacman -S --needed --noconfirm tmux

dotfiles_log_info "tmux installed"
