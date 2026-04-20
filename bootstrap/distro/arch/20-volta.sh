#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v volta >/dev/null 2>&1; then
  dotfiles_log_info "volta already installed"
else
  dotfiles_log_info "installing volta without shell setup"
  curl -fsSL https://get.volta.sh | env VOLTA_HOME="$HOME/.volta" bash -s -- --skip-setup
fi

PATH="${HOME}/.volta/bin:${PATH:-}" volta install node@24.15.0

dotfiles_log_info "volta installed"
