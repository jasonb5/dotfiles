#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing NVIDIA container toolkit"
sudo pacman -S --needed --noconfirm nvidia-container-toolkit

if systemctl is-enabled --quiet docker 2>/dev/null || systemctl is-active --quiet docker 2>/dev/null; then
  dotfiles_log_info "configuring NVIDIA runtime for Docker"
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
fi

dotfiles_log_info "NVIDIA container toolkit installed"
