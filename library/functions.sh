#! /bin/bash

#==============================
# Exports
#==============================

export GPG_TTY=$(tty)
export EDITOR=vim

#==============================
# constants
#==============================

DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"

WHITE="\e[0m"
GRAY="\e[37m"
DARK_GRAY="\e[90m"
LIGHT_PURPLE="\e[95m"
PURPLE="\e[35m"
CYAN="\e[36m"
GREEN="\e[32m"
ORANGE=""
RED="\e[31m"
PINK=""
YELLOW="\e[33m"

declare -a CONFIG_FILES

CONFIG_FILES=(
	.condarc
	.yarnrc.yml
	.vimrc
	.vim/coc-settings.json
	.gitconfig
	.gitconfig.personal
	.gitconfig.work
	.gitconfig.nosign
	.tmux.conf
	.tmux/plugins/tpm
	.gnupg/gpg.conf
	.ssh/config
)

#==============================
# Prompt
#==============================

export PROMPT_COMMAND='RET=$?; \
	PS1="${CONDA_PROMPT_MODIFIER:-}${CYAN}\w\n${GREEN}$(__user)${WHITE}@${PURPLE}\H${WHITE} $> "
	'

	function __user() {
		if [[ -n "${PRIVATE}" ]]; then
			echo "user"
		else
			echo "\u"
		fi
	}

#==============================
# user functions
#==============================

function dotfiles::user::miniforge3() {
    local url

    if dotfiles::utils::is-linux; then
        url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    else
        url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
    fi

    local condapath="${INSTALLPATH:-${HOME}/conda}"
    local filepath="${TMPDIR:-/tmp}/miniforge3.sh"

    if [[ ! -e "${condapath}" ]] || [[ "${UPGRADE:-false}" == "true" ]]; then
        [[ ! -e "${filepath}" ]] &&  curl -Lo "${filepath}" "${url}"

        chmod +x "${filepath}"

        "${filepath}" -b -p "${condapath}" -u
    fi

    echo "${condapath}"
}

function dotfiles::user::dev() {
    local conda="$(dotfiles::user::miniforge3)"

    source "${conda}/etc/profile.d/conda.sh"

    conda activate

    conda init bash

    mamba create -n dev -y python=3.10

    conda activate dev

    if dotfiles::utils::is-installed "apt-get"; then
        sudo apt-get install -y --no-install-recommends watchman
    fi
}

function dotfiles::user::ssh::new() {
	ssh-keygen -t ed25519 -C "${1}"
}

function dotfiles::user::windows11-usb() {
    [[ "${#}" -ne "2" ]] && echo "Usage: device image" && return

    local device="${1}"
    local image="${2}"

    sudo wipefs -a "${device}"

    sudo parted "${device}" --script "mklabel gpt mkpart BOOT fat32 0% 1GiB mkpart INSTALL ntfs 1GiB 10GiB"

    sudo mkfs.vfat -n BOOT "${device}1"
    sudo mkfs.ntfs --quick -L INSTALL "${device}2"

    local temp="$(mktemp -d)"
    local iso="${temp}/iso"
    local vfat="${temp}/vfat"
    local ntfs="${temp}/ntfs"

    sudo mkdir "${iso}" "${vfat}" "${ntfs}"

    sudo mount "${image}" "${iso}"
    sudo mount "${device}1" "${vfat}"
    sudo mount "${device}2" "${ntfs}"

    sudo rsync -r --progress --exclude sources --delete-before "${iso}/" "${vfat}"
    sudo cp "${iso}/sources/boot.wim" "${vfat}/sources/"

    sudo rsync -r --progress --delete-before "${iso}/" "${ntfs}/"

    sudo umount "${iso}" "${vfat}" "${ntfs}"

    sudo sync

    sudo rm -rf "${temp}"
}

#==============================
# install/uninstall functions
#==============================

function dotfiles::install() {
	dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

	dotfiles::symlinks::add

	dotfiles::vimplug::install

	dotfiles::bashrc::load

	source "${DOTFILE_PATH}/library/alias.sh"
}

function dotfiles::uninstall() {
	dotfiles::log "Uninstalling dotfiles"

	dotfiles::vimplug::uninstall

	dotfiles::symlinks::remove

	dotfiles::bashrc::remove

	unset DOTFILE_PATH
}

#==============================
# logging functions
#==============================

function dotfiles::log() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

function dotfiles::debug() {
	[[ -n "${DEBUG}" ]] && dotfiles::log "${*}"
}

function dotfiles::error() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#==============================
# vim-plug functions
#==============================

