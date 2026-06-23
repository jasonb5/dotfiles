#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing Proton Mail Bridge"
yay -S --needed --noconfirm protonmail-bridge

dotfiles_log_info "Proton Mail Bridge installed"
