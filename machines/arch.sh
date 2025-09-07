#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

info "Running arch bootstrap"

info "Updating system packages"

sudo pacman -Syu

info "Installing required packages"

sudo pacman -Sy \
  hyprlock \
  hypridle \
  hyprpolkitagent \
  waybar \
  playerctl \
  nerd-fonts \
  ttf-jetbrains-mono \
  wofi \
  rofimoji
