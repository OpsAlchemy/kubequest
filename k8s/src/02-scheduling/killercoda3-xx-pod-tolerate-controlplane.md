https://killercoda.com/chadmcrowell/course/cka/add-toleration

controlplane:~$ k get no controlplane -o yaml | grep -A4 taints
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
status:
  addresses:
controlplane:~$ vi pod-tolerate.yaml
controlplane:~$ k apply -f pod-tolerate.yaml
pod/nginx created
controlplane:~$ cat pod-tolerate.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule" 
      
  containers:
  - image: nginx
    name: nginx
  nodeSelector:
    kubernetes.io/hostname: controlplane
controlplane:~$ k get pods
NAME    READY   STATUS              RESTARTS   AGE
nginx   0/1     ContainerCreating   0          4s
controlplane:~$ k get pod -w 
NAME    READY   STATUS              RESTARTS   AGE
nginx   0/1     ContainerCreating   0          9s
nginx   1/1     Running             0          12s
^Ccontrolplane:~$ k get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          17s   192.168.0.4   controlplane   <none>           <none>
controlplane:~$ 