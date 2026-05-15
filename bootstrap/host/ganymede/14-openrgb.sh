#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing OpenRGB and plugins"
yay -S --needed --noconfirm openrgb openrgb-plugin-effects-git openrgb-plugin-visual-map-git

dotfiles_log_info "OpenRGB installed"
