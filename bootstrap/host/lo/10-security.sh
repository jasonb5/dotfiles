#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing laptop-specific security baseline"
sudo pacman -S --needed --noconfirm ufw firejail

dotfiles_log_info "enabling firewall"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable
sudo systemctl enable --now ufw

disable_unit() {
  local unit="$1"

  sudo systemctl disable --now "$unit" >/dev/null 2>&1 || true
  sudo systemctl mask "$unit" >/dev/null 2>&1 || true
}

dotfiles_log_info "disabling sshd"
disable_unit sshd

dotfiles_log_info "disabling unused network services"
disable_unit avahi-daemon.service
disable_unit avahi-daemon.socket
disable_unit cups.service
disable_unit cups.socket
disable_unit bluetooth.service

dotfiles_log_info "laptop-specific security baseline installed"
