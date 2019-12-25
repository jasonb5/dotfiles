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

####################
# Required functions
####################

SUDO=""

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

function init_system {
  if [[ $(command_exists sudo) -eq 0 ]] && [[ $(is_root) -eq 1 ]]
  then
    SUDO="sudo"
  fi

  CONDA_PATH="$(find_conda_path)"

  [[ "${PATH}" =~ "${CONDA_PATH}" ]] && echo "Conda path already in path" || export PATH="${CONDA_PATH}:${PATH}"

  install_system_applications

  install_dotfiles
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
