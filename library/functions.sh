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
	.vimrc
	.vim/coc-settings.json
	.gitconfig
	.gitconfig.personal
	.gitconfig.work
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

function dotfiles::user::ssh() {
	local do_tmux=''
	if [ -n "$TMUX" ] && [ "$(tmux list-panes -F 'P')" = 'P' ]; then
		do_tmux='yeah boy'
	fi
	if [ -n "$do_tmux" ]; then
		local prefix="$(tmux display -p '#{prefix}')"
		local status_mode="$(tmux display -p '#{status}')"
		tmux set status off
		tmux set key-table nested
		tmux set prefix None
	fi
	command ssh "$@"
	local ret=$?
	echo
	echo -e "Back on $(dotfiles::utils::hostname) as $(whoami)"
	if [ -n "$do_tmux" ]; then
		tmux set status
		tmux set key-table root
		tmux set prefix "$prefix"
	fi
	echo "$ret"
}

function dotfiles::user::miniforge3() {
	local url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
	local filepath="/tmp/miniforge3.sh"
	curl -Lo "${filepath}" "${url}"
	chmod +x "${filepath}"
	"${filepath}" -b -p "${HOME}/conda" -u
}

function dotfiles::user::env::exists() {
  if [[ -n "${!1}" ]]; then
		>&2 echo "Using ${1} = ${!1}"
		return "1"
	fi

	>&2 echo "Please export ${1}"
	return "0"
}

function dotfiles::user::gpg::quick() {
	dotfiles::user::env::exists GNUPGHOME && return

	[[ "${#}" -eq "0" ]] && echo "${FUNCNAME} name <email> (comment)" && return

	mkdir -p "${GNUPGHOME}"

	find "${GNUPGHOME}" -type f -exec chmod 0600 {} \;
	find "${GNUPGHOME}" -type d -exec chmod 0700 {} \;

	gpg2 --quick-generate-key "${1}" ed25519 cert 5y
}

function dotfiles::user::gpg::list() {
	dotfiles::user::env::exists GNUPGHOME && return

	gpg2 --list-keys --keyid-format short
}

function dotfiles::user::gpg::list-long() {
	dotfiles::user::env::exists GNUPGHOME && return

	gpg2 --list-keys --keyid-format long
}

function dotfiles::user::gpg::quick-add() {
	dotfiles::user::gpg::list

	read -p 'Enter fingerprint: ' fpr

	gpg2 --quick-add-key "${fpr}" "${@}"
}

function dotfiles::user::gpg::gen-revoke() {
	dotfiles::user::env::exists GNUPGHOME && return

	[[ "${#}" -eq "0" ]] && echo "${FUNCNAME} keyid"

	gpg2 --generate-revocation "${1}" > "${GNUPGHOME}/${1}-revocation-certificate"
}

function dotfiles::user::gpg::clean() {
	read -p 'Have you backed up your keys (y/n): ' confirm1

	[[ "${confirm1}" != "y" ]] && return

	read -p 'Are you sure you want to remove your primary key (y/n): ' confirm2

	[[ "${confirm2}" != "y" ]] && return

	dotfiles::user::gpg::list

	read -p 'Enter the primary key id: ' keyid

	gpg --with-keygrip --list-key "${keyid}"

	read -p 'Enter the primary keygrip: ' keygrip

	rm -rf "${GNUPGHOME}/private-keys-v1.d/${keygrip}.key"

	rm -rf "${GNUPGHOME}/secring.gpg"
}

function dotfiles::user::gpg::export() {
	dotfiles::user::gpg::list

	read -p 'Enter keys to export (add exclamation at the end of each key): ' keys

	gpg2 --export-secret-subkeys --armor ${keys} | gpg2 --armor --symmetric --output "${1}"
}

function dotfiles::user::gpg::import() {
	dotfiles::user::gpg::list

	gpg2 --decrypt "${1}" | gpg2 --import
}

function dotfiles::user::ssh::new() {
	ssh-keygen -t ed25519 -C "${1}"
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
