# kubeadm Cluster Create & Upgrade

## Upgrade Order (Must Follow)

* Always upgrade **kubeadm first**
* Upgrade **control plane nodes before worker nodes**
* **kubelet must be upgraded manually** on every node

---

## Upgrade kubeadm

### Check Available Versions

```bash
apt-cache show kubeadm
```

### Install Specific kubeadm Version

```bash
apt-get install kubeadm=1.34.3-1.1
kubeadm version
```

---

## Upgrade the Control Plane

### See Upgrade Plan

```bash
kubeadm upgrade plan
```

### Apply Upgrade (Example Version)

```bash
kubeadm upgrade apply v1.34.1
```

---

## Upgrade kubelet and kubectl

```bash
apt-get install kubelet=1.34.1-1.1 kubectl=1.34.1-1.1
systemctl restart kubelet
```

---

## Create a Cluster (kubeadm init)

### Basic Init

```bash
kubeadm init --kubernetes-version=1.34.1
```

### Init with Pod Network CIDR

```bash
kubeadm init \
  --kubernetes-version=1.34.1 \
  --pod-network-cidr=192.168.0.0/16 \
  --ignore-preflight-errors=NumCPU,Mem
```

### Pod Network CIDR Notes

* Required for some CNIs (Calico, Flannel)
* Must be valid CIDR (0–255 per octet)
* Must not conflict with host or service CIDR

---

## Configure kubectl Access

```bash
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
```

If copying to another node:

```bash
scp /etc/kubernetes/admin.conf node-summer:/root/.kube/config
```

---

## Join Worker Nodes

### Generate Join Command

```bash
kubeadm token create --print-join-command
```

### Example Join

```bash
kubeadm join 172.30.1.2:6443 \
  --token m3qmx4.qa9c83ju82ru6njq \
  --discovery-token-ca-cert-hash sha256:4b0e1b1109e852de2f92bbb4bf0bdeae7616dd94ec1a35da21ba7ba83c0bb441
```

---
