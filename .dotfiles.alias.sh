unalias -a

alias sb="source ~/.bashrc"
alias ea="vim ~/.dotfiles.alias.sh"
alias eb="vim ~/.dotfiles.bashrc.sh"
alias ef="vim ~/.dotfiles.functions.sh"
alias et="vim ~/.tmux.conf"
alias ev="vim ~/.vimrc"

if [[ "$(uname)" == "Darwin" ]]; then
    alias ls="ls -la -G"
else
    alias ls="ls -la --color"
fi

alias dotfile="pushd ${DOTFILE_PATH}"

alias k="kubectl"

alias template_helm="cookiecutter ${DOTFILE_PATH}/templates/helm"
