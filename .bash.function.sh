function kube_templates {
cat << EOF > "$1.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $1-deployment
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
#      volumes:
#      - name: data-volume
#        persistentVolumeClaim:
#          claimName: data-volume
#      - name: $1-secret
#        secret:
#          secretName: $1-secret
#      - name: $1-config
#        configMap:
#          name: $1-config
---
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: $1-config
#data:
#  test.txt: |
#    hello=world
#---
#apiVersion: v1
#kind: Secret
#metadata:
#  name: $1-secret
#type: Opaque
#data:
#  username: hello
---
kind: Service
apiVersion: v1
metadata:
  name: $1-service
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
  name: $1-ingress
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: $1-service
          servicePort: 80
---
#apiVersion: v1
#kind: PersistentVolume
#metadata:
#  name: $1-pv
#spec:
#  capacity:
#    storage: 5Gi
#  volumeMode: Filesystem
#  accessModes:
#    - ReadWriteOnce
#  persistentVolumeReclaimPolicy: Retain
#  storageClassName: slow
#  hostPath:
#    path: /data
#    type: DirectoryOrCreate
#---
#kind: PersistentVolumeClaim
#apiVersion: v1
#metadata:
#  name: $1-pvc
#spec:
#  accessModes:
#    - ReadWriteOnce
#  volumeMode: Filesystem
#  resources:
#    requests:
#      storage: 8Gi
#  storageClassName: slow
#  selector:
#    matchLabels:
#      name: $1-pv
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
