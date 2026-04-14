#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

tpm_dir="$HOME/.tmux/plugins/tpm"

if [[ -d "$tpm_dir" ]]; then
  dotfiles_log_info "tmux plugin manager already installed"
  exit 0
fi

dotfiles_log_info "installing tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm "$tpm_dir"

dotfiles_log_info "tmux plugin manager installed"
