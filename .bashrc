export DOTFILE_PATH="$(cat ${HOME}/.dotfile_path)"
export TERM="xterm-256color"

RESET="\[[0m\]"
C1="\[[91m\]" # LIGHT RED
C2="\[[94m\]" # LIGHT BLUE
C3="\[[92m\]" # LIGHT GREEN
C4="\[[95m\]" # LIGHT MAGENTA
C5="\[[97m\]" # WHITE

. ~/.bash.alias.sh

. ~/.bash.function.sh

PS1="${C4}$(uname -s) ($(uname -r)):${RESET} ${C1}[\u]${RESET}${C5}@${RESET}${C3}\h${RESET} ${C5}in${RESET} ${C2}[\w]${RESET}
${C5}$ ${RESET}"
