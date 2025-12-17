#!/usr/bin/env bash

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null

eval "$(starship init bash)"

if [[ -e "${HOME}/.config/nvm/nvm.sh" ]]; then
    source "${HOME}/.config/nvm/nvm.sh"
fi
