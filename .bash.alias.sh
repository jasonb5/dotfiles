unalias -a

alias sb=". ${HOME}/.bashrc"

alias eb="vim ${HOME}/.bashrc"
alias ev="vim ${HOME}/.vimrc"
alias ei="vim ${HOME}/.bash.init.sh"
alias ea="vim ${HOME}/.bash.alias.sh"
alias ef="vim ${HOME}/.bash.function.sh"
alias et="vim ${HOME}/.tmux.conf"

alias dot="pushd ${DOTFILE_PATH}"

if [[ "$(uname)" == "Linux" ]]
then
  LS_EXTRA="--color"
else
  LS_EXTRA=""
fi

alias ls="ls -lh ${LS_EXTRA}"
alias lsa="ls -lah ${LS_EXTRA}"

alias d="docker"

alias k="kubectl"
alias kdrain="kubectl drain --ignore-daemonsets --delete-local-data"
alias ks="kubectl -n kube-system"
alias kfdel="kubectl delete --force --grace-period=0"
alias kcont="kubectl config use-context"
alias kdel="kubectl delete"
