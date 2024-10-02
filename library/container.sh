#!/bin/bash

function dotfiles::container::get-id() {
	if dotfiles::utils::is-installed "docker"; then
		echo "$(docker ps -a -f name=${1} -q)"
	elif dotfiles::utils::is-installed "nerdctl"; then
		echo "$(nerdctl ps -a -f name=${1} -q)"
	fi

	echo ""
}

function dotfiles::container::remove() {
	echo "Removing container ${1}"

	if dotfiles::utils::is-installed "docker"; then
		docker stop "${1}"
		docker rm "${1}"
	elif dotfiles::utils::is-installed "nerdctl"; then
		nerdctl stop "${1}"
		nerdctl rm "${1}"
	fi
}

function dotfiles::container::run-daemon() {
	local name="${1}" && shift
	local id="$(dotfiles::container::get-id)"

	if [[ -n "${id}" ]]; then
		dotfiles::container::remove "${id}"
	fi

	if dotfiles::utils::is-installed "docker"; then
		eval "docker run -n ${name} -d ${@}"
	elif dotfiles::utils::is-installed "nerdctl"; then
		eval "nerdctl run --name ${name} -d ${@}"
	else
		echo "No container softward is installed"
	fi
}

function dotfiles::container::run() {
	if dotfiles::utils::is-installed "docker"; then
		eval "docker run --rm -it ${@}"
	elif dotfiles::utils::is-installed "nerdctl"; then
		eval "nerdctl run --rm -it ${@}"
	else
		echo "No container softward is installed"
	fi
}
