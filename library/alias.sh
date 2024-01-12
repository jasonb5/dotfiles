unalias -a

alias sb="source ~/.bashrc"
alias et="vim ${DOTFILE_PATH}/configs/.tmux.conf"
alias ev="vim ${DOTFILE_PATH}/configs/.vimrc"
alias eg="vim ${DOTFILE_PATH}/configs/.gitconfig"
alias ec="vim ${DOTFILE_PATH}/configs/.vim/coc-settings.json"

alias ea="vim ${DOTFILE_PATH}/library/alias.sh"
alias eb="vim ${DOTFILE_PATH}/library/bashrc.sh"
alias ee="vim ${DOTFILE_PATH}/library/exports.sh"
alias ef="vim ${DOTFILE_PATH}/library/functions.sh"

# Utility aliases
alias df-install="dotfiles::install"
alias df-uninstall="dotfiles::uninstall"
alias df-persist="dotfiles::bashrc::append"
alias df-list-usb="dotfiles::user::usb::list"
alias df-ssh-password="ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password"
alias df-miniforge="dotfiles::user::miniforge::install"
alias tmux="TERM=xterm-256color tmux -2"

if [[ "$(uname)" != "Darwin" ]]; then
alias df-new-mac=" printf '%02x' $((0x$(od /dev/urandom -N1 -t x1 -An | tr -d ' ') & 0xFE | 0x02)); od /dev/urandom -N5 -t x1 -An | tr ' '  ':'"
fi

# Docker
alias cime="dotfiles::user::docker::run cime false --rm -v ~/Documents/cime-data:/storage/input-data -v ~/devel:/src -w /src/E3SM/cime -e CIME_MODEL=e3sm -e INIT=false --entrypoint /bin/bash ghcr.io/esmci/cime:latest"
alias cime-cesm="dotfiles::user::docker::run cime false --rm -v ~/Documents/cime-data:/storage/input-data -v ~/devel:/src -w /src/CESM/cime -e CIME_MODEL=cesm -e INIT=false --entrypoint /bin/bash ghcr.io/esmci/cime:latest"

alias ollama="dotfiles::user::docker::run ollama true -v ~/Documents/ollama:/root/.ollama -p 11434:11434 ollama/ollama"
alias ollama-gpu="dotfiles::user::docker::run ollama-gpu true --gpus=all -v ~/Documents/ollama:/root/.ollama -p 11434:11434 ollama/ollama"

alias jupyter="dotfiles::user::docker::run jupyter false --rm --gpus=all -v ~/devel:/home/jovyan/devel -p 8888:8888 jupyter/scipy-notebook"

