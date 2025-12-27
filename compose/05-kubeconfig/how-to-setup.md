kubectl config set-cluster kubernetes --server=https://172.30.1.2:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt
kubectl config set-credentials kubelet --token=m3qmx4.qa9c83ju82ru6njq
kubectl config set-context default --cluster=kubernetes --user=kubelet
kubectl config use-context default