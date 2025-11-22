cat <<EOF > high-prio.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-prio
spec:
  priorityClassName: high-priority
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "1", "--vm", "1", "--vm-bytes", "512M", "--timeout", "300s"]
    resources:
      requests:
        memory: "200Mi"
        cpu: "200m"
EOF












high-prio


# request additional memory
sed -i 's/200Mi/600Mi/' high-prio.yaml

# restart the pod
kubectl replace -f high-prio.yaml --force
# watch the low priority pod get evicted while the high priority gets scheduled again
kubectl get po -w 
















controlplane:~$ k get priorityclass
NAME                      VALUE        GLOBAL-DEFAULT   AGE   PREEMPTIONPOLICY
system-cluster-critical   2000000000   false            14d   PreemptLowerPriority
system-node-critical      2000001000   false            14d   PreemptLowerPriority
controlplane:~$ k create priorityclass -h
Create a priority class with the specified name, value, globalDefault and description.

Aliases:
priorityclass, pc

Examples:
  # Create a priority class named high-priority
  kubectl create priorityclass high-priority --value=1000 --description="high priority"
  
  # Create a priority class named default-priority that is considered as the global default priority
  kubectl create priorityclass default-priority --value=1000 --global-default=true
--description="default priority"
  
  # Create a priority class named high-priority that cannot preempt pods with lower priority
  kubectl create priorityclass high-priority --value=1000 --description="high priority"
--preemption-policy="Never"

Options:
    --allow-missing-template-keys=true:
        If true, ignore any errors in templates when a field or map key is missing in the
        template. Only applies to golang and jsonpath output formats.

    --description='':
        description is an arbitrary string that usually provides guidelines on when this priority
        class should be used.

    --dry-run='none':
        Must be "none", "server", or "client". If client strategy, only print the object that
        would be sent, without sending it. If server strategy, submit server-side request without
        persisting the resource.

    --field-manager='kubectl-create':
        Name of the manager used to track field ownership.

    --global-default=false:
        global-default specifies whether this PriorityClass should be considered as the default
        priority.

    -o, --output='':
        Output format. One of: (json, yaml, name, go-template, go-template-file, template,
        templatefile, jsonpath, jsonpath-as-json, jsonpath-file).

    --preemption-policy='PreemptLowerPriority':
        preemption-policy is the policy for preempting pods with lower priority.

    --save-config=false:
        If true, the configuration of current object will be saved in its annotation. Otherwise,
        the annotation will be unchanged. This flag is useful when you want to perform kubectl
        apply on this object in the future.

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

    --value=0:
        the value of this priority class.

Usage:
  kubectl create priorityclass NAME --value=VALUE --global-default=BOOL
