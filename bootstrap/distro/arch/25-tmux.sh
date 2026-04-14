#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing tmux"
sudo pacman -S --needed --noconfirm tmux

dotfiles_log_info "tmux installed"
