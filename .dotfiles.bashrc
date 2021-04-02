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

source "${HOME}/.dotfiles.bashrc.dynamic"

if [ -z "$(echo "${PATH}" | grep "${CONDA_PATH}")" ]; then
  export PATH="${CONDA_PATH}:${PATH}"
fi

BASHRC_USER="${HOME}/.dotfiles.bashrc.user"

# Load user bashrc
[ -x "${BASHRC_USER}" ] && source "${BASHRC_USER}"

source "${HOME}/.dotfiles.functions.sh"

source "${HOME}/.dotfiles.alias.sh"
