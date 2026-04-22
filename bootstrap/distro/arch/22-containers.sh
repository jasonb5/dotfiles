#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing kind and Helm"
sudo pacman -S --needed --noconfirm helm
yay -S --needed --noconfirm kind

dotfiles_log_info "kind and Helm installed"
