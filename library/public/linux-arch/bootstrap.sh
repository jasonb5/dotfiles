#!/usr/bin/env bash

install_packages() {
    read -r -p "Skip installing required packages? [Y|n] " -t 2 answer

    if [[ $? -gt 128 ]] || [[ "${answer}" == "y" ]]; then
        echo 

        info "Skipping installing required packages"

        return 1
    fi

    echo 

    info "Installing required packages"

    yay -Sy \
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
        networkmanager \
        swww \
        python-pywal16 \
        rofi-nerdy \
        sddm-astronaut-theme \
        starship 

    if [[ "$(systemctl is-active systemd-networkd)" == "active" ]]; then
        sudo systemctl stop systemd-networkd
        sudo systemctl disable systemd-networkd

        sudo systemctl stop iwd
        sudo systemctl disable iwd
    fi

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
}

install_yay() {
    if ! command_exists yay; then
        local temp_dir="$(mktemp -d)"

        git clone --filter blob:none https://aur.archlinux.org/yay.git "${temp_dir}"

        pushd "${temp_dir}"

        makepkg -i

        popd
    fi
}

install_other() {
    read -r -p "Skip installing other packages? [Y|n] " -t 2 answer

    if [[ $? -gt 128 ]] || [[ "${answer}" == "y" ]]; then
        echo

        info "Skipping installing other packages"

        return 1
    fi

    echo

    if ! command_exists yay; then
        install_yay
    fi

    info "Yay: $(yay --version)"

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

    info "Gemini: $(gemini --version)"

    if [[ ! -e ~/.tmux ]];  then
        info "Installing tmux tpm"

        git clone --filter=blob:none https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

setup_sddm() {
    local theme="astronaut.conf"
    local width; local height

    width="$(hyprctl monitors | grep -A1 Monitor | sed -n '2p' | cut -d'@' -f1 | tr -d '\t' | cut -d'x' -f1)"
    height="$(hyprctl monitors | grep -A1 Monitor | sed -n '2p' | cut -d'@' -f1 | tr -d '\t' | cut -d'x' -f2)"

    sudo chown -R root:titters /usr/share/sddm/themes
    sudo chmod -R 0775 /usr/share/sddm/themes

    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

    sed -i'' "s/\(ConfigFile=Themes\/\).*/\1${theme}/" /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop

    cp "/usr/share/sddm/themes/sddm-astronaut-theme/Themes/${theme}" "/usr/share/sddm/themes/sddm-astronaut-theme/Themes/${theme}.user" 

    sed -i'' "s/\(ScreenWidth=\).*/\1\"${width}\"/" /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf.user
    sed -i'' "s/\(ScreenHeight=\).*/\1\"${height}\"/" /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf.user
    sed -i'' "s/\(Font=\).*/\1\"Fira Code Mono\"/" /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf.user
    sed -i'' "s/\(Background=\"Backgrounds\/\).*/\1current\"/" /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf.user
}

bootstrap_post() {
    install_yay
    install_packages
    install_other
    setup_sddm
}

link_post() {
    hyprctl reload
}
