#!/bin/bash

[[ -n "${DEBUG}" ]] && set -x

dotfile_path="${DOTFILE_PATH:-${HOME}/devel/dotfiles}"

if [[ ! -e "${dotfile_path}" ]]; then
	git clone https://github.com/jasonb5/dotfiles ${dotfile_path}

	pushd "${dotfile_path}"

	git submodule update --init

	popd
fi

source "${dotfile_path}/library/functions.sh"

dotfiles::install "${dotfile_path}"
