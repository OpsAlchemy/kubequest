controlplane:~$ k create label node controlplane --label=availability-zone=zone1
error: unknown flag: --label
See 'kubectl create --help' for usage.
controlplane:~$ k create label node controlplane availability-zone=zone1
error: Unexpected args: [label node controlplane availability-zone=zone1]
See 'kubectl create -h' for help and examples
controlplane:~$ k label node controlplane availability-zone=zone1
node/controlplane not labeled
controlplane:~$ ^C
controlplane:~$ kubectl label node controlplane availability-zone=zone1 --overwrite
kubectl get node controlplane --show-labels
node/controlplane not labeled
NAME           STATUS   ROLES           AGE   VERSION   LABELS
controlplane   Ready    control-plane   14d   v1.33.2   availability-zone=zone1,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
controlplane:~$ kubectl create namespace 012963bd

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: az1-pod
  namespace: 012963bd
spec:
  affinity:
    nodeAffinity:
      # hard requirement: schedule only on the controlplane node
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values: ["controlplane"]
      # soft preferences: zone1 weight 80, zone2 weight 20
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 80
        preference:
          matchExpressions:
          - key: availability-zone
            operator: In
            values: ["zone1"]
      - weight: 20
        preference:
          matchExpressions:
          - key: availability-zone
YAML- containerPort: 80one2"]
Error from server (AlreadyExists): namespaces "012963bd" already exists
pod/az1-pod created
controlplane:~$ kubectl get pod az1-pod -n 012963bd -o wide
kubectl describe pod az1-pod -n 012963bd | grep -A3 Affinity
NAME      READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
az1-pod   0/1     Pending   0          13s   <none>   <none>   <none>           <none>
controlplane:~$ k get pods
No resources found in default namespace.
controlplane:~$ ^C
controlplane:~$ kubectl get pod az1-pod -n 012963bd -o wide
NAME      READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
az1-pod   0/1     Pending   0          25s   <none>   <none>   <none>           <none>
controlplane:~$ kubectl get pod az1-pod -n 012963bd -o wide -w
NAME      READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
az1-pod   0/1     Pending   0          28s   <none>   <none>   <none>           <none>
^Ccontrolplane:~$ 