#!/usr/bin/env bash

function __setup() {
    install_presetup_packages
    install_yay
    install_packages
    install_nvm
    install_theme_assets

    setup_tmux
}

function install_presetup_packages() {
    sudo pacman -Sy --needed \
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

function install_packages() {
    yay -Sy --needed \
        swaync \
        ttf-iosevka-nerd \
        ttf-iosevkaterm-nerd \
        rose-pine-gtk-theme-full
}

function install_nvm() {
    if command_exists "node"; then
        return
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    nvm install 22
}

function install_theme_assets() {
    install_asset \
        https://raw.githubusercontent.com/rose-pine/kitty/refs/heads/main/dist/rose-pine-moon.conf \
        "${HOME}/.config/kitty/themes/rose-pine-moon.conf"

    install_asset \
        https://raw.githubusercontent.com/rose-pine/waybar/refs/heads/main/rose-pine-moon.css \
        "${HOME}/.config/waybar/rose-pine-moon.css"

    install_asset \
        https://raw.githubusercontent.com/rose-pine/swaync/refs/heads/main/theme/rose-pine-moon.css \
        "${HOME}/.config/swaync/style.css"

    install_asset \
        https://raw.githubusercontent.com/rose-pine/rofi/refs/heads/main/rose-pine-moon.rasi \
        "${HOME}/.config/rofi/config.rasi"
}

function install_asset() {
    local url="${1}"
    local path="${2}"

    if [[ ! -e "$(dirname ${path})" ]]; then
        mkdir -p "$(dirname ${path})"
    fi

    curl -L -o "${path}" "${url}"

    if ! grep "${path}" "${DOTFILE_MANIFEST}"; then
        echo "${path}" >> "${DOTFILE_MANIFEST}"
    fi
}

function setup_tmux() {
    if [[ ! -e "${HOME}/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

function fzf_nvim() {
    local file
    file=$(find . -type f | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --height=40% --layout=reverse --border)
    if [[ -n "$file" ]]; then
        nvim "$file"
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
