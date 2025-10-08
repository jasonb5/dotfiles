#!/usr/bin/env bash

check_missing_aur_packages() {
    local required_packages=("swww" "pywal16", "rofi-nerdy") 
    local missing=""

    for pkg in "${required_packages[@]}"; do 
        if ! command_exists "${pkg}"; then
            missing+="${pkg}, "
        fi
    done

    if (( ${#missing} > 0 )); then
        info "${missing:0:(( ${#missing} - 2 ))}"
        else
            info "No missing aur packages"
    fi
}
