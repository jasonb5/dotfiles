#!/usr/bin/env bash

wallpaper_dir="$(realpath ~/Pictures/Wallpapers)"

selected=$(find "${wallpaper_dir}" -maxdepth 1 -type f -exec basename {} \; | sort | while read -r filename; do echo -en "$filename\0icon\x1fthumbnail://${wallpaper_dir}/${filename}\n"; done | PREVIEW=true rofi -dmenu)

if [[ -n "${selected}" ]]; then
    wal -i "$(realpath ~/Pictures/Wallpapers)/${selected}"
fi
