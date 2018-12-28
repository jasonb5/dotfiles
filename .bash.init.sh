export DOTFILE_PATH=`cat ${HOME}/.dotfile_path`

export TERM="xterm-256color"

conda_path="/opt/conda/bin"
conda_home_path="${HOME}/conda/bin"

[[ -e "${conda_path}" ]] && prepend_path ${conda_path}
[[ -e "${conda_home_path}" ]] && prepend_path ${conda_home_path}
