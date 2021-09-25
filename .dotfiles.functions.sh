#! /bin/bash

#==============================
# constants
#==============================
DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

function remove_snap {
	snap list | grep -v Name | cut -d" " -f1 | xargs -I% sudo snap remove --purge %
	snap list | grep -v Name | cut -d" " -f1 | xargs -I% sudo snap remove --purge %

	sudo rm -rf /var/cache/snapd
	sudo apt autoremove -y --purge snapd gnome-software-plugin-snap
	rm -rf ~/snap
	sudo apt-mark hold snapd
}

#==============================
# library functions
#==============================
declare -a FILES

FILES=(
.dotfiles.alias.sh
.dotfiles.bashrc.sh
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

	echo "${DOTFILE_PATH}" > "${HOME}/.dotfiles"	

	if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
source "${HOME}/.dotfiles.bashrc.sh"
${DOTFILE_STOP}
EOF
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

	if [[ -e "${HOME}/.dotfiles" ]]; then
		rm -rf "${HOME}/,dotfiles"
	fi

	if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
		sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
	fi
}
