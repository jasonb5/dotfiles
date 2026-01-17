#!/usr/bin/env bash

DOTFILE_PATH="$(realpath ~/devel/personal/dotfiles)"
readonly DOTFILE_PATH
DOTFILE_MANIFEST="$(realpath ~/.dotfiles.manifest)"
readonly DOTFILE_MANIFEST
readonly DOTFILE_MAIN="${DOTFILE_PATH}/main.sh"
readonly DOTFILE_MODULES="${DOTFILE_PATH}/modules"
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
    find ${DOTFILE_MODULES} -type d -path "*/$(installer::os)" | head -n1
}

installer::os_dist_dir() {
    find ${DOTFILE_MODULES} -type d -path "*/$(installer::os)-$(installer::dist)" | head -n1
}

installer::bootstrap() {
    info "Bootstrapping dotfiles"

    if [[ ! -e "${DOTFILE_PATH}" ]]; then
        info "Cloning dotfiles to ${DOTFILE_PATH}"

        git clone --filter=blob:none "${DOTFILE_REPO}" "${DOTFILE_PATH}"
    fi

    source "${DOTFILE_MAIN}" install
}

installer::setup() {
    local os_dir="$(installer::os_dir)"
    local dist_dir="$(installer::os_dist_dir)"

    if [[ -e "${os_dir}/functions.sh" ]]; then
        source "${os_dir}/functions.sh"

        declare -f __setup && eval "__setup"
    fi

    if [[ -e "${dist_dir}/functions.sh" ]]; then
        source "${dist_dir}/functions.sh"

        declare -f __setup && eval "__setup"
    fi

    find "${DOTFILE_PATH}" -type f -iname 'hostname_regex.txt' -print0 \
        | while IFS= read -r -d '' file; do
        local hostname_regex
        hostname_regex="$(cat $file)"
        local path
        path="$(dirname $file)"

        if [[ "$(uname -n)" =~ ${hostname_regex} ]] && [[ -e "${path}/functions.sh" ]]; then
            source "${path}/functions.sh"

            declare -f __setup && eval "__setup"
        fi
    done
}

installer::link() {
    local os_dir="$(installer::os_dir)"
    local dist_dir="$(installer::os_dist_dir)"

    info "Linking files from \"${DOTFILE_PATH}\""

    find "${DOTFILE_PATH}" -type f \( -iname '.*' -o -path '*/.*/*' \) ! \( -path '*/.git/*' -o -path '*/modules/*' \) -print0 \
        | while IFS= read -r -d '' file; do
        installer::link_path "${DOTFILE_PATH}" "${file}"
    done

    info "Linking files from \"${os_dir}\""

    find "${os_dir}" -type f \( -iname '.*' -o -path '*/.*/*' \) ! -path '*/.git/*' -print0 \
        | while IFS= read -r -d '' file; do
        installer::link_path "${os_dir}" "${file}"
    done

    info "Linking files from \"${dist_dir}\""

    find "${dist_dir}" -type f \( -iname '.*' -o -path '*/.*/*' \) ! -path '*/.git/*' -print0 \
        | while IFS= read -r -d '' file; do
        installer::link_path "${dist_dir}" "${file}"
    done

    find "${DOTFILE_PATH}" -type f -iname 'hostname_regex.txt' -print0 \
        | while IFS= read -r -d '' file; do
        local hostname_regex
        hostname_regex="$(cat $file)"
        local path
        path="$(dirname $file)"

        if [[ "$(uname -n)" =~ ${hostname_regex} ]]; then
            info "Linking files from \"${path}\""

            find "${path}" -type f \( -iname '.*' -o -path '*/.*/*' \) ! -path '*/.git/*' -print0 \
                | while IFS= read -r -d '' file2; do
                installer::link_path "${path}" "${file2}"
            done
        fi
    done
}

installer::link_path() {
    local file
    file="$(realpath ${2})"
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

    if [[ ! -e "${link}" ]]; then
        ln -sfr "${file}" "${link}"

        echo "${link}" >> "${DOTFILE_MANIFEST}"
    fi
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
    # Skip bootstrap.sh, only used during bookstrapping
    find "${1}" -maxdepth 1 -type f -not \( -name bootstrap.sh -or -iname '.*' \) -exec echo -en "source {}\n" \;
}

installer::modify_bashrc() {
    if [[ -z "$(grep "##### DOTFILE START #####" ~/.bashrc)" ]]; then
        read -r -p "Modify ~/.bashrc to load dotfiles? [y|N] " -t 4 autoload

        if [[ "${autoload:-n}" == "y" ]]; then
            local os_dir="$(installer::os_dir)"
            local dist_dir="$(installer::os_dist_dir)"

            info "Appending ~/.bashrc"

            tee -a "${HOME}/.bashrc" << EOF >>/dev/null
##### DOTFILE START #####
export DOTFILE_PATH="\$(realpath ~/devel/personal/dotfiles)"
export DOTFILE_MANIFEST="\$(realpath ~/.dotfiles.manifest)"

$(installer::get_files_to_source ${os_dir})
$(installer::get_files_to_source ${dist_dir})

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

    if [[ -e "${DOTFILE_MANIFEST}" ]]; then
        installer::unlink
    fi

    touch "${DOTFILE_MANIFEST}"

    installer::link

    installer::modify_bashrc
}

installer::uninstall() {
    info "Uninstalling dotfiles"

    installer::unlink

    installer::clear_bashrc
}

bootstrap_logging() {
    if [[ -e "${DOTFILE_PATH}/modules/$(installer::os)/functions.sh" ]]; then
        cat "${DOTFILE_PATH}/modules/$(installer::os)/functions.sh"
    else
        curl -L "${DOTFILE_RAW_REPO}/modules/$(installer::os)/functions.sh"
    fi
}

eval "$(bootstrap_logging)"

main() {
    local cmd="${1:-bootstrap}"

    case "${cmd}" in
        bootstrap|b)
            installer::bootstrap;;
        install|i)
            installer::install;;
        uninstall|u)
            installer::uninstall;;
        link|l)
            installer::link;;
        update-link|ul)
            installer::unlink
            installer::link
            ;;
        update-shell|us)
            installer::clear_bashrc
            installer::modify_bashrc
            ;;
        setup):
            installer::setup
            ;;
        *)
            echo "Invalid command ${cmd}"
            ;;
    esac
}

main "$@"
