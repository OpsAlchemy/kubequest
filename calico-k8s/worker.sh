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
