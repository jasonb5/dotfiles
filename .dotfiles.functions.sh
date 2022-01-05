#! /bin/bash

#==============================
# exports
#==============================

# prefer buildkit backend
export DOCKER_BUILDKIT=1

#==============================
# constants
#==============================
DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

function dotfile_install_nodesource {
	curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
}

function dotfile_install_mambaforge {
	local script_path="${HOME}/conda.sh"
	if [[ ! -e "${script_path}" ]]; then
		curl -L -o "${script_path}" https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
	fi
	bash "${script_path}" -b -p "${HOME}/conda"
	rm "${script_path}"
	source "${HOME}/conda/etc/profile.d/conda.sh"
	conda init bash
}

function dotfile_remove_snap {
	snap list | grep -v Name | cut -d" " -f1 | xargs -I% sudo snap remove --purge %
	snap list | grep -v Name | cut -d" " -f1 | xargs -I% sudo snap remove --purge %

	sudo rm -rf /var/cache/snapd
	sudo apt autoremove -y --purge snapd gnome-software-plugin-snap
	rm -rf ~/snap
	sudo apt-mark hold snapd
}

function dotfile_generate_certificates {
	if [[ "${#}" -lt 1 ]]; then
		echo "missing name"
		return
	fi

	[[ ! -e "${PWD}/ca.key" ]] && openssl genrsa -des3 -out ca.key 4096
	[[ ! -e "${PWD}/ca.crt" ]] && openssl req -x509 -new -nodes -key "${PWD}/ca.key" -sha256 -days 1024 -out "${PWD}/ca.crt"

cat << EOF > "${PWD}/${1}.conf"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = VA
L = City
O = YourOrganization
OU = YourOrganizationUnit
CN = www.example.com
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.example.com
DNS.2 = example.com
DNS.3 = sub.example.com
DNS.4 = sub2.example.net
EOF

	vim "${PWD}/${1}.conf"

	openssl req -new -newkey rsa:2048 -nodes -sha256 -keyout "${PWD}/${1}.key" -config "${PWD}/${1}.conf" -out "${PWD}/${1}.csr"
	openssl x509 -req -in "${PWD}/${1}.csr" -CA "${PWD}/ca.crt" -CAkey "${PWD}/ca.key" -CAcreateserial -out "${PWD}/${1}.crt" -days 365 -sha256
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
.vim/coc-settings.json
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

			if [[ ! -e "`dirname ${dst_file}`" ]]; then
				mkdir -p "`dirname ${dst_file}`"
			fi

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
