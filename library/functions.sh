#! /bin/bash

#==============================
# constants
#==============================

DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"
CONFIG_FILES=(
  .tmux/plugins/tpm
  .tmux.conf
  .vim/coc-settings.json
  .vimrc
  .gitconfig
)

#==============================
# user functions
#==============================

function dotfiles::list_usb() {
  for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
      (
          syspath="${sysdevpath%/dev}"
          devname="$(udevadm info -q name -p $syspath)"
          [[ "$devname" == "bus/"* ]] && exit
          eval "$(udevadm info -q property --export -p $syspath)"
          [[ -z "$ID_SERIAL" ]] && exit
          echo "/dev/$devname - $ID_SERIAL"
      )
  done
}

function dotfiles::install_miniforge() {
  local url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
  local install_dir="${HOME}/conda"

  if [[ ! -e "${install_dir}" ]]; then
    curl -L -o "/tmp/conda.sh" "${url}"

    chmod +x "/tmp/conda.sh"

    /tmp/conda.sh -b -p "${install_dir}"
  fi

  source "${install_dir}/etc/profile.d/conda.sh"

  conda init bash

  sb
}

function dotfiles::dev::install() {
  dotfiles::install_miniforge

  dotfiles::utils::sudo pacman -S nodejs

  mamba install -y tmux
}

#==============================
# install/uninstall functions
#==============================

function dotfiles::install() {
  dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

  dotfiles::symlinks::install

  dotfiles::vimplug::install 

  if [[ -n "${CONTAINER}" ]]; then
    dotfiles::dev
  fi
}

function dotfiles::uninstall() {
  dotfiles::log "Uninstalling dotfiles"

  dotfiles::symlinks::remove

  dotfiles::bashrc::remove

  dotfiles::vimplug::remove
}

#==============================
# logging functions
#==============================

function dotfiles::log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

function dotfiles::debug() {
  [[ -n "${DEBUG}" ]] && dotfiles::log "${*}"
}

function dotfiles::error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#==============================
# utility functions
#==============================

function dotfiles::utils::sudo() {
  if [[ "${USER}" == "root" ]] || [[ "$(id -u)" -eq 0 ]]; then
    "${@}"
  else
    sudo "${@}"
  fi
}

#==============================
# symlink functions
#==============================

function dotfiles::symlinks::install() {
  for path in "${CONFIG_FILES[@]}"; do
    local user_file="${HOME}/${path}"
    local repo_file="${DOTFILE_PATH}/configs/${path}"

    if [[ -e "${user_file}" ]] && [[ ! -L "${user_file}" ]] && [[ ! -e "${user_file}.bak" ]]; then
      dotfiles::log "Backing up ${user_file}"	

      mv "${user_file}" "${user_file}.bak"
    fi

    if [[ ! -e "${user_file}" ]]; then
      dotfiles::log "Linking ${repo_file} -> ${user_file}"

      if [[ ! -e "${user_file%/*}" ]]; then
        mkdir -p "${user_file%/*}"
      fi

      ln -sf "${repo_file}" "${user_file}"
    else
      dotfiles::log "Skipping ${repo_file}"
    fi
  done
}

function dotfiles::symlinks::remove() {
  for path in "${CONFIG_FILES[@]}"; do
    local user_file="${HOME}/${path}"

    if [[ -e "${user_file}" ]] && [[ -L "${user_file}" ]]; then
      dotfiles::log "Unlinking ${user_file}"	

      unlink "${user_file}"
    fi

    if [[ -e "${user_file}.bak" ]]; then
      dotfiles::log "Restoring backup ${user_file}.bak"

      mv "${user_file}.bak" "${user_file}"
    fi
  done
}

#==============================
# vim-plug functions
#==============================

function dotfiles::vimplug::install() {
  if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
    dotfiles::log "Downloading vim plug"

    curl -Lo "${VIM_PLUG_PATH}" --create-dirs "${VIM_PLUG_URL}"
  fi
}

function dotfiles::vimplug::remove() {
  if [[ -e "${VIM_PLUG_PATH}" ]]; then
    dotfiles::log "Removing ${VIM_PLUG_PATH}"

    rm -rf "${VIM_PLUG_PATH}"
  fi
}

#==============================
# bashrc functions
#==============================

function dotfiles::bashrc::temp() {
  export DOTFILE_PATH="${HOME}/devel/dotfiles"

  source "${DOTFILE_PATH}/library/alias.sh"
  source "${DOTFILE_PATH}/library/bashrc.sh"
  source "${DOTFILE_PATH}/library/functions.sh"
}

function dotfiles::bashrc::install() {
  if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    dotfiles::log "Appending ${HOME}/.bashrc"

    cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
export DOTFILE_PATH="\${HOME}/devel/dotfiles"

source "\${DOTFILE_PATH}/library/alias.sh"
source "\${DOTFILE_PATH}/library/bashrc.sh"
source "\${DOTFILE_PATH}/library/functions.sh"

if [[ -e "${HOME}/.dotfiles.user.sh" ]]; then
    source "${HOME}/.dotfiles.user.sh"
fi
${DOTFILE_STOP}
EOF
  fi
}

function dotfiles::bashrc::remove() {
  if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    dotfiles::log "Removing entry from ${HOME}/.bashrc"

    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i "" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    else
      sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    fi
  fi
}
