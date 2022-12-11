#! /bin/bash

#==============================
# constants
#==============================
declare -a CONFIGS

CONFIGS=( .gitconfig .tmux.conf .vim/coc-settings.json .vimrc )
DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

DEFAULT_CURL_FLAGS="-fsSL"

#==============================
# user functions
#==============================

function dotfiles::rand_32() {
    openssl rand -base64 32
}

function dotfiles::development_environment() {
    dotfiles::install_nodesource_current

    vim +PlugInstall +qall
}

function dotfiles::install_nodesource_current() {
    curl "${DEFAULT_CURL_FLAGS}"  https://deb.nodesource.com/setup_current.x | dotfiles::sudo bash -

    dotfiles::sudo apt-get install -y nodejs
}

function dotfiles::install_mambaforge() {
    curl "${DEFAULT_CURL_FLAGS}" -o "${PWD}/conda.sh" https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh

    trap 'rm "${PWD}/conda.sh"' RETURN

    chmod +x conda.sh

    ./conda.sh -b -u -p "${HOME}/conda"

    . "${HOME}/conda/etc/profile.d/conda.sh"

    conda init bash
}

function dotfiles::tmux_local() {
    name="$(basename `pwd` | sed -e 's/\.//g')"

    /usr/bin/tmux new-session -A -s "${name}"
}

function dotfiles::tmux_remote() {
    name="$(echo ${1} | tr '@.' '-')"

    ssh "${1}" -t /usr/bin/tmux new-session -A -s "${name}"
}

function dotfiles::build_container() {
    while [[ -n "${@}" ]]; do
        case "${1}" in
            --image)
                local image="${2}" && shift 2
                ;;
            --target)
                local target="${2}" && shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    [[ -z "${image}" ]] && echo "Missing required --image" && return

    local extra=""

    if [[ -n "${target}" ]]; then
        extra="--target ${target} ${extra}"
    fi

    dotfiles::sudo DOCKER_BUILDKIT=1 docker \
        build \
        ${extra} \
        -t "${image}" \
        .
}

function dotfiles::run_container() {
    while [[ -n "${@}" ]]; do
        case "${1}" in
            --image)
                local image="${2}" && shift 2
                ;;
            --entrypoint)
                local entrypoint="${2}" && shift 2
                ;;
            --args)
                local args="${2}" && shift 2
                ;;
            --extra)
                local extra="${2}" && shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    [[ -z "${image}" ]] && echo "Missing required --image" && return

    local cmd="docker run -it --rm"

    if [[ -n "${entrypoint}" ]]; then
        cmd="${cmd} --entrypoint ${entrypoint}"
    fi

    cmd="${cmd} ${extra} ${image} ${args}"

    dotfiles::sudo /bin/bash -c "${cmd}"
}

function dotfiles::generate_macaddr() {
    printf '%02x' $((0x$(od /dev/urandom -N1 -t x1 -An | tr -d ' ') & 0xFE | 0x02)); od /dev/urandom -N5 -t x1 -An | tr ' '  ':'
}

function dotfiles::generate_new_ssh_key() {
    ssh-keygen -t ed25519 -f "${HOME}/.ssh/id_${1}" -C "${2}"
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
    [[ -n "${DEBUG}" ]] && log "${*}"
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

    # store path to dotfiles repo for use in exports.sh
    if [[ ! -e "${HOME}/.dotfiles" ]]; then
        echo "${repo_path}" >> "${HOME}/.dotfiles"
    fi

    if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
        dotfiles::log "Appending .bashrc"

cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
source "${repo_path}/library/alias.sh"
source "${repo_path}/library/exports.sh"
source "${repo_path}/library/bashrc.sh"
source "${repo_path}/library/functions.sh"

if [[ -e "${HOME}/.dotfiles.user.sh" ]]; then
    source "${HOME}/.dotfiles.user.sh"
fi
${DOTFILE_STOP}
EOF
    fi

    if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
        curl -fLo "${VIM_PLUG_PATH}" --create-dirs \
            "${VIM_PLUG_URL}"
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

    dotfiles::log "Removing ${HOME}/.dotfiles"

    rm "${HOME}/.dotfiles"

    if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
        dotfiles::log "Removing entry from .bashrc"

        sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    fi

    if [[ -e "${VIM_PLUG_PATH}" ]]; then
        rm -rf "${VIM_PLUG_PATH}"
    fi
}
