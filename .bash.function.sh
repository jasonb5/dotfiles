err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

backup_file() {
  local file_path="${1}"

  [[ -e "${file_path}" ]] && mv "${file_path}" "${file_path}.bak"
}

link_files() {
  local install_path="${1}"

  shift

  while [[ $# -gt 0 ]]; do
    local filename="${1}"

    shift

    if [[ ! -h "${install_path}/${filename}" ]]; then
      backup_file "${install_path}/${filename}"

      ln -sf "${PWD}/${filename}" "${install_path}"
    fi
  done
}
