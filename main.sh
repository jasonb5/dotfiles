#!/usr/bin/env bash

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

installer::os() {
    echo "$(uname -s | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::distribution() {
    echo "$(echo $(lsb_release -i ) | sed 's/.*: //' | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::hostname() {
    echo "$(uname -n | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::source_and_run() {
    local file="${1}"
    local function_name="${2}"

    if [[ ! -e "${file}" ]]; then
        debug "Skipping '${file}', does not exist"

        return
    fi

    debug "Loading '${file}'"

    source "${file}"

    if ! declare -f ${function_name} &>/dev/null; then
        debug "Skipping '${function_name}', does not exist"
        
        return
    fi

    debug "Running '${function_name}'"

    "${function_name}"

    debug "Clearing '${function_name}'"

    unset "${function_name}"
}

installer::run_host_function() {
    local os
    local distribution
    local hostname
    local response
    local read_code
    local function_name="${1}"

    read -p "Would you like to skip '${function_name}'? (y/n) " -s -t 4 "response"

    read_code="$?"

    echo ""

    if [[ ${read_code} -gt 128 ]]; then
        debug "User input timed out"

        response="y"
    fi

    if [[ "${response}" != "n" ]]; then
        debug "Skipping running '${function_name}', got response '${response}'"

        return
    fi

    os="$(installer::os)"
    distribution="$(installer::distribution)"
    hostname="$(installer::hostname)"

    installer::source_and_run "${DOTFILE_PATH}/library/99_hosts/${os}.sh" "${function_name}"
    installer::source_and_run "${DOTFILE_PATH}/library/99_hosts/${os}-${distribution}.sh" "${function_name}"
    installer::source_and_run "${DOTFILE_PATH}/library/99_hosts/${os}-${distribution}-${hostname}.sh" "${function_name}"
}

installer::bootstrap() {
    info "Bootstrapping dotfiles"

    if [[ ! -e "${DOTFILE_PATH}" ]]; then
        info "Cloning dotfiles to ${DOTFILE_PATH}"

        git clone --filter=blob:none "${DOTFILE_REPO}" "${DOTFILE_PATH}"
    fi

    installer::run_host_function "bootstrap_pre"

    source "${DOTFILE_MAIN}" install

    installer::run_host_function "bootstrap_post"
}

installer::link() {
    if [[ -e "${DOTFILE_MANIFEST}" ]]; then
        installer::unlink

        touch "${DOTFILE_MANIFEST}"
    fi

    installer::run_host_function "link_pre"

    local file

    find "${DOTFILE_PATH}/dotfiles" -type f -print0 | while IFS= read -r -d '' file; do
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

    installer::run_host_function "link_post"
}

installer::unlink() {
    local file

    if [[ -e "${DOTFILE_MANIFEST}" ]]; then
        info "Unlinking dotfiles"

        while IFS= read -r file; do
            info "Unlink ${file}"

            unlink "${file}"

            if [[ -e "${file}.bak" ]]; then
                debug "Restoring backup \"${file}\""

                mv "${file}.bak" "${file}"
            fi
        done < "${DOTFILE_MANIFEST}"

        info "Removing dotfiles manifest"

        rm "${DOTFILE_MANIFEST}"
    fi
}

installer::install() {
    info "Installing dotfiles"

    installer::link

    if [[ -z "$(grep "##### DOTFILE START #####" ~/.bashrc)" ]]; then
        read -r -p "Modify ~/.bashrc to load dotfiles? (y/n) " autoload

        if [[ "${autoload}" == "y" ]]; then
            info "Appending ~/.bashrc"

            tee -a ~/.bashrc << EOF >>/dev/null
##### DOTFILE START #####
export DOTFILE_PATH="\$(realpath ~/devel/personal/dotfiles)"
export DOTFILE_MANIFEST="\$(realpath ~/.dotfiles.manifest)"

source <(cat ~/devel/personal/dotfiles/library/*.sh)
##### DOTFILE STOP  #####
EOF
        fi
    fi
}

installer::uninstall() {
    info "Uninstalling dotfiles"

    installer::unlink

    info "Cleaning up ~/.bashrc"

    sed -i "/##### DOTFILE START #####/,/##### DOTFILE STOP  #####/d" ~/.bashrc
}

main() {
    local cmd="${1:-bootstrap}"

    case "${cmd}" in
        bootstrap)
            installer::bootstrap
            ;;
        link)
            installer::link
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
