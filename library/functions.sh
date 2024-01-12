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

function dotfiles::user::docker::run() {
  name="${1}"
  shift
  background="${1}"
  shift
  args="${@}"

  existing=$(docker ps -a -f name="${name}" -q)

  if [[ -n "${existing}" ]]; then
    if [[ "${background}" == "true" ]]; then
      docker start "${existing}"
    else
      docker exec -it "${existing}" /bin/bash
    fi
  else
    if [[ "${background}" == "true" ]]; then
      run_args="-d --name ${name}"
    else
      run_args="-it --name ${name}"
    fi

    docker run ${run_args} ${args}
  fi
}

function dotfiles::user::usb::list() {
  dotfiles::log "Listing usb devices"

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

function dotfiles::user::miniforge::install() {
  local url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
  local install_dir="${HOME}/conda"

  dotfiles::log "Installing miniforge to ${install_dir}"

  if [[ ! -e "${install_dir}" ]]; then
    curl -L -o "/tmp/conda.sh" "${url}"

    dotfiles::log "Downloaded installer to /tmp/conda.sh"

    chmod +x "/tmp/conda.sh"

    /tmp/conda.sh -b -p "${install_dir}"

    dotfiles::log "Installed conda to ${install_dir}"
  fi

  source "${install_dir}/etc/profile.d/conda.sh"

  dotfiles::log "Sourcing conda.sh"

  conda init bash

  dotfiles::log "Executed 'conda init bash'"

  sb
}

#==============================
# install/uninstall functions
#==============================

function dotfiles::install() {
  dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

  dotfiles::symlinks::add

  dotfiles::vimplug::install 
}

function dotfiles::uninstall() {
  dotfiles::log "Uninstalling dotfiles"

  dotfiles::symlinks::remove

  dotfiles::bashrc::remove

  dotfiles::vimplug::remove

  unset DOTFILE_PATH
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

function dotfiles::symlinks::add() {
  dotfiles::log "Adding dotfiles symlinks to ${HOME} from `pwd`"

  for path in "${CONFIG_FILES[@]}"; do
    local user_file="${HOME}/${path}"
    local repo_file="${DOTFILE_PATH}/configs/${path}"

    dotfiles::log "Linking ${repo_file} -> ${user_file}"

    if [[ -e "${user_file}" ]] && [[ ! -L "${user_file}" ]] && [[ ! -e "${user_file}.bak" ]]; then
      mv "${user_file}" "${user_file}.bak"

      dotfiles::log "Backed up ${user_file} -> ${user_file}.bak"
    fi

    if [[ ! -e "${user_file}" ]]; then
      if [[ ! -e "${user_file%/*}" ]]; then
        mkdir -p "${user_file%/*}"

        dotfiles::log "Creating parent directory ${user_file%/*}"
      fi

      ln -sf "${repo_file}" "${user_file}"

      dotfiles::log "Linked ${repo_file} -> ${user_file}"
    else
      dotfiles::log "Skipping ${repo_file}, link already exists"
    fi
  done
}

function dotfiles::symlinks::remove() {
  dotfiles::log "Removing dotfiles symlinks from ${HOME}"

  for path in "${CONFIG_FILES[@]}"; do
    local user_file="${HOME}/${path}"

    dotfiles::log "Removing ${user_file}"

    if [[ -e "${user_file}" ]] && [[ -L "${user_file}" ]]; then
      unlink "${user_file}"

      dotfiles::log "Unlinked ${user_file}"
    fi

    if [[ -e "${user_file}.bak" ]]; then
      mv "${user_file}.bak" "${user_file}"

      dotfiles::log "Restored ${user_file} from ${user_file}.bak"
    fi
  done
}

#==============================
# vim-plug functions
#==============================

function dotfiles::vimplug::install() {
  dotfiles::log "Installing vimplug to ${VIM_PLUG_PATH}"

  if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
    curl -Lo "${VIM_PLUG_PATH}" --create-dirs "${VIM_PLUG_URL}"

    dotfiles::log "Installed vimplug to ${VIM_PLUG_PATH} from ${VIM_PLUG_URL}"
  fi
}

function dotfiles::vimplug::uninstall() {
  dotfiles::log "Uninstalling vimplug from ${VIM_PLUG_PATH}"

  if [[ -e "${VIM_PLUG_PATH}" ]]; then
    rm -rf "${VIM_PLUG_PATH}"

    dotfiles::log "Removed vimplug from ${VIM_PLUG_PATH}"
  fi
}

#==============================
# bashrc functions
#==============================

function dotfiles::bashrc::load() {
  export DOTFILE_PATH="${HOME}/devel/dotfiles"

  source "${DOTFILE_PATH}/library/alias.sh"
  source "${DOTFILE_PATH}/library/bashrc.sh"
  source "${DOTFILE_PATH}/library/functions.sh"
}

function dotfiles::bashrc::append() {
  dotfiles::log "Appending dotfiles bashrc entry"

  if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
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

    dotfiles::log "Appended dotfiles basrc entry"
  fi
}

function dotfiles::bashrc::remove() {
  dotfiles::log "Removing dotfiles bashrc entry"

  if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i "" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    else
      sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    fi

    dotfiles::log "Found and removed dotfiles bashrc entry"
  fi
}
