#==============================
# exports
#==============================

export GPG_TTY=$(tty)
export EDITOR=vim

CLEAR="\[\033[0m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"

export PROMPT_COMMAND='EXIT="$?";
  if [[ -n "${PRIVATE}" ]]; then
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}user@$(hostnamectl hostname): $(pwd)${CLEAR}";
  else
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}$(whoami)@$(hostnamectl hostname): $(pwd)${CLEAR}";
  fi

  L2="${CYAN}${EXIT} $> ${CLEAR}";

  PS1="${L1}\n${L2}";'
