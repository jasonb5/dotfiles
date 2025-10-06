#!/usr/bin/env bash

source "${DOTFILE_PATH}/library/10_functions.sh"

action="${1}"

function metadata() {
    echo "$(playerctl metadata title)\n$(playerctl metadata artist) - $(playerctl metadata album)"
}

case "${action}" in
    "next")
        playerctl next
        debug "next"
        sleep 0.5
        dunstify -r 200 "Next track" "$(metadata)"
        ;;
    "previous")
        playerctl previous
        debug "previous"
        sleep 0.5
        dunstify -r 200 "Previous track" "$(metadata)"
        ;;
    "play")
        playerctl play-pause
        debug "play"
        sleep 0.5
        dunstify -r 200 "Play track" "$(metadata)"
        ;;
    "pause")
        playerctl pause
        debug "pause"
        sleep 0.5
        dunstify -r 200 "Pause track" "$(metadata)"
        ;;
    "play-pause")
        playerctl play-pause
        debug "play-pause"
        sleep 0.5
        dunstify -r 200 "Toggle track" "$(metadata)"
        ;;
esac
