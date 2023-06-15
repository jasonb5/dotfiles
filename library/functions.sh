#! /bin/bash

#==============================
# constants
#==============================

DOTFILE_START="# >>>>>> DOTFILE_START >>>>>>"
DOTFILE_STOP="# <<<<<< DOTFILE_STOP <<<<<<"
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_PATH="${HOME}/.vim/autoload/plug.vim"

#==============================
# user functions
#==============================

function dotfiles::dev() {
  dotfiles::host::check_install "conda" "dotfiles::mambaforge::install" 

  dotfiles::host::check_install "vim" "mamba install -y vim"

  dotfiles::host::check_install "git" "mamba install -y git"

  dotfiles::host::check_install "node" "dotfiles::nodesource::install"
}

function dotfiles::host::check_install() {
  local name="${1}"
  local cmd="${2}"

  if [[ -z "$(which ${name})" ]]; then
    eval "${cmd}"
  else
    dotfiles::log "${name} has already been installed"
  fi
}

function dotfiles::mambaforge::install() {
  url="https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh"
  output_path="/tmp/$(basename ${url})"

  curl -sfL -o "${output_path}" "${url}"

  chmod +x "${output_path}"

  "${output_path}" -b -p "${HOME}/conda" -u

  source "${HOME}/conda/etc/profile.d/conda.sh"

  conda init bash
}

function dotfiles::nodesource::install() {
  curl -fsSL https://deb.nodesource.com/setup_current.x | dotfiles::sudo bash -

  dotfiles::sudo apt install -y --no-install-recommends nodejs
}

#==============================
# library functions
#==============================

function dotfiles::sudo() {
  if [[ "${USER}" == "root" ]] || [[ "$(id -u)" -eq 0 ]]; then
    "${@}"
  else
    sudo "${@}"
  fi
}

function dotfiles::log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

function dotfiles::debug() {
  [[ -n "${DEBUG}" ]] && dotfiles::log "${*}"
}

function dotfiles::error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

function dotfiles::install() {
  dotfiles::host::required

  dotfiles::log "Installing dotfiles from ${DOTFILE_PATH}"

  dotfiles::symlinks::install

  # dotfiles::bashrc::install

  dotfiles::vimplug::install 

  if [[ -n "${CONTAINER}" ]]; then
    dotfiles::dev
  fi
}

function dotfiles::host::required() {
  if [[ -z "$(which curl)" ]]; then
    dotfiles::log "Installing curl package"

    dotfiles::sudo apt update

    dotfiles::sudo apt install -y --no-install-recommends curl ca-certificates
  fi
}

function dotfiles::symlinks::install() {
  for file in `ls -a "${DOTFILE_PATH}/configs" | grep -vE "\.$|\.\.$"`; do
    local user_file="${HOME}/${file}"
    local repo_file="${DOTFILE_PATH}/configs/${file}"

    if [[ -e "${user_file}" ]] && [[ ! -L "${user_file}" ]] && [[ ! -e "${user_file}.bak" ]]; then
      dotfiles::log "Backup up ${user_file}"

      mv "${user_file}" "${user_file}.bak"
    fi

    dotfiles::log "Linking ${repo_file} -> ${user_file}"

    if [[ ! -e "$(dirname ${user_file})" ]]; then
      mkdir -p "$(dirname ${user_file})"
    fi

    if [[ ! -e "${user_file}" ]]; then
      ln -sf "${repo_file}" "${user_file}"
    fi
  done
}

function dotfiles::bashrc::install() {
  if [[ -z "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    dotfiles::log "Appending .bashrc"

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

function dotfiles::vimplug::install() {
  if [[ ! -e "${VIM_PLUG_PATH}" ]]; then
    dotfiles::log "Downloading vim plug"

    curl -Lo "${VIM_PLUG_PATH}" --create-dirs "${VIM_PLUG_URL}"
  fi
}

function dotfiles::uninstall() {
  dotfiles::log "Uninstalling dotfiles"

  dotfiles::symlinks::remove

  dotfiles::bashrc::remove

  dotfiles::vimplug::remove
}

function dotfiles::symlinks::remove() {
  for file in `ls -a "${DOTFILE_PATH}/configs" | grep -vE "\.$|\.\.$"`; do
    local user_file="${HOME}/${file}"

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

function dotfiles::bashrc::remove() {
  if [[ -n "$(grep "${DOTFILE_START}" "${HOME}/.bashrc")" ]]; then
    dotfiles::log "Removing entry from .bashrc"

    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i "" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    else
      sed -i"" "/${DOTFILE_START}/,/${DOTFILE_STOP}/d" "${HOME}/.bashrc"
    fi
  fi
}

function dotfiles::vimplug::remove() {
  if [[ -e "${VIM_PLUG_PATH}" ]]; then
    dotfiles::log "Removing ${VIM_PLUG_PATH}"

    rm -rf "${VIM_PLUG_PATH}"
  fi
}

function dotfiles::bashrc::temp_install() {
  export DOTFILE_PATH="${HOME}/devel/dotfiles"

  source "${DOTFILE_PATH}/library/alias.sh"
  source "${DOTFILE_PATH}/library/bashrc.sh"
  source "${DOTFILE_PATH}/library/functions.sh"
}
