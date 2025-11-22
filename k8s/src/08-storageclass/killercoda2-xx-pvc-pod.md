https://killercoda.com/sachin/course/CKA/pvc-pod

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pvc
No resources found in default namespace.
controlplane:~$ k get pv
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
nginx-pv-cka   100Mi      RWO            Retain           Available           nginx-stc-cka   <unset>                          63s
controlplane:~$ k get pv nginx-pv-cka -o yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"PersistentVolume","metadata":{"annotations":{},"name":"nginx-pv-cka"},"spec":{"accessModes":["ReadWriteOnce"],"capacity":{"storage":"100Mi"},"local":{"path":"/opt/nginx-data-cka"},"nodeAffinity":{"required":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/hostname","operator":"In","values":["controlplane"]}]}]}},"storageClassName":"nginx-stc-cka"}}
  creationTimestamp: "2025-09-07T00:20:55Z"
  finalizers:
  - kubernetes.io/pv-protection
  name: nginx-pv-cka
  resourceVersion: "9890"
  uid: 10389324-83a3-4690-a112-8e26216b19a0
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  local:
    path: /opt/nginx-data-cka
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - controlplane
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nginx-stc-cka
  volumeMode: Filesystem
status:
  lastPhaseTransitionTime: "2025-09-07T00:20:55Z"
  phase: Available
controlplane:~$ vi nginx-pvc-cka.yaml
controlplane:~$ k apply -f nginx-pvc-cka.yaml 
The PersistentVolumeClaim "nginx-pvc-cka" is invalid: spec.resources[storage]: Required value
controlplane:~$ nvim
Command 'nvim' not found, but can be installed with:
apt install neovim
controlplane:~$ vi nginx-pvc-cka.yaml 
controlplane:~$ vi nginx-pvc-cka.yaml
controlplane:~$ k apply -f nginx-pvc-cka.yaml 
persistentvolumeclaim/nginx-pvc-cka created
controlplane:~$ k get pvc nginx-pvc-cka -o ymal
error: unable to match a printer suitable for the output format "ymal", allowed formats are: custom-columns,custom-columns-file,go-template,go-template-file,json,jsonpath,jsonpath-as-json,jsonpath-file,name,template,templatefile,wide,yaml
controlplane:~$ k get pvc nginx-pvc-cka -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"nginx-pvc-cka","namespace":"default"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"80Mi"}},"storageClassName":"nginx-stc-cka","volumeName":"nginx-pv-cka"}}
    pv.kubernetes.io/bind-completed: "yes"
  creationTimestamp: "2025-09-07T00:25:25Z"
  finalizers:
  - kubernetes.io/pvc-protection
  name: nginx-pvc-cka
  namespace: default
  resourceVersion: "10272"
  uid: ff2ecb36-566c-4522-b983-07c587f93cbc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 80Mi
  storageClassName: nginx-stc-cka
  volumeMode: Filesystem
  volumeName: nginx-pv-cka
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  phase: Bound
controlplane:~$ k get pvc
NAME            STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
nginx-pvc-cka   Bound    nginx-pv-cka   100Mi      RWO            nginx-stc-cka   <unset>                 22s
controlplane:~$ k get pv
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS    VOLUMEATTRIBUTESCLASS   REASON   AGE
nginx-pv-cka   100Mi      RWO            Retain           Bound    default/nginx-pvc-cka   nginx-stc-cka   <unset>                          5m11s
controlplane:~$ k get sc
NAME                   PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path          Delete          WaitForFirstConsumer   false                  18d
nginx-stc-cka          kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   true                   5m20s
controlplane:~$ vi pod.yaml
controlplane:~$ k get pod
No resources found in default namespace.
controlplane:~$ ls
filesystem  nginx-pod-cka.yaml  nginx-pvc-cka.yaml
controlplane:~$ vi nginx-pod-cka.yaml 
controlplane:~$ k apply -f nginx-pod-cka.yaml --dry-run=client
pod/nginx-pod-cka created (dry run)
controlplane:~$ k apply -f nginx-pod-cka.yal
error: the path "nginx-pod-cka.yal" does not exist
controlplane:~$ k apply -f nginx-pod-cka.yaml
pod/nginx-pod-cka created
controlplane:~$ k get pods -w
NAME            READY   STATUS              RESTARTS   AGE
nginx-pod-cka   0/1     ContainerCreating   0          4s
nginx-pod-cka   1/1     Running             0          9s
^Ccontrolplane:~$ ls
filesystem  nginx-pod-cka.yaml  nginx-pvc-cka.yaml
controlplane:~$ cat *
cat: filesystem: Is a directory
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-cka
spec:
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule" 
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: nginx-pvc-cka
  containers:
    - name: my-container
      image: nginx:latest
      volumeMounts:
      - name: shared-storage
        mountPath: /var/www/html
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc-cka
spec:
  accessModes:
  - ReadWriteOnce
  volumeName: nginx-pv-cka
  storageClassName: nginx-stc-cka
  resources:
    requests:
      storage: 80Mi
  
controlplane:~$ 