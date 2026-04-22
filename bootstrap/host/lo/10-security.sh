#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing laptop security baseline"
sudo pacman -S --needed --noconfirm ufw audit firejail

dotfiles_log_info "writing sysctl hardening"
sudo tee /etc/sysctl.d/99-dotfiles-laptop.conf >/dev/null <<'EOF'
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.unprivileged_bpf_disabled=1
kernel.yama.ptrace_scope=1
fs.protected_hardlinks=1
fs.protected_symlinks=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.tcp_syncookies=1
EOF
sudo sysctl --system >/dev/null

dotfiles_log_info "enabling firewall"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
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

dotfiles_log_info "enabling audit logging"
sudo systemctl enable --now auditd

dotfiles_log_info "laptop security baseline installed"