[--dry-run=server|client|none] [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
controlplane:~$ k create priorityclass high-priority --value=1000000
priorityclass.scheduling.k8s.io/high-priority created
controlplane:~$ k create deploy low-prio --image polinux/stress --dry-run=client -o yaml > d.yaml
controlplane:~$ vi d.yaml
controlplane:~$ k apply -f d.yaml
deployment.apps/low-prio created
controlplane:~$ k get pods
NAME                        READY   STATUS              RESTARTS   AGE
low-prio-55c4ff8b4f-92tbn   0/1     ContainerCreating   0          3s
low-prio-55c4ff8b4f-thrx4   0/1     ContainerCreating   0          3s
low-prio-55c4ff8b4f-vqq4r   0/1     ContainerCreating   0          3s
controlplane:~$ k get pods -w
NAME                        READY   STATUS              RESTARTS   AGE
low-prio-55c4ff8b4f-92tbn   0/1     ContainerCreating   0          7s
low-prio-55c4ff8b4f-thrx4   0/1     ContainerCreating   0          7s
low-prio-55c4ff8b4f-vqq4r   1/1     Running             0          7s
low-prio-55c4ff8b4f-thrx4   1/1     Running             0          18s
low-prio-55c4ff8b4f-92tbn   1/1     Running             0          29s
low-prio-55c4ff8b4f-92tbn   1/1     Running             1 (4s ago)   31s
^Ccontrolplane:~$ cp d.yaml dh.yaml
controlplane:~$ vi dh.yaml
controlplane:~$ k apply -f dh.yaml 
deployment.apps/high-prio created
controlplane:~$ k get pods -w
NAME                         READY   STATUS              RESTARTS      AGE
high-prio-7f6988b6dd-5flz2   0/1     ContainerCreating   0             3s
high-prio-7f6988b6dd-98zvr   0/1     Pending             0             3s
high-prio-7f6988b6dd-f5r4c   0/1     ContainerCreating   0             3s
low-prio-55c4ff8b4f-92tbn    0/1     CrashLoopBackOff    2 (23s ago)   2m
low-prio-55c4ff8b4f-thrx4    1/1     Running             1 (74s ago)   2m
low-prio-55c4ff8b4f-vqq4r    1/1     Running             1 (48s ago)   2m
high-prio-7f6988b6dd-f5r4c   1/1     Running             0             11s
high-prio-7f6988b6dd-f5r4c   0/1     OOMKilled           0             15s
low-prio-55c4ff8b4f-92tbn    1/1     Running             3 (35s ago)   2m12s
high-prio-7f6988b6dd-5flz2   0/1     OOMKilled           1 (11s ago)   16s
low-prio-55c4ff8b4f-vqq4r    0/1     OOMKilled           1 (61s ago)   2m13s
high-prio-7f6988b6dd-f5r4c   0/1     OOMKilled           1 (8s ago)    16s
high-prio-7f6988b6dd-5flz2   0/1     CrashLoopBackOff    1 (13s ago)   23s
high-prio-7f6988b6dd-5flz2   1/1     Running             2 (25s ago)   35s
low-prio-55c4ff8b4f-vqq4r    1/1     Running             2 (21s ago)   2m32s
high-prio-7f6988b6dd-5flz2   0/1     OOMKilled           2 (25s ago)   35s
high-prio-7f6988b6dd-f5r4c   0/1     OOMKilled           2 (23s ago)   35s
low-prio-55c4ff8b4f-thrx4    0/1     OOMKilled           1 (107s ago)   2m33s
high-prio-7f6988b6dd-f5r4c   0/1     CrashLoopBackOff    2 (12s ago)    41s
high-prio-7f6988b6dd-5flz2   0/1     CrashLoopBackOff    2 (16s ago)    42s
low-prio-55c4ff8b4f-thrx4    0/1     CrashLoopBackOff    1 (18s ago)    2m48s
low-prio-55c4ff8b4f-thrx4    1/1     Running             2 (22s ago)    2m52s
low-prio-55c4ff8b4f-92tbn    0/1     OOMKilled           3 (75s ago)    2m52s
high-prio-7f6988b6dd-f5r4c   1/1     Running             3 (27s ago)    56s
high-prio-7f6988b6dd-5flz2   0/1     OOMKilled           3 (35s ago)    61s
high-prio-7f6988b6dd-f5r4c   0/1     OOMKilled           3 (32s ago)    61s
low-prio-55c4ff8b4f-92tbn    0/1     CrashLoopBackOff    3 (12s ago)    3m3s
high-prio-7f6988b6dd-f5r4c   0/1     CrashLoopBackOff    3 (14s ago)    72s
high-prio-7f6988b6dd-5flz2   0/1     CrashLoopBackOff    3 (14s ago)    73s
^Ccontrolplane:~$ cat <<EOF > high-prio.yaml
> apiVersion: v1
> kind: Pod
> metadata:
>   name: high-prio
> spec:
>   priorityClassName: high-priority
>   containers:
>   - name: stress
>     image: polinux/stress
>     command: ["stress"]
>     args: ["--cpu", "1", "--vm", "1", "--vm-bytes", "512M", "--timeout", "300s"]
>     resources:
>       requests:
>         memory: "200Mi"
>         cpu: "200m"
> EOF
controlplane:~$ k get po 
NAME                         READY   STATUS             RESTARTS      AGE
high-prio-7f6988b6dd-5flz2   0/1     CrashLoopBackOff   3 (37s ago)   96s
high-prio-7f6988b6dd-98zvr   0/1     Pending            0             96s
high-prio-7f6988b6dd-f5r4c   0/1     CrashLoopBackOff   3 (38s ago)   96s
low-prio-55c4ff8b4f-92tbn    0/1     CrashLoopBackOff   3 (42s ago)   3m33s
low-prio-55c4ff8b4f-thrx4    1/1     Running            2 (63s ago)   3m33s
low-prio-55c4ff8b4f-vqq4r    1/1     Running            2 (82s ago)   3m33s
controlplane:~$ k get po
NAME                         READY   STATUS             RESTARTS      AGE
high-prio-7f6988b6dd-5flz2   0/1     CrashLoopBackOff   3 (47s ago)   106s
high-prio-7f6988b6dd-98zvr   0/1     Pending            0             106s
high-prio-7f6988b6dd-f5r4c   0/1     CrashLoopBackOff   3 (48s ago)   106s
low-prio-55c4ff8b4f-92tbn    0/1     CrashLoopBackOff   3 (52s ago)   3m43s
low-prio-55c4ff8b4f-thrx4    1/1     Running            2 (73s ago)   3m43s
low-prio-55c4ff8b4f-vqq4r    1/1     Running            2 (92s ago)   3m43s
controlplane:~$ ls
d.yaml  dh.yaml  filesystem  high-prio.yaml
controlplane:~$ k delete -f dh.yaml
deployment.apps "high-prio" deleted
controlplane:~$ k apply -f high-prio.yaml
pod/high-prio created
controlplane:~$ k get po
NAME                        READY   STATUS              RESTARTS       AGE
high-prio                   0/1     ContainerCreating   0              3s
low-prio-55c4ff8b4f-92tbn   0/1     OOMKilled           4 (78s ago)    4m9s
low-prio-55c4ff8b4f-thrx4   1/1     Running             2 (99s ago)    4m9s
low-prio-55c4ff8b4f-vqq4r   1/1     Running             2 (118s ago)   4m9s
controlplane:~$ k get po -w
NAME                        READY   STATUS             RESTARTS       AGE
high-prio                   1/1     Running            0              13s
low-prio-55c4ff8b4f-92tbn   0/1     CrashLoopBackOff   4 (25s ago)    4m19s
low-prio-55c4ff8b4f-thrx4   1/1     Running            2 (109s ago)   4m19s
low-prio-55c4ff8b4f-vqq4r   1/1     Running            2 (2m8s ago)   4m19s
high-prio                   0/1     OOMKilled          0              13s
high-prio                   1/1     Running            1 (4s ago)     16s
high-prio                   0/1     Error              1 (4s ago)     16s
high-prio                   0/1     CrashLoopBackOff   1 (13s ago)    28s
high-prio                   1/1     Running            2 (14s ago)    29s
high-prio                   0/1     OOMKilled          2 (17s ago)    32s
cat <<EOF > high-prio.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-prio
spec:
  priorityClassName: high-priority
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "1", "--vm", "1", "--vm-bytes", "512M", "--timeout", "300s"]
    resources:
      requests:
        memory: "200Mi"
        cpu: "200m"
