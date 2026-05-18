#!/usr/bin/env bash

set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
wallpaper_dir="$repo_root/wallpapers"
default_wallpaper="$wallpaper_dir/rose-pine-block-wave-moon.png"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
selected_wallpaper_file="$state_dir/selected-wallpaper"
wallpaper="${SWAY_WALLPAPER:-}"
fallback_color="#232136"

if [ -z "$wallpaper" ]; then
  if [ -f "$selected_wallpaper_file" ]; then
    wallpaper="$(<"$selected_wallpaper_file")"
  else
    wallpaper="$default_wallpaper"
  fi
fi

if [ -f "$wallpaper" ]; then
  pkill -x swaybg >/dev/null 2>&1 || true
  if command -v swww >/dev/null 2>&1; then
    swww-daemon >/dev/null 2>&1 &
    sleep 0.2
    swww img "$wallpaper" --transition-type fade --transition-duration 0.7
  else
    swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
  fi
else
  pkill -x swaybg >/dev/null 2>&1 || true
  swaybg -c "$fallback_color" >/dev/null 2>&1 &
fi
