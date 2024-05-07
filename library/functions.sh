#! /bin/bash

#==============================
# constants
#==============================

DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
CONFIG_FILES=(
  .gitconfig
)

#==============================
# user functions
#==============================

function dotfiles::user::usb_list() {
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

#==============================
# install/uninstall functions
#==============================

function dotfiles::load() {
  source "${DOTFILE_PATH}/library/alias.sh"
  source "${DOTFILE_PATH}/library/bashrc.sh"
  source "${DOTFILE_PATH}/library/functions.sh"
}

function dotfiles::install() {
  dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

  dotfiles::symlinks::add

  dotfiles::load
}

function dotfiles::uninstall() {
  dotfiles::log "Uninstalling dotfiles"

  dotfiles::symlinks::remove

  dotfiles::bashrc::remove

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
# bashrc functions
#==============================

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
