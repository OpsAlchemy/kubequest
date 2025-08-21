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

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

########################################
# 6. Check system pods
########################################
kubectl get pods -n kube-flannel -o wide
kubectl get pods -n kube-system -o wide

