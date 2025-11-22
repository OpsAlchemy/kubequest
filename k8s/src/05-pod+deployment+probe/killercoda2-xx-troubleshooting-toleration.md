controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ vi application-deployment.yaml 
controlplane:~$ k get node node01 -o yaml | grep -A10 -B10 taints
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: node01
    kubernetes.io/os: linux
  name: node01
  resourceVersion: "4985"
  uid: d695cd3c-67a1-4a88-840b-6cab651d5b5d
spec:
  podCIDR: 192.168.1.0/24
  podCIDRs:
  - 192.168.1.0/24
  taints:
  - effect: NoSchedule
    key: nodeName
    value: workerNode01
status:
  addresses:
  - address: 172.30.2.2
    type: InternalIP
  - address: node01
    type: Hostname
  allocatable:
controlplane:~$ vi po^C
controlplane:~$ vi         
.ICEauthority                .dbus/                       .profile                     .wget-hsts
.Xauthority                  .gnupg/                      .ssh/                        application-deployment.yaml
.bash_history                .gvfs/                       .theia/                      filesystem/
.bashrc                      .kube/                       .viminfo                     
.cache/                      .local/                      .vimrc                       
.config/                     .mozilla/                    .vnc/                        
controlplane:~$ vi application-deployment.yaml 
controlplane:~$ k apply -f application-deployment.yaml --dry-run=server
pod/redis-pod created (server dry run)
controlplane:~$ k apply -f application-deployment.yaml 
pod/redis-pod created
controlplane:~$ k get po -w
NAME        READY   STATUS              RESTARTS   AGE
redis-pod   0/1     ContainerCreating   0          2s
redis-pod   1/1     Running             0          9s
^Ccontrolplane:~$ ls
application-deployment.yaml  filesystem
controlplane:~$ cat application-deployment.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: redis-pod
spec:
  tolerations:
  - key: nodeName
    operator: "Equal"
    value: workerNode01
    effect: NoSchedule
  containers:
    - name: redis-container
      image: redis:latest
      ports:
        - containerPort: 6379
controlplane:~$ 

https://killercoda.com/sachin/course/CKA/pod-issue-7