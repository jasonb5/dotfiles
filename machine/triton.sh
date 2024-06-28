source "${DOTFILE_PATH}/library/docker.sh"

alias cime="dotfiles::docker::run cime -it --rm -v ~/devel:/src -e CIME_MACHINE=docker -e SRC_PATH=/src/E3SM/cime -w /src/E3SM/cime --entrypoint /bin/bash ghcr.io/esmci/cime:latest"
