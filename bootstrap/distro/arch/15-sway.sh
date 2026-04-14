#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing sway and runtime tools"
sudo pacman -S --needed --noconfirm sway swaybg fuzzel grim slurp wl-clipboard kitty

dotfiles_log_info "sway installed"
