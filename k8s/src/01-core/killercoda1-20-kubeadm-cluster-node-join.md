kubeadm token create --print-join-command
kubeadm join 172.30.1.2:6443 --token ekr13o.9nq9z5pbxip0w1v9 --discovery-token-ca-cert-hash sha256:a6a509290240a52bf6e8776227b83b7fc69d4765636a8ec54988e2d0d919a4cc 
controlplane:~$ ^C
controlplane:~$ 


kubeadm certs renew apiserver

kubeadm certs renew scheduler.conf

kubeadm certs check-expiration e