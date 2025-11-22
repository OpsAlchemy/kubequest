https://killercoda.com/sachin/course/CKA/pod-issue-6

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get po
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   0/1     Pending   0          12s
controlplane:~$ k get po my-pod-cka -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"my-pod-cka","namespace":"default"},"spec":{"containers":[{"image":"nginx","name":"nginx-container","volumeMounts":[{"mountPath":"/var/www/html","name":"shared-storage"}]}],"volumes":[{"name":"shared-storage","persistentVolumeClaim":{"claimName":"my-pvc-cka"}}]}}
  creationTimestamp: "2025-09-07T02:36:11Z"
  generation: 1
  name: my-pod-cka
  namespace: default
  resourceVersion: "5183"
  uid: c6b5bcf6-1f99-4f58-811d-4cdd04f3893e
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx-container
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/www/html
      name: shared-storage
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-5lp88
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: my-pvc-cka
  - name: kube-api-access-5lp88
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2025-09-07T02:36:11Z"
    message: '0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims.
      preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.'
    reason: Unschedulable
    status: "False"
    type: PodScheduled
  phase: Pending
  qosClass: BestEffort
controlplane:~$ k get pvc
NAME         STATUS    VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc-cka   Pending   my-pv-cka   0                         standard       <unset>                 22s
controlplane:~$ k get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
my-pv-cka   100Mi      RWO            Retain           Available           standard       <unset>                          25s
controlplane:~$ k get pvc -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"my-pvc-cka","namespace":"default"},"spec":{"accessModes":["ReadWriteMany"],"resources":{"requests":{"storage":"100Mi"}},"storageClassName":"standard","volumeName":"my-pv-cka"}}
    creationTimestamp: "2025-09-07T02:36:11Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: my-pvc-cka
    namespace: default
    resourceVersion: "5180"
    uid: 0aa3eefb-fd11-4715-a42c-37fd61c430a9
  spec:
    accessModes:
    - ReadWriteMany
    resources:
      requests:
        storage: 100Mi
    storageClassName: standard
    volumeMode: Filesystem
    volumeName: my-pv-cka
  status:
    phase: Pending
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k edit pvc my-pvc-cka 
error: persistentvolumeclaims "my-pvc-cka" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-179015948.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-179015948.yaml --force
persistentvolumeclaim "my-pvc-cka" deleted
persistentvolumeclaim/my-pvc-cka replaced
controlplane:~$ k get po -w
NAME         READY   STATUS              RESTARTS   AGE
my-pod-cka   0/1     ContainerCreating   0          67s
my-pod-cka   1/1     Running             0          74s
^Ccontrolplane:~$ 