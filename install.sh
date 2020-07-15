#! /bin/bash

INSTALL_PATH="${HOME}/devel"
DOTFILE_PATH="${INSTALL_PATH}/dotfiles"
GITHUB_URL="https://github.com/jasonb5/dotfiles"

while [[ "$#" -gt 0 ]]
do
  flag="${1}"
  shift

  case "${flag}" in
    --debug)
      set -x
      ;;
  esac
done

if [[ -e "${DOTFILE_PATH}" ]]
then
  cd "${DOTFILE_PATH}"

  git pull
else
  echo "Cloning ${GITHUB_URL} to ${DOTFILE_PATH}"

  git clone ${GITHUB_URL} "${DOTFILE_PATH}"

  cd "${DOTFILE_PATH}"
fi

. "${PWD}/.bash.function.sh"

init_system
