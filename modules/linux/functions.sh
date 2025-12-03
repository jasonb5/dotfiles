#!/usr/bin/env bash

command_exists() {
    command -v "${1}" >/dev/null 2>&1

    if [[ "$?" == 0 ]]; then
        return 0
    fi

    return 1
}

run_if_defined() {
    if declare -f "${1}" >/dev/null; then
        "${1}"
    fi
}

log_date() {
    echo "$(date +'%Y-%m-%dT%H:%M:%S%z')"
}

error() {
    echo "[$(log_date)][ERR]: $*" >&2
}

debug() {
    [[ -n "${DEBUG}" ]] && [[ "${DEBUG}" == "true" ]] && echo "[$(log_date)][DEBUG]: $*" >&1
}

info() {
    echo "[$(log_date)][INFO]: $*" >&1
}
