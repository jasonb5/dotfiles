#!/usr/bin/env bash

case "${1}" in
    dec)
        brightnessctl set +5% ;;
    inc)
        brightnessctl set 5%-;;
    *)
        info "Unknown backlight command ${1}" ;;
esac
