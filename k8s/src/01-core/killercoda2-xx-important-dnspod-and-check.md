https://killercoda.com/sachin/course/CKA/coredns


https://chatgpt.com/share/68b94e22-c538-8005-aa0f-5b3a49009d33


Perfect. Here's a **fully detailed version** of the CoreDNS / Kubernetes DNS failure and recovery session — including the **root causes, what each error meant, and exactly how each fix resolved it**, with CKA-level clarity.

---

# 🧾 Detailed Notes: Kubernetes DNS Failure and CoreDNS Recovery

---

## 🧠 Problem Statement

Inside running pods (`dns-rs-cka-*`), DNS queries to in-cluster and external services were failing:

```bash
kubectl exec -it dns-rs-cka-9rz2h -- nslookup kubernetes.default
;; connection timed out; no servers could be reached
```

This occurred even though the CoreDNS pods were in a `Running` state.

---

## 🔍 Phase 1: Initial Observations

### 1. **Pod `/etc/resolv.conf`**

```bash
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
```

✅ This is correct. It means the pod is trying to resolve DNS via the ClusterIP of the kube-dns service.

---

### 2. **CoreDNS Service IP Check**

```bash
kubectl get svc -n kube-system kube-dns
```

Output:

```bash
NAME       TYPE       CLUSTER-IP    ...  SELECTOR
kube-dns   ClusterIP  10.96.0.10    ...  k8s-app=kube-dns
```

✅ The service exists and matches the pod DNS configuration.

---

### 3. **CoreDNS Pods**

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
```

✅ Two pods were running and reachable via ping:

```
192.168.1.2
192.168.1.3
```

✅ From within the test pod:

```bash
ping 192.168.1.2 → success
ping 192.168.1.3 → success
```

❌ But:

```bash
ping 10.96.0.10 → FAIL (timeout)
```

---

## 🔥 Phase 2: Diagnosing the Real Problem

### ❗ `kubectl get endpoints -n kube-system kube-dns -o yaml`

Returned:

```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: kube-dns
  ...
subsets:  <---- MISSING!
```

🔴 **This is the problem.**

> The `kube-dns` service had no registered endpoints (`subsets:` was empty).
> So Kubernetes didn’t know which pods should receive traffic for `10.96.0.10`.

---

### 🔎 Why is that a problem?

When Kubernetes Services (type `ClusterIP`) are created:

1. A `Service` object (like `kube-dns`) is registered.
2. An `Endpoints` object is automatically created that maps **selectors → matching pods**
3. `kube-proxy` watches these endpoints and generates **iptables NAT rules** to route traffic from the ClusterIP (e.g., `10.96.0.10`) to actual pod IPs (e.g., `192.168.1.2`, `192.168.1.3`)

---

### 🔍 Check for iptables rule

```bash
sudo iptables -t nat -L -n | grep 10.96.0.10
```

🔴 No entry found → **No routing path exists for DNS traffic.**

---

## 📛 Root Cause Summary

| Component        | Status    | Details                                       |
| ---------------- | --------- | --------------------------------------------- |
| CoreDNS Pods     | ✅ Running | But not matched by kube-dns service selector  |
| kube-dns Service | ✅ Exists  | ClusterIP: 10.96.0.10                         |
| Endpoints        | ❌ Empty   | No `subsets:` → No backend pod IPs registered |
| kube-proxy Rules | ❌ Missing | No iptables NAT to CoreDNS pods               |
| DNS Resolution   | ❌ Broken  | Packets to `10.96.0.10` dropped silently      |

---

## 🛠️ Phase 3: The Fix – What Was Done

### ✅ Step 1: Backup the broken service

```bash
kubectl get svc -n kube-system kube-dns -o yaml > kube-dns-svc.yaml
```

---

### ✅ Step 2: Delete the broken `kube-dns` Service

```bash
kubectl delete svc -n kube-system kube-dns
```

This removed the non-functional `kube-dns` and its empty `Endpoints`.

---

### ✅ Step 3: Reapply a correct CoreDNS Deployment

Created a new manifest (`coredns.yaml`) with:

* A corrected `kube-dns` Service (with selector `k8s-app=kube-dns`)
* A `Deployment` with 2 CoreDNS pods
* A `ConfigMap` with a working Corefile

```bash
kubectl apply -f coredns.yaml
```

This:

* Recreated the CoreDNS pods with correct labels
* Triggered automatic creation of matching `Endpoints`
* Allowed kube-proxy to set up NAT rules for DNS routing

---

### ✅ Step 4: Validate Endpoints

```bash
kubectl get endpoints -n kube-system kube-dns -o yaml
```

Confirmed:

```yaml
subsets:
  - addresses:
      - ip: 192.168.0.4
      - ip: 192.168.0.5
    ports:
      - port: 53
        protocol: UDP
      - port: 53
        protocol: TCP
