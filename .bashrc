. ~/.bash.alias.sh

. ~/.bash.function.sh

export TERM="xterm-256color"

RESET="\[\e[0m\]"
C1="\[\e[91m\]" # LIGHT RED
C2="\[\e[94m\]" # LIGHT BLUE
C3="\[\e[92m\]" # LIGHT GREEN
C4="\[\e[95m\]" # LIGHT MAGENTA
C5="\[\e[97m\]" # WHITE

PS1="${C4}$(uname -s) ($(uname -r)):${RESET} ${C1}[\u]${RESET}${C5}@${RESET}${C3}\h${RESET} ${C5}in${RESET} ${C2}[\w]${RESET}\n${C5}$ ${RESET}"
