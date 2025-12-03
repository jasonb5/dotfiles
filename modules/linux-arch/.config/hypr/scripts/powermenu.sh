#!/usr/bin/env bash

entries=" Lock\n↩️ Logout\n󰤄 Suspend\n󰜉 Reboot\n⏻ Shutdown"

selected=$(echo -e "${entries}" | rofi -height 40% -dmenu | awk '{print tolower($2)}')

case "${selected}" in
    lock)
        hyprlock;;
    logout)
        hyprctl dispatch exit;;
    suspend)
        systemctl suspend;;
    reboot)
        systemctl reboot;;
    shutdown)
        systemctl poweroff -i;;
esac
