unalias -a

alias eb="vim ~/.bashrc"
alias sb="source ~/.bashrc"

if command -v tree >/dev/null; then
alias tree="tree -a -I .git"
fi
