no emoji as i have instructed you t, controlplane:~$ k get ns --show-labels
NAME                 STATUS   AGE    LABELS
default              Active   25d    kubernetes.io/metadata.name=default
kube-node-lease      Active   25d    kubernetes.io/metadata.name=kube-node-lease
kube-public          Active   25d    kubernetes.io/metadata.name=kube-public
kube-system          Active   25d    kubernetes.io/metadata.name=kube-system
level-1000           Active   110s   kubernetes.io/metadata.name=level-1000
level-1001           Active   110s   kubernetes.io/metadata.name=level-1001
level-1002           Active   110s   kubernetes.io/metadata.name=level-1002
local-path-storage   Active   25d    kubernetes.io/metadata.name=local-path-storage
other                Active   110s   kubernetes.io/metadata.name=other
controlplane:~$ vi sol.yaml
controlplane:~$ k apply -f sol.yaml
Warning: resource networkpolicies/np-100x is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
The request is invalid: patch: Invalid value: "map[metadata:map[annotations:map[kubectl.kubernetes.io/last-applied-configuration:{\"apiVersion\":\"networking.k8s.io/v1\",\"kind\":\"NetworkPolicy\",\"metadata\":{\"annotations\":{},\"name\":\"np-100x\",\"namespace\":\"default\"},\"spec\":{\"egress\":[{\"ports\":[{\"port\":53,\"protocol\":\"TCP\"},{\"port\":53,\"protocol\":\"UDP\"}]},{\"from\":[{\"namespaceSelector\":{\"matchLabels\":{\"kubernetes.io/metadata.name\":\"level-1000\"}},\"podSelector\":{\"matchLabels\":{\"level\":\"100x\"}}},{\"namespaceSelector\":{\"matchLabels\":{\"kubernetes.io/metadata.name\":\"level-1001\"}},\"podSelector\":{\"matchLabels\":{\"level\":\"100x\"}}},{\"namespaceSelector\":{\"matchLabels\":{\"kubernetes.io/metadata.name\":\"level-1002\"}},\"podSelector\":{\"matchLabels\":{\"level\":\"100x\"}}}]}],\"podSelector\":{\"matchLabels\":{\"level\":\"100x\"}},\"policyTypes\":[\"egress\"]}}\n]] spec:map[egress:[map[ports:[map[port:53 protocol:TCP] map[port:53 protocol:UDP]]] map[from:[map[namespaceSelector:map[matchLabels:map[kubernetes.io/metadata.name:level-1000]] podSelector:map[matchLabels:map[level:100x]]] map[namespaceSelector:map[matchLabels:map[kubernetes.io/metadata.name:level-1001]] podSelector:map[matchLabels:map[level:100x]]] map[namespaceSelector:map[matchLabels:map[kubernetes.io/metadata.name:level-1002]] podSelector:map[matchLabels:map[level:100x]]]]]] policyTypes:[egress]]]": strict decoding error: unknown field "spec.egress[1].from"
controlplane:~$ vi sol.yaml
controlplane:~$ k apply -f sol.yaml
Warning: resource networkpolicies/np-100x is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
The NetworkPolicy "np-100x" is invalid: spec.policyTypes[0]: Unsupported value: "egress": supported values: "Ingress", "Egress"
controlplane:~$ vi sol.yaml
controlplane:~$ kaf sol.yaml
Command 'kaf' not found, did you mean:
  command 'kar' from deb sra-toolkit (3.0.3+dfsg-6ubuntu1)
  command 'kak' from deb kakoune (2022.10.31-2)
  command 'kas' from deb kas (4.0-1)
  command 'kdf' from deb kdf (4:23.08.4-0ubuntu1)
  command 'kf' from deb heimdal-clients (7.8.git20221117.28daf24+dfsg-3ubuntu4)
  command 'caf' from deb libcoarrays-mpich-dev (2.10.1-1)
  command 'caf' from deb libcoarrays-openmpi-dev (2.10.1-1)
  command 'paf' from deb libpod-abstract-perl (0.20-3)
Try: apt install <deb name>
controlplane:~$ k apply -f sol.yaml
Warning: resource networkpolicies/np-100x is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
networkpolicy.networking.k8s.io/np-100x configured
controlplane:~$ k get netpol -o yaml
apiVersion: v1
items:
- apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"networking.k8s.io/v1","kind":"NetworkPolicy","metadata":{"annotations":{},"name":"np-100x","namespace":"default"},"spec":{"egress":[{"ports":[{"port":53,"protocol":"TCP"},{"port":53,"protocol":"UDP"}]},{"to":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"level-1000"}},"podSelector":{"matchLabels":{"level":"100x"}}},{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"level-1001"}},"podSelector":{"matchLabels":{"level":"100x"}}},{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"level-1002"}},"podSelector":{"matchLabels":{"level":"100x"}}}]}],"podSelector":{"matchLabels":{"level":"100x"}},"policyTypes":["Egress"]}}
    creationTimestamp: "2025-12-13T15:14:06Z"
    generation: 2
    name: np-100x
    namespace: default
    resourceVersion: "4609"
    uid: 7ec59420-998f-4550-aa71-7832b5813a79
  spec:
    egress:
    - ports:
      - port: 53
        protocol: TCP
      - port: 53
        protocol: UDP
    - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: level-1000
        podSelector:
          matchLabels:
            level: 100x
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: level-1001
        podSelector:
          matchLabels:
            level: 100x
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: level-1002
        podSelector:
          matchLabels:
            level: 100x
    podSelector:
      matchLabels:
        level: 100x
    policyTypes:
    - Egress
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ kubectl exec tester-0 -- curl tester.level-1000.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1001.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1002.svc.cluster.local
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   615 100   615   0     0  8367     0  --:--:-- --:--:-- --:--:--  9044
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615 100   615   0     0 104060     0  --:--:-- --:--:-- --:--:-- 123000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   615 100   615   0     0 122534     0  --:--:-- --:--:-- --:--:-- 153750
controlplane:~$ All Pods in Namespace default with label level=100x should be able to communicate with Pods with label level=100x in Namespaces level-1000 , level-1001 and level-1002 .

Fix the existing NetworkPolicy np-100x to ensure this.


Tip 1

For learning you can check the NetworkPolicy Editor


Tip 2

kubectl get pod -A --show-labels

# there are tester pods that you can use
kubectl get svc,pod -A --show-labels | grep tester

Solution


We need to update the NetworkPolicy to fix a mistake:


kubectl edit networkpolicy np-100x

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-100x
  namespace: default
spec:
  podSelector:
    matchLabels:
      level: 100x
  policyTypes:
  - Egress
  egress:
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1000
       podSelector:
         matchLabels:
           level: 100x
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1001 # CHANGE
       podSelector:
         matchLabels:
           level: 100x
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1002
       podSelector:
         matchLabels:
           level: 100x
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP

Verify


These should work:


kubectl exec tester-0 -- curl tester.level-1000.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1001.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1002.svc.cluster.local

