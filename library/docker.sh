function dotfiles::docker::run() {
	local name="${1}" && shift

	local container_id="$(docker ps -a -f name=${name} -q)"

	if [[ -n "${container_id}" ]]; then
		docker stop "${container_id}"

		docker rm "${container_id}"

	fi

	docker run --name "${name}" "${@}"

	container_id="$(docker ps -a -f name=${name} -q)"

	docker logs -f "${container_id}"
}

