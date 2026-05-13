#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v bw >/dev/null 2>&1; then
  dotfiles_log_info "bitwarden cli already installed"
  exit 0
fi

if ! pacman -Si bitwarden-cli >/dev/null 2>&1; then
  die "bitwarden-cli is not available in configured pacman repos; refusing insecure install path"
fi

dotfiles_log_info "installing bitwarden cli from signed pacman repositories"
sudo pacman -S --needed --noconfirm bitwarden-cli

dotfiles_log_info "bitwarden cli installed"
