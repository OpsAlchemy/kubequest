# DaemonSets

## Question 1

**Namespace:** `ops`  
**Name:** `node-config-writer`  
**Image:** `busybox:1.36`  
**Command:** `sh -c "echo $NODE_NAME > /host/node.txt && sleep 3600"`  

### Specifications

**Nodes:**
- All worker nodes

**Environment Variables:**
- `NODE_NAME` from Downward API

**Volumes:**
- HostPath: `/etc/node-info`
- Mount path: `/host`

**Scheduling:**
- One Pod per node

### Task

Create a DaemonSet that writes the node name to a file on each worker node.

---

## Question 2

**Namespace:** `infra`  
**Name:** `zone-aware-daemon`  
**Image:** `busybox:1.36`  
**Command:** `printenv ZONE && sleep 3600`  

### Specifications

**Nodes:**
- Only nodes with label `topology.kubernetes.io/zone`

**Environment Variables:**
- Set `ZONE` environment variable from the node label `topology.kubernetes.io/zone` using Downward API

**Scheduling:**
- One Pod per eligible node

### Task

Create a DaemonSet that reads a node label and exposes it as an environment variable inside the Pod. Use nodeAffinity to schedule only on nodes that have the `topology.kubernetes.io/zone` label.

---

## Question 3

**Namespace:** `monitoring`  
**Name:** `log-collector`  
**Image:** `busybox:1.36`  
**Command:** `sh -c "while true; do echo '[SYSTEM] Node: '$HOSTNAME' - Memory: $(free -m | grep Mem | awk '{print $3}')MB' >> /var/log/node-metrics.log; sleep 30; done"`  

### Specifications

**Nodes:**
- All nodes

**Environment Variables:**
- `HOSTNAME` from Downward API (pod.spec.nodeName)

**Volumes:**
- HostPath: `/var/log`
- Mount path: `/var/log`
- Type: DirectoryOrCreate

**Resources:**
- Requests: CPU 100m, Memory 64Mi
- Limits: CPU 200m, Memory 128Mi

**Scheduling:**
- One Pod per node
- Tolerate all taints

### Task

Create a DaemonSet that collects and logs node metrics to a shared log file on each node. The Pod should be able to run on all nodes including master nodes by using tolerations.

---

## Question 4

**Namespace:** `system`  
**Name:** `network-monitor`  
**Image:** `busybox:1.36`  
**Command:** `sh -c "while true; do echo '[TIMESTAMP]' $(date '+%Y-%m-%d %H:%M:%S') '[INTERFACE] eth0:' $(ip addr show eth0 | grep 'inet ' | awk '{print $2}') '[GATEWAY]' $(ip route | grep default | awk '{print $3}') >> /var/log/network-info.log; sleep 60; done"`  

### Specifications

**Nodes:**
- All nodes

**Environment Variables:**
- `NODE_IP` from pod.status.podIP

**Volumes:**
- HostPath: `/var/log`
- Mount path: `/var/log`
- Type: DirectoryOrCreate

**Init Container:**
- Image: busybox:1.36
- Command: Create `/var/log/network-info.log` if it doesn't exist

**Resources:**
- Requests: CPU 50m, Memory 32Mi
- Limits: CPU 100m, Memory 64Mi

**Scheduling:**
- One Pod per node
- Skip control-plane nodes (use nodeSelector or taints/tolerations)

### Task

Create a DaemonSet that monitors network information on each worker node and logs it periodically. Use an init container to ensure the log file exists, and verify that Pods do NOT run on control-plane nodes.
