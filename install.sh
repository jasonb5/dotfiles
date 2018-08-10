#! /bin/bash

install_path="$HOME/devel"

echo -n "Install path? (default ${install_path}): "

read candidate_path

[[ -n "${candidate_path}" ]] && install_path="${candidate_path}"

echo "Installing into \"${install_path}\""
