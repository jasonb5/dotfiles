#! /bin/bash


#===============
# lib functions
#===============

declare -a FILES

FILES=(
.dotfiles.alias.sh
.dotfiles.bashrc
.dotfiles.functions.sh
.gitconfig
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
}
