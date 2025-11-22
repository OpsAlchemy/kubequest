ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
    config.vm.box = "generic/ubuntu2204"

    config.vm.provider :libvirt do |lv|
        lv.cpus = 2
        lv.memory = 2048
    end

    config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__auto: true, rsync__exclude: [".git/", "node_modules/"]

    MASTER = <<-SHELL
        sudo kubeadm init \
        --pod-network-cidr=10.244.0.0/16 \
        --cri-socket=unix:///run/containerd/containerd.sock
        
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

        mkdir -p /home/vagrant/.kube
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        sudo chown vagrant:vagrant /home/vagrant/.kube/config

        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
        kubectl get pods -n kube-system -o wide
    SHELL

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

        KUBE_VERSION="1.33.2-1.1"
        sudo apt-get install -y kubelet=$KUBE_VERSION kubeadm=$KUBE_VERSION kubectl=$KUBE_VERSION
        sudo apt-mark hold kubelet kubeadm kubectl

        sudo sysctl -w net.ipv4.ip_forward=1
        sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf
        sudo sysctl -p
    SHELL

    REDIS_IP  = "192.168.56.11"
    MASTER_IP = "192.168.56.12"
    WORKER_IP = "192.168.56.13"

    config.vm.define "shared" do |shared|
        shared.vm.hostname = "shared"
        shared.vm.network "private_network", ip: REDIS_IP
        shared.vm.provision "shell", inline: <<-SHELL
            apt-get update -y
            apt-get install -y redis-server
            sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
            sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
            systemctl restart redis-server
        SHELL
    end

    config.vm.define "master" do |master|
        master.vm.hostname = "k8s-master"
        master.vm.network "private_network", ip: MASTER_IP
        master.vm.provision "shell", inline: COMMON
        master.vm.provision "shell", inline: MASTER
        master.vm.provision "shell", inline: <<-SHELL
            command=$(kubeadm token create --print-join-command)
            admin_conf=$(cat $HOME/.kube/config)

            sudo apt-get install -y redis-tools
            redis-cli -h #{REDIS_IP} set k8s_join_command "$command"
            redis-cli -h #{REDIS_IP} set k8s_admin_conf "$admin_conf"
        SHELL
    end

    config.vm.define "worker" do |worker|
        worker.vm.hostname = "k8s-worker"
        worker.vm.network "private_network", ip: WORKER_IP
        worker.vm.provision "shell", inline: COMMON
        worker.vm.provision "shell", inline: <<-SHELL
            sudo apt-get install -y redis-tools
            command=$(redis-cli -h #{REDIS_IP} get k8s_join_command)
            admin_conf=$(redis-cli -h #{REDIS_IP} get k8s_admin_conf)

            echo "$command" 
            echo "$admin_conf"

            mkdir -p /home/vagrant/.kube
            echo "$admin_conf" > /home/vagrant/.kube/config
            sudo chown vagrant:vagrant /home/vagrant/.kube/config
            echo "Joining the cluster with command: $command"
            sudo bash -c "$command" 2>&1 | tee /home/vagrant/setup.log
        SHELL
    end
end

