alias eb="vim ~/.bashrc"
alias sb="source ~/.bashrc"

if command_exists tree; then
    alias tree="tree -a -I .git"
fi
