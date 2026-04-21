#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v rustup >/dev/null 2>&1; then
  dotfiles_log_info "rustup already installed"
else
  dotfiles_log_info "installing rustup without shell setup"
  curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
fi

PATH="${HOME}/.cargo/bin:${PATH:-}" rustup component add rust-analyzer rustfmt clippy

dotfiles_log_info "rustup, rust-analyzer, rustfmt, and clippy installed"
