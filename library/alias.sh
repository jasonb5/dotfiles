unalias -a

alias sb="source ~/.bashrc"
alias eg="vim ${DOTFILE_PATH}/configs/.gitconfig"

alias ea="vim ${DOTFILE_PATH}/library/alias.sh"
alias ef="vim ${DOTFILE_PATH}/library/functions.sh"

alias ev="vim ${DOTFILE_PATH}/configs/.vimrc"
alias et="vim ${DOTFILE_PATH}/configs/.tmux.conf"

alias dotfile-reload="dotfile-unload && dotfile-load"
alias dotfile-load="dotfiles::bashrc::append && source ${HOME}/.bashrc"
alias dotfile-unload="dotfiles::bashrc::remove && source ${HOME}/.bashrc"
alias dotfile-uninstall="dotfiles::uninstall"
