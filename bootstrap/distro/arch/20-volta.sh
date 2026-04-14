#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v volta >/dev/null 2>&1; then
  dotfiles_log_info "volta already installed"
  exit 0
fi

dotfiles_log_info "installing volta without shell setup"
curl -fsSL https://get.volta.sh | env VOLTA_HOME="$HOME/.volta" bash -s -- --skip-setup

dotfiles_log_info "volta installed"
