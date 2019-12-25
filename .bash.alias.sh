unalias -a

alias sb=". ${HOME}/.bashrc"

alias eb="vim ${HOME}/.bashrc"
alias ev="vim ${HOME}/.vimrc"
alias ei="vim ${HOME}/.bash.init.sh"
alias ea="vim ${HOME}/.bash.alias.sh"
alias ef="vim ${HOME}/.bash.function.sh"

alias dotcd="pushd ${DOTFILE_PATH}"
alias dot="dotcd && git status && popd"

alias ls="ls -lah --color"
