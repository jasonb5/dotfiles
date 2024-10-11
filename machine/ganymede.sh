source "${DOTFILE_PATH}/machine/common.sh"
source "${DOTFILE_PATH}/library/container.sh"

function _jupyter() {
	dotfiles::container::run "-p 8888:8888 -v ~/:/home/jovyan/host quay.io/jupyter/datascience-notebook"
}
alias jupyter="_jupyter"

function _localai() {
	dotfiles::container::run-daemon "localai" "-p 8080:8080 ~/models:/build/models --gpus=all localai/localai:latest-aio-gpu-nvidia-cuda-12"
}
alias localai="_localai"

function _cime_e3sm() {
	dotfiles::container::run "-v ~/devel:/src -v ~/devel:/root/devel -e CIME_MODEL=e3sm -e CIME_MACHINE=docker -e SRC_PATH=/src -e SKIP_CIME_UPDATE=true -e SKIP_MODEL_SETUP=true -e DEBUG=true -w /src/work/E3SM/cime ghcr.io/esmci/cime:latest bash"
}
alias cime="_cime_e3sm"

function _cime_cesm() {
	dotfiles::container::run "-v ~/devel:/src -v ~/devel:/root/devel -e CIME_MODEL=cesm -e CIME_MACHINE=docker -e SRC_PATH=/src -e SKIP_CIME_UPDATE=true -e SKIP_MODEL_SETUP=true -e DEBUG=true -w /src/work/CESM/cime ghcr.io/esmci/cime:latest bash"
}
alias cime-cesm="_cime_cesm"
