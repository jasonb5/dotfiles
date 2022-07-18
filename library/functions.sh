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

#==============================
# user functions
#==============================

function dotfiles::install_nodesource() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | _sudo bash -
    _sudo apt-get install -y nodejs
}

function dotfiles::install_mambaforge() {
    curl -fsSL -o "${PWD}/conda.sh" https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
    chmod +x conda.sh
    ./conda.sh -b -u -p "${HOME}/conda"
    . "${HOME}/conda/etc/profile.d/conda.sh"
    conda init bash
    rm conda.sh
}

function tat {
    name="$(basename `pwd` | sed -e 's/\.//g')"

    if tmux ls 2>&1 | grep "${name}"; then
        tmux attach -t "${name}"
    elif [ -f .envrc ]; then
        direnv exec / tmux new-session -s "${name}"
    else
        tmux new-session -s "${name}"
    fi
}

#==============================
# library functions
#==============================

function _sudo() {
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
