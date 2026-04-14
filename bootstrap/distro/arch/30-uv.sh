#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

if command -v uv >/dev/null 2>&1; then
  dotfiles_log_info "uv already installed"
  exit 0
fi

dotfiles_log_info "installing uv without shell setup"
curl -fsSL https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh

dotfiles_log_info "uv installed"
