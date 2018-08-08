#! /bin/bash

error_log=$HOME/dotfile-err.log
install_path=$HOME/devel
dotfile_path=$install_path/dotfiles

echo -n "Where would you like to install? (default: $install_path) "

read candidate_path

[[ ! -z "$candidate_path" ]] && install_path=$candidate_path

echo "Installing in $install_path"

pushd $install_path

git clone https://github.com/jasonb5/dotfiles 2> $error_log

popd

pushd $dotfile_path

popd
