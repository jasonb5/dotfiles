SUDO=""

function install_vim_plug {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    vim +PlugInstall +qall
}

function install_system_application {
  if [[ $(is_installed apt-get) -eq 1 ]]
  then
    ${SUDO} apt-get update

    # curl -sL https://deb.nodesource.com/setup_12.x | bash -

    ${SUDO} apt-get install --no-install-recommends -y vim-nox
  fi
}

function check_system {
  if [[ $(is_installed sudo) -eq 1 ]] && [[ $(id -u -n) != "root" ]]
  then
    SUDO="sudo"
  fi
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

function console_colors {
  #Foreground
  for clfg in {30..37} {90..97} 39 ; do
    #Formatting
    for attr in 0 1 2 4 5 7 ; do
      #Print the result
      echo -en "\e[${attr};49;${clfg}m ^[${attr};49;${clfg}m \e[0m"
    done
    echo #Newline
  done
}

function prepend_path {
  [[ $(contains $PATH $1) -eq 1 ]] && export PATH="$1:$PATH"
}

function contains {
  [[ "$1" =~ "$2" ]] && echo 0 || echo 1
}

function is_installed {
  command $1 >/dev/null 2>&1

  echo $?
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
