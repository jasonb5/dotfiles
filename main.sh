#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:


DOTFILE_PATH="$(realpath ~/devel/personal/dotfiles)"
readonly DOTFILE_PATH
DOTFILE_MANIFEST="$(realpath ~/.dotfiles.manifest)"
readonly DOTFILE_MANIFEST
readonly DOTFILE_MAIN="${DOTFILE_PATH}/main.sh"
readonly DOTFILE_REPO="https://github.com/jasonb5/dotfiles"
readonly DOTFILE_RAW_REPO="https://raw.githubusercontent.com/jasonb5/dotfiles/refs/heads/main"

bootstrap_logging() {
  local local_file="${DOTFILE_PATH}/library/10_functions.sh"
  local remote_file="${DOTFILE_RAW_REPO}/library/10_functions.sh"

  if [[ -e "${local_file}" ]]; then
    cat "${local_file}"
  else
    curl -L "${remote_file}"
  fi
}

eval "$(bootstrap_logging)"

installer::bootstrap() {
  info "Bootstrapping dotfiles"

  if [[ ! -e "${DOTFILE_PATH}" ]]; then
    info "Cloning dotfiles to ${DOTFILE_PATH}"

    git clone --filter=blob:none "${DOTFILE_REPO}" "${DOTFILE_PATH}"
  fi

  # shellcheck source=main.sh
  . "${DOTFILE_MAIN}" install
}

installer::install() {
  info "Installing dotfiles"

  source "${DOTFILE_PATH}/library/00_init.sh"

  if [[ -e "${DOTFILE_MANIFEST}" ]]; then
    debug "Removing old manifest file"

    rm "${DOTFILE_MANIFEST}"

    touch "${DOTFILE_MANIFEST}"
  fi

  local file

  find "${DOTFILE_PATH}/dotfiles" -type f -print0 \
    | while IFS= read -r -d '' file; do
    local relative="${file##"${DOTFILE_PATH}/dotfiles/"}"
    local link
    link="$(realpath ~)/${relative}"
    local link_parent="${link%%"$(basename "${link}")"}"

    if [[ ! -e "${link_parent}" ]]; then
      debug "Creating link parent directory"

      mkdir -p "${link_parent}"
    fi

    info "Linking ${file} -> ${link}"

    if [[ -e "${link}" ]] && [[ ! -L "${link}" ]]; then
      debug "Found existing ${link}, creating backup"

      mv "${link}" "${link}.bak"
    fi

    ln -sfr "${file}" "${link}"

    echo "${link}" >> ~/.dotfiles.manifest
  done

  read -r -p "Modify ~/.bashrc to load dotfiles? (y/n) " autoload

  if [[ "${autoload}" == "y" ]]; then
    info "Appending ~/.bashrc"

tee -a ~/.bashrc << EOF >>/dev/null
##### DOTFILE START #####
source <(cat ~/devel/personal/dotfiles/library/*.sh)
##### DOTFILE STOP  #####
EOF
  fi

  source "${DOTFILE_PATH}//library/10_functions.sh"
}

installer::uninstall() {
  info "Uninstalling dotfiles"

  local file

  if [[ -e "${DOTFILE_MANIFEST}" ]]; then
    while IFS= read -r file; do
      info "Unlink ${file}"

      unlink "${file}"

      if [[ -e "${file}.bak" ]]; then
        debug "Restoring backup \"${file}\""

        mv "${file}.bak" "${file}"
      fi
    done < "${DOTFILE_MANIFEST}"

    rm "${DOTFILE_MANIFEST}"
  fi

  info "Cleaning up ~/.bashrc"

  sed -i "/##### DOTFILE START #####/,/##### DOTFILE STOP  #####/d" ~/.bashrc
}

main() {
  local cmd="${1:-bootstrap}"

  case "${cmd}" in
    bootstrap)
      installer::bootstrap
      ;;
    install)
      installer::install
      ;;
    uninstall)
      installer::uninstall
      ;;
    *)
      echo "Invalid option ${cmd}"
      ;;
  esac
}

main "$@"

