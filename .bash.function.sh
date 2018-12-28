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

function pexec {
  kube exec -it $1 /bin/bash
}

function spexec {
  skube exec -it $1 /bin/bash
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
