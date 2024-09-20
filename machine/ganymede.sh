source "${DOTFILE_PATH}/machine/common.sh"
source "${DOTFILE_PATH}/library/docker.sh"

alias jupyter="dotfiles::docker::run jupyter -d -p 8888:8888 --gpus=all --runtime=nvidia -v ~/:/home/jovyan/host quay.io/jupyter/minimal-notebook:lab-4.2.1"
alias localai="dotfiles::docker::run localai -d -p 8080:8080 --gpus=all --runtime=nvidia -v ~/models/localai:/build/models localai/localai:latest-aio-gpu-nvidia-cuda-12"
alias cime="dotfiles::docker::run cime -it --rm -v ~/devel:/src -e CIME_MACHINE=docker -e SRC_PATH=/src/E3SM/cime -w /src/E3SM/cime --entrypoint /bin/bash ghcr.io/esmci/cime:latest"
