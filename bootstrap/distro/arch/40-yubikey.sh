#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/install.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

dotfiles_log_info "installing gpg and yubi key support packages"
sudo pacman -S --needed --noconfirm gnupg pinentry pcsclite ccid opensc openssh yubikey-manager

install -d -m 700 "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

agent_conf_source="${DOTFILES_ROOT:?}/config/distro/arch/.gnupg/gpg-agent.conf"
agent_conf_target="$HOME/.gnupg/gpg-agent.conf"

if [[ ! -L "$agent_conf_target" || "$(readlink -- "$agent_conf_target")" != "$(dotfiles_realpath_relative "$agent_conf_source" "$HOME/.gnupg")" ]]; then
  dotfiles_backup_existing "$agent_conf_target"
  ln -s -- "$(dotfiles_realpath_relative "$agent_conf_source" "$HOME/.gnupg")" "$agent_conf_target"
fi

# Import your exported public key separately when you have the file handy.
# gpg --import pubkey.asc

dotfiles_log_info "enabling pcscd socket"
sudo systemctl enable --now pcscd.socket

dotfiles_log_info "yubi key support installed"
