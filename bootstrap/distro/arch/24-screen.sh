#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing screen"
sudo pacman -S --needed --noconfirm screen

dotfiles_log_info "screen installed"
