backup_file() {
  local file_path="${1}"

  [[ -e "${file_path}" ]] && mv "${file_path}" "${file_path}.bak"
}

link_files() {
  local install_dir="${1}" && shift

  while [[ $# -gt 0 ]]; do
    local install_file="${install_dir}/${1}" && shift

    if [[ ! -h "${install_file}" ]]; then
      backup_file "${install_file}"

      echo "Linking ${PWD}/${install_file##*/} to ${install_path}"

      ln -sf "${PWD}/${install_file##*/}" "${install_path}"
    fi
  done
}

unlink_files() {
  local install_dir="${1}" && shift

  while [[ $# -gt 0 ]]; do
    local install_file="${install_dir}/${1}" && shift

    if [[ -h "${install_file}" ]]; then
      local backup="${install_file}.bak"

      unlink "${install_file}"      

      if [[ -e "${backup}" ]]; then
        mv "${backup}" "${install_file}"
      fi
    fi
  done
}
