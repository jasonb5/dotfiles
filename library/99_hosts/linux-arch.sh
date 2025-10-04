#!/usr/bin/env bash

install_aur() {
    local tempdir
    local package="${1}"
    local review="${2}"

    tempdir="$(mktemp -d)"

    git clone --depth 1 "https://aur.archlinux.org/${package}.git" "${tempdir}"

    pushd "${tempdir}"

    if [[ "${review}" == "true" ]]; then
        makepkg -o --printsrcinfo --verifysource

        vim PKGBUILD
    fi

    makepkg -si

    popd
}

check_missing_aur_packages() {
    local required_packages=("swww" "wallust", "rofi-nerdy") 
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

install_packages() {
    info "Installing required packages"

    sudo pacman -Sy --noconfirm \
        base-devel \
        unzip \
        git \
        less \
        pacman-contrib \
        hyprlock \
        hypridle \
        hyprpolkitagent \
        waybar \
        playerctl \
        brightnessctl \
        ttf-fira-code \
        ttf-jetbrains-mono \
        woff2-font-awesome \
        nerd-fonts \
        rofi \
        rofi-emoji \
        fastfetch \
        wl-clipboard \
        cliphist \
        dunst \
        wtype \
        tmux \
        fzf \
        neovim \
        lazygit \
        lsb-release \
        networkmanager

    if [[ "$(systemctl is-active systemd-networkd)" == "active" ]]; then
        sudo systemctl stop systemd-networkd
        sudo systemctl disable systemd-networkd

        sudo systemctl stop iwd
        sudo systemctl disable iwd
    fi

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
}

install_other() {
    if ! command_exists node; then
        info "Install fnm and nodejs"

        curl -o- https://fnm.vercel.app/install | bash

        fnm install 22
    fi

    info "Node: $(node --version) Npm: $(npm -v)"

    if ! command_exists gemini; then
        info "Installing Gemini CLI"

        npm install -g @google/gemini-cli
    fi

    if [[ ! -e ~/.tmux ]];  then
        info "Installing tmux tpm"

        git clone --filter=blob:none https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

generate_hypr_host_file() {
    local scale="1.0"
    local hypr_host_file
    hypr_host_file="$(realpath ~/.config/hypr/config/host.conf)"

    if [[ ! -e "${hypr_host_file}" ]]; then
        info "Generating hyprland host.conf"

        if [[ "${HOSTNAME}" == "lo" ]]; then
            scale="1.2"
        fi

        debug "Setting hyprland scale to ${scale}"

        tee -a "${hypr_host_file}" << EOF >>/dev/null
\$monitorScale = ${scale}
EOF

if [[ -v $(grep "${hypr_host_file}" "${DOTFILE_MANIFEST}") ]]; then
    echo "${hypr_host_file}" | tee -a "${DOTFILE_MANIFEST}"
fi
    fi
}

bootstrap_pre() {
    generate_hypr_host_file
}

bootstrap_post() {
    install_packages
    install_other
}

link_post() {
    hyprctl reload
}
