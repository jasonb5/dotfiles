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
else
  echo "Cloning dotfile from ${github_url} to ${dotfile_path}"

  git clone ${github_url}

  cd "${dotfile_path}"
fi

. "${PWD}/.bash.function.sh"

[[ ! -e ".dotfile_path" ]] && echo "${dotfile_path}" > .dotfile_path

install_dotfiles

[[ $(is_installed apt-get) -eq 1 ]] && apt-get update && apt-get install -y vim

if [[ ! -e "${HOME}/.cache/dein" ]]
then
  curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh

  bash installer.sh ${HOME}/.cache/dein

  rm installer.sh
fi
