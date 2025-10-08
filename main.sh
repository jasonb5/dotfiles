#!/usr/bin/env bash

DOTFILE_PATH="$(realpath ~/devel/personal/dotfiles)"
readonly DOTFILE_PATH
DOTFILE_MANIFEST="$(realpath ~/.dotfiles.manifest)"
readonly DOTFILE_MANIFEST
readonly DOTFILE_MAIN="${DOTFILE_PATH}/main.sh"
readonly DOTFILE_REPO="https://github.com/jasonb5/dotfiles"
readonly DOTFILE_RAW_REPO="https://raw.githubusercontent.com/jasonb5/dotfiles/refs/heads/main"

installer::os() {
    echo "$(uname -s | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::dist() {
    echo "$(echo $(lsb_release -i ) | sed 's/.*: //' | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::hostname() {
    echo "$(uname -n | tr '[[:upper:]]' '[[:lower:]]')"
}

installer::is_valid_path() {
    if [[ -e "${1}" ]]; then
        debug "Path '${1}' exists"

        return 0
    fi

    return 1
}

installer::find_valid_host_file() {
    find "${1}" -mindepth 1 -type d | while read -r dir; do
        local dirname="${dir##${1}/}"

        if [[ ${dirname} =~ ^[a-zA-Z0-1]+-[a-zA-Z0-1]+-[a-zA-Z0-1]+$ ]]; then
            local hostname="$(echo ${dir} | cut -d'-' -f3)"

            if [[ "${2}" =~ ${hostname} ]]; then
                echo "${dir}/${3}"

                return 0
            fi
        fi
    done

    return 1
}

installer::source_and_run() {
    if installer::is_valid_path "${1}"; then
        debug "Sourcing '${1}'"

        source "${1}"

        if declare -f "${2}" &>/dev/null; then
            debug "Running '${2}'"

            "${2}"
            unset "${2}"
        else
            debug "Skipping '${2}', does not exist"
        fi
    else
        debug "Skipping '${1}', does not exist"
    fi
}

installer::run_hook() {
    local os_file="${DOTFILE_PATH}/library/$(installer::os)/${1}"
    local dist_file="${DOTFILE_PATH}/library/$(installer::os)-$(installer::dist)/${1}"
    local host_file="$(installer::find_valid_host_file $(dirname $(dirname ${dist_file})) $(installer::hostname) ${1})"

    installer::source_and_run "${os_file}" "${2}"
    installer::source_and_run "${dist_file}" "${2}"
    installer::source_and_run "${host_file}" "${2}"
}

installer::bootstrap() {
    info "Bootstrapping dotfiles"

    if [[ ! -e "${DOTFILE_PATH}" ]]; then
        info "Cloning dotfiles to ${DOTFILE_PATH}"

        git clone --filter=blob:none "${DOTFILE_REPO}" "${DOTFILE_PATH}"
    fi

    installer::run_hook "bootstrap.sh" "bootstrap_pre"

    source "${DOTFILE_MAIN}" install

    installer::run_hook "bootstrap.sh" "bootstrap_post"
}

installer::link() {
    if [[ -e "${DOTFILE_MANIFEST}" ]]; then
        installer::unlink

        touch "${DOTFILE_MANIFEST}"
    fi

    local file

    installer::run_hook "bootstrap.sh" "link_pre"

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

    installer::run_hook "bootstrap.sh" "link_post"
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

installer::modify_bashrc() {
    if [[ -z "$(grep "##### DOTFILE START #####" ~/.bashrc)" ]]; then
        read -r -p "Modify ~/.bashrc to load dotfiles? (y/n) " autoload

        if [[ "${autoload}" == "y" ]]; then
            local os_dir="${DOTFILE_PATH}/library/$(installer::os)"
            local dist_dir="${os_dir}-$(installer::dist)"
            local host_dir="$(installer::find_valid_host_file ${dist_dir})"

            info "Appending ~/.bashrc"

            tee -a ~/.bashrc << EOF >>/dev/null
##### DOTFILE START #####
export DOTFILE_PATH="\$(realpath ~/devel/personal/dotfiles)"
export DOTFILE_MANIFEST="\$(realpath ~/.dotfiles.manifest)"

$(if installer::is_valid_path ${os_dir}; then find ${os_dir} -maxdepth 1 -type f -exec echo -en "source {}\n" \; ; fi)
$(if installer::is_valid_path ${dist_dir}; then find ${dist_dir} -maxdepth 1 -type f -exec echo -en "source {}\n" \; ; fi)
$(if installer::is_valid_path ${host_dir}; then find ${host_dir} -maxdepth 1 -type f -exec echo -en "source {}\n" \; ; fi)
##### DOTFILE STOP  #####
EOF
        fi
    fi
}

installer::clear_bashrc() {
    info "Cleaning up ~/.bashrc"

    sed -i "/##### DOTFILE START #####/,/##### DOTFILE STOP  #####/d" ~/.bashrc
}

installer::install() {
    info "Installing dotfiles"

    installer::link

    installer::modify_bashrc 
}

installer::uninstall() {
    info "Uninstalling dotfiles"

    installer::unlink

    installer::clear_bashrc
}

bootstrap_logging() {
    # logging functions are always in base os
    local local_file="${DOTFILE_PATH}/library/$(installer::os)/functions.sh"
    local remote_file="${DOTFILE_RAW_REPO}/library/$(installer::os)/functions.sh"

    if [[ -e "${local_file}" ]]; then
        cat "${local_file}"
    else
        curl -L "${remote_file}"
    fi
}

eval "$(bootstrap_logging)"

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
        reset-bashrc)
            installer::clear_bashrc 
            installer::modify_bashrc 
            ;;
        *)
            echo "Invalid option ${cmd}"
            ;;
    esac
}

main "$@"