EOF
cat <<EOF > high-prio.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-prio
spec:
  priorityClassName: high-priority
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "1", "--vm", "1", "--vm-bytes", "512M", "--timeout", "300s"]
    resources:
      requests:
        memory: "200Mi"
        cpu: "200m"
EOF
high-prio                   0/1     CrashLoopBackOff   2 (14s ago)    44s
high-prio                   1/1     Running            3 (28s ago)    58s
high-prio                   0/1     OOMKilled          3 (33s ago)    63s
^Ccontrolplane:~$ k get po -w
NAME                        READY   STATUS             RESTARTS        AGE
high-prio                   0/1     OOMKilled          3 (40s ago)     70s
low-prio-55c4ff8b4f-92tbn   0/1     CrashLoopBackOff   4 (82s ago)     5m16s
low-prio-55c4ff8b4f-thrx4   1/1     Running            2 (2m46s ago)   5m16s
low-prio-55c4ff8b4f-vqq4r   1/1     Running            2 (3m5s ago)    5m16s
high-prio                   0/1     CrashLoopBackOff   3 (13s ago)     75s
low-prio-55c4ff8b4f-92tbn   1/1     Running            5 (92s ago)     5m26s
low-prio-55c4ff8b4f-92tbn   0/1     OOMKilled          5 (99s ago)     5m33s
^Ccontrolplane:~$ k get priority class
error: the server doesn't have a resource type "priority"
controlplane:~$ k describe pod high-prio
Name:                 high-prio
Namespace:            default
Priority:             1000000
Priority Class Name:  high-priority
Service Account:      default
Node:                 controlplane/172.30.1.2
Start Time:           Tue, 02 Sep 2025 11:30:29 +0000
Labels:               <none>
Annotations:          cni.projectcalico.org/containerID: cce006b9661b1010fbb75b9c62ae82b407a2e83f864948e8f980ef00cce79cc8
                      cni.projectcalico.org/podIP: 192.168.0.11/32
                      cni.projectcalico.org/podIPs: 192.168.0.11/32
