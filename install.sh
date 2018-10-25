#! /bin/bash

install_path="${HOME}/devel"
github_url="https://github.com/jasonb5/dotfiles"

echo -n "Install path? (default ${install_path}): "

read candidate_path

[[ -n "${candidate_path}" ]] && install_path="${candidate_path}"

echo "Installing into \"${install_path}\""

[[ ! -e "${install_path}" ]] && mkdir -p ${install_path}

cd "${install_path}"

dotfile_path="${install_path}/dotfiles"

echo "Cloning dotfile from ${github_url}"

git clone ${github_url}

cd "${dotfile_path}"

echo "${dotfile_path}" > "${dotfile_path}/.DOTFILE_INSTALL_PATH"

echo "Checking out submodules"

git submodule init

git submodule update

. "${PWD}/.bash.function.sh"

echo "Linking files from \"files.txt\""

link_files "${HOME}" $(cat files.txt)

if [[ $(contains "${PWD}/.bashrc" "DOTFILE_PATH") -eq 1 ]]; then
  echo -e "export DOTFILE_PATH=${PWD}\n\n$(cat ${PWD}/.bashrc)" > "${PWD}/.bashrc"
fi

[[ $(is_installed vim) -ne 0 ]] && apt update && apt install -y vim

[[ $(is_installed vim) -eq 0 ]] && vim Silent +PluginInstall +qall
