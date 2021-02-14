#!/bin/bash

declare -a FILES

FILES=(
	.tmux.conf
	.vimrc
	.gitconfig
)

git submodule init

for x in ${FILES[*]}
do
	ln -sf "${PWD}/${x}" "${HOME}/${x}"
done

[ ! -f "${HOME}/.vim/autoload/plug.vim" ] && \
  mkdir -p ${HOME}/.vim/autoload && \
  ln -sf "${PWD}/vim-plug/plug.vim" "${HOME}/.vim/autoload/plug.vim"

vim -E -s -u "${HOME}/.vimrc" +PlugInstall +qall
