CLEAR="\[\033[0m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"

export PROMPT_COMMAND=__prompt

function __prompt {
  EXIT="$?"

  if [[ -n "${PRIVATE_SHELL}" ]]; then
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}user@$(hostname): $(pwd)${CLEAR}"
  else
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}$(whoami)@$(hostname): $(pwd)${CLEAR}"
  fi

  L2="${CYAN}${EXIT} $> ${CLEAR}"

  PS1="${L1}\n${L2}"
}

if [[ "$(uname)" == "Darwin" ]]; then
  export TERM="screen-256color"
else
  export TERM="tmux-256color"
fi