```

✅ Success! Endpoints registered.

---

### ✅ Step 5: Confirm iptables rule added

```bash
sudo iptables -t nat -L -n | grep 10.96.0.10
```

Output showed NAT rules present. `kube-proxy` correctly picked up the endpoints and programmed routing.

---

### ✅ Step 6: Final Tests

```bash
kubectl exec -it dns-rs-cka-9rz2h -- nslookup kubernetes.default
```

Output:

```
Server:    10.96.0.10
Address:   10.96.0.10#53

Name:      kubernetes.default.svc.cluster.local
Address:   10.96.0.1
```

✅ DNS resolution restored.

Also tested:

```bash
kubectl exec -it dns-rs-cka-9rz2h -- nslookup google.com
```

✅ External DNS resolution works too.

---

## 📘 Key Learnings

### What caused this?

* The `kube-dns` service was either misconfigured, missing, or not properly linked to CoreDNS pods.
* This resulted in an empty `Endpoints` object → no service routing.
* CoreDNS pods ran fine, but never received traffic.

---

### How was it fixed?

* Recreated both the **Service** and the **Deployment** with correct labels.
* Kubernetes automatically created correct Endpoints once selector matched pods.
* `kube-proxy` automatically set up the necessary iptables NAT rules.

---

## ✅ Commands Reference

| Purpose                            | Command                                                       |                   |
| ---------------------------------- | ------------------------------------------------------------- | ----------------- |
| Check pod DNS config               | `cat /etc/resolv.conf` in pod                                 |                   |
| Check CoreDNS service IP           | `kubectl get svc -n kube-system kube-dns -o wide`             |                   |
| Check CoreDNS pod IPs              | `kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide` |                   |
| Ping CoreDNS pods from another pod | `ping <pod-ip>`                                               |                   |
| Check Endpoints                    | `kubectl get endpoints -n kube-system kube-dns -o yaml`       |                   |
| Check iptables routing             | \`sudo iptables -t nat -L -n                                  | grep 10.96.0.10\` |
| Reapply CoreDNS                    | `kubectl apply -f coredns.yaml`                               |                   |
| Test DNS resolution                | `nslookup kubernetes.default` or `google.com` from pod        |                   |

---

## 📦 Want Export?

Let me know if you'd like this as:

* `Markdown (.md)`
* `PDF`
* `Plain text`
* `Word (.docx)`

I can generate the file for download instantly.
controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k create rs dns-rs-cka
error: Unexpected args: [rs dns-rs-cka]
See 'kubectl create -h' for help and examples
controlplane:~$ k create rs dns-rs-cka --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --replicas=2 --container-name=dns-container --command -- "sleep" "3600"   
error: unknown flag: --image
See 'kubectl create --help' for usage.
controlplane:~$ k create rs --help
Create a resource from a file or from stdin.

 JSON and YAML formats are accepted.

Examples:
  # Create a pod using the data in pod.json
  kubectl create -f ./pod.json
  
  # Create a pod based on the JSON passed into stdin
  cat pod.json | kubectl create -f -
  
  # Edit the data in registry.yaml in JSON then create the resource using the edited data
  kubectl create -f registry.yaml --edit -o json

Available Commands:
  clusterrole           Create a cluster role
  clusterrolebinding    Create a cluster role binding for a particular cluster role
  configmap             Create a config map from a local file, directory or literal value
  cronjob               Create a cron job with the specified name
  deployment            Create a deployment with the specified name
  ingress               Create an ingress with the specified name
  job                   Create a job with the specified name
  namespace             Create a namespace with the specified name
  poddisruptionbudget   Create a pod disruption budget with the specified name
  priorityclass         Create a priority class with the specified name
  quota                 Create a quota with the specified name
  role                  Create a role with single rule
  rolebinding           Create a role binding for a particular role or cluster role
  secret                Create a secret using a specified subcommand
  service               Create a service using a specified subcommand
  serviceaccount        Create a service account with the specified name
  token                 Request a service account token

Options:
    --allow-missing-template-keys=true:
        If true, ignore any errors in templates when a field or map key is missing in the
        template. Only applies to golang and jsonpath output formats.

    --dry-run='none':
        Must be "none", "server", or "client". If client strategy, only print the object that
        would be sent, without sending it. If server strategy, submit server-side request without
        persisting the resource.

    --edit=false:
        Edit the API resource before creating

    --field-manager='kubectl-create':
        Name of the manager used to track field ownership.

    -f, --filename=[]:
        Filename, directory, or URL to files to use to create the resource

    -k, --kustomize='':
        Process the kustomization directory. This flag can't be used together with -f or -R.

    -o, --output='':
        Output format. One of: (json, yaml, name, go-template, go-template-file, template,
        templatefile, jsonpath, jsonpath-as-json, jsonpath-file).

    --raw='':
        Raw URI to POST to the server.  Uses the transport specified by the kubeconfig file.

    -R, --recursive=false:
        Process the directory used in -f, --filename recursively. Useful when you want to manage
        related manifests organized within the same directory.

    --save-config=false:
        If true, the configuration of current object will be saved in its annotation. Otherwise,
        the annotation will be unchanged. This flag is useful when you want to perform kubectl
        apply on this object in the future.

    -l, --selector='':
        Selector (label query) to filter on, supports '=', '==', '!=', 'in', 'notin'.(e.g. -l
        key1=value1,key2=value2,key3 in (value3)). Matching objects must satisfy all of the
        specified label constraints.

    --show-managed-fields=false:
        If true, keep the managedFields when printing objects in JSON or YAML format.

    --template='':
        Template string or path to template file to use when -o=go-template, -o=go-template-file.
        The template format is golang templates
        [http://golang.org/pkg/text/template/#pkg-overview].

    --validate='strict':
        Must be one of: strict (or true), warn, ignore (or false). "true" or "strict" will use a
        schema to validate the input and fail the request if invalid. It will perform server side
        validation if ServerSideFieldValidation is enabled on the api-server, but will fall back
        to less reliable client-side validation if not. "warn" will warn about unknown or
        duplicate fields without blocking the request if server-side field validation is enabled
        on the API server, and behave as "ignore" otherwise. "false" or "ignore" will not perform
        any schema validation, silently dropping any unknown or duplicate fields.

    --windows-line-endings=false:
        Only relevant if --edit=true. Defaults to the line ending native to your platform.

Usage:
  kubectl create -f FILENAME [options]

Use "kubectl create <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
controlplane:~$ k create deploy dns-rs-cka --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --replicas=2 -
-container-name=dns-container --command -- "sleep" "3600" 
error: unknown flag: --container-name
See 'kubectl create deployment --help' for usage.
controlplane:~$ k create deploy dns-rs-cka --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --replicas=2  
--command -- "sleep" "3600" --dry-run=client
error: unknown flag: --command
See 'kubectl create deployment --help' for usage.
controlplane:~$ k get pods
No resources found in default namespace.
controlplane:~$ k create deploy dns-rs-cka --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --replicas=2  --dry-run=client
deployment.apps/dns-rs-cka created (dry run)
controlplane:~$ k create deploy dns-rs-cka --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --replicas=2  --dry-run=client -o yaml > deploy.yaml
controlplane:~$ vi deploy.yaml 
controlplane:~$ k apply -f deploy.yaml 
Error from server (BadRequest): error when creating "deploy.yaml": ReplicaSet in version "v1" cannot be handled as a ReplicaSet: strict decoding error: unknown field "spec.strategy"
controlplane:~$ vi deploy.yaml 
controlplane:~$ k apply -f deploy.yaml 
replicaset.apps/dns-rs-cka created
controlplane:~$ k get pods
NAME               READY   STATUS              RESTARTS   AGE
dns-rs-cka-9rz2h   0/1     ContainerCreating   0          2s
dns-rs-cka-smfgt   0/1     ContainerCreating   0          2s
controlplane:~$ k get pods -w
NAME               READY   STATUS              RESTARTS   AGE
dns-rs-cka-9rz2h   0/1     ContainerCreating   0          7s
dns-rs-cka-smfgt   0/1     ContainerCreating   0          7s
dns-rs-cka-smfgt   1/1     Running             0          17s
dns-rs-cka-9rz2h   1/1     Running             0          19s
^Ccontrolplane:~$ k exec -it dns-rs-cka-9rz2h  -- nslookup kubernetes.default
;; connection timed out; no servers could be reached

command terminated with exit code 1
controlplane:~$ k exec -it dns-rs-cka-9rz2h  -- nslookup kubernetes.default > dns-output.txt
command terminated with exit code 1
controlplane:~$ k exec -it dns-rs-cka-9rz2h  -- nslookup google.com        
;; connection timed out; no servers could be reached

command terminated with exit code 1
controlplane:~$ ^C
controlplane:~$ k exec -it dns-rs-cka-9rz2h -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
controlplane:~$ ^C
controlplane:~$ k get pod -o wide -A | grep -i dns
default              dns-rs-cka-9rz2h                          1/1     Running   0             4m18s   192.168.1.5   node01         <none>           <none>
default              dns-rs-cka-smfgt                          1/1     Running   0             4m18s   192.168.1.4   node01         <none>           <none>
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running   1 (12m ago)   15d     192.168.1.3   node01         <none>           <none>
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running   1 (12m ago)   15d     192.168.1.2   node01         <none>           <none>
controlplane:~$ ^C
controlplane:~$ k get svc -o wide -A | grep -i dns
kube-system   kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   15d   k8s-app=core-dns
controlplane:~$ ^C
controlplane:~$ k exec -it dns-rs-cka-9rz2h -- apt update && apt install -y dnsutils netcat
Err http://deb.debian.org jessie InRelease                           
  
Err http://deb.debian.org jessie-updates InRelease                   
  
Err http://deb.debian.org jessie Release.gpg                         
  Could not resolve 'deb.debian.org'
Err http://deb.debian.org jessie-updates Release.gpg
  Could not resolve 'deb.debian.org'
Err http://security.debian.org jessie/updates InRelease
  
Err http://security.debian.org jessie/updates Release.gpg
  Could not resolve 'security.debian.org'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
All packages are up to date.
W: Failed to fetch http://deb.debian.org/debian/dists/jessie/InRelease  

W: Failed to fetch http://security.debian.org/debian-security/dists/jessie/updates/InRelease  

W: Failed to fetch http://deb.debian.org/debian/dists/jessie-updates/InRelease  

W: Failed to fetch http://deb.debian.org/debian/dists/jessie/Release.gpg  Could not resolve 'deb.debian.org'

W: Failed to fetch http://deb.debian.org/debian/dists/jessie-updates/Release.gpg  Could not resolve 'deb.debian.org'

W: Failed to fetch http://security.debian.org/debian-security/dists/jessie/updates/Release.gpg  Could not resolve 'security.debian.org'

W: Some index files failed to download. They have been ignored, or old ones used instead.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Package netcat is a virtual package provided by:
  netcat-traditional 1.10-48
  netcat-openbsd 1.226-1ubuntu2
You should explicitly select one to install.

E: Package 'netcat' has no installation candidate
controlplane:~$ k exec -it dns-rs-cka-9rz2h -- nc -zv 10.96.0.10 53^C
controlplane:~$ ^C
controlplane:~$ nslookup google.com
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.192.78
Name:   google.com
Address: 2404:6800:4009:829::200e

controlplane:~$ ^C
controlplane:~$ k get pods -A
NAMESPACE            NAME                                      READY   STATUS    RESTARTS      AGE
default              dns-rs-cka-9rz2h                          1/1     Running   0             6m14s
default              dns-rs-cka-smfgt                          1/1     Running   0             6m14s
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   2 (14m ago)   15d
kube-system          canal-5q8x5                               2/2     Running   2 (14m ago)   15d
kube-system          canal-hvvtk                               2/2     Running   2 (14m ago)   15d
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running   1 (14m ago)   15d
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running   1 (14m ago)   15d
kube-system          etcd-controlplane                         1/1     Running   2 (14m ago)   15d
kube-system          kube-apiserver-controlplane               1/1     Running   2 (14m ago)   15d
kube-system          kube-controller-manager-controlplane      1/1     Running   2 (14m ago)   15d
kube-system          kube-proxy-7kdz8                          1/1     Running   2 (14m ago)   15d
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (14m ago)   15d
kube-system          kube-scheduler-controlplane               1/1     Running   2 (14m ago)   15d
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running   2 (14m ago)   15d
controlplane:~$ ^C
controlplane:~$ k get pods -n kube-system -o wide | grep coredns
coredns-6ff97d97f9-gq4nd                  1/1     Running   1 (15m ago)   15d   192.168.1.3   node01         <none>           <none>
coredns-6ff97d97f9-hcn7j                  1/1     Running   1 (15m ago)   15d   192.168.1.2   node01         <none>           <none>
controlplane:~$ ^C
controlplane:~$ k exec -it dns-rs-cka-9rz2h -- ping -c 3 192.168.1.3
PING 192.168.1.3 (192.168.1.3) 56(84) bytes of data.
64 bytes from 192.168.1.3: icmp_seq=1 ttl=63 time=0.119 ms
64 bytes from 192.168.1.3: icmp_seq=2 ttl=63 time=0.047 ms
64 bytes from 192.168.1.3: icmp_seq=3 ttl=63 time=0.049 ms

--- 192.168.1.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2041ms
rtt min/avg/max/mdev = 0.047/0.071/0.119/0.034 ms
controlplane:~$ ^C
controlplane:~$ ^C
controlplane:~$ k exec -it dns-rs-cka-9rz2h -- ping -c 3 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=63 time=0.071 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=63 time=0.075 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=63 time=0.056 ms

--- 192.168.1.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2077ms
rtt min/avg/max/mdev = 0.056/0.067/0.075/0.010 ms
controlplane:~$ ^C
controlplane:~$ ^C
controlplane:~$ k get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
dns-rs-cka-9rz2h   1/1     Running   0          7m28s   192.168.1.5   node01   <none>           <none>
dns-rs-cka-smfgt   1/1     Running   0          7m28s   192.168.1.4   node01   <none>           <none>
controlplane:~$ ^C
controlplane:~$ sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
controlplane:~$ ^C
controlplane:~$ ssh node01
Last login: Mon Feb 10 22:06:42 2025 from 10.244.0.131
node01:~$ p_seq=1 ttl=63 time=0.071 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=63 time=0.075 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=63 time=0.056 ms

--- 192.168.1.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2077ms
rtt min/avg/max/mdev = 0.056/0.067/0.075/0.010 ms
controlplane:~$ ^C
controlplane:~$ ^C
controlplane:~$ k get pods -o wide
NAME               READY   STATUS    RESTARTS   AGE     IP            NODE     NOMINATED NODE   READINESS GATES
dns-rs-cka-9rz2h   1/1     Running   0          7m28s   192.168.1.5   node01   <none>           <none>
dns-rs-cka-smfgt   1/1     Running   0          7m28s   192.168.1.4   node01   <none>           <none>
controlplane:~$ ^C
controlplane:~$ sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
controlplane:~$ ^C
node01:~$ sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
node01:~$ ^C
node01:~$ k logs -n kube-system -l k8s-app=kube-proxy
E0904 08:24:12.930380    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.932010    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.933531    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.934992    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:~$ ^C
node01:~$ exit
logout
Connection to node01 closed.
controlplane:~$ 
controlplane:~$ ^C
node01:~$ sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
node01:~$ ^C
node01:~$ k logs -n kube-system -l k8s-app=kube-proxy
E0904 08:24:12.930380    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.932010    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.933531    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E0904 08:24:12.934992    6895 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:~$ ^C
controlplane:~$ k logs -n kube-system -l k8s-app=kube-proxy
I0904 08:07:43.824150       1 shared_informer.go:350] "Waiting for caches to sync" controller="service config"
I0904 08:07:43.904987       1 shared_informer.go:350] "Waiting for caches to sync" controller="endpoint slice config"
I0904 08:07:43.905175       1 config.go:440] "Starting serviceCIDR config controller"
I0904 08:07:43.905257       1 shared_informer.go:350] "Waiting for caches to sync" controller="serviceCIDR config"
I0904 08:07:43.915892       1 config.go:329] "Starting node config controller"
I0904 08:07:43.915907       1 shared_informer.go:350] "Waiting for caches to sync" controller="node config"
I0904 08:07:44.108067       1 shared_informer.go:357] "Caches are synced" controller="serviceCIDR config"
I0904 08:07:44.118048       1 shared_informer.go:357] "Caches are synced" controller="endpoint slice config"
I0904 08:07:44.128426       1 shared_informer.go:357] "Caches are synced" controller="service config"
I0904 08:07:46.928457       1 shared_informer.go:357] "Caches are synced" controller="node config"
I0904 08:07:48.883730       1 config.go:105] "Starting endpoint slice config controller"
I0904 08:07:48.883879       1 shared_informer.go:350] "Waiting for caches to sync" controller="endpoint slice config"
I0904 08:07:48.883936       1 config.go:440] "Starting serviceCIDR config controller"
I0904 08:07:48.883983       1 shared_informer.go:350] "Waiting for caches to sync" controller="serviceCIDR config"
I0904 08:07:48.916071       1 config.go:329] "Starting node config controller"
I0904 08:07:48.917326       1 shared_informer.go:350] "Waiting for caches to sync" controller="node config"
I0904 08:07:48.983759       1 shared_informer.go:357] "Caches are synced" controller="service config"
I0904 08:07:49.006656       1 shared_informer.go:357] "Caches are synced" controller="serviceCIDR config"
I0904 08:07:49.007346       1 shared_informer.go:357] "Caches are synced" controller="endpoint slice config"
I0904 08:07:49.018349       1 shared_informer.go:357] "Caches are synced" controller="node config"
controlplane:~$ ^C
controlplane:~$ k get endpoints -n kube-system kube-dns -o yaml
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
apiVersion: v1
kind: Endpoints
metadata:
  creationTimestamp: "2025-08-19T09:04:01Z"
  labels:
    endpoints.kubernetes.io/managed-by: endpoint-controller
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "3100"
  uid: 12264454-6e46-419d-988b-ad9843e3a691
controlplane:~$ ^C
controlplane:~$ ssh node01
Last login: Thu Sep  4 08:23:34 2025 from 10.244.4.234
node01:~$ sudo iptables -t nat -L -n | grep 10.96.0.10
node01:~$ ^C
node01:~$ exit
logout
Connection to node01 closed.
controlplane:~$ k get endpoints -n kube-system kube-dns -o yaml
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
apiVersion: v1
kind: Endpoints
metadata:
  creationTimestamp: "2025-08-19T09:04:01Z"
  labels:
    endpoints.kubernetes.io/managed-by: endpoint-controller
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "3100"
  uid: 12264454-6e46-419d-988b-ad9843e3a691
controlplane:~$ ^C
controlplane:~$ kubectl get svc -n kube-system kube-dns -o yaml > kube-dns-svc.yaml
controlplane:~$ kubectl delete svc -n kube-system kube-dns
service "kube-dns" deleted
controlplane:~$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/coredns/coredns.yaml
error: unable to read URL "https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/coredns/coredns.yaml", server reported 404 Not Found, status code=404
controlplane:~$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/coredns/coredns.yaml
error: unable to read URL "https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/coredns/coredns.yaml", server reported 404 Not Found, status code=404
controlplane:~$ kubectl apply -f kube-dns-svc.yaml
service/kube-dns created
controlplane:~$ ^C
controlplane:~$ kubectl get endpoints -n kube-system kube-dns -o yaml
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    endpoints.kubernetes.io/last-change-trigger-time: "2025-09-04T08:26:10Z"
  creationTimestamp: "2025-09-04T08:26:10Z"
  labels:
    endpoints.kubernetes.io/managed-by: endpoint-controller
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "4343"
  uid: 04c2ea35-e710-4ca0-8c58-030ea0ead578
controlplane:~$ ^C
controlplane:~$ vi coredns.yaml
controlplane:~$ k apply -f coredns.yaml
service/kube-dns configured
Warning: resource deployments/coredns is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
deployment.apps/coredns configured
Warning: resource configmaps/coredns is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/coredns configured
controlplane:~$ ^C
controlplane:~$ kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get endpoints -n kube-system kube-dns -o yaml
NAME                       READY   STATUS        RESTARTS      AGE
coredns-6ff97d97f9-gq4nd   1/1     Terminating   1 (20m ago)   15d
coredns-7fcfc6d89b-fmdxk   1/1     Running       0             13s
coredns-7fcfc6d89b-nk2kw   1/1     Running       0             13s
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
apiVersion: v1
kind: Endpoints
metadata:
  annotations:
    endpoints.kubernetes.io/last-change-trigger-time: "2025-09-04T08:27:22Z"
  creationTimestamp: "2025-09-04T08:26:10Z"
  labels:
    endpoints.kubernetes.io/managed-by: endpoint-controller
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "4522"
  uid: 04c2ea35-e710-4ca0-8c58-030ea0ead578
subsets:
- addresses:
  - ip: 192.168.0.4
    nodeName: controlplane
    targetRef:
      kind: Pod
      name: coredns-7fcfc6d89b-fmdxk
      namespace: kube-system
      uid: 99c7740f-422a-4d27-993c-ae81a7927304
  - ip: 192.168.0.5
    nodeName: controlplane
    targetRef:
      kind: Pod
      name: coredns-7fcfc6d89b-nk2kw
      namespace: kube-system
      uid: 4be53e2c-aa90-4625-b868-29c3eb436d64
  ports:
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: dns
    port: 53
    protocol: UDP
controlplane:~$ ^C
controlplane:~$ kubectl exec -it dns-rs-cka-9rz2h -- nslookup kubernetes.default
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

controlplane:~$ kubectl exec -it dns-rs-cka-9rz2h -- nslookup kubernetes.default > dns-output.txt
controlplane:~$ ^C
controlplane:~$ ls    
coredns.yaml  deploy.yaml  dns-output.txt  dns-pod-test.txt  filesystem  kube-dns-svc.yaml
controlplane:~$ vi deploy.yaml 
controlplane:~$ k create ns dns-ns
namespace/dns-ns created
controlplane:~$ k apply -f deploy.yaml 
replicaset.apps/dns-rs-cka created
controlplane:~$ 