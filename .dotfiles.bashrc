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

[[ -z "$(echo ${PATH} | grep ${HOME}/conda/bin)" ]] && \
  export PATH=${HOME}/conda/bin:${PATH}

source .dotfiles.functions.sh

source .dotfiles.alias.sh
