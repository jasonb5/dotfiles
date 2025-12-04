#!/usr/bin/env bash

function setup_os() {
    install_os_packages
    install_packages

    setup_networkmanager
    setup_tmux
}

function install_os_packages() {
    if ! command_exists yay; then
        local temp_dir
        temp_dir="$(mktemp -d)"

        git clone --filter blob:none https://aur.archlinux.org/yay.git "${temp_dir}"

        pushd "${temp_dir}"

        makepkg -i

        info "Installed \"yay\""
    fi

    yay -Sy \
        ttf-fira-code \
        ttf-jetbrains-mono \
        woff2-font-awesome \
        nerd-fonts \
        base-devel \
        lua-language-server \
        unzip \
        git \
        less \
        lsb-release \
        tmux \
        neovim \
        pacman-contrib \
        playerctl \
        brightnessctl \
        hyprlock \
        hypridle \
        hyprpolkitagent \
        wl-clipboard \
        cliphist \
        wtype \
        sddm-astronaut-theme \
        swww \
        waybar \
        rofi \
        rofi-emoji \
        rofi-nerdy \
        fastfetch \
        dunst \
        fzf \
        lazygit \
        python-pywal16 \
        networkmanager \
        starship
}

function install_packages() {
    if ! command_exists node; then
        curl -o- https://fnm.vercel.app/install | bash

        info "Installed \"fnm\" and \"node\""
    fi

    if ! command_exists gemini; then
        npm install -g @google/gemini-cli

        info "INstalled \"gemini\""
    fi
}

function setup_networkmanager() {
    if [[ "$(systemctl is-active systemd-networkd)" == "active" ]]; then
        sudo systemctl stop systemd-networkd
        sudo systemctl disable systemd-networkd
    fi

    if [[ "$(systemctl is-active iwd)" == "active" ]]; then
        sudo systemctl stop iwd
        sudo systemctl disable iwd
    fi

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
}

function setup_tmux() {
    if command_exists tmux && [[ ! -e "${HOME}/.tmux/plugins/tpm"  ]]; then
        info "Installing tmux tpm"

        git clone --filter=blob:none https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
    fi
}

function init_bash() {
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
    gpg-connect-agent updatestartuptty /bye > /dev/null

    eval "$(starship init bash)"

    export HISTTIMEFORMAT="%F %T "
    export HISTCONTROL=ignoredups:ignorespace

    shopt -s histappend

    ulimit -c 0
}

function tmuxs() {
    local selected="$(find ~/devel -mindepth 2 -maxdepth 2 -type d | fzf)"
    local name="${selected##$(dirname ${selected})/}"

    if [[ -z "${TMUX}" ]]; then
        tmux new-session -A -c "${selected}" -s "${name}"
    else
        if ! tmux has-session -t "${name}" 2>/dev/null; then
            tmux new-session -c "${selected}" -s "${name}" -d
        fi

        tmux switch-client -t "${name}"
    fi
}

function fcd() {
    target="$(find . -type d -not -path '*.git*' | fzf)"

    pushd "${target}"
}
