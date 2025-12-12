alias eb="vim ~/.bashrc"
alias sb="source ~/.bashrc"

if command_exists tree; then
    alias tree="tree -a -I .git"
fi

alias sd="source $DOTFILE_PATH/main.sh link"
alias rd="source $DOTFILE_PATH/main.sh relink"
