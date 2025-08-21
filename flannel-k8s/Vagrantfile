ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
    config.vm.box = "generic/ubuntu2204"

    config.vm.provider :libvirt do |lv|
        lv.cpus = 2
        lv.memory = 2048
    end

    config.vm.synced_folder ".", "/vagrant", disabled: true

    MASTER_IP   = "10.10.10.10"
    WORKER_IP   = "10.10.10.11"
    POD_CIDR    = "10.244.0.0/16"

    COMMON = <<-SHELL
        set -euo pipefail
        export DEBIAN_FRONTEND=noninteractive

        sudo apt update
        sudo apt-get install -y containerd
        sudo mkdir -p /etc/containerd
        containerd config default \
        | sed 's/SystemdCgroup = false/SystemdCgroup = true/' \
        | sed 's|sandbox_image = ".*"|sandbox_image = "registry.k8s.io/pause:3.10"|' \
        | sudo tee /etc/containerd/config.toml > /dev/null
        sudo systemctl restart containerd

        sudo swapoff -a

        sudo apt update
        sudo apt-get install -y apt-transport-https ca-certificates curl gpg
        sudo mkdir -p -m 755 /etc/apt/keyrings
        sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt-get update

        apt-cache madison kubelet
        apt-cache madison kubectl
        apt-cache madison kubeadm

        KUBE_VERSION="1.33.2-1.1"

        sudo apt-get install -y kubelet=$KUBE_VERSION kubeadm=$KUBE_VERSION kubectl=$KUBE_VERSION
        sudo apt-mark hold kubelet kubeadm kubectl

        sudo sysctl -w net.ipv4.ip_forward=1
        sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf
        sudo sysctl -p
    SHELL

    config.vm.define "master" do |master|
        master.vm.hostname = "k8s-master"
        master.vm.network "private_network", ip: MASTER_IP, libvirt__dhcp_enabled: false
        master.vm.provision "shell", inline: COMMON
    end

    config.vm.define "worker" do |worker|
        worker.vm.hostname = "k8s-worker"
        worker.vm.network "private_network", ip: WORKER_IP, libvirt__dhcp_enabled: false
        worker.vm.provision "shell", inline: COMMON
    end
end
