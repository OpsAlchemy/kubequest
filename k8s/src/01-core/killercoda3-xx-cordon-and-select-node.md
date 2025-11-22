https://killercoda.com/chadmcrowell/course/cka/nodeselector-cordon

controlplane:~$ k ge tno

error: unknown command "ge" for "kubectl"

Did you mean this?
        set
        get
        cp
controlplane:~$ k get no
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   14d   v1.33.2
node01         Ready    <none>          14d   v1.33.2
controlplane:~$ k cordon node01
node/node01 cordoned
controlplane:~$ k run nginx --image nginx
pod/nginx created
controlplane:~$ k get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          3s
controlplane:~$ k get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          8s    192.168.0.6   controlplane   <none>           <none>
controlplane:~$ k get pod nginx -o yaml > pod.yaml
controlplane:~$ vi pod.yaml
controlplane:~$ k delete pod ngin
Error from server (NotFound): pods "ngin" not found
controlplane:~$ k delete pod nginx
pod "nginx" deleted
controlplane:~$ k apply -f pod.yaml
pod/nginx created
controlplane:~$ k get pod -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/containerID: 1744416516788abb66af4b76e849a3d2f415754f33b84f2be1f8a62094b861c4
      cni.projectcalico.org/podIP: 192.168.1.7/32
      cni.projectcalico.org/podIPs: 192.168.1.7/32
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{"cni.projectcalico.org/containerID":"be973df230af965f2bc541d57ff876113f83e79ad326035cbcd029eebdd3ec27","cni.projectcalico.org/podIP":"192.168.0.6/32","cni.projectcalico.org/podIPs":"192.168.0.6/32"},"creationTimestamp":"2025-09-02T17:01:53Z","generation":1,"labels":{"run":"nginx"},"name":"nginx","namespace":"default","resourceVersion":"3296","uid":"a21afba9-47db-4050-97a8-ca12a43b5d5a"},"spec":{"containers":[{"image":"nginx","imagePullPolicy":"Always","name":"nginx","resources":{},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","volumeMounts":[{"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount","name":"kube-api-access-kkp4w","readOnly":true}]}],"dnsPolicy":"ClusterFirst","enableServiceLinks":true,"nodeName":"node01","preemptionPolicy":"PreemptLowerPriority","priority":0,"restartPolicy":"Always","schedulerName":"default-scheduler","securityContext":{},"serviceAccount":"default","serviceAccountName":"default","terminationGracePeriodSeconds":30,"tolerations":[{"effect":"NoExecute","key":"node.kubernetes.io/not-ready","operator":"Exists","tolerationSeconds":300},{"effect":"NoExecute","key":"node.kubernetes.io/unreachable","operator":"Exists","tolerationSeconds":300}],"volumes":[{"name":"kube-api-access-kkp4w","projected":{"defaultMode":420,"sources":[{"serviceAccountToken":{"expirationSeconds":3607,"path":"token"}},{"configMap":{"items":[{"key":"ca.crt","path":"ca.crt"}],"name":"kube-root-ca.crt"}},{"downwardAPI":{"items":[{"fieldRef":{"apiVersion":"v1","fieldPath":"metadata.namespace"},"path":"namespace"}]}}]}}]},"status":{"conditions":[{"lastProbeTime":null,"lastTransitionTime":"2025-09-02T17:01:55Z","status":"True","type":"PodReadyToStartContainers"},{"lastProbeTime":null,"lastTransitionTime":"2025-09-02T17:01:53Z","status":"True","type":"Initialized"},{"lastProbeTime":null,"lastTransitionTime":"2025-09-02T17:01:55Z","status":"True","type":"Ready"},{"lastProbeTime":null,"lastTransitionTime":"2025-09-02T17:01:55Z","status":"True","type":"ContainersReady"},{"lastProbeTime":null,"lastTransitionTime":"2025-09-02T17:01:53Z","status":"True","type":"PodScheduled"}],"containerStatuses":[{"containerID":"containerd://62ee4e834648adbc61115f547d1584569661379b6e80f3aae837c0a050f92bb1","image":"docker.io/library/nginx:latest","imageID":"docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57","lastState":{},"name":"nginx","ready":true,"resources":{},"restartCount":0,"started":true,"state":{"running":{"startedAt":"2025-09-02T17:01:55Z"}},"volumeMounts":[{"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount","name":"kube-api-access-kkp4w","readOnly":true,"recursiveReadOnly":"Disabled"}]}],"hostIP":"172.30.1.2","hostIPs":[{"ip":"172.30.1.2"}],"phase":"Running","podIP":"192.168.0.6","podIPs":[{"ip":"192.168.0.6"}],"qosClass":"BestEffort","startTime":"2025-09-02T17:01:53Z"}}
    creationTimestamp: "2025-09-02T17:03:12Z"
    generation: 1
    labels:
      run: nginx
    name: nginx
    namespace: default
    resourceVersion: "3421"
    uid: 416a30ab-d9a2-48e9-837e-b4fc2efb093e
  spec:
    containers:
    - image: nginx
      imagePullPolicy: Always
      name: nginx
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-kkp4w
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
    - name: kube-api-access-kkp4w
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
      lastTransitionTime: "2025-09-02T17:03:14Z"
      status: "True"
      type: PodReadyToStartContainers
    - lastProbeTime: null
      lastTransitionTime: "2025-09-02T17:03:12Z"
      status: "True"
      type: Initialized
    - lastProbeTime: null
      lastTransitionTime: "2025-09-02T17:03:14Z"
      status: "True"
      type: Ready
    - lastProbeTime: null
      lastTransitionTime: "2025-09-02T17:03:14Z"
      status: "True"
      type: ContainersReady
    - lastProbeTime: null
      lastTransitionTime: "2025-09-02T17:03:12Z"
      status: "True"
      type: PodScheduled
    containerStatuses:
    - containerID: containerd://751a295d736c9ec02161a4b537a5ec10b73b35a610206d5276d781fa2f57c76e
      image: docker.io/library/nginx:latest
      imageID: docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
      lastState: {}
      name: nginx
      ready: true
      resources: {}
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2025-09-02T17:03:14Z"
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-kkp4w
        readOnly: true
        recursiveReadOnly: Disabled
    hostIP: 172.30.2.2
    hostIPs:
    - ip: 172.30.2.2
    phase: Running
    podIP: 192.168.1.7
    podIPs:
    - ip: 192.168.1.7
    qosClass: BestEffort
    startTime: "2025-09-02T17:03:12Z"
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          16s   192.168.1.7   node01   <none>           <none>
controlplane:~$ 