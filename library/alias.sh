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

alias dev="dotfiles::development_environment"

alias build="dotfiles::build_container"
alias container="dotfiles::run_container"
alias cime="dotfiles::run_container --image jasonb87/cime:latest --mount ${HOME}/devel:/root/devel --args bash"
alias jupyterlab="dotfiles::container --image jupyter/minimal-notebook:latest --mount ${HOME}/devel:/home/jovyan/devel --port 8888"

alias install-nodesource-current="dotfiles::install_nodesource_current"

alias tmux="dotfiles::tmux_local"
alias tmux-remote="dotfiles::tmux_remote"

alias new-mac="dotfiles::generate_macaddr"

alias new-ssh-key="dotfiles::generate_new_ssh_key"
