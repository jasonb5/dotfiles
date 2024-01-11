unalias -a

alias sb="source ~/.bashrc"
alias et="vim ${DOTFILE_PATH}/configs/.tmux.conf"
alias ev="vim ${DOTFILE_PATH}/configs/.vimrc"
alias eg="vim ${DOTFILE_PATH}/configs/.gitconfig"
alias ec="vim ${DOTFILE_PATH}/configs/.vim/coc-settings.json"

alias ea="vim ${DOTFILE_PATH}/library/alias.sh"
alias eb="vim ${DOTFILE_PATH}/library/bashrc.sh"
alias ee="vim ${DOTFILE_PATH}/library/exports.sh"
alias ef="vim ${DOTFILE_PATH}/library/functions.sh"

alias df-install="dotfiles::install"
alias df-uninstall="dotfiles::uninstall"
alias df-persist="dotfiles::bashrc::append"

alias df-list-usb="dotfiles::user::usb::list"

alias df-ssh-password="ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password"

alias df-miniforge="dotfiles::user::miniforge::install"

alias tmux="TERM=xterm-256color tmux -2"

if [[ "$(uname)" != "Darwin" ]]; then
alias df-new-mac=" printf '%02x' $((0x$(od /dev/urandom -N1 -t x1 -An | tr -d ' ') & 0xFE | 0x02)); od /dev/urandom -N5 -t x1 -An | tr ' '  ':'"
fi

