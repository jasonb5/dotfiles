function keycloak_client_credentials {
	if [ $# -ne 4 ]; then
		echo "Usage: keycloak_jwt HOSTNAME REALM CLIENT_ID CLIENT_SECRET"
		return 1
	fi

	token_url="http://${1}/auth/realms/${2}/protocol/openid-connect/token"

	echo "${token_url}"

	curl -X POST "${token_url}" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d "grant_type=client_credentials" \
		-d "client_id=${3}" \
		-d "client_secret=${4}" \
		-d "audience=minio" | python -m json.tool
}


#===============
# lib functions
#===============

declare -a FILES

FILES=(
.bash_profile
.dotfiles.alias.sh
.dotfiles.bashrc
.dotfiles.bashrc.dynamic
.dotfiles.functions.sh
.gitconfig
.tmux.conf
.vimrc
)

BASHRC_DYNAMIC="${PWD}/.dotfiles.bashrc.dynamic"

BASHRC_START_TAG="# >>> dotfiles start >>>"
BASHRC_END_TAG="# <<< dotfiles end <<<"

function install_dotfiles {
	git submodule init
	git submodule update

	# Remove old dynamic bashrc
	[ -x "${BASHRC_DYNAMIC}" ] && rm "${BASHRC_DYNAMIC}"

	if [ -z "${NOLOAD}" ]; then
		modify_bashrc
	fi

	detect_conda

  load_vim

	for x in "${FILES[@]}"; do
		local src="${PWD}/${x}"
		local dst="${HOME}/${x}"

		if [ "${x}" == ".bash_profile" ] && [ ! -z "${NOLOAD}" ]; then
			continue
		fi

		ln -sf "${src}" "${dst}"
	done
}

function uninstall_dotfiles {
	for x in "${FILES[@]}"; do
		local src="${HOME}/${x}"

		rm "${src}"
	done
}

function load_vim {
  local vim_autoload="${HOME}/.vim/autoload"

  if [ ! -e "${vim_autoload}" ]; then
    mkdir -p "${vim_autoload}"
  fi

  if [ ! -e "${vim_autoload}/plug.vim" ]; then
    ln -sf "${PWD}/vim-plug/plug.vim" "${vim_autoload}/plug.vim"
  fi
}

function file_contains_text {
	grep -E "${1}" "${2}"
}

function modify_bashrc {
	local bashrc="${HOME}/.bashrc"
	local cmd_source="source "${HOME}/.dotfiles.bashrc""

	if [ -z "$(file_contains_text "${cmd_source}" "${bashrc}")" ]; then
		echo "${cmd_source}" >> "${bashrc}"
	fi
}

function any_exist {
	for x in "${@}"; do
		if [ -x "${x}" ]; then
			echo "${x}"

			break
		fi
	done
}

function detect_conda {
	local conda_path="$(any_exist "/opt/conda/bin" "${HOME}/conda/bin")"

	if [ ! -z "${conda_path}" ]; then
		if [ -z "$(echo ${PATH} | grep "${conda_path}")" ]; then
			export PATH="${conda_path}:${PATH}"
		fi

		conda init bash

		echo "CONDA_PATH=\"${conda_path}\"" >> "${BASHRC_DYNAMIC}"
	fi
}
