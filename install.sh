#! /bin/bash

install_path="${HOME}/devel"
github_url="https://github.com/jasonb5/dotfiles"

echo -n "Install path? (default ${install_path}): "

read candidate_path

[[ -n "${candidate_path}" ]] && install_path="${candidate_path}"

echo "Installing into \"${install_path}\""

[[ ! -e "${install_path}" ]] && mkdir -p ${install_path}

cd "${install_path}"

echo "Cloning dotfile from ${github_url}"

git clone ${github_url}

cd "dotfiles"

echo "Checking out submodules"

git submodule init

git submodule update

. "${PWD}/.bash.function.sh"

echo "Linking files from \"files.txt\""

link_files "${HOME}" $(cat files.txt)
