https://killercoda.com/chadmcrowell/course/cka/cordon-drain-node


controlplane:~$ k get pods
No resources found in default namespace.
controlplane:~$ k get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   14d   v1.33.2
node01         Ready    <none>          14d   v1.33.2
controlplane:~$ k cordon -h
Mark node as unschedulable.

Examples:
  # Mark node "foo" as unschedulable
  kubectl cordon foo

Options:
    --dry-run='none':
        Must be "none", "server", or "client". If client strategy, only print the object that
        would be sent, without sending it. If server strategy, submit server-side request without
        persisting the resource.

    -l, --selector='':
        Selector (label query) to filter on, supports '=', '==', '!=', 'in', 'notin'.(e.g. -l
        key1=value1,key2=value2,key3 in (value3)). Matching objects must satisfy all of the
        specified label constraints.

Usage:
  kubectl cordon NODE [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
controlplane:~$ k cordon node01
node/node01 cordoned
controlplane:~$ ^C
controlplane:~$ k get pods -o wide
No resources found in default namespace.
controlplane:~$ k get pods -o wide -A
NAMESPACE            NAME                                      READY   STATUS    RESTARTS       AGE    IP            NODE           NOMINATED NODE   READINESS GATES
012963bd             nginx-5869d7778c-4d5hr                    1/1     Running   0              104s   192.168.1.5   node01         <none>           <none>
012963bd             nginx-5869d7778c-6bnch                    1/1     Running   0              104s   192.168.0.5   controlplane   <none>           <none>
012963bd             nginx-5869d7778c-6ksn2                    1/1     Running   0              104s   192.168.1.4   node01         <none>           <none>
012963bd             nginx-5869d7778c-lrmdg                    1/1     Running   0              103s   192.168.0.4   controlplane   <none>           <none>
012963bd             nginx-5869d7778c-vgxrt                    1/1     Running   0              103s   192.168.1.6   node01         <none>           <none>
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   2 (8m3s ago)   14d    192.168.0.2   controlplane   <none>           <none>
kube-system          canal-5q8x5                               2/2     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
kube-system          canal-hvvtk                               2/2     Running   2 (8m5s ago)   14d    172.30.2.2    node01         <none>           <none>
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running   1 (8m5s ago)   14d    192.168.1.2   node01         <none>           <none>
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running   1 (8m5s ago)   14d    192.168.1.3   node01         <none>           <none>
kube-system          etcd-controlplane                         1/1     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
kube-system          kube-apiserver-controlplane               1/1     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
kube-system          kube-controller-manager-controlplane      1/1     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
kube-system          kube-proxy-7kdz8                          1/1     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (8m5s ago)   14d    172.30.2.2    node01         <none>           <none>
kube-system          kube-scheduler-controlplane               1/1     Running   2 (8m3s ago)   14d    172.30.1.2    controlplane   <none>           <none>
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running   2 (8m3s ago)   14d    192.168.0.3   controlplane   <none>           <none>
controlplane:~$ k drain node01 --ignore-daemonsets
node/node01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/canal-hvvtk, kube-system/kube-proxy-lg8cx
evicting pod kube-system/coredns-6ff97d97f9-hcn7j
evicting pod 012963bd/nginx-5869d7778c-4d5hr
evicting pod 012963bd/nginx-5869d7778c-6ksn2
evicting pod 012963bd/nginx-5869d7778c-vgxrt
evicting pod kube-system/coredns-6ff97d97f9-gq4nd
pod/nginx-5869d7778c-6ksn2 evicted
pod/nginx-5869d7778c-4d5hr evicted
pod/nginx-5869d7778c-vgxrt evicted
pod/coredns-6ff97d97f9-hcn7j evicted
pod/coredns-6ff97d97f9-gq4nd evicted
node/node01 drained
controlplane:~$ k get po -o wide -A | grep node01
kube-system          canal-hvvtk                               2/2     Running   2 (8m56s ago)   14d     172.30.2.2     node01         <none>           <none>
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (8m56s ago)   14d     172.30.2.2     node01         <none>           <none>
controlplane:~$ k get po -o wide -A | grep node01
kube-system          canal-hvvtk                               2/2     Running   2 (9m ago)      14d     172.30.2.2     node01         <none>           <none>
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (9m ago)      14d     172.30.2.2     node01         <none>           <none>
controlplane:~$ k get po -o wide -A | grep node01
kube-system          canal-hvvtk                               2/2     Running   2 (9m4s ago)   14d     172.30.2.2     node01         <none>           <none>
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (9m4s ago)   14d     172.30.2.2     node01         <none>           <none>
controlplane:~$ # evict the pods that are running on node01
controlplane:~$ kubectl drain node01 --ignore-daemonsets
node/node01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/canal-hvvtk, kube-system/kube-proxy-lg8cx
node/node01 drained
controlplane:~$ 
controlplane:~$ # verify that there are no pods running on node01
controlplane:~$ kubectl get po -o wide | grep node01
No resources found in default namespace.
controlplane:~$ 
controlplane:~$ # mark the node scheduleable once again
controlplane:~$ kubectl uncordon node01
node/node01 uncordoned
controlplane:~$ 
controlplane:~$ 
controlplane:~$ 