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
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

#==============================
# library functions
#==============================

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
source "${DOTFILE_PATH}/library/alias.sh"
source "${DOTFILE_PATH}/library/exports.sh"
source "${DOTFILE_PATH}/library/bashrc.sh"
source "${DOTFILE_PATH}/library/functions.sh"

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
