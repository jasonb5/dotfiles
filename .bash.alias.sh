unalias -a

alias sb=". ${HOME}/.bashrc"

alias eb="vim ${HOME}/.bashrc"
alias ev="vim ${HOME}/.vimrc"
alias ei="vim ${HOME}/.bash.init.sh"
alias ea="vim ${HOME}/.bash.alias.sh"
alias ef="vim ${HOME}/.bash.function.sh"

alias dotcd="cd ${DOTFILE_PATH}"
alias dotadd="dotcd && git add ."
alias dotstatus="dotcd && git status"
alias dotcommit="dotcd && git commit"
alias dotpush="dotcd && git push"
