#! /bin/bash

#==============================
# constants
#==============================

DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
CONFIG_FILES=(
  .vimrc
  .gitconfig
  .tmux.conf
  .tmux.remote.conf
  .tmux/plugins/tpm
)

#==============================
# Exports
export GPG_TTY=$(tty)
export EDITOR=vim
#==============================

CLEAR="\[\033[0m\]"
PURPLE="\[\033[35m\]"
CYAN="\[\033[36m\]"

export PROMPT_COMMAND='EXIT="$?";
  if [[ -n "${PRIVATE}" ]]; then
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}user@$(dotfiles::utils::hostname): $(pwd)${CLEAR}";
  else
    L1="${CONDA_PROMPT_MODIFIER:-}${PURPLE}$(whoami)@$(dotfiles::utils::hostname): $(pwd)${CLEAR}";
  fi

  L2="${CYAN}${EXIT} $> ${CLEAR}";

  PS1="${L1}\n${L2}";'

#==============================
# user functions
#==============================

function dotfiles::user::miniforge3() {
  url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
  filepath="/tmp/miniforge.sh"
  curl -Lo "${filepath}" "${url}"
  chmod +x "${filepath}"
  "${filepath}" -b -p "${HOME}/devel/conda" -u
}

#==============================
# install/uninstall functions
#==============================

function dotfiles::load() {
  source "${DOTFILE_PATH}/library/alias.sh"
  source "${DOTFILE_PATH}/library/functions.sh"
}

function dotfiles::install() {
  dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

  dotfiles::symlinks::add

  dotfiles::vimplug::install

  dotfiles::load
}

function dotfiles::uninstall() {
  dotfiles::log "Uninstalling dotfiles"

  dotfiles::vimplug::uninstall

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
# vim-plug functions
#==============================

function dotfiles::vimplug::install() {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim    
}

function dotfiles::vimplug::uninstall() {
  rm -rf ~/.vim/autoload/plug.vim
}

#==============================
# utility functions
#==============================

function dotfiles::utils::hostname() {
  if [[ -z "${HOSTNAME}" ]]; then
    hostnamectl hostname
  else
    echo "${HOSTNAME}"
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
# bashrc functions
#==============================

function dotfiles::bashrc::append() {
  dotfiles::log "Appending dotfiles bashrc entry"

  if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    cat << EOF >> "${HOME}/.bashrc"
${DOTFILE_START}
export DOTFILE_PATH="\${HOME}/devel/dotfiles"

source "\${DOTFILE_PATH}/library/alias.sh"
source "\${DOTFILE_PATH}/library/functions.sh"

dotfiles::bashrc::fix_path

dotfiles::bashrc::machine::load
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

function dotfiles::bashrc::machine::load() {
  hostname="$(dotfiles::utils::hostname)"

  dotfiles::log "Searching machine specific bashrc for \"${hostname}\""

  # Load version controlled machine specific
  while IFS='' read -r -d '' filepath; do
    filename="$(basename ${filepath})"

    if [[ "$(echo ${hostname} | grep ${filename})" == "${hostname}" ]]; then
      dotfiles::log "Found match ${filepath}"

      source "${filepath}"
    fi
  done < <(find ${DOTFILE_PATH}/machine -maxdepth 1 -type f -print0)

  # Load non-version controllered machine specific
  [[ -e "${HOME}/.bashrc.user" ]] && source "${HOME}/.bashrc.user"
}

function dotfiles::bashrc::fix_path() {
  if [[ -z "${DOTFILE_LOADED}" ]]; then
    export PATH="${HOME}/.bin:${PATH}"

    export DOTFILE_LOADED="true"
  fi
}
