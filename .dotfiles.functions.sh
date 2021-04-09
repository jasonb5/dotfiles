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
