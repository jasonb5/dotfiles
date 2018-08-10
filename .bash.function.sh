is_installed() {
  [[ -z "$(command -v $1)" ]] && echo "1" || echo "0"
}

gen_tls_cert() {
  openssl genrsa -out "${1}.key" 4096

  openssl req -x509 -new -nodes -key "${1}.key" -sha256 -days 1024 -subj "/C=US/ST=CA/L=Bay Area/O=Blackhole/CN=blackhole" -out "${1}.crt"
}

gen_ca() {
  openssl genrsa -out ca.key 4096

  openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -subj "/C=US/ST=CA/L=Bay Area/O=Blackhole/CN=blackhole" -out ca.crt
}

write_edit_csr_conf() {
  cat <<-EOF > "${1}.conf"
[ req ]
default_bits = 2048
default_key = ${1}.key
encrypt_key = no
default_md = sha1
prompt = no
utf8 = yes
distinguished_name = ${1}

[ ${1} ]
C = US
ST = CA
L = Bay Area
O = Blackhole
CN = blackhole

[ my_extensions ]
basicConstraints=CA:FALSE
subjectAltName=@subject_alt_names
subjectKeyIdentifier=hash

[ subject_alt_names ]
DNS.1 = ${1}
IP.1 = 127.0.0.1
EOF

  ${EDITOR} "${1}.conf"
}

gen_cert() {
  local name="${1}"

  [[ ! -e "ca.key" ]] && gen_ca

  openssl genrsa -out "${name}.key" 2048

  write_edit_csr_conf "${name}" && openssl req -new -out "${name}.csr" -config "${name}.conf"

  openssl x509 -req -in "${name}.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -out "${name}.crt"
}

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

      echo "Linking ${PWD}/${filename} to ${install_path}"

      ln -sf "${PWD}/${filename}" "${install_path}"
    fi
  done
}
