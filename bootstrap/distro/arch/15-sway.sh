#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing sway and runtime tools"
sudo pacman -S --needed --noconfirm sway swaybg swayidle swaylock fuzzel grim slurp wl-clipboard kitty firefox labwc ironbar swaync obs-studio ttf-iosevka-nerd xorg-xwayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk upower tuned polkit-gnome
sudo systemctl enable --now tuned

dotfiles_log_info "sway installed"
