#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing security and runtime baseline"
sudo pacman -S --needed --noconfirm audit docker docker-compose podman podman-compose wireguard-tools openresolv

dotfiles_log_info "writing sysctl hardening"
sudo tee /etc/sysctl.d/99-dotfiles-arch.conf >/dev/null <<'EOF'
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.unprivileged_bpf_disabled=1
kernel.yama.ptrace_scope=1
fs.protected_hardlinks=1
fs.protected_symlinks=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.tcp_syncookies=1
EOF
sudo sysctl --system >/dev/null

dotfiles_log_info "enabling Docker service"
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"
dotfiles_log_info "Docker, Docker Compose, Podman, and Podman Compose installed; re-login to pick up docker group membership"

dotfiles_log_info "enabling audit logging"
sudo systemctl enable --now auditd

dotfiles_log_info "security and runtime baseline installed (including WireGuard tooling and resolveconf)"
