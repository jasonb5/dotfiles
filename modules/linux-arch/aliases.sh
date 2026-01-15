alias eb="vim ~/.bashrc"
alias sb="source ~/.bashrc"

if command_exists tree; then
    alias tree="tree -a -I .git"
fi

alias tmuxf="fzf_tmux"

alias ul="source ${DOTFILE_PATH}/main.sh ul"
alias us="source ${DOTFILE_PATH}/main.sh us"

alias lf="fc-list"
