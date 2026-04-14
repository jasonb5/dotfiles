#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing rose pine GTK theme"
yay -S --needed --noconfirm rose-pine-gtk-theme-full

dotfiles_log_info "rose pine GTK theme installed"
