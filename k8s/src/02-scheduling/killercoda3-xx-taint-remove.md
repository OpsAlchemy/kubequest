https://killercoda.com/chadmcrowell/course/cka/remove-taint


controlplane:~$ k get node  
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   14d   v1.33.2
node01         Ready    <none>          14d   v1.33.2
controlplane:~$ cat <<EOF | kubectl apply -f -
> apiVersion: v1
> kind: Pod
> metadata:
>   creationTimestamp: null
>   labels:
>     run: nginx
>   name: nginx
> spec:
>   containers:
>   - image: nginx
>     name: nginx
>   nodeSelector:
>     kubernetes.io/hostname: controlplane
> EOF
pod/nginx created
controlplane:~$ 
controlplane:~$ k get po -wide   
error: unknown shorthand flag: 'i' in -ide
See 'kubectl get --help' for usage.
controlplane:~$ k get po -w
NAME    READY   STATUS    RESTARTS   AGE
nginx   0/1     Pending   0          22s
^Ccontrolplane:~$ # get the pod to run on the control plane by removing the taint
controlplane:~$ kubectl taint no controlplane node-role.kubernetes.io/control-plane:NoSchedule-
node/controlplane untainted
controlplane:~$ # check to see if the pod is now running and scheduled to the control plane node
controlplane:~$ kubectl get po -o wide
NAME    READY   STATUS              RESTARTS   AGE   IP       NODE           NOMINATED NODE   READINESS GATES
nginx   0/1     ContainerCreating   0          48s   <none>   controlplane   <none>           <none>
controlplane:~$ # describe the pod to see why the pod is in a pending state
controlplane:~$ kubectl describe po nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             controlplane/172.30.1.2
Start Time:       Tue, 02 Sep 2025 17:12:54 +0000
Labels:           run=nginx
Annotations:      cni.projectcalico.org/containerID: 5d6e5553869c6c7dc7ba336806ff329cda501ac695a3d743899d4f22606638a2
                  cni.projectcalico.org/podIP: 192.168.0.4/32
                  cni.projectcalico.org/podIPs: 192.168.0.4/32
Status:           Pending
IP:               
IPs:              <none>
Containers:
  nginx:
    Container ID:   
    Image:          nginx
    Image ID:       
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-rchsw (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   False 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-rchsw:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              kubernetes.io/hostname=controlplane
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  52s   default-scheduler  0/2 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
  Normal   Scheduled         6s    default-scheduler  Successfully assigned default/nginx to controlplane
  Normal   Pulling           6s    kubelet            Pulling image "nginx"
controlplane:~$ # describe the controlplane node to view the taint applied
controlplane:~$ kubectl describe no controlplane | grep Taint
Taints:             <none>
controlplane:~$ # check to see if the pod is now running and scheduled to the control plane node
controlplane:~$ kubectl get po -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          57s   192.168.0.4   controlplane   <none>           <none>
controlplane:~$ 