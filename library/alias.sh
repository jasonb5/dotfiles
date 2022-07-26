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

alias ls="ls --color"
alias ll="ls -la"

alias tmux="dotfiles::tmux-local"

alias container="dotfiles::container"
alias cime_container="dotfiles::container jasonb87/cime:latest bash"

alias generate_macaddr="dotfiles::generate_macaddr"
