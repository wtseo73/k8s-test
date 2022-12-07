# Base Image
BOX_IMAGE = "ubuntu/focal64"
BOX_VERSION = "20210831.0.0"

# max number of worker nodes
N = 3

# ssh config
$ssh_config = <<-SCRIPT
  echo ">>>> root password <<<<<<"
  printf "qwe123\nqwe123\n" | passwd

  echo ">>>> ssh-config <<<<<<"
  sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
SCRIPT

Vagrant.configure("2") do |config|
#-----Manager Node
    config.vm.define "k8s-m" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      config.vm.box_version = BOX_VERSION
      subconfig.vm.provider "virtualbox" do |v|
        v.name = "k8s-m"
        v.memory = 2048
        v.cpus = 2
        v.linked_clone = true
      end
      subconfig.vm.hostname = "k8s-m"
      subconfig.vm.synced_folder "./", "/vagrant", disabled: true
      subconfig.vm.network "private_network", ip: "192.168.56.10"
      subconfig.vm.network "forwarded_port", guest: 22, host: 50010, auto_correct: true, id: "ssh"
      subconfig.vm.provision "shell", inline: $ssh_config
      subconfig.vm.provision "shell", path: "https://raw.githubusercontent.com/wtseo73/k8s-test/main/init_cfg.sh", args: N
      subconfig.vm.provision "shell", path: "https://raw.githubusercontent.com/wtseo73/k8s-test/main/master.sh"
    end

#-----Worker Node
  (1..N).each do |i|
    config.vm.define "k8s-w#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      config.vm.box_version = BOX_VERSION
      subconfig.vm.provider "virtualbox" do |v|
        v.name = "k8s-w#{i}"
        v.memory = 1536
        v.cpus = 2
        v.linked_clone = true
      end
      subconfig.vm.hostname = "k8s-w#{i}"
      subconfig.vm.synced_folder "./", "/vagrant", disabled: true
      subconfig.vm.network "private_network", ip: "192.168.56.10#{i}"
      subconfig.vm.network "forwarded_port", guest: 22, host: "5001#{i}", auto_correct: true, id: "ssh"
      subconfig.vm.provision "shell", inline: $ssh_config
      subconfig.vm.provision "shell", path: "https://raw.githubusercontent.com/wtseo73/k8s-test/main/init_cfg.sh", args: N
      subconfig.vm.provision "shell", path: "https://raw.githubusercontent.com/wtseo73/k8s-test/main/worker.sh"
    end
  end

end
