#!/usr/bin/env bash

set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
wallpaper_dir="$repo_root/wallpapers"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
selected_wallpaper_file="$state_dir/selected-wallpaper"

shopt -s nullglob
wallpapers=(
  "$wallpaper_dir"/*.png
  "$wallpaper_dir"/*.jpg
  "$wallpaper_dir"/*.jpeg
  "$wallpaper_dir"/*.webp
)
shopt -u nullglob

[ "${#wallpapers[@]}" -gt 0 ] || exit 0

choices=()
for wallpaper in "${wallpapers[@]}"; do
  choices+=("$(basename -- "$wallpaper")")
done

selection="$(printf '%s\n' "${choices[@]}" | fuzzel --dmenu --prompt 'wallpaper> ')"
[ -n "$selection" ] || exit 0

selected="$wallpaper_dir/$selection"
[ -f "$selected" ] || exit 1

mkdir -p "$state_dir"
printf '%s\n' "$selected" > "$selected_wallpaper_file"

SWAY_WALLPAPER="$selected" "$repo_root/scripts/distro/arch/wallpaper.sh"
