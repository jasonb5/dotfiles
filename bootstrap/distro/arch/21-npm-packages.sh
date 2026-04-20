#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v opencode >/dev/null 2>&1; then
  dotfiles_log_info "opencode already installed"
  exit 0
fi

dotfiles_log_info "installing opencode prerequisites"
PATH="${HOME}/.volta/bin:$PATH" npm install -g opencode-ai@1.14.18

dotfiles_log_info "opencode installed"
