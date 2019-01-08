export DOTFILE_PATH=`cat ${HOME}/.dotfile_path`

export TERM="xterm-256color"

CONDA_PATH=("/opt/conda" "${HOME}/conda" "${HOME}/miniconda2")

for x in ${CONDA_PATH[@]}; do
  [[ -e "${x}/bin" ]] && prepend_path "${x}/bin"
done
