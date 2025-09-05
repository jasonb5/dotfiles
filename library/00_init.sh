#!/bin/bash
# vim: set shiftwidth=2 tabstop=2 softtabstop=2 et:

hypr_host_file="$(realpath ~/.config/hypr/config/host.conf)"

if [[ ! -e "${hypr_host_file}" ]]; then
  if [[ "${HOSTNAME}" == "lo" ]]; then
tee -a "${hypr_host_file}" << EOF >>/dev/null
\$monitorScale = 1.2
EOF
  elif [[ "${HOSTNAME}" == "ganymede" ]]; then
tee -a "${hypr_host_file}" << EOF >>/dev/null
\$monitorScale = 1.0
EOF
  fi

  echo "${hypr_host_file}" >> "${DOTFILE_MANIFEST}"
fi
