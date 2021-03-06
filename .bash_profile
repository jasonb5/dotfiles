source "${HOME}/.bashrc"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/boutte3/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/boutte3/conda/etc/profile.d/conda.sh" ]; then
        . "/Users/boutte3/conda/etc/profile.d/conda.sh"
    else
        export PATH="/Users/boutte3/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

