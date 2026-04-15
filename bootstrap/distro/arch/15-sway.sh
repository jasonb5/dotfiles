#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing sway and runtime tools"
sudo pacman -S --needed --noconfirm sway swaybg swayidle swaylock fuzzel grim slurp wl-clipboard kitty ironbar swaync ttf-iosevka-nerd xorg-xwayland xdg-desktop-portal-wlr upower

dotfiles_log_info "sway installed"
