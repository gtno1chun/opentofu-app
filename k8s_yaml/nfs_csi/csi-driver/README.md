## NFS 설치 및 구성 

#### Vagrantfile
```
# Vagrantfile for setting up an Ubuntu 20.04 NFS server with a specific disk size

Vagrant.configure("2") do |config|
  # Define a VM named "nfs-server"
  config.vm.define "nfs-server" do |server|
    server.vm.box = "ubuntu/focal64" # Ubuntu 20.04 box
    server.vm.hostname = "nfs-server"

    # Network configuration with a specific IP
    server.vm.network "private_network", ip: "192.168.56.10"

    # Use VirtualBox provider and set the VM name and disk size
    server.vm.provider "virtualbox" do |vb|
      vb.name = "NFS_server"
      vb.memory = "1024" # Optional: Set memory size
      vb.cpus = 2 # Optional: Set number of CPUs
    end

    # Set the disk size using vagrant-disksize plugin
    server.disksize.size = '200GB'

    # Provisioning script for NFS server setup
    server.vm.provision "shell", inline: <<-SHELL
      # Update package list and install NFS server
      sudo apt-get update
      sudo apt-get install -y nfs-kernel-server

      # Create a directory to share via NFS
      sudo mkdir -p /srv/nfs/shared
      sudo chown nobody:nogroup /srv/nfs/shared
      sudo chmod 777 /srv/nfs/shared

      # Configure NFS exports
      echo "/srv/nfs/shared *(rw,sync,no_subtree_check)" | sudo tee /etc/exports

      # Restart NFS server to apply changes
      sudo exportfs -a
      sudo systemctl restart nfs-kernel-server
    SHELL
  end
end
```

#### NFS server 설정 

```
참고 : 서브넷이 다른 클라언트 insecure 설정이 더 필요함. 또 no_root_squash 옵션을 추가하여 pvc 볼륨 쓰기 권한을 root가 아닌 각 서비스별 권한을 가지도록 함. 
 
vi /etc/exportfs
# /etc/exports
/srv/nfs/shared *(rw,sync,no_subtree_check,no_root_squash,insecure)

sudo exportfs -ra
sudo systemctl restart nfs-kernel-server.service
```


## k8s node 설정 
```
참고: 모든 노드에 nfs-common 설치 
sudo apt update
sudo apt install nfs-common
```

```
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.8.0
```

## 정적  PVC 확인 방법 
```
#### nfs-sc StorageClass
# dynamic-pvc.yaml
# csi-nfs-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-nfs-sc
provisioner: nfs.csi.k8s.io
parameters:
  server: <NFS_SERVER_IP>
  share: /srv/nfs/kubedata


#### pvc.yaml
# dynamic-nfs-test-deployment.yaml
# csi-dynamic-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-dynamic-nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-nfs-sc


#### test Deployment 
# dynamic-nfs-test-deployment.yaml
# csi-dynamic-nfs-test-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csi-dynamic-nfs-test-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: csi-dynamic-nfs-test
  template:
    metadata:
      labels:
        app: csi-dynamic-nfs-test
    spec:
      containers:
      - name: csi-dynamic-nfs-test-container
        image: nginx
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: csi-dynamic-nfs-volume
      volumes:
      - name: csi-dynamic-nfs-volume
        persistentVolumeClaim:
          claimName: csi-dynamic-nfs-pvc
```

