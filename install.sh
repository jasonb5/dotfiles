#! /bin/bash

install_path="$HOME/devel"

echo -n "Install path? (default ${install_path}): "

read candidate_path

[[ -n "${candidate_path}" ]] && install_path="${candidate_path}"

echo "Installing into \"${install_path}\""

[[ ! -e "${install_path}" ]] && mkdir -p ${install_path}

cd ${install_path}

git clone https://github.com/jasonb5/dotfiles

cd dotfiles

git submodule init

git submodule update
