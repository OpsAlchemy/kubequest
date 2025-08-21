########################################
# ⚠️ RUN ONLY ON THE CONTROL PLANE NODE #
########################################

# 1. Initialize the cluster using containerd
# --cri-socket must use unix:// prefix
# --pod-network-cidr=10.244.0.0/16 is required for Flannel
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock

########################################
# 2. HOW TO RESET IF NEEDED
########################################
# sudo kubeadm reset --cri-socket=unix:///run/containerd/containerd.sock -f
# sudo rm -rf /etc/kubernetes /var/lib/etcd $HOME/.kube

########################################
# 3. Configure kubectl for the current user
########################################
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

########################################
# 4. Kernel modules & sysctl for Flannel
########################################
# Load required kernel modules
echo "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf
echo "overlay" | sudo tee -a /etc/modules-load.d/br_netfilter.conf
sudo modprobe br_netfilter
sudo modprobe overlay

# Enable required sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

########################################
# 5. Install Flannel CNI
########################################
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

########################################
# 6. Check system pods
########################################
kubectl get pods -n kube-flannel -o wide
kubectl get pods -n kube-system -o wide

