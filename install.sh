#!/bin/bash

[[ -n "${DEBUG}" ]] && set -x

export DOTFILE_PATH="${HOME}/devel/personal/dotfiles"

if [[ ! -e "${DOTFILE_PATH}" ]]; then
	git clone https://github.com/jasonb5/dotfiles ${DOTFILE_PATH}

	pushd "${DOTFILE_PATH}"

	git submodule update --init

	popd
fi

source "${DOTFILE_PATH}/library/functions.sh"

dotfiles::install
