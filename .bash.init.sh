export DOTFILE_PATH=`cat ${HOME}/.dotfile_path`

export TERM="xterm-256color"

CONDA_PATH=("/opt/conda" "${HOME}/conda" "${HOME}/miniconda2")

for x in ${CONDA_PATH[@]}; do
  [[ -e "${x}/bin" ]] && prepend_path "${x}/bin"
done

. /etc/os-release

RESET="\e[0m"
C1="\e[91m" # LIGHT RED
C2="\e[94m" # LIGHT BLUE
C3="\e[92m" # LIGHT GREEN
C4="\e[95m" # LIGHT MAGENTA
C5="\e[97m" # WHITE

PS1="${C4}${NAME} (${VERSION_ID}):${RESET} ${C1}\u${RESSET}${C5}@${RESET}${C3}\h${RESET} ${C5}in${RESET} ${C2}\w${RESET}\n${C5}\$ "