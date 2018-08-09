#! /bin/bash

install_path="$HOME/devel"
dotfile_path="$install_path/dotfiles"

echo -n "Where would you like to install? (default: ${install_path}) "

read candidate_path

[[ -n "${candidate_path}" ]] && install_path="${candidate_path}"

echo "Installing in ${install_path}"

pushd "${install_path}"

git clone https://github.com/jasonb5/dotfiles

popd

pushd "${dotfile_path}"

git submodule init

git submodule update

. .bash.function.sh

link_files "$HOME" $(cat files.txt)

popd
