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

alias jupyter="dotfiles::docker::run jupyter -d -p 8888:8888 --gpus=all --runtime=nvidia -v ~/:/home/jovyan/host quay.io/jupyter/minimal-notebook:lab-4.2.1"
alias localai="dotfiles::docker::run localai -d -p 8080:8080 --gpus=all --runtime=nvidia -v ~/models/localai:/build/models localai/localai:latest-aio-gpu-nvidia-cuda-12"