Status:               Running
IP:                   192.168.0.11
IPs:
  IP:  192.168.0.11
Containers:
  stress:
    Container ID:  containerd://4fffd3a8a2e24d12b3c6926b251010be4e81b5d1c38f2fb028e0240b20f5ddb6
    Image:         polinux/stress
    Image ID:      docker.io/polinux/stress@sha256:b6144f84f9c15dac80deb48d3a646b55c7043ab1d83ea0a697c09097aaad21aa
    Port:          <none>
    Host Port:     <none>
    Command:
      stress
    Args:
      --cpu
      1
      --vm
      1
      --vm-bytes
      512M
      --timeout
      300s
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Tue, 02 Sep 2025 11:31:25 +0000
      Finished:     Tue, 02 Sep 2025 11:31:31 +0000
    Ready:          False
    Restart Count:  3
    Requests:
      cpu:        200m
      memory:     200Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kt4wx (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-kt4wx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  104s                default-scheduler  Successfully assigned default/high-prio to controlplane
  Normal   Pulled     103s                kubelet            Successfully pulled image "polinux/stress" in 655ms (655ms including waiting). Image size: 4041495 bytes.
  Normal   Pulled     91s                 kubelet            Successfully pulled image "polinux/stress" in 849ms (849ms including waiting). Image size: 4041495 bytes.
  Normal   Pulled     77s                 kubelet            Successfully pulled image "polinux/stress" in 688ms (688ms including waiting). Image size: 4041495 bytes.
  Normal   Pulling    50s (x4 over 104s)  kubelet            Pulling image "polinux/stress"
  Normal   Created    49s (x4 over 103s)  kubelet            Created container: stress
  Normal   Started    49s (x4 over 103s)  kubelet            Started container stress
  Normal   Pulled     49s                 kubelet            Successfully pulled image "polinux/stress" in 875ms (875ms including waiting). Image size: 4041495 bytes.
  Warning  BackOff    5s (x7 over 89s)    kubelet            Back-off restarting failed container stress in pod high-prio_default(43a96e12-8c0a-4b53-a777-2026440b86e5)
controlplane:~$ vi high-prio.yaml 
controlplane:~$ k delete -f high-prio.yaml 
pod "high-prio" deleted
k apcontrolplane:~$ k apply -f high-prio.yaml 
pod/high-prio created
controlplane:~$ k get po -w
NAME                        READY   STATUS              RESTARTS        AGE
high-prio                   0/1     ContainerCreating   0               3s
low-prio-55c4ff8b4f-cmb6q   0/1     Pending             0               2s
low-prio-55c4ff8b4f-thrx4   1/1     Running             2 (4m2s ago)    6m32s
low-prio-55c4ff8b4f-vqq4r   1/1     Running             2 (4m21s ago)   6m32s
high-prio                   0/1     ContainerCreating   0               3s
high-prio                   1/1     Running             0               8s
low-prio-55c4ff8b4f-thrx4   0/1     OOMKilled           2 (4m8s ago)    6m38s
low-prio-55c4ff8b4f-thrx4   0/1     CrashLoopBackOff    2 (16s ago)     6m51s
low-prio-55c4ff8b4f-thrx4   1/1     Running             3 (31s ago)     7m6s
# request additional memory
sed -i 's/200Mi/600Mi/' high-prio.yaml

# restart the pod
kubectl replace -f high-prio.yaml --force
low-prio-55c4ff8b4f-thrx4   0/1     OOMKilled           3 (35s ago)     7m10s
low-prio-55c4ff8b4f-thrx4   0/1     CrashLoopBackOff    3 (12s ago)     7m21s
^Ccontrolplane:~$ 