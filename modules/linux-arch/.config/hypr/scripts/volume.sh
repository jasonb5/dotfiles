#!/usr/bin/env bash

case "${1}" in
    dec)
        wpctl set-volume @DEFAULT_SINK@ 5%-
        ;;
    enc)
        wpctl set-volume @DEFAULT_SINK@ 5%+
        ;;
    mute)
        wpctl set-mute @DEFAULT_SINK@ toggle
        ;;
    *)
        info "Unknown volume command ${1}"
        ;;
esac
