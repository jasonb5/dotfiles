set -x

DOTFILE_PATH="${HOME}/devel/dotfiles"

if [ ! -e "${DOTFILE_PATH}" ]
then
	git clone https://github.com/jasonb5/dotfiles ${DOTFILE_PATH}
fi

cd "${DOTFILE_PATH}"

source "${PWD}/.dotfiles.functions.sh"

install_dotfiles
