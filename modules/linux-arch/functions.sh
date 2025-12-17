#!/usr/bin/env bash

function setup() {
    install_nvm
}

function install_nvm() {
    if ! command_exists "node"; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

        nvm install 22
    fi
}
