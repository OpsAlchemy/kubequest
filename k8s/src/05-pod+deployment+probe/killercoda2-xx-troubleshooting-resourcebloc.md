https://killercoda.com/sachin/course/CKA/pod-issue-5

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ vi redis-pod.yaml
controlplane:~$ k apply -f redis-pod.yaml
pod/redis-pod created
controlplane:~$ cat redis-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: redis-pod
spec:
  containers:
    - name: redis-container
      image: redis:latest
  resources:
    requests:
      memory: "150Mi"
      cpu: "15m"
    limits:
      memory: "100Mi"
      cpu: "10m"
controlplane:~$ 