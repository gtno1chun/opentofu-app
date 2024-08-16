## NFS 설치 및 구성 

#### nfs server 설치 
```
Vagrantfile 에 있는 폴더에서 아래 명령 수행. 
$ vagrant up
```
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

nfs 서버 IP    : 192.168.56.10 

client 서버 IP : 192.168.56.101 ~ 103 

client 서버 IP : 192.168.58.101 ~ 103  -> nfs server와 서브넷 대역이 다름, 라우터 설정해도 안됨 : insecure 옵션 추가 후 정상 동작  (rw,sync,no_subtree_check,insecure)

```
참고 : 서브넷이 다른 클라언트 insecure 설정이 더 필요함. 
vi /etc/exportfs
/srv/nfs/shared *(rw,sync,no_subtree_check,insecure)

sudo exportfs -ra
sudo systemctl restart nfs-kernel-server.service
```


