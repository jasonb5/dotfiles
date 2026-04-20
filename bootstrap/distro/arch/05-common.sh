#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing common Arch packages"
sudo pacman -S --needed --noconfirm neovim tree less

dotfiles_log_info "common Arch packages installed"
