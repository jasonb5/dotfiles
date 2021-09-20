#! /bin/bash

#==============================
# constants
#==============================
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

#==============================
# library functions
#==============================
declare -a FILES

FILES=(
.dotfiles.alias.sh
.dotfiles.bashrc
.dotfiles.functions.sh
.gitconfig
.vimrc
.tmux.conf
)

log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function install_dotfiles {
	for filename in "${FILES[@]}"; do
		local dst_file="${HOME}/${filename}"
		local src_file="${DOTFILE_PATH}/${filename}"

		if [[ -e "${dst_file}" ]] && [[ ! -L "${dst_file}" ]]; then
			log "Backing up ${dst_file}"

			mv "${dst_file}" "${dst_file}.bak"
		fi

		if [[ ! -e "${dst_file}" ]]; then
			log "Linking ${src_file} -> ${dst_file}"

			ln -sf "${src_file}" "${dst_file}"
		fi
	done

	if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
		curl -fLo "${VIM_PLUG_PATH}" --create-dirs \
			"https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
	fi
}

function uninstall_dotfiles {
	for filename in "${FILES[@]}"; do
		local installed_file="${HOME}/${filename}"

		if [[ -e "${installed_file}" ]] && [[ -L "${installed_file}" ]]; then
			log "Unlinking ${installed_file}"

			unlink "${installed_file}"
		fi

		if [[ -e "${installed_file}.bak" ]]; then
			log "Restoring ${installed_file} backup"

			mv "${installed_file}.bak" "${installed_file}"
		fi
	done

	if [[ -e "${VIM_PLUG_PATH}" ]]; then
		rm -rf "${VIM_PLUG_PATH}"
	fi
}
