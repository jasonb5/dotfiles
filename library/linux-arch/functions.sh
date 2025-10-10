#!/usr/bin/env bash

function init_bash() {
    eval "$(starship init bash)"

    export HISTTIMEFORMAT="%F %T "
    export HISTCONTROL=ignoredups:ignorespace

    shopt -s histappend

    ulimit -c 0
}

function tmuxs() {
    local selected="$(find ~/devel -mindepth 2 -maxdepth 2 -type d | fzf)"
    local name="${selected##$(dirname ${selected})/}"

    if [[ -z "${TMUX}" ]]; then
        tmux new-session -A -c "${selected}" -s "${name}"
    else
        if ! tmux has-session -t "${name}" 2>/dev/null; then
            tmux new-session -c "${selected}" -s "${name}" -d
        fi

        tmux switch-client -t "${name}"
    fi
}
