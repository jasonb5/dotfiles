#!/usr/bin/env bash

source "${DOTFILE_PATH}/library/10_functions.sh"

action="${1}"
amount="${2:-5}"

current="$(brightnessctl get)"
max="$(brightnessctl max)"

case "${action}" in
    up)
        target="$(( (${current}*100/${max})+${amount} ))"
        ;;
    down)
        target="$(( (${current}*100/${max})-${amount} ))"
        ;;
    *)
        debug "Unknown action ${action}"
        exit 1
        ;;
esac

debug "Current: ${current} Max: ${max} Target: ${target}"

if [[ "${target}" -gt 100 ]] && [[ "${target}" -lt 0 ]]; then
    debug "Target valuye '${target}' out of range (0 - 100)"

    dunstify -r 300 "Backlight" "Could not set brightness ${target} out of range"

    exit 1
fi

case "${action}" in
    up)
        brightnessctl -q set +${amount}%
        ;;
    down)
        brightnessctl -q set ${amount}%-
        ;;
esac
