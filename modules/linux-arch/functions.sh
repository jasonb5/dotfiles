#!/usr/bin/env bash

function setup() {
    install_packages
    install_yay
    install_nvm

    setup_tmux
}

function install_packages() {
    sudo pacman -S --needed \
        git \
        base-devel
}

function install_yay() {
    if command_exists "yay"; then
        return
    fi

    let temp_dir
    temp_dir="$(mktemp -d)"

    pushd "${temp_dir}"

    git clone https://aur.archlinux.org/yay.git

    cd yay

    makepkg -si
}

function install_nvm() {
    if command_exists "node"; then
        return
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    nvm install 22
}

function setup_tmux() {
    if [[ ! -e "${HOME}/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

function fzf_tmux() {
    selected="$(find ${HOME}/devel -mindepth 2 -maxdepth 2 -type d | fzf)"

    if [[ -z "${selected}" ]]; then
        return
    fi

    selected_name="$(basename ${selected} | tr . _)"
    tmux_running="$(pgrep tmux)"

    if [[ -z "${TMUX}" ]] && [[ -z "${tmux_running}" ]]; then
        tmux new-session -s "${selected_name}" -c "${selected}"

        return
    fi

    if ! tmux has-session -t="${selected_name}" 2>/dev/null; then
        tmux new-session -ds "${selected_name}" -c "${selected}"
    fi

    if [[ -n "${TMUX}" ]]; then
        tmux switch-client -t "${selected_name}"
    else
        tmux attach-session -t "${selected_name}"
    fi
}
