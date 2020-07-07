source "${HOME}/.env"

export DOTFILE_PATH="${DOTFILE_PATH}"

if [[ $(contains "${PATH}" "${CONDA_PATH}") -eq 0 ]]
then
  export PATH="${CONDA_PATH}:${PATH}"
fi

export TERM="xterm-256color"

RESET="\[\033[0m\]"
RED="\[\033[31m\]"
GREEN="\[\033[32m\]"
BLUE="\[\033[34m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"
WHITE="\[\033[37m\]"

. ~/.bash.alias.sh

. ~/.bash.function.sh

PS1="$RESET$CYAN$(whoami)$RESET$WHITE@$RESET$PURPLE\h$RESET$GREEN\$(GIT_BRANCH)\n$RESET$BLUE[\w]$RESET: "
