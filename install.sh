#! /bin/bash

INSTALL_PATH="${HOME}/devel"
GITHUB_URL="https://github.com/jasonb5/dotfiles"

read -p "Install path (default: ${INSTALL_PATH}): " candidate_path

[[ -n "${candidate_path}" ]] && INSTALL_PATH="${candidate_path}"

echo "Installing into \"${INSTALL_PATH}\""

[[ ! -e "${INSTALL_PATH}" ]] && mkdir -p ${INSTALL_PATH}

cd "${INSTALL_PATH}"

DOTFILE_PATH="${INSTALL_PATH}/dotfiles"

if [[ -e "${DOTFILE_PATH}" ]]
then
  cd "${DOTFILE_PATH}"

  git pull
else
  echo "Cloning ${GITHUB_URL} to ${DOTFILE_PATH}"

  git clone ${GITHUB_URL}

  cd "${DOTFILE_PATH}"
fi

. "${PWD}/.bash.function.sh"

[[ ! -e "${PWD}/.dotfile_path" ]] && echo "${DOTFILE_PATH}" > "${PWD}/.dotfile_path"

install_dotfiles

if [[ $(is_installed apt-get) -eq 1 ]]
then
  SUDO=""

  if [[ $(is_installed sudo) -eq 1 ]] && [[ $(id -u -n) != "root" ]]
  then
    SUDO="sudo"
  fi

  ${SUDO} apt-get update

  ${SUDO} apt-get install -y vim
fi

if [[ ! -e "${HOME}/.cache/dein" ]]
then
  curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh

  bash installer.sh ${HOME}/.cache/dein

  rm installer.sh
fi
