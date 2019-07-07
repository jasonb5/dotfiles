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

function kube_account {
  if [[ $# < 4 ]]
  then
    echo "Usage kube_account USERNAME NAMESPACE CLUSTERNAME CLUSTERADDRESS"

    echo "  e.g. kube_account test development bigcluster https://127.0.0.1:6443"
  else
    openssl genrsa -out ${1}.key 2048

    openssl req -new -key ${1}.key -out ${1}.csr -subj "/CN=${1}/O=${2}"

    sudo openssl x509 -req -in ${1}.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ${1}.crt -days 365

    sudo chown $(id -g):$(id -u) ${1}.crt

    kubectl --kubeconfig ${1}-config config set-credentials ${1} --client-certificate=${1}.crt --client-key=${1}.key --embed-certs

    kubectl --kubeconfig ${1}-config config set-context ${1}-context --cluster=${3} --namespace=${2} --user=${1}

    sudo kubectl --kubeconfig ${1}-config config set-cluster ${3} --server ${4} --embed-certs --certificate-authority=/etc/kubernetes/pki/ca.crt

    kubectl --kubeconfig ${1}-config config use-context ${1}-context

cat << EOF >> ${1}-role-rolebinding.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: ${2}
  name: deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] You can also use ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${1}-deployment-manager-binding
  namespace: ${2}
subjects:
- kind: User
  name: ${1}
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: ""
EOF
  fi
}

function kube_config_test {
  local kubeconfig=${1} && shift  

  kubectl --kubeconfig ${kubeconfig} ${@}
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
