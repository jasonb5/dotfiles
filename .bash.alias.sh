unalias -a

alias sb=". ${HOME}/.bashrc"

alias eb="vim ${HOME}/.bashrc"
alias ev="vim ${HOME}/.vimrc"
alias ei="vim ${HOME}/.bash.init.sh"
alias ea="vim ${HOME}/.bash.alias.sh"
alias ef="vim ${HOME}/.bash.function.sh"
alias et="vim ${HOME}/.tmux.conf"

alias dot="pushd ${DOTFILE_PATH} && git pull && popd"
alias cdot="pushd ${DOTFILE_PATH}"

alias ls="ls -lh"
alias lsa="ls -lah"

alias d="docker"

alias k="kubectl"
alias kdrain="kubectl drain --ignore-daemonsets --delete-local-data"
alias ks="kubectl -n kube-system"
alias kfdel="kubectl delete --force --grace-period=0"
alias kcont="kubectl config use-context"
alias kdel="kubectl delete"

alias rm_term_pods="k get pods | grep Terminating | grep -v NAME | get_field 1 > /tmp/k8soutput; check /tmp/k8soutput | xargs kubectl delete pods --force --grace-period=0"
alias rm_crash_pods="k get pods | grep Crash | grep -v NAME | get_field 1 > /tmp/k8soutput; check /tmp/k8soutput | xargs kubectl delete pods --force --grace-period=0"
