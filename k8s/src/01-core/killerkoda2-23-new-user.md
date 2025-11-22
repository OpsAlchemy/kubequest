controlplane:~$ k create ns web
namespace/web created
controlplane:~$ k -n web create role pod-reader --verb=get,list --resource=pods
role.rbac.authorization.k8s.io/pod-reader created
controlplane:~$ k -n web create rolebinding pod-reader-binding --role=pod-reader --user=carlton
rolebinding.rbac.authorization.k8s.io/pod-reader-binding created
controlplane:~$ k -n web run pod1 --image=nginx
pod/pod1 created
controlplane:~$ openssl genrsa -out carlton.key 2048
controlplane:~$ openssl req -new -key carlton.key -subj "/CN=carlton" -out carlton.csr
controlplane:~$ ls   
carlton.csr  carlton.key  filesystem
controlplane:~$ export REQUEST=$(cat carlton.csr | base64 -w 0)
controlplane:~$ echo $REQUEST
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1Z6Q0NBVDhDQVFBd0VqRVFNQTRHQTFVRUF3d0hZMkZ5YkhSdmJqQ0NBU0l3RFFZSktvWklodmNOQVFFQgpCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFNY1gzazIxU3FDcWpKRkhzOFFicjBUeEFXVlZKZ24yMHQyYnhiOStQUzVmCmRhWVN3TTFPZWxEWFM1M1dBSERoM2twTnB2MGJjeUxNR1hlNFZna3NEZ0lyTUdVYlhkTllCVTlRczExWUw2ZkQKRDhjbEVNS3h0elY1bVBud3IrVW8vMGs2OXVWQmx5d2NCTDJDS2RwS3dKRStzWVZkRDVsWGhOZnpJZGxYamtUQgpGTWRJK0VOM2dGS0JEVUxCdU93V0xiQ2RzbkJoNVc3aTE2SjVxTWx0a0xldnN0UGs3bGIxeUdVYzM1b3UxSng0CkROUjF3UjhWOW5jRVZwTFV5NU9saXZZTWRVbzdWZUdJTFByeldkN2JyRVJic3dJc3VlQVpNdmZMRytrSy9jbTcKZjZpbjgva2dwYUNQWVZaVVhWSkpsamttaGpwWUhkbHFHR25kcU1kODJPMENBd0VBQWFBQU1BMEdDU3FHU0liMwpEUUVCQ3dVQUE0SUJBUUNOdnJsS0k4N3AwZmZsVkVqdmFxZmxOYXBQaUpNaVhiZzJtcXVWUGVSOGwrY0xxSEhMCkJxQkpxOW9WbVJTQ0xTSlJmQW0rRWJQTDdLRVI3MkMzQTFUYlY1bERldmh1UHF6WEF2VWF2M2ZkNXEyRE9wKzQKQzRsSVdsVmh6U0I1OVFIZlN6UVIrMVRsaW5KKzFrY2ZOOXFmNTc5OWR6R1ZLMk9WQjZNd1g0enpVYkd1b0hZYwo5WW9ndDBxNi9UVEFjSm5FVFBiRlloWUx1b1FtMUJUc1dtVGMzWlZTcjZWU2dlUWdObEFFY3g3K09YeVhyczBaCmhadm5yd3VDUCtnVXRRZzkwU0x3VGlxZU1KT3F6MzVsNFVmdUkxcWFoMEFaYlFoSm5lVkFrTlNNRkZNUUJhYVQKdmppY21udytPVThWcmk0NlNUZTZIUldlenRKOE1VNEExS09ZCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
controlplane:~$ cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: carlton
spec:
  groups:
  - system:authenticated
  request: $REQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
certificatesigningrequest.certificates.k8s.io/carlton created
controlplane:~$ k get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
carlton     9s    kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Pending
csr-c5vhd   14d   kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued
controlplane:~$ k certificate approve carlton
certificatesigningrequest.certificates.k8s.io/carlton approved
controlplane:~$ k get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
carlton     36s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
csr-c5vhd   14d   kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued
controlplane:~$ k get csr carlton -o jsonpath='{.status.certificate}' | base64 -d > carlton.crt
controlplane:~$ k config set-credentials carlton --client-key=carlton.key --client-certificate=carlton.crt --embed-certs
User "carlton" set.
controlplane:~$ k config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://172.30.1.2:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: carlton
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
controlplane:~$ k config use-context carlton
error: no context exists with the name: "carlton"
controlplane:~$ k config set-context carlton --user=carlton --cluster=kubernetes
Context "carlton" created.
controlplane:~$ k config use-context carlton
Switched to context "carlton".
controlplane:~$ k -n web get po
NAME   READY   STATUS    RESTARTS   AGE
pod1   1/1     Running   0          3m21s
controlplane:~$ 



https://killercoda.com/chadmcrowell/course/cka/kubernetes-create-user