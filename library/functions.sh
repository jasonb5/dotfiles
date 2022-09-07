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
            --target)
                target="${2}" && shift 2
                ;;
            --image)
                image="${2}" && shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    EXTRA=""

    if [[ -z "${target}" ]]; then
        EXTRA="--opt target=${target} ${EXTRA}"
    fi

    dotfiles::sudo ctr \
        run \
        -t --rm \
        --privileged \
        --net-host \
        --mount type=bind,src=${PWD},dst=/host,options=rbind:rw \
        docker.io/moby/buildkit:master \
        buildkit \
        /usr/bin/buildctl-daemonless.sh \
        build \
        --frontend dockerfile.v0 \
        --local context=/host \
        --local dockerfile=/host ${EXTRA} \
        --output type=docker,dest=/host/output.tar,name=docker.io/${image} \
        --export-cache type=local,mode=max,dest=/host/cache \
        --import-cache type=local,src=/host/cache

    dotfiles::sudo ctr \
        images \
        import \
        output.tar
}

function dotfiles::run_container() {
    while [[ -n "${@}" ]]; do
        case "${1}" in
            --image)
                image="${2}" && shift 2
                ;;
            --mount)
                mount="${2}" && shift 2
                ;;
            --port)
                port="${2}" && shift 2
                ;;
            --args)
                args="${2}" && shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    name="$(echo ${image} | sed "s/^.*\///" | tr ":" "-")"

    if [[ -n "$(command -v docker)" ]]; then
        command="docker run -it --rm"

        if [[ -n "${mount}" ]]; then
            command="${command} -v ${mount}"
        fi

        if [[ -n "${port}" ]]; then
            command="${command} -p ${port}"
        fi

        command="${command} ${image} ${args}"
    elif [[ -n "$(command -v ctr; echo $?)" ]]; then
        if [[ -z "$(dotfiles::sudo ctr images ls | grep ${image})" ]]; then
            dotfiles::sudo ctr image pull "docker.io/${image}"
        fi

        if [[ -n "$(dotfiles::sudo ctr c ls | grep ${name})" ]]; then
            dotfiles::sudo ctr c rm "${name}"
        fi

        command="ctr run -t --rm"

        if [[ -n "${mount}" ]]; then
            command="${command} --mount type=bind,$(echo $mount | awk -F: '{print "src="$1",dst="$2}'),options=rbind:rw"
        fi

        command="${command} --net-host docker.io/${image} ${name} ${args}"
    else
        echo "Could not detect `docker` or `ctr` to run container"

        return
    fi

    dotfiles::sudo bash -c "${command}"
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

function dotfiles::err() {
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
