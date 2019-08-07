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

install_system_application

install_vim_plug
