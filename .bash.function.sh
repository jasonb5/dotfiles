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

function kube_deployment {
cat << EOF > "$1.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $1
  labels:
    app: $1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $1
  template:
    metadata:
      labels:
        app: $1
    spec:
      containers:
      - name: $1
        image: $1:APPVERSION
        ports:
        - containerPort: 80
#        volumeMounts:
#        - mountPath: /data
#          name: data-volume
#        - mountPath: /etc/config
#          readOnly: true
#          name: $1-secret
#        - mountPath: /etc/config
#          name: $1-config
#      nodeSelector:
#        tier: frontend
#      volumes:
#      - name: data-volume
#        persistentVolumeClaim:
#          claimName: data-volume
#      - name: $1-secret
#        secret:
#          secretName: $1
#      - name: $1-config
#        configMap:
#          name: $1
#---
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: $1
#data:
#  test.txt: |
#    hello=world
#---
#apiVersion: v1
#kind: Secret
#metadata:
#  name: $1
#type: Opaque
#data:
#  username: hello
---
kind: Service
apiVersion: v1
metadata:
  name: $1
spec:
  selector:
    app: $1
  ports:
  - protocol: TCP
    port: 80
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: $1
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: $1
          servicePort: 80
---
EOF
}

function kube_storage {
cat << EOF > "${1}-persistence.yaml"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $1
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: slow
  hostPath:
    path: /data
    type: DirectoryOrCreate
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $1
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
  storageClassName: slow
  selector:
    matchLabels:
      name: $1
EOF
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
