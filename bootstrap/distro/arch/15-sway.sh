#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing sway and runtime tools"
sudo pacman -S --needed --noconfirm \
  sway swaybg swww swayidle swaylock fuzzel grim slurp wl-clipboard \
  kitty chromium firefox labwc ironbar swaync ttf-iosevka-nerd xorg-xwayland \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  upower tuned polkit-gnome
sudo systemctl enable --now tuned

dotfiles_log_info "sway installed"
