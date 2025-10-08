#!/usr/bin/env bash

wallpaper_dir="$(realpath ~/Pictures/Wallpapers)"

selected=$(find "${wallpaper_dir}" -maxdepth 1 -type f -exec basename {} \; | sort | while read -r filename; do echo -en "$filename\0icon\x1fthumbnail://${wallpaper_dir}/${filename}\n"; done | PREVIEW=true rofi -dmenu)

if [[ -n "${selected}" ]]; then
    wallpaper_path="${wallpaper_dir}/${selected}"
    current_path="$(realpath ~)/.local/state/dotfiles/current_wallpaper"

    if [[ ! -e "$(dirname ${current_path})" ]]; then
        mkdir -p "$(dirname ${current_path})"
    fi

    ln -sf "${wallpaper_path}" "${current_path}"
    ln -sf "${wallpaper_path}" "/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/current"

    wal -i "${current_path}"
fi
