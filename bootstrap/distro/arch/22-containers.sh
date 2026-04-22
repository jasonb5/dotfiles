#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing Docker, kind, and Helm"
sudo pacman -S --needed --noconfirm docker helm
yay -S --needed --noconfirm kind
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

dotfiles_log_info "Docker installed; re-login to pick up docker group membership"
