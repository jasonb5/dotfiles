#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v rustup >/dev/null 2>&1; then
  dotfiles_log_info "rustup already installed"
  exit 0
fi

dotfiles_log_info "installing rustup without shell setup"
curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal

dotfiles_log_info "rustup installed"
