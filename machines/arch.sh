#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

install_aur() {
  local temp_dir
  local package="${1}"

  temp_dir="$(mktemp -d)"

  pushd "${temp_dir}"

  git clone --depth 1 "https://aur.archlinux.org/${package}.git/" .

  makepkg -seo # sync deps, no extract, no build

  vim PKGBUILD

  read -p "Would you like to continue installing ${name}? (y/n) " answer

  if [[ "${answer}" == "y" ]]; then
    makepkg -i
  fi

  popd
}

update_system() {
  info "Updating system packages"

  sudo pacman -Syu
}

install_packages() {
  info "Installing required packages"

  sudo pacman -Sy --noconfirm \
    hyprlock \
    hypridle \
    hyprpolkitagent \
    waybar \
    playerctl \
    ttf-fire-coda \
    ttf-jetbrains-mono \
    wofi \
    rofimoji \
    fastfetch \
    wl-clipboard \
    cliphist
}

install_other() {
  info "Install fnm and nodejs"

  curl -o- https://fnm.vercel.app/install | bash

  fnm install 22

  info "Node: $(node --version) Npm: $(npm -v)"

  info "Installing Gemini CLI"

  npm install -g @google/gemini-cli
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
  update_system
  install_packages
  install_other
}
