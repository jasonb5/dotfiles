#! /bin/bash

#==============================
# exports
#==============================

export EDITOR=vim

#==============================
# constants
#==============================

declare -a CONFIGS

CONFIGS=( .gitconfig .tmux.conf .vim/coc-settings.json .vimrc .tmux/plugins/tpm .config/tmuxinator )
DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

function dotfiles::container_cime_e3sm() {
        dotfiles::run_container \
                --image jasonb87/cime:latest \
                --flags "-v ${HOME}/devel:/root/devel -w /root/devel/E3SM -e CIME_MODEL=e3sm -e INSTALL_PATH=/root/devel/E3SM" \
                --args "/bin/bash"
}

function dotfiles::container_jupyterlab() {
        dotfiles::run_container \
                --image jupyter/minimal-notebook \
                --flags "-p 8888:8888 -v ${HOME}/devel:/home/jovyan/devel -w /home/jovyan/devel"
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

#==============================
# library functions
#==============================

function dotfiles::sudo() {
        if [[ "${USER}" == "root" ]]; then
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
