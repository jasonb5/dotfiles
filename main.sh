#!/usr/bin/env bash

DOTFILE_PATH="$(realpath ~/devel/personal/dotfiles)"
readonly DOTFILE_PATH
DOTFILE_MANIFEST="$(realpath ~/.dotfiles.manifest)"
readonly DOTFILE_MANIFEST
readonly DOTFILE_MAIN="${DOTFILE_PATH}/main.sh"
readonly DOTFILE_REPO="https://github.com/jasonb5/dotfiles"
readonly DOTFILE_RAW_REPO="https://raw.githubusercontent.com/jasonb5/dotfiles/refs/heads/main"

installer::os() {
    uname -s | tr '[[:upper:]]' '[[:lower:]]'
}

installer::dist() {
    lsb_release -i | sed 's/[^:]*:\s//' | tr '[[:upper:]]' '[[:lower:]]'
}

installer::hostname() {
    uname -n | tr '[[:upper:]]' '[[:lower:]]'
}

installer::os_dir() {
    find ${DOTFILE_PATH}/library -type d -path */$(installer::os) | head -n1
}

installer::os_dist_dir() {
    find ${DOTFILE_PATH}/library -type d -path */$(installer::os)-$(installer::dist) | head -n1
}

installer::os_dist_host_dir() {
    find ${DOTFILE_PATH}/library -type d -regex .*$(installer::os)-$(installer::dist)-[^//]* | while IFS= read -r x; do
        local hostname="$(basename ${x} | rev | cut -d'-' -f1 | rev)"
        if [[ "$(installer::hostname)" =~ .*${hostname}.* ]]; then
            echo "${x}"
            return 1
        fi
    done 

    return 0
}

installer::is_valid_path() {
    if [[ -e "${1}" ]]; then
        debug "Path '${1}' exists"

        return 0
    fi

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
    local os_file
    local dist_file
    local host_file

    os_file="$(installer::os_dir)/${1}"
    dist_file="$(installer::os_dist_dir)/${1}"
    host_file="$(installer::os_dist_host_dir)/${1}"

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

    installer::run_hook "bootstrap.sh" "link_pre"

    local os_dir="$(installer::os_dir)"
    local dist_dir="$(installer::os_dist_dir)"
    local host_dir="$(installer::os_dist_host_dir)"

    installer::link_files_from_dir "${DOTFILE_PATH}/dotfiles"
    installer::link_files_from_dir "${os_dir}/dotfiles"
    installer::link_files_from_dir "${dist_dir}/dotfiles"
    installer::link_files_from_dir "${host_dir}/dotfiles"

    installer::run_hook "bootstrap.sh" "link_post"
}

installer::link_files_from_dir() {
    if [[ ! -e "${1}" ]]; then
        debug "Skipping linking dotfiles from \"${1}\", does not exist"
        
        return 1
    fi

    find "${1}" -type f -print0 | while IFS= read -r -d '' file; do
        local relative="${file##"${1}/"}"
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

        echo "${link}" >> "${DOTFILE_MANIFEST}"
    done

    return 0 
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

installer::get_files_to_source() {
    if installer::is_valid_path "${1}"; then
        # Skip bootstrap.sh, only used during bookstrapping
        find "${1}" -maxdepth 1 -type f -not -name bootstrap.sh -exec echo -en "source {}\n" \;
    fi
}

installer::modify_bashrc() {
    if [[ -z "$(grep "##### DOTFILE START #####" ~/.bashrc)" ]]; then
        read -r -p "Modify ~/.bashrc to load dotfiles? [y|N] " -t 4 autoload

        if [[ "${autoload:-n}" == "y" ]]; then
            local os_dir="$(installer::os_dir)"
            local dist_dir="$(installer::os_dist_dir)"
            local host_dir="$(installer::os_dist_host_dir)"

            info "Appending ~/.bashrc"

            tee -a ~/.bashrc << EOF >>/dev/null
##### DOTFILE START #####
export DOTFILE_PATH="\$(realpath ~/devel/personal/dotfiles)"
export DOTFILE_MANIFEST="\$(realpath ~/.dotfiles.manifest)"

$(installer::get_files_to_source ${os_dir})
$(installer::get_files_to_source ${dist_dir})
$(installer::get_files_to_source ${host_dir})

# run init_bash if it exists
if declare -f init_bash >/dev/null; then
    init_bash
fi

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
    local local_file="${DOTFILE_PATH}/library/public/$(installer::os)/functions.sh"
    local remote_file="${DOTFILE_RAW_REPO}/library/public/$(installer::os)/functions.sh"

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
        bootstrap) installer::bootstrap;;
        link) installer::link;;
        install) installer::install;;
        uninstall) installer::uninstall;;
        bashrc)
            installer::clear_bashrc
            installer::modify_bashrc
            ;;
        *)
            echo "Invalid option ${cmd}"
            ;;
    esac
}

main "$@"
