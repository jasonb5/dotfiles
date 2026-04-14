#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v yay >/dev/null 2>&1; then
  dotfiles_log_info "yay already installed"
  exit 0
fi

dotfiles_log_info "installing yay prerequisites"
sudo pacman -S --needed --noconfirm git base-devel

tmpdir="$(mktemp -d)"
trap 'rm -rf -- "$tmpdir"' EXIT

dotfiles_log_info "cloning yay build recipe"
git clone --depth 1 https://aur.archlinux.org/yay.git "$tmpdir/yay"

dotfiles_log_info "building yay"
cd "$tmpdir/yay"
makepkg -si --noconfirm --needed

dotfiles_log_info "yay installed"
