unalias -a

alias sb=". ${HOME}/.bashrc"

alias eb="vim ${HOME}/.bashrc"
alias ev="vim ${HOME}/.vimrc"
alias ea="vim ${HOME}/.bash.alias.sh"
alias ef="vim ${HOME}/.bash.function.sh"

alias dot="cd ${DOTFILE_PATH}"

alias kube="kubectl"
alias pods="kube get pods"
alias skube="kube -n kube-system"
alias spods="skube get pods"
