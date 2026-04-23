#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing VM management stack"
sudo pacman -S --needed --noconfirm libvirt qemu-base qemu-system-x86 qemu-img virt-manager virt-install virt-viewer dnsmasq edk2-ovmf swtpm

dotfiles_log_info "enabling libvirt"
sudo systemctl enable --now libvirtd

sudo usermod -aG libvirt,kvm "$USER"
dotfiles_log_info "VM management stack installed; re-login to pick up libvirt and kvm group membership"
