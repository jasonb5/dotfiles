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

if [[ -e "${dotfile_path}" ]]
then
  cd "${dotfile_path}"

  git pull

  git submodule update
else
  echo "Cloning dotfile from ${github_url} to ${dotfile_path}"

  git clone ${github_url}

  cd "${dotfile_path}"

  echo "Checking out submodules"

  cp files.txt files_local.txt

  git submodule init

  git submodule update
fi

. "${PWD}/.bash.function.sh"

[[ ! -e ".dotfile_path" ]] && echo "${dotfile_path}" > .dotfile_path

install_dotfiles

[[ $(is_installed apt-get) -eq 1 ]] && apt-get update && apt-get install -y vim

[[ $(is_installed vim) -eq 1 ]] && vim -E +PluginInstall +qall
