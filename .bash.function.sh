function conda_install {
  pushd "${HOME}"

  if [[ "$(uname)" == "Darwin" ]]
  then
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
  elif [[ "$(uname)" == "Linux" ]]
  then
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  fi 

  bash Miniconda3-latest-*-x86_64.sh -bf -p ${HOME}/conda

  popd
}

function conda_dev {
  if [[ ! -z "$(conda env list | grep dev)" ]]
  then
    conda env remove -n dev
  fi

  conda create -n dev -y -c conda-forge conda-build anaconda-client bump2version
}

function conda_update_base {
  conda update -n base -c defaults conda
}

function conda_revisions {
  conda list --revisions
}

modprobe_override=/etc/modprobe.d/vfio-driver-override.conf

function vm-prep {
  echo 1 | sudo tee /proc/sys/vm/compact_memory

  echo 8192 | sudo tee /proc/sys/vm/nr_hugepages

  for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo "performance" | sudo tee "${file}"; done
}

function vm-release {
  echo 0 | sudo tee /proc/sys/vm/nr_hugepages

  for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo "powersave" | sudo tee "${file}"; done
}

function lock-nvidia {
  echo "options vfio-pci ids=10de:1b81,10de:10f0,1106:3483" | sudo tee "${modprobe_override}"

  sudo update-initramfs -u
}

function unlock-nvidia {
  sudo rm "${modprobe_override}"

  sudo update-initramfs -u
}

function iommu_groups {
  for d in /sys/kernel/iommu_groups/*/devices/*;
  do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
  done
}

function rm_finalizer {
  kubectl patch ${1} ${2} --type merge -p '{"metadata":{"finalizers": [null]}}'
}

function check {
  cat "${1}"

  read -ep "Continue (y/n): " cont

  [[ "${cont}" == "y" ]] && cat "${1}" || echo ""
}

function get_field {
  tr -s " " | cut -d " " -f ${1}
}

function dump_certs {
  if [[ $# < 1 ]]
  then
    echo "Usage dump_certs HOST"

    echo " e.g. dump_certs www.google.com"
  else
    openssl s_client -showcerts -verify 5 -connect ${1}:443 < /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".pem"; print >out}' 

    for cert in *.pem; do newname=$(openssl x509 -noout -subject -in $cert | sed -n 's/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p').pem; mv $cert $newname; done
  fi
}

function colors {
  T='gYw'   # The test text

  echo -e "\n                 40m     41m     42m     43m\
       44m     45m     46m     47m";

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
             '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
             '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
      do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
    done
    echo;
  done
  echo
}

####################
# Required functions
####################

SUDO=""

function GIT_BRANCH {
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  [[ ! -z "${BRANCH}" ]] && echo " (${BRANCH})"
}

function is_root {
  [[ $(id -u -n) == "root" ]] && echo 0 || echo 1
}

function command_exists {
  command -v $1 >/dev/null 2>&1

  echo $?
}

function find_conda_path {
  echo $(find /opt/*conda*/bin ${HOME}/*conda*/bin -type d 2>/dev/null)
}

function str_contains {
  [[ "${1}" =~ "${2}" ]] && echo 1 || echo 0
}

function file_contains {
  grep -E "${1}" "${2}"; echo $?
}

function prepend_file {
  echo -e "${1}\n$(cat ${2})" > ${2}
}

function init_system {
  install_dotfiles

cat << EOF > "${HOME}/.env"
DOTFILE_PATH="${DOTFILE_PATH}"
CONDA_PATH="$(find_conda_path)"
EOF

  if [[ $(command_exists vim) -eq 0 ]]
  then
    install_vim_plug
  fi

  if [[ $(commnad_exists conda) -eq 0 ]]
  then
    conda init bash
  fi

  if [[ -z "$(grep "source ${HOME}/.bash_profile" ${HOME}/.bashrc)" ]]
  then
    echo "source ${HOME}/.bash_profile" >> "${HOME}/.bashrc"
  fi

  . "${HOME}/.bash_profile"
}

function install_system_applications {
  if [[ $(command_exists apt) -eq 0 ]]
  then
    ${SUDO} apt update

    ${SUDO} apt install --no-install-recommends -y vim-nox tmux
  fi
}

function install_dotfiles {
	for filename in $(cat files.txt); do
		local src_path="${PWD}/${filename}"
		local dst_path="${HOME}/${filename}"
		local bak_path="${dst_path}.bak"
	
		if [[ -e ${dst_path} ]] && [[ ! -h ${dst_path} ]]; then
			echo "Backing up ${dst_path}"

			mv ${dst_path} ${bak_path}
		fi	

    if [[ ! -h ${dst_path} ]]; then
      echo "Linking ${src_path} to ${dst_path}"
     
      ln -s ${src_path} ${dst_path}
    fi
	done
}

function uninstall_dotfiles {
  for filename in $(cat files.txt); do
		local dst_path="${HOME}/${filename}"
		local bak_path="${dst_path}.bak"

    if [[ -h ${dst_path} ]]; then
     unlink ${dst_path}
    fi

    if [[ -e ${bak_path} ]]; then
      mv ${bak_path} ${dst_path}
    fi  
  done
}

function install_vim_plug {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    vim +PlugInstall +qall
}
