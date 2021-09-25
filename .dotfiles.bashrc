CLEAR="\[\033[0m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"

export PROMPT_COMMAND=__prompt

function __prompt {
  EXIT="$?"

  L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}$(whoami)@$(hostname): $(pwd)${CLEAR}"
  L2="${CYAN}${EXIT} $> ${CLEAR}"

  PS1="${L1}\n${L2}"
}

export DOTFILE_PATH="$(cat ${HOME}/.dotfiles)"

source "${HOME}/.dotfiles.alias.sh"

BASHRC_USER="${HOME}/.dotfiles.bashrc.user"

# Load user bashrc
if [ -e "${BASHRC_USER}" ]; then
  source "${BASHRC_USER}"
fi

source "${HOME}/.dotfiles.functions.sh"
