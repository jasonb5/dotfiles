declare -a FILES

FILES=(
.tmux.conf
.vimrc
.gitconfig
.bash_profile
.dotfiles.bashrc
.dotfiles.functions.sh
.dotfiles.alias.sh
)

function dotfiles_install {
	git submodule init
	git submodule update

	for x in ${FILES[*]}
	do
		ln -sf "${PWD}/${x}" "${HOME}/${x}"

		echo "Linking ${PWD}/${x} -> ${HOME}/${x}"
	done

	[[ ! -f "${HOME}/.vim/autoload/plug.vim" ]] && \
		mkdir -p ${HOME}/.vim/autoload && \
		ln -sf "${PWD}/vim-plug/plug.vim" "${HOME}/.vim/autoload/plug.vim"

	vim -E -s -u "${HOME}/.vimrc" +PlugInstall +qall

	if [[ -e "${HOME}/.bashrc" ]]
	then
		[[ -z "$(cat ${HOME}/.bashrc | grep -e 'source ${HOME}/.dotfiles.bashrc')" ]] && \
			echo 'source ${HOME}/.dotfiles.bashrc' >> ${HOME}/.bashrc
	else
		echo 'source ${HOME}/.dotfiles.bashrc' >> ${HOME}/.bashrc
	fi

	source .dotfiles.bashrc

	conda init bash
}

function dotfiles_uninstall {
	for x in ${FILES[*]}
	do
		rm "${HOME}/${x}"
	done

	rm "${HOME}/.vim/autoload/plug.vim"

	sed -i' ' '/^source ${HOME}\/\.dotfiles\.bashrc$/d' ${HOME}/.bashrc
}

function test_colours {
	T='gYw'   # The test text

	echo -e "\n                 40m     41m     42m     43m\
		44m     45m     46m     47m";

	for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
		'1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
		'  36m' '1;36m' '  37m' '1;37m';
do FG=${FGs// /}
	echo -en " $FGs \033[$FG  $T  "
	for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
	do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
	done
	echo;
done
echo
}
