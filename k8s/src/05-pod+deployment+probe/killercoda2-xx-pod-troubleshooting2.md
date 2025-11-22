controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get po frontend -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"frontend","namespace":"default"},"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"NodeName","operator":"In","values":["frontend"]}]}]}}},"containers":[{"image":"nginx:latest","name":"my-container"}]}}
  creationTimestamp: "2025-09-07T02:24:33Z"
  generation: 1
  name: frontend
  namespace: default
  resourceVersion: "5465"
  uid: 95ccf15a-ebeb-4135-a4aa-dc95237460d3
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: NodeName
            operator: In
            values:
            - frontend
  containers:
  - image: nginx:latest
    imagePullPolicy: Always
    name: my-container
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-4nmnj
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
  - name: kube-api-access-4nmnj
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
    lastTransitionTime: "2025-09-07T02:24:33Z"
    message: '0/2 nodes are available: 1 node(s) didn''t match Pod''s node affinity/selector,
      1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }. preemption:
      0/2 nodes are available: 2 Preemption is not helpful for scheduling.'
    reason: Unschedulable
    status: "False"
    type: PodScheduled
  phase: Pending
  qosClass: BestEffort
controlplane:~$ k get no
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   18d   v1.33.2
node01         Ready    <none>          18d   v1.33.2
controlplane:~$ k get no | grep -A10 -B10 -i taints
controlplane:~$ k get no -o yaml | grep -A10 -B10 -i taints
      kubernetes.io/os: linux
      node-role.kubernetes.io/control-plane: ""
      node.kubernetes.io/exclude-from-external-load-balancers: ""
    name: controlplane
    resourceVersion: "5339"
    uid: fa72abf6-d70b-4fcf-976d-5c874b24ef4d
  spec:
    podCIDR: 192.168.0.0/24
    podCIDRs:
    - 192.168.0.0/24
    taints:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
  status:
    addresses:
    - address: 172.30.1.2
      type: InternalIP
    - address: controlplane
      type: Hostname
    allocatable:
      cpu: "1"
controlplane:~$ k get no -o yaml | grep -A10 -B10 -i taints^C
controlplane:~$ k get no node01-o yaml | grep -A10 -B10 -i taints
Error from server (NotFound): nodes "node01-o" not found
Error from server (NotFound): nodes "yaml" not found
controlplane:~$ k get no node01 -o yaml | grep -A10 -B10 -i taints
controlplane:~$ k get no
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   18d   v1.33.2
node01         Ready    <none>          18d   v1.33.2
controlplane:~$ k label node01 NodeName=frontned
error: the server doesn't have a resource type "node01"
controlplane:~$ k label node node01 NodeName=frontend
error: 'NodeName' already has a value (frontendnodes), and --overwrite is false
controlplane:~$ k label node node01 NodeName=frontend --overwrite
node/node01 labeled
controlplane:~$ k get po -w
NAME       READY   STATUS              RESTARTS   AGE
frontend   0/1     ContainerCreating   0          3m10s
frontend   1/1     Running             0          3m17s

https://killercoda.com/sachin/course/CKA/pod-issue-3