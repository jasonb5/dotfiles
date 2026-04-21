#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing fzf-lua dependencies"
sudo pacman -S --needed --noconfirm fzf fd ripgrep

dotfiles_log_info "fzf-lua dependencies installed"
