unalias -a

alias sb="source ~/.bashrc"
alias eg="vim ${DOTFILE_PATH}/configs/.gitconfig"
alias ea="vim ${DOTFILE_PATH}/library/alias.sh"
alias ef="vim ${DOTFILE_PATH}/library/functions.sh"
alias ev="vim ${DOTFILE_PATH}/configs/.vimrc"
alias et="vim ${DOTFILE_PATH}/configs/.tmux.conf"
alias em="vim ${DOTFILE_PATH}/machine/$(dotfiles::utils::hostname).sh"
alias eu="vim ~/.bashrc.user"

alias miniforge3="dotfiles::user::miniforge3"
alias dev="dotfiles::user::dev"
alias windows11-usb="dotfiles::user::windows11-usb"

alias df-install="dotfiles::bashrc::append && source ${HOME}/.bashrc"
alias df-uninstall="dotfiles::bashrc::remove && dotfiles::uninstall && source ${HOME}/.bashrc"

alias ssh-new="dotfiles::user::ssh::new"
