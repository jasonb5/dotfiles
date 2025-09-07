#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

info "Running arch bootstrap"

info "Updating system packages"

sudo pacman -Syu

info "Installing required packages"

sudo pacman -Sy --noconfirm \
  hyprlock \
  hypridle \
  hyprpolkitagent \
  waybar \
  playerctl \
  nerd-fonts \
  ttf-jetbrains-mono \
  wofi \
  rofimoji \
  fastfetch \
  wl-clipboard \
  cliphist

curl -o- https://fnm.vercel.app/install | bash

fnm install 22

info "Node: $(node --version) Npm: $(npm -v)"

npm install -g @google/gemini-cli
