https://killercoda.com/sachin/course/CKA/pod-log-1

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pod product -o yaml > pod.yaml
controlplane:~$ k create config tv --from-literal=tv=Sony
error: unknown flag: --from-literal
See 'kubectl create --help' for usage.
controlplane:~$ k create cm tv --from-literal=tv=Sony
configmap/tv created
controlplane:~$ vi pod.yaml
controlplane:~$ k delete pod product 
pod "product" deleted
k apply -f pod.yaml
controlplane:~$ k apply -f pod.yaml
pod/product created
controlplane:~$ k logs product
Sony Tv Is Good
controlplane:~$ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: f9bcbd552b308292730d95cb3acb3259929816a5af34c5ffee04ae3f95e22e59
    cni.projectcalico.org/podIP: 192.168.1.4/32
    cni.projectcalico.org/podIPs: 192.168.1.4/32
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"product","namespace":"default"},"spec":{"containers":[{"command":["sh","-c","echo 'Mi Tv Is Good' \u0026\u0026 sleep 3600"],"image":"busybox","name":"product-container"}]}}
  creationTimestamp: "2025-09-03T11:02:55Z"
  generation: 1
  name: product
  namespace: default
  resourceVersion: "3073"
  uid: b8d927b0-d2ec-44c5-a9e5-85c65dbed97a
spec:
  containers:
  - command:
    - sh
    - -c
    - echo "${TV} Tv Is Good" && sleep 3600
    image: busybox
    imagePullPolicy: Always
    env:
    - name: TV
      valueFrom:
        configMapKeyRef:
          key: tv
          name: tv
    name: product-container
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-kgml6
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node01
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
  - name: kube-api-access-kgml6
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
    lastTransitionTime: "2025-09-03T11:03:00Z"
    status: "True"
    type: PodReadyToStartContainers
  - lastProbeTime: null
    lastTransitionTime: "2025-09-03T11:02:55Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2025-09-03T11:03:00Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2025-09-03T11:03:00Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2025-09-03T11:02:55Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://6ce61defb56b4ec2a6e3ad3a1abcd48db1fe257a4543776171c53029c6839a22
    image: docker.io/library/busybox:latest
    imageID: docker.io/library/busybox@sha256:ab33eacc8251e3807b85bb6dba570e4698c3998eca6f0fc2ccb60575a563ea74
    lastState: {}
    name: product-container
    ready: true
    resources: {}
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2025-09-03T11:02:59Z"
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-kgml6
      readOnly: true
      recursiveReadOnly: Disabled
  hostIP: 172.30.2.2
  hostIPs:
  - ip: 172.30.2.2
  phase: Running
  podIP: 192.168.1.4
  podIPs:
  - ip: 192.168.1.4
  qosClass: BestEffort
  startTime: "2025-09-03T11:02:55Z"
controlplane:~$ 