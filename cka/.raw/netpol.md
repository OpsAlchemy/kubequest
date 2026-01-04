# controlplane:~$ k get ns --show-labels
# NAME                 STATUS   AGE    LABELS
# default              Active   25d    kubernetes.io/metadata.name=default
# kube-node-lease      Active   25d    kubernetes.io/metadata.name=kube-node-lease
# kube-public          Active   25d    kubernetes.io/metadata.name=kube-public
# kube-system          Active   25d    kubernetes.io/metadata.name=kube-system
# local-path-storage   Active   25d    kubernetes.io/metadata.name=local-path-storage
# space1               Active   7m5s   kubernetes.io/metadata.name=space1
# space2               Active   7m5s   kubernetes.io/metadata.name=space2
# controlplane:~$ vi sol.yaml
# controlplane:~$ k apply -f sol.yaml
# networkpolicy.networking.k8s.io/np created
# controlplane:~$ vi sol.yaml
# controlplane:~$ alias kaf="k apply -f"
# controlplane:~$ 
# controlplane:~$ kaf sol.yamol
# error: the path "sol.yamol" does not exist
# controlplane:~$ kaf sol.yaml
# networkpolicy.networking.k8s.io/np configured
# controlplane:~$ cp sol.yaml sol1.yaml
# controlplane:~$ vi sol1.yaml 
# controlplane:~$ kaf sol1.yaml
# Error from server (BadRequest): error when creating "sol1.yaml": NetworkPolicy in version "v1" cannot be handled as a NetworkPolicy: strict decoding error: unknown field "spec.Egress"
# controlplane:~$ vi sol.yaml
# controlplane:~$ vi sol1.yaml
# controlplane:~$ kaf sol1.yaml
# networkpolicy.networking.k8s.io/np created
# controlplane:~$ k get netpol -n space1 -o yaml
# apiVersion: v1
# items:
# - apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     annotations:
#       kubectl.kubernetes.io/last-applied-configuration: |
#         {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"name":"np","namespace":"space1"},"spec":{"egress":[{"ports":[{"port":53,"protocol":"TCP"},{"port":53,"protocol":"UDP"}]},{"to":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"space2"}}}]}],"podSelector":{},"policyTypes":["Egress"]}}
#     creationTimestamp: "2025-12-13T14:47:13Z"
#     generation: 2
#     name: np
#     namespace: space1
#     resourceVersion: "3701"
#     uid: 507180ea-e9bf-4467-b1d1-5c88851161bd
#   spec:
#     egress:
#     - ports:
#       - port: 53
#         protocol: TCP
#       - port: 53
#         protocol: UDP
#     - to:
#       - namespaceSelector:
#           matchLabels:
#             kubernetes.io/metadata.name: space2
#     podSelector: {}
#     policyTypes:
#     - Egress
# kind: List
# metadata:
#   resourceVersion: ""
# controlplane:~$ k run busybox --image busybox --dry-run=client -o yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   labels:
#     run: busybox
#   name: busybox
# spec:
#   containers:
#   - image: busybox
#     name: busybox
#     resources: {}
#   dnsPolicy: ClusterFirst
#   restartPolicy: Always
# status: {}
# controlplane:~$ k run busybox --image busybox --dry-run=client -o yaml > sol.yaml
# controlplane:~$ vi sol.yaml
# controlplane:~$ kaf sol.yaml
# pod/busybox created
# controlplane:~$ k get po -w
# NAME       READY   STATUS              RESTARTS   AGE
# busybox    0/1     ContainerCreating   0          2s
# tester-0   1/1     Running             0          17m
# busybox    1/1     Running             0          5s
# ^Ccontrolplane:~$ k exec tester-0 
# error: you must specify at least one command for the container
# controlplane:~$ k exec -it tester-0
# error: you must specify at least one command for the container
# controlplane:~$ k get po
# NAME       READY   STATUS    RESTARTS   AGE
# busybox    1/1     Running   0          27s
# tester-0   1/1     Running   0          17m
# controlplane:~$ k config get-context --current
# error: unknown flag: --current
# See 'kubectl config --help' for usage.
# controlplane:~$ k config get-context current
# error: unknown command "get-context current"
# See 'kubectl config -h' for help and examples
# controlplane:~$ k config current
# error: unknown command "current"
# See 'kubectl config -h' for help and examples
# controlplane:~$ k get po -n space1
# NAME     READY   STATUS    RESTARTS   AGE
# app1-0   1/1     Running   0          18m
# controlplane:~$ k exec -it app1-0 -n space1
# error: you must specify at least one command for the container
# controlplane:~$ k get po app1-0 -n space1 -o yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   annotations:
#     cni.projectcalico.org/containerID: 39f0d0fb70cb220687be6880a4ea245307ba391dfa3967d7219291952a7bf7f5
#     cni.projectcalico.org/podIP: 192.168.0.8/32
#     cni.projectcalico.org/podIPs: 192.168.0.8/32
#   creationTimestamp: "2025-12-13T14:37:38Z"
#   generateName: app1-
#   generation: 1
#   labels:
#     app: app1
#     apps.kubernetes.io/pod-index: "0"
#     controller-revision-hash: app1-76d4566b4f
#     statefulset.kubernetes.io/pod-name: app1-0
#   name: app1-0
#   namespace: space1
#   ownerReferences:
#   - apiVersion: apps/v1
#     blockOwnerDeletion: true
#     controller: true
#     kind: StatefulSet
#     name: app1
#     uid: 3c44f283-8b05-44a3-ab16-56cb7635ee1f
#   resourceVersion: "2766"
#   uid: 6080ff72-26e9-4bbd-9f55-e922a4f2686d
# spec:
#   containers:
#   - image: nginx:1.21.5-alpine
#     imagePullPolicy: IfNotPresent
#     name: c
#     resources: {}
#     terminationMessagePath: /dev/termination-log
#     terminationMessagePolicy: File
#     volumeMounts:
#     - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#       name: kube-api-access-hzx56
#       readOnly: true
#   dnsPolicy: ClusterFirst
#   enableServiceLinks: true
#   hostname: app1-0
#   nodeName: controlplane
#   preemptionPolicy: PreemptLowerPriority
#   priority: 0
#   restartPolicy: Always
#   schedulerName: default-scheduler
#   securityContext: {}
#   serviceAccount: default
#   serviceAccountName: default
#   subdomain: app1
#   terminationGracePeriodSeconds: 30
#   tolerations:
#   - effect: NoExecute
#     key: node.kubernetes.io/not-ready
#     operator: Exists
#     tolerationSeconds: 300
#   - effect: NoExecute
#     key: node.kubernetes.io/unreachable
#     operator: Exists
#     tolerationSeconds: 300
#   volumes:
#   - name: kube-api-access-hzx56
#     projected:
#       defaultMode: 420
#       sources:
#       - serviceAccountToken:
#           expirationSeconds: 3607
#           path: token
#       - configMap:
#           items:
#           - key: ca.crt
#             path: ca.crt
#           name: kube-root-ca.crt
#       - downwardAPI:
#           items:
#           - fieldRef:
#               apiVersion: v1
#               fieldPath: metadata.namespace
#             path: namespace
# status:
#   conditions:
#   - lastProbeTime: null
#     lastTransitionTime: "2025-12-13T14:37:45Z"
#     observedGeneration: 1
#     status: "True"
#     type: PodReadyToStartContainers
#   - lastProbeTime: null
#     lastTransitionTime: "2025-12-13T14:37:38Z"
#     observedGeneration: 1
#     status: "True"
#     type: Initialized
#   - lastProbeTime: null
#     lastTransitionTime: "2025-12-13T14:37:45Z"
#     observedGeneration: 1
#     status: "True"
#     type: Ready
#   - lastProbeTime: null
#     lastTransitionTime: "2025-12-13T14:37:45Z"
#     observedGeneration: 1
#     status: "True"
#     type: ContainersReady
#   - lastProbeTime: null
#     lastTransitionTime: "2025-12-13T14:37:38Z"
#     observedGeneration: 1
#     status: "True"
#     type: PodScheduled
#   containerStatuses:
#   - containerID: containerd://5f239d0969bcb62f4796389479dc321ee0f09fe8fde825e093440b662dc6a174
#     image: docker.io/library/nginx:1.21.5-alpine
#     imageID: docker.io/library/nginx@sha256:eb05700fe7baa6890b74278e39b66b2ed1326831f9ec3ed4bdc6361a4ac2f333
#     lastState: {}
#     name: c
#     ready: true
#     resources: {}
#     restartCount: 0
#     started: true
#     state:
#       running:
#         startedAt: "2025-12-13T14:37:44Z"
#     volumeMounts:
#     - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
#       name: kube-api-access-hzx56
#       readOnly: true
#       recursiveReadOnly: Disabled
#   hostIP: 172.30.1.2
#   hostIPs:
#   - ip: 172.30.1.2
#   observedGeneration: 1
#   phase: Running
#   podIP: 192.168.0.8
#   podIPs:
#   - ip: 192.168.0.8
#   qosClass: BestEffort
#   startTime: "2025-12-13T14:37:38Z"
# controlplane:~$ alias kns="kubectl config set-context --current --namespace"
# controlplane:~$ kns space1
# Context "kubernetes-admin@kubernetes" modified.
# controlplane:~$ k get po
# NAME     READY   STATUS    RESTARTS   AGE
# app1-0   1/1     Running   0          20m
# controlplane:~$ k exec -it app1-0 sh
# error: exec [POD] [COMMAND] is not supported anymore. Use exec [POD] -- [COMMAND] instead
# See 'kubectl exec -h' for help and examples
# controlplane:~$ k exec -it app1-0 -- sh
# / # curl http://app2-0
# curl: (6) Could not resolve host: app2-0
# / # nslookkup
# sh: nslookkup: not found
# / # nslookup
# BusyBox v1.34.1 (2021-11-23 00:57:35 UTC) multi-call binary.

# Usage: nslookup [-type=QUERY_TYPE] [-debug] HOST [DNS_SERVER]

# Query DNS about HOST

# QUERY_TYPE: soa,ns,a,aaaa,cname,mx,txt,ptr,srv,any
# / # curl http://get.docker.com
# ^C
# / # curl https://get.docker.com
# ^C
# / # nslookup google.com
# Server:		10.96.0.10
# Address:	10.96.0.10:53

# Non-authoritative answer:
# Name:	google.com
# Address: 74.125.24.139
# Name:	google.com
# Address: 74.125.24.138
# Name:	google.com
# Address: 74.125.24.100
# Name:	google.com
# Address: 74.125.24.101
# Name:	google.com
# Address: 74.125.24.102
# Name:	google.com
# Address: 74.125.24.113

# Non-authoritative answer:
# Name:	google.com
# Address: 2404:6800:4003:c1a::66
# Name:	google.com
# Address: 2404:6800:4003:c1a::71
# Name:	google.com
# Address: 2404:6800:4003:c1a::64
# Name:	google.com
# Address: 2404:6800:4003:c1a::8b

# / # exit
# controlplane:~$ ls
# Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  filesystem  sol.yaml  sol1.yaml
# controlplane:~$ k get po -n space2 
# NAME              READY   STATUS    RESTARTS   AGE
# microservice1-0   1/1     Running   0          22m
# microservice2-0   1/1     Running   0          22m
# controlplane:~$ k exec -it app0-1
# error: you must specify at least one command for the container
# controlplane:~$ k exec -it app0-1 -- sh
# Error from server (NotFound): pods "app0-1" not found
# controlplane:~$ k get po
# NAME     READY   STATUS    RESTARTS   AGE
# app1-0   1/1     Running   0          22m
# controlplane:~$ k exec -it app1-0 -- sh
# / # curl http://microservice1-0
# curl: (6) Could not resolve host: microservice1-0
# / # curl http://microservice2-0
# curl: (6) Could not resolve host: microservice2-0
# / # exit
# command terminated with exit code 6
# controlplane:~$ k get po -n space2 -o wide
# NAME              READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
# microservice1-0   1/1     Running   0          23m   192.168.0.6   controlplane   <none>           <none>
# microservice2-0   1/1     Running   0          23m   192.168.0.9   controlplane   <none>           <none>
# controlplane:~$ k exec -it app1-0 -- sh
# / # curl http://192.168.0.6
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# / # nslookukp microservice1-0
# sh: nslookukp: not found
# / # nslookup microservice1-0
# Server:		10.96.0.10
# Address:	10.96.0.10:53

# ** server can't find microservice1-0.space1.svc.cluster.local: NXDOMAIN

# ** server can't find microservice1-0.svc.cluster.local: NXDOMAIN

# ** server can't find microservice1-0.cluster.local: NXDOMAIN

# ** server can't find microservice1-0.space1.svc.cluster.local: NXDOMAIN

# ** server can't find microservice1-0.svc.cluster.local: NXDOMAIN

# ** server can't find microservice1-0.cluster.local: NXDOMAIN

# / # exit
# command terminated with exit code 1
# controlplane:~$ ls
# Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  filesystem  sol.yaml  sol1.yaml
# controlplane:~$ k -n space1 exec app1-0 -- curl -m 1 microservice1.space2.svc.cluster.local
# k -n space1 exec app1-0 -- curl -m 1 microservice2.space2.svc.cluster.local
# k -n space1 exec app1-0 -- nslookup tester.default.svc.cluster.local
# k -n kube-system exec -it validate-checker-pod -- curl -m 1 app1.space1.svc.cluster.local
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# 100   615  100   615    0     0  72335      0 --:--:-- --:--:-- --:--:-- 76875
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
#   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# 100   615  100   615    0     0  76236      0 --:--:-- --:--:-- --:--:-- 87857
# Server:		10.96.0.10
# Address:	10.96.0.10:53

