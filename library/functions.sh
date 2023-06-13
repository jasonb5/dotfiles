#! /bin/bash

#==============================
# exports
#==============================

export EDITOR=vim

#==============================
# constants
#==============================

declare -a CONFIGS

CONFIGS=( .gitconfig .vim/coc-settings.json .vimrc )
DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

function dotfiles::container_ubuntu() {
        dotfiles::run_container \
                --image ubuntu:latest \
                --flags "--rm -v ${HOME}/conda/pkgs:/opt/conda/pkgs -v ${HOME}/devel:/root/devel -w /root/devel -e CONTAINER=ubuntu:latest" \
                --args "/bin/bash"
}

function dotfiles::container_cime_e3sm() {
        dotfiles::run_container \
                --image jasonb87/cime:latest \
                --flags "--rm -v ${HOME}/conda/pkgs:/opt/conda/pkgs -v ${HOME}/devel/cime-inputdata:/storage/inputdata -v ${HOME}/devel:/root/devel -w /root/devel/E3SM -e CIME_MODEL=e3sm -e INSTALL_PATH=/root/devel/E3SM -e CONTAINER=jasonb87/cime:latest" \
                --args "/bin/bash"
}

function dotfiles::container_jupyterlab() {
        dotfiles::run_container \
                --image jupyter/minimal-notebook:latest \
                --flags "--rm -p 8888:8888 -v ${HOME}/conda/pkgs:/opt/conda/pkgs -v ${HOME}/devel:/home/jovyan/devel -w /home/jovyan/devel -e CONTAINER=jupyter/minimal-notebook:latest"
}

function dotfiles::run_container() {
        dotfiles::debug "${@}"

        flags="-it"

        while [[ "${#}" -gt 0 ]]; do
                dotfiles::debug "${1}"

                case "${1}" in
                        --image) image="${2}"; shift 2;;
                        --flags) flags="${flags} ${2}"; shift 2;;
                        --args) args="${2}"; shift 2;;
                        *);;
                esac
        done

        dotfiles::debug "image = ${image}"
        dotfiles::debug "flags = ${flags}"
        dotfiles::debug "args = ${args}"

        docker run ${flags} ${image} ${args}
}

function dotfiles::dev() {
        if [[ -z "$(which conda)" ]]; then
                dotfiles::install_mambaforge

                source "${HOME}/.bashrc"
        fi

        if [[ -z "$(which vim)" ]]; then
                mamba install -y vim 
        fi

        if [[ -z "$(which git)" ]]; then
                mamba install -y git
        fi

        if [[ -z "$(which node)" ]]; then
                dotfiles::install_nodesource
        fi
}

function dotfiles::install_mambaforge() {
        url="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh"
        output_path="/tmp/$(basename ${url})"

        curl -sfL -o "${output_path}" "${url}"

        chmod +x "${output_path}"

        "${output_path}" -b -p "${HOME}/conda" -u

        source "${HOME}/conda/etc/profile.d/conda.sh"

        conda init bash
}

function dotfiles::install_nodesource() {
        curl -fsSL https://deb.nodesource.com/setup_current.x | dotfiles::sudo bash -

        dotfiles::sudo apt install -y --no-install-recommends nodejs
}

#==============================
# library functions
#==============================

function dotfiles::sudo() {
        if [[ "${USER}" == "root" ]] || [[ "$(id -u)" -eq 0 ]]; then
                "${@}"
        else
                sudo "${@}"
        fi
}

function dotfiles() {
        dotfiles::log "placeholder"
}

function dotfiles::log() {
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

function dotfiles::debug() {
        [[ -n "${DEBUG}" ]] && dotfiles::log "${*}"
}

function dotfiles::error() {
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function dotfiles::install() {
        local repo_path="${1}"

        if [[ -z "$(which curl)" ]]; then
                dotfiles::log "Installing curl package"

                dotfiles::sudo apt update

                dotfiles::sudo apt install -y --no-install-recommends curl ca-certificates
        fi

        dotfiles::log "Installing dotfiles from ${repo_path}"

        for file in "${CONFIGS[@]}"; do
                local user_file="${HOME}/${file}"
                local repo_file="${repo_path}/configs/${file}"

                if [[ -e "${user_file}" ]] && [[ ! -L "${user_file}" ]]; then
                        dotfiles::log "Backing up ${user_file}"

                        mv "${user_file}" "${user_file}.bak"
                fi

                dotfiles::log "Linking ${repo_file} to ${user_file}"

                if [[ ! -e "$(dirname ${user_file})" ]]; then
                        mkdir -p "$(dirname ${user_file})"
                fi

                ln -sf "${repo_file}" "${user_file}"
        done

        if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]] && [[ -z "${SKIP_BASHRC}" ]]; then
                dotfiles::log "Appending .bashrc"

                    cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
export DOTFILE_PATH="\${HOME}/devel/dotfiles"

source "\${DOTFILE_PATH}/library/alias.sh"
source "\${DOTFILE_PATH}/library/bashrc.sh"
source "\${DOTFILE_PATH}/library/functions.sh"

if [[ -e "${HOME}/.dotfiles.user.sh" ]]; then
    source "${HOME}/.dotfiles.user.sh"
fi
${DOTFILE_STOP}
EOF
        fi

        if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
                dotfiles::log "Downloading vim plug"

                curl -Lo "${VIM_PLUG_PATH}" --create-dirs "${VIM_PLUG_URL}"
        fi

        if [[ -n "${CONTAINER}" ]]; then
                dotfiles::dev
        fi
}

function dotfiles::uninstall() {
        dotfiles::log "Uninstalling dotfiles"

        for file in "${CONFIGS[@]}"; do
                local user_file="${HOME}/${file}"

                if [[ -e "${user_file}" ]] && [[ -L "${user_file}" ]]; then
                        dotfiles::log "Unlinking ${user_file}"

                        unlink "${user_file}"
                fi

                if [[ -e "${user_file}.bak" ]]; then
                        dotfiles::log "Restoring backup ${user_file}.bak"

                        mv "${user_file}.bak" "${user_file}"
                fi
        done

        if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
                dotfiles::log "Removing entry from .bashrc"


                if [[ "$(uname)" == "Darwin" ]]; then
                        sed -i "" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
                else
                        sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
                fi
        fi

        if [[ -e "${VIM_PLUG_PATH}" ]]; then
                dotfiles::log "Removing ${VIM_PLUG_PATH}"

                rm -rf "${VIM_PLUG_PATH}"
        fi
}