function dotfiles::vimplug::install() {
	dotfiles::log "Installing vimplug to ~/.vim/autoload/plug.vim"

	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function dotfiles::vimplug::uninstall() {
	dotfiles::log "Uninstalling vimplug from ~/.vim/autoload/plug.vim"

	rm -rf ~/.vim/autoload/plug.vim
}

#==============================
# utility functions
#==============================

function dotfiles::utils::is-linux() {
	[[ "$(uname)" == "Linux" ]] && return 0

	return 1
}

function dotfiles::utils::is-darwin() {
	[[ "$(uname)" == "Darwin" ]] && return 0

	return 1
}

function dotfiles::utils::is-installed() {
	if command -v "${1}" >/dev/null 2>&1; then
		return 0
	fi

	return 1
}

function dotfiles::utils::hostname() {
	if [[ -z "${HOSTNAME}" ]]; then
		hostnamectl hostname
	else
		echo "${HOSTNAME}"
	fi
}

#==============================
# symlink functions
#==============================

function dotfiles::symlinks::add() {
	dotfiles::log "Adding dotfiles symlinks to ${HOME} from `pwd`"

	for path in "${CONFIG_FILES[@]}"; do
		local user_file="${HOME}/${path}"
		local repo_file="${DOTFILE_PATH}/configs/${path}"

		dotfiles::log "Linking ${repo_file} -> ${user_file}"

		if [[ -e "${user_file}" ]] && [[ ! -L "${user_file}" ]] && [[ ! -e "${user_file}.bak" ]]; then
			mv "${user_file}" "${user_file}.bak"

			dotfiles::log "Backed up ${user_file} -> ${user_file}.bak"
		fi

		if [[ ! -e "${user_file}" ]]; then
			if [[ ! -e "${user_file%/*}" ]]; then
				mkdir -p "${user_file%/*}"

				dotfiles::log "Creating parent directory ${user_file%/*}"
			fi

			ln -sf "${repo_file}" "${user_file}"

			dotfiles::log "Linked ${repo_file} -> ${user_file}"
		else
			dotfiles::log "Skipping ${repo_file}, link already exists"
		fi
	done
}

function dotfiles::symlinks::remove() {
	dotfiles::log "Removing dotfiles symlinks from ${HOME}"

	for path in "${CONFIG_FILES[@]}"; do
		local user_file="${HOME}/${path}"

		dotfiles::log "Removing ${user_file}"

		if [[ -e "${user_file}" ]] && [[ -L "${user_file}" ]]; then
			unlink "${user_file}"

			dotfiles::log "Unlinked ${user_file}"
		fi

		if [[ -e "${user_file}.bak" ]]; then
			mv "${user_file}.bak" "${user_file}"

			dotfiles::log "Restored ${user_file} from ${user_file}.bak"
		fi
	done
}

#==============================
# bashrc functions
#==============================

function dotfiles::bashrc::append() {
	dotfiles::log "Appending dotfiles bashrc entry"

	if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
		cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
export DOTFILE_PATH="\${HOME}/devel/dotfiles"

source "\${DOTFILE_PATH}/library/functions.sh"
source "\${DOTFILE_PATH}/library/alias.sh"

dotfiles::bashrc::load
${DOTFILE_STOP}
EOF

		dotfiles::log "Appended dotfiles basrc entry"
	fi
}

function dotfiles::bashrc::remove() {
	dotfiles::log "Removing dotfiles bashrc entry"

	if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
		if [[ "$(uname)" == "Darwin" ]]; then
			sed -i "" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
		else
			sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
		fi

		dotfiles::log "Found and removed dotfiles bashrc entry"
	fi
}

function dotfiles::bashrc::load() {
	if [[ -z "${DOTFILE_LOADED}" ]]; then
		export PATH="${HOME}/.bin:${PATH}"

		export DOTFILE_LOADED="true"
	fi

	dotfiles::bashrc::machine::load
}

function dotfiles::bashrc::machine::load() {
	hostname="$(dotfiles::utils::hostname)"

	dotfiles::debug "Searching machine specific bashrc for \"${hostname}\""

	# Load version controlled machine specific
	while IFS='' read -r -d '' filepath; do
		dotfiles::debug "Checking ${filepath}"
		filename="$(basename ${filepath})"

		if [[ -n "$(echo ${filepath} | grep ${hostname})" ]]; then
			dotfiles::debug "Found match ${filepath}"

			source "${filepath}"
		fi
	done < <(find ${DOTFILE_PATH}/machine -maxdepth 1 -type f -print0)

	# Load non-version controllered machine specific
	[[ -e "${HOME}/.bashrc.user" ]] && source "${HOME}/.bashrc.user"
}