# Name:	tester.default.svc.cluster.local
# Address: 10.110.155.56


# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# controlplane:~$ k -n space1 exec app1-0 -- curl -m 1 tester.default.svc.cluster.local
# k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice1.space2.svc.cluster.local
# k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice2.space2.svc.cluster.local
# k -n default run nginx --image=nginx:1.21.5-alpine --restart=Never -i --rm  -- curl -m 1 microservice1.space2.svc.cluster.local

# CHECK
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
#   0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
# curl: (28) Connection timed out after 1000 milliseconds
# command terminated with exit code 28
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# 100   615  100   615    0     0   109k      0 --:--:-- --:--:-- --:--:--  120k
# pod "nginx" deleted from default namespace
# CHECK: command not found
# controlplane:~$ k -n space1 exec app1-0 -- curl -m 1 tester.default.svc.cluster.local
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
#   0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
# curl: (28) Connection timed out after 1000 milliseconds
# command terminated with exit code 28
# controlplane:~$ k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice1.space2.svc.cluster.local
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# controlplane:~$ vi sol1.yaml
# controlplane:~$ k get sol.yaml
# error: the server doesn't have a resource type "sol"
# controlplane:~$ cat sol.yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   labels:
#     run: busybox
#   name: busybox
# spec:
#   containers:
#   - image: busybox
#     name: busybox
#     resources: {}
#     command: ["sleep", "3600"]
#   dnsPolicy: ClusterFirst
#   restartPolicy: Always
# status: {}
# controlplane:~$ ls
# Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  filesystem  sol.yaml  sol1.yaml
# controlplane:~$ vi sol.yaml
# controlplane:~$ k get netpol -o yaml
# apiVersion: v1
# items:
# - apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     annotations:
#       kubectl.kubernetes.io/last-applied-configuration: |
#         {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"name":"np","namespace":"space1"},"spec":{"egress":[{"ports":[{"port":53,"protocol":"TCP"},{"port":53,"protocol":"UDP"}]},{"to":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"space2"}}}]}],"podSelector":{},"policyTypes":["Egress"]}}
#     creationTimestamp: "2025-12-13T14:47:13Z"
#     generation: 2
#     name: np
#     namespace: space1
#     resourceVersion: "3701"
#     uid: 507180ea-e9bf-4467-b1d1-5c88851161bd
#   spec:
#     egress:
#     - ports:
#       - port: 53
#         protocol: TCP
#       - port: 53
#         protocol: UDP
#     - to:
#       - namespaceSelector:
#           matchLabels:
#             kubernetes.io/metadata.name: space2
#     podSelector: {}
#     policyTypes:
#     - Egress
# kind: List
# metadata:
#   resourceVersion: ""
# controlplane:~$ vi sol1.yaml
# controlplane:~$ kaf sol1.yaml
# networkpolicy.networking.k8s.io/np configured
# controlplane:~$ k -n space1 exec app1-0 -- curl -m 1 microservice1.space2.svc.cluster.local
# k -n space1 exec app1-0 -- curl -m 1 microservice2.space2.svc.cluster.local
# k -n space1 exec app1-0 -- nslookup tester.default.svc.cluster.local
# k -n kube-system exec -it validate-checker-pod -- curl -m 1 app1.space1.svc.cluster.local
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# 100   615  100   615    0     0  64736      0 --:--:-- --:--:-- --:--:-- 68333
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# 100   615  100   615    0     0  92690      0 --:--:-- --:--:-- --:--:--  100k
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# Server:		10.96.0.10
# Address:	10.96.0.10:53

