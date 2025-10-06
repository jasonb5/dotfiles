#!/usr/bin/env bash

source "${DOTFILE_PATH}/library/10_functions.sh"

action="${1}"
amount="${2:-5}"

function get_volume() {
    echo "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)"
}

if [[ "${action}" == "up" ]]; then
    target="$(( $(get_volume)+${amount} ))"
elif [[ "${action}" == "down" ]]; then
    target="$(( $(get_volume)-${amount} ))"
elif [[ "${action}" == "mute" ]]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle

    muted="$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po 'Mute: \K.*')"

    debug "Current mute state: ${muted}"

    if [[ "${muted}" == "yes" ]]; then
        dunstify -r 100 "Volume change" "Muted"
    else
        dunstify -r 100 "Volume change" "Unmuted"
    fi

    exit 0
else
    debug "Unknown action: ${action}"

    exit 1
fi

debug "Direction: ${action} Amount: ${amount} Target: ${target}"

if [[ "${target}" -gt 100 ]] || [[ "${target}" -lt 0 ]]; then
    debug "Cannot set volume, out of range (0-100)"

    dunstify -r 100 "Volume change" "Cannot set volume to ${target}"

    exit 1
fi

if [[ "${action}" == "up" ]]; then
    pactl set-sink-volume @DEFAULT_SINK@ +${amount}%
else
    pactl set-sink-volume @DEFAULT_SINK@ -${amount}%
fi

debug "Updated volume to ${target}"

dunstify -r 100 "Volume change" "Set volume to ${target}"
