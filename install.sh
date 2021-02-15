#!/bin/bash

DOTFILES="${HOME}/devel/dotfiles"

if [ ! -e "${DOTFILES}" ]
then
	git clone https://github.com/jasonb5/dotfiles "${DOTFILES}"
fi

cd "${DOTFILES}"

source .bashrc.dotfiles

install_dotfiles