# Name:	tester.default.svc.cluster.local
# Address: 10.110.155.56


# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
# html { color-scheme: light dark; }
# body { width: 35em; margin: 0 auto;
# font-family: Tahoma, Verdana, Arial, sans-serif; }
# </style>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p>If you see this page, the nginx web server is successfully installed and
# working. Further configuration is required.</p>

# <p>For online documentation and support please refer to
# <a href="http://nginx.org/">nginx.org</a>.<br/>
# Commercial support is available at
# <a href="http://nginx.com/">nginx.com</a>.</p>

# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# controlplane:~$ k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice1.space2.svc.cluster.local
# curl: (28) Connection timed out after 1000 milliseconds
# command terminated with exit code 28
# controlplane:~$ k -n default run nginx --image=nginx:1.21.5-alpine --restart=Never -i --rm  -- curl -m 1 microservice1.space2.svc.cluster.local

# CHECK
# Exam Desktop
# Editor
# Tab 1
# +
# All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
# If you don't see a command prompt, try pressing enter.
#   0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
# curl: (28) Connection timed out after 1001 milliseconds
# pod "nginx" deleted from default namespace
# pod default/nginx terminated (Error)
# CHECK: command not found
# Exam: command not found
# Command 'Editor' not found, but there are 42 similar ones.
# Command 'Tab' not found, did you mean:
#   command 'ab' from deb apache2-utils (2.4.58-1ubuntu8.8)
#   command 'fab' from deb fabric (2.6.0-1)
#   command 'dab' from deb bsdgames (2.17-30)
# Try: apt install <deb name>
# +: command not found
# controlplane:~$ ls
# Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  filesystem  sol.yaml  sol1.yaml
# controlplane:~$ k get netpol -A -o yaml
# apiVersion: v1
# items:
# - apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     annotations:
#       kubectl.kubernetes.io/last-applied-configuration: |
#         {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"name":"np","namespace":"space1"},"spec":{"egress":[{"ports":[{"port":53,"protocol":"TCP"},{"port":53,"protocol":"UDP"}]},{"to":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"space2"}}}]}],"podSelector":{},"policyTypes":["Egress"]}}
#     creationTimestamp: "2025-12-13T14:47:13Z"
#     generation: 2
#     name: np
#     namespace: space1
#     resourceVersion: "3701"
#     uid: 507180ea-e9bf-4467-b1d1-5c88851161bd
#   spec:
#     egress:
#     - ports:
#       - port: 53
#         protocol: TCP
#       - port: 53
#         protocol: UDP
#     - to:
#       - namespaceSelector:
#           matchLabels:
#             kubernetes.io/metadata.name: space2
#     podSelector: {}
#     policyTypes:
#     - Egress
# - apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     annotations:
#       kubectl.kubernetes.io/last-applied-configuration: |
#         {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"name":"np","namespace":"space2"},"spec":{"ingress":[{"from":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"space1"}}}]}],"podSelector":{},"policyTypes":["Ingress"]}}
#     creationTimestamp: "2025-12-13T14:51:24Z"
#     generation: 2
#     name: np
#     namespace: space2
#     resourceVersion: "4913"
#     uid: 8d8d90a9-9998-408d-bab7-7a9b52becdca
#   spec:
#     ingress:
#     - from:
#       - namespaceSelector:
#           matchLabels:
#             kubernetes.io/metadata.name: space1
#     podSelector: {}
#     policyTypes:
#     - Ingress
# kind: List
# metadata:
#   resourceVersion: ""
# controlplane:~$ 