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
alias cime-container="dotfiles::container jasonb87/cime:latest bash"

alias gen-macaddr="dotfiles::generate_macaddr"

alias ssh-nopass="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"
alias ssh-copy-id-nopass="ssh-copy-id -o PreferredAuthentications=password -o PubkeyAuthentication=no"

alias new-sshkey="dotfiles::generate_new_ssh_key"

alias dev="dotfiles::development_environment"
