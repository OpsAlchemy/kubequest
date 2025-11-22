1. A developer needs a persistent volume for an application. Create a PersistentVolumeClaim with:
- Name: app-pvc
- Size 100Mi
- Access mode ReadWriteOnce
- Using the storage class "local-path"

Create a pod that mounts this PVC at /data and verify that the volume is automatically created and mounted.

Ref: Alta3-Research

2. Manually create a PersistentVolume that:
    - is named static-pv-example
    - requested 200Mi
    - uses a hostPath on node-1 
    - access mode ReadWriteOnce
    - Retain reclaim policy
Then create a matching PersistentVolumeClaim ( static-pvc-example ) to bind to it.

Ref: Alta3-Research - https://www.youtube.com/watch?v=eGv6iPWQKyo [ 8.24 ]

3. For this question, please set this context (In exam, diff cluster name)

kubectl config use-context kubernetes-admin@kubernetes
Create a storage class called green-stc  as per the properties given below:
- Provisioner should be kubernetes.io/no-provisioner . 
- Volume binding mode should be WaitForFirstConsumer .

Volume expansion should be enabled

Ref: killercoda - https://killercoda.com/sachin/course/CKA/Storage-class

4. my-pod-cka pod is stuck in a Pending state, Fix this issue
Note: Don't remove any specification 

Ref: https://killercoda.com/sachin/course/CKA/pod-issue-6

5. Create a new user setup kubeconfig manually, create context and change to it

6. An existing nginx pod, my-pod-cka and Persistent Volume Claim (PVC) named my-pvc-cka are available. Your task is to implement the following modifications:
- NOTE:- PVC to PV binding and my-pod-cka pods sometimes takes around 2Mins to Up & Running So Please wait
- Update the pod to include a sidecar container that uses the busybox image. Ensure that this sidecar container remains operational by including an appropriate command "tail -f /dev/null" .
- Share the shared-storage volume between the main application and the sidecar container, mounting it at the path /var/www/shared . Additionally, ensure that the sidecar container has read-only access to this shared volume.

Ref: https://killercoda.com/sachin/course/CKA/Shared-Volume

7. For this question, please set this context (In exam, diff cluster name)

- Create a Storage Class named fast-storage with a provisioner of kubernetes.io/no-provisioner and a volumeBindingMode of Immediate .
- Create a Persistent Volume (PV) named fast-pv-cka with a storage capacity of 50Mi using the fast-storage Storage Class with ReadWriteOnce permission and host path /tmp/fast-data .
- Create a Persistent Volume Claim (PVC) named fast-pvc-cka that requests 30Mi of storage from the fast-pv-cka PV(using the fast-storage Storage Class).
- Create a Pod named fast-pod-cka with nginx:latest image that uses the fast-pvc-cka PVC and mounts the volume at the path /app/data .

Ref: https://killercoda.com/sachin/course/CKA/sc-pv-pvc-pod

8. For this question, please set this context (In exam, diff cluster name)

Your task involves setting up storage components in a Kubernetes cluster. Follow these steps:
- Step 1: Create a Storage Class named blue-stc-cka with the following properties:
    Provisioner: kubernetes.io/no-provisioner
    Volume binding mode: WaitForFirstConsumer
- Step 2: Create a Persistent Volume (PV) named blue-pv-cka with the following properties:
    Capacity: 100Mi
    Access mode: ReadWriteOnce
    Reclaim policy: Retain
    Storage class: blue-stc-cka
    Local path: /opt/blue-data-cka
    Node affinity: Set node affinity to create this PV on controlplane .
- Step 3:  Create a Persistent Volume Claim (PVC) named blue-pvc-cka with the following properties:
    Access mode: ReadWriteOnce
    Storage class: blue-stc-cka
    Storage request: 50Mi
    The volume should be bound to blue-pv-cka .
Ref: https://killercoda.com/sachin/course/CKA/sc-pv-pvc

9. A Kubernetes pod definition file named nginx-pod-cka.yaml is available. Your task is to make the following modifications to the manifest file: 
- Create a Persistent Volume Claim (PVC) with the name nginx-pvc-cka . This PVC should request 80Mi of storage from an existing Persistent Volume (PV) named nginx-pv-cka and Storage Class namednginx-stc-cka . Use the access mode ReadWriteOnce.
- Add the created nginx-pvc-cka PVC to the existing nginx-pod-cka POD definition.
- Mount the volume claimed by nginx-pvc-cka at the path /var/www/html within the nginx-pod-cka POD.
- Add tolerations with the key node-role.kubernetes.io/control-plane set to Exists and effect NoSchedule to the nginx-pod-cka Pod
- Ensure that the nginx-pod-cka POD is running and that the Persistent Volume (PV) is successfully bound .

Ref: https://killercoda.com/sachin/course/CKA/pvc-pod

10. A persistent volume named red-pv-cka is available. Your task is to create a PersistentVolumeClaim (PVC) named red-pvc-cka and request 30Mi of storage from the red-pv-cka PersistentVolume (PV).
Ensure the following criteria are met:
    Access mode: ReadWriteOnce
    Storage class: manual

Ref: https://killercoda.com/sachin/course/CKA/pvc

11. You are responsible for provisioning storage for a Kubernetes cluster. Your task is to create a PersistentVolume (PV), a PersistentVolumeClaim (PVC), and deploy a pod that uses the PVC for shared storage.

Here are the specific requirements:

- Create a PersistentVolume (PV) named my-pv-cka with the following properties:
    Storage capacity: 100Mi
    Access mode: ReadWriteOnce
    Host path: /mnt/data
    Storage class: standard
- Create a PersistentVolumeClaim (PVC) named my-pvc-cka to claim storage from the my-pv-cka PV, with the following properties:
    Storage class: standard
    request storage: 100Mi (less than)
- Deploy a pod named my-pod-cka using the nginx container image.
- Mount the PVC, my-pvc-cka , to the pod at the path /var/www/html.
  Ensure that the PV, PVC, and pod are successfully created, and the pod is in a Running state.

Ref: https://killercoda.com/sachin/course/CKA/pv-pvc-pod

12. Create a PersistentVolume (PV) and a PersistentVolumeClaim (PVC) using an existing storage class named gold-stc-cka to meet the following requirements:

Step 1: Create a Persistent Volume (PV)
    Name the PV as gold-pv-cka .
    Set the capacity to 50Mi .
    Use the volume type hostpath with the path /opt/gold-stc-cka .
    Assign the storage class as gold-stc-cka .
    Ensure that the PV is created on node01 , where the /opt/gold-stc-cka directory already exists.
    Apply a label to the PV with key tier and value white .

Step 2: Create a Persistent Volume Claim (PVC)
    Name the PVC as gold-pvc-cka .
    Request 30Mi of storage from the PV gold-pv-cka using the matchLabels criterion.
    Use the gold-stc-cka storage class.
    Set the access mode to ReadWriteMany .

Ref: https://killercoda.com/sachin/course/CKA/pv-pvc

13. Create a PersistentVolume (PV) named black-pv-cka with the following specifications:
    Volume Type: hostPath
    Path: /opt/black-pv-cka
    Capacity: 50Mi

Ref: https://killercoda.com/sachin/course/CKA/pv

14. You are tasked with deploying a web application named app-alpha to the production namespace. This application requires a complex configuration from a file named app.config. The development team has provided you with the configuration for three different environments. You must use the production values.

File: app-config-data.yaml
```yaml
# Development Environment Config
database_url: dev.db.example.com
debug_mode: true
log_level: verbose
feature_x_enabled: true

# Staging Environment Config
database_url: staging.db.example.com
debug_mode: true
log_level: debug
feature_x_enabled: false

# Production Environment Config
database_url: prod.db.example.com:6379
debug_mode: false
log_level: warn
feature_x_enabled: true
max_connections: 250
api_timeout: 30s
```
Your Tasks:

1. Create the ConfigMap:

- Create a ConfigMap named app-alpha-config in the production namespace.
- The ConfigMap must be created from the file app-config-data.yaml. However, you must only use the key-value pairs under the # Production Environment Config section. (Hint: You might need to split the file or use a different method).
- The key in the ConfigMap for this data should be application.properties.

2. Create the Pod:
- Write a Pod manifest named app-alpha-pod.yaml.
- The Pod runs a container using the image nginx:alpine.
- Mount the application.properties key from the app-alpha-config ConfigMap as a volume.
- The volume should be mounted at the path /etc/app/config/ inside the container.
- Ensure the volume is mounted as read-only.

3. Test the Configuration:
- Deploy the Pod and use kubectl exec to cat the contents of the file /etc/app/config/application.properties inside the container. Verify the contents match the production configuration.

4. Update and Observe:
- Update the ConfigMap to change the log_level from warn to error.
- Without restarting the Pod, check the file inside the container again after a short period. What is the value of log_level now? Explain the behavior.

5. Create a Specialized Key Mount:
- Now, modify the Pod spec (create a new Pod named app-alpha-pod-2 if needed) to mount only the max_connections key from the same ConfigMap.
- This key should be mounted as a file named connection-pool.conf at the path /app/options/.
- Check the contents of the file. What is the content of /app/options/connection-pool.conf?





15. You need to deploy a financial service API named payments-api in the fin-prod namespace. This service is extremely sensitive and requires TLS encryption. You have been given the following files:
- tls.crt - The TLS certificate.
- tls.key - The private key for the certificate.
- api-credentials.txt - A file containing a single line: API_KEY="sdjk93-2idj83-3d8jdi".

Your Tasks:
1. Namespace and Secrets:
- Create the namespace fin-prod.
- Create a generic Secret named payments-api-credentials from the file api-credentials.txt.
- Create a TLS Secret named payments-api-tls using the tls.crt and tls.key files.

2. Create the Pod:
- Write a Pod manifest for a Pod named payments-api.
- The Pod uses the image bitnami/nginx.
- It must mount two volumes:

    Volume 1: The TLS Secret (payments-api-tls). Mount this volume so the certificate and key are available at /etc/nginx/certs/. The files should maintain their names (tls.crt and tls.key).
    Volume 2: The credentials Secret (payments-api-credentials). Mount this volume so the api-credentials.txt file is available at /app/secrets/. The mounted file should be named api.key instead of its original name.

- The containers must not have read/write access to the root filesystem (readOnlyRootFilesystem: true). Ensure the volume mounts are read-only.

3. Verify Security Context:
- Apply the Pod manifest. If it fails to start, diagnose the issue related to the security context and correct it. (Hint: The bitnami/nginx image writes to a temporary directory at startup).

4. Inspect the Secrets:
- Use kubectl exec to list the contents of /etc/nginx/certs/ and /app/secrets/. Verify the permissions (mode) of the files in these directories. What do you notice about the file permissions, and why is this important?
- Decode and check the content of the api.key file. Does it match the original content of api-credentials.txt?

5. Simulate a Secret Rotation:
- Update the payments-api-credentials Secret with a new API key: API_KEY="new-key-12345-67890".
- Without restarting the Pod, check the content of the /app/secrets/api.key file after a short period. What is the value? Explain the behavior and its implications.


16. ConfigMap & Values
### Step 1: Create main ConfigMap

Create a ConfigMap named **cfg-main-cka** with the following keys:

* `app.properties` containing

  ```
  database.url=jdbc:postgresql://db:5432/mydb
  feature.flag=true
  log.level=INFO
  ```
* `ui.conf=theme=light`

### Step 2: Create extra ConfigMap

Create a ConfigMap named **cfg-extra-cka** with keys:

* `extra1=x1`
* `extra2=x2`

### Step 3: Create certificate ConfigMap

Generate a self-signed certificate:

```
openssl req -x509 -newkey rsa:2048 -nodes -keyout tls.key -out tls.crt -subj "/CN=test/O=cka"
```

Create a ConfigMap named **cfg-cert-cka** from these files so it contains:

* `tls.crt`
* `tls.key`

### Step 4: Create sensitive Secret

Create a Secret named **sensitive-cka** with keys:

* `db-user=admin`
* `db-pass=s3cr3t!`

### Step 5: Define Pod with volumes

Create a Pod named **app-pod-cka** with main container `nginx`. The Pod must:

* Mount full **cfg-main-cka** at `/etc/app`
* Mount only `app.properties` from **cfg-main-cka** at `/etc/app/app.properties` using subPath (read-only)
* Mount **cfg-extra-cka** at `/etc/app/extras` with file mode `0640`
* Mount **cfg-cert-cka** at `/etc/tls` so `tls.crt` and `tls.key` are available
* Mount **sensitive-cka** exposing only `db-pass` at `/etc/secret/db-password.txt` with mode `0600`
* Mount projected volume at `/proj` combining **cfg-main-cka** and **sensitive-cka**
* Use EmptyDir `work` for writable config populated by initContainer
* Use EmptyDir `logs` for shared logging
* Use EmptyDir `scripts` for runtime scripts
* Use a downwardAPI volume exposing pod name and namespace into `/etc/downward`

### Step 6: Configure initContainer

Add an initContainer **bootstrap** using `busybox`. It must:

* Mount `cfg-main-cka` at `/tmp/config` and `work` at `/work`
* Copy all files from `/tmp/config` to `/work`
* Generate a script `/scripts/start.sh` that prints “config ready”, displays the pod’s name and namespace by reading from `/etc/downward`, and writes a health-check file into `/work/ready.txt`
* Generate another script `/scripts/rotate.sh` that archives files in `/mnt/data` (logs) older than 30 seconds
* Set ownership of `/work` and `/scripts` to UID 1000

### Step 7: Configure main container

The main container `nginx` must:

* Mount `/work` at `/usr/share/nginx/html/config`
* Mount `/scripts` at `/opt/scripts` and execute `/opt/scripts/start.sh` via a lifecycle `postStart` hook
* Consume environment variables `EXTRA_ONE` from **cfg-extra-cka.extra1**, `DB_USER` from **sensitive-cka.db-user**, and downward API fields `POD_NAME` and `POD_NAMESPACE`
* Run as `runAsUser=1000` and `runAsGroup=3000`
* Requests: `cpu=50m`, `memory=64Mi`
* Limits: `cpu=250m`, `memory=256Mi`

### Step 8: Add logger sidecar

Add sidecar container **logger** using `busybox`. It must:

* Mount `logs` EmptyDir at `/mnt/data`
* Continuously append timestamps and `$POD_NAME` from downward API env into `/mnt/data/nginx.log`
* Periodically execute `/scripts/rotate.sh` to compress logs

### Step 9: Add auditor sidecar

Add sidecar container **auditor** using `busybox`. It must:

* Mount projected volume `/proj` read-only
* Verify that both config and secret files exist and print results into `/mnt/data/audit.txt`
* Deny access to `work` and `scripts`

### Step 10: Add maintenance sidecar

Add sidecar container **maintainer** using `busybox`. It must:

* Mount `work` and delete temp files older than 1 minute
* Mount `/etc/secret` and verify permissions remain `0600`
* Append warnings or success messages into `/mnt/data/maint.log`

### Step 11: Add watcher sidecar

Add sidecar container **watcher** using `busybox`. It must:

* Mount downwardAPI volume at `/etc/downward`
* Continuously read and print pod metadata (name, namespace, UID) into `/mnt/data/watch.log`
* Exit with error if metadata is missing, simulating a readiness watchdog

### Step 12: Scenarios demonstrated

* ConfigMaps mounted fully and partially with subPath
* Secrets mounted securely with strict file modes
* Certificates provided through ConfigMap for nginx TLS
* Projected volumes merging configs and secrets
* Writable runtime config with initContainer and EmptyDir
* Runtime script generation and lifecycle hooks executing them
* Environment variable injection from ConfigMaps, Secrets, and downward API
* Logger sidecar generating and rotating logs
* Auditor sidecar verifying integrity of config and secret
* Maintainer sidecar cleaning up temp files and enforcing permissions
* Watcher sidecar monitoring pod metadata via downward API and acting as a watchdog


17. ### Step 1: Create a Pod using the Downward API

Create a Pod named **downwardapi-pod-cka** with the following requirements:

* Use the `busybox` image with command `sleep 3600`
* Mount a volume of type `downwardAPI` at `/etc/podinfo`
* The volume must include the following items:

  * `pod_name` from `metadata.name`
  * `pod_namespace` from `metadata.namespace`
  * `labels` from `metadata.labels`
  * `annotations` from `metadata.annotations`
* Add environment variables to expose pod fields inside the container:

  * `POD_NAME` from `metadata.name`
  * `POD_NAMESPACE` from `metadata.namespace`
  * `NODE_NAME` from `spec.nodeName`
* The container must run with requests `cpu=50m` and `memory=32Mi` and limits `cpu=100m` and `memory=64Mi`.

### Step 2: Add simple scripting

Configure the container to periodically print the values of environment variables and the contents of `/etc/podinfo` into stdout every 10 seconds.

### Step 3: Use cases

* Demonstrates how the Downward API can expose pod metadata and annotations to containers via environment variables and volumes.
* Useful for debugging, telemetry, and applications that must be aware of their runtime context without needing external APIs.
* Provides a simple pattern to log pod identity and metadata into logs for observability.

18. ### Step 1: Create a Pod with shared emptyDir

Create a Pod named **writer-pod-cka** with the following:

* Container `busybox` that runs a shell loop appending `"hello world"` every 10 seconds into `/mnt/data/hello.txt`
* Use an `emptyDir` volume named `shared` mounted at `/mnt/data`

### Step 2: Create a Pod with cache emptyDir

Create a Pod named **cache-pod-cka** with the following:

* Container `registry.k8s.io/test-webserver` mounting an `emptyDir` volume named `cache-volume` at `/cache`
* Set a `sizeLimit` of `500Mi` for the emptyDir

### Step 3: Create a Deployment with two containers sharing memory-backed emptyDir

Create a Deployment named **hmm-intresting-cka** with these specs:

* 1 replica, label `app=hmm-intresting`
* Use an `emptyDir` volume named `shared` with medium `Memory` and sizeLimit `500Mi`
* First container `nginx` mounting `shared` at `/usr/share/nginx/html` and exposing port 80
* Second container `curl` using image `badouralix/curl-jq` mounting the same `shared` volume at `/cache` and running a script that:

  * Initializes `/cache/joke.json` with empty JSON array `[]`
  * Every 10 seconds fetches a new joke from `https://api.chucknorris.io/jokes/random`, appends it to the JSON array in `/cache/joke.json` using `jq`, and ensures file permissions are `644`

### Step 4: Create a Service

Create a Service named **hmm-intresting-svc-cka** with the following:

* Type `ClusterIP`
* Selector `app=hmm-intresting`
* Expose port 80/TCP

### Step 5: Use cases demonstrated

* Using `emptyDir` for simple data sharing between containers in the same Pod
* Applying `sizeLimit` to restrict usage of ephemeral storage
* Using `emptyDir` with medium `Memory` to store temporary data in RAM
* Combining an `nginx` web server with a sidecar container that dynamically generates content (jokes) into a shared volume, making the data immediately available via HTTP
* Exposing the multi-container workload with a ClusterIP Service for internal cluster access

19. ### Step 1: Create a Pod that writes logs to a shared hostPath

Create a Pod named **alpha-cka** with the following:

* Labels: `app=alpha`, `tier=backend`
* A volume `podinfo-vol` using DownwardAPI that writes labels into a file named `podinfo`
* A volume `shared-vol` using hostPath `/mnt/alpha-data` with type `DirectoryOrCreate`
* Container `alpha-container` using `busybox` with env var `POD_NAME` from `metadata.name`
* Command loop writing `${POD_NAME} writing logs` every 10 seconds into `/mnt/data/logs.txt`
* Mount `shared-vol` at `/mnt/data`

### Step 2: Create a Pod that tails the log from the hostPath

Create a Pod named **beta-cka** with the following:

* Labels: `app=beta`, `tier=frontend`
* A volume `shared-vol` using hostPath `/mnt/alpha-data`
* Container `beta-container` using `busybox` with command tailing `/mnt/data/logs.txt`
* Mount `shared-vol` at `/mnt/data`

### Step 3: Create a privileged Pod with host root mount

Create a Pod named **gamma-cka** with the following:

* Labels: `app=gamma`, `role=infra`
* Container `gamma-container` using `ubuntu` with command `sleep infinity`
* SecurityContext set to `privileged: true` and `runAsUser: 0`
* Mount the host root `/` at `/host-root` using hostPath

### Step 4: Create a Pod serving content from a hostPath

Create a Pod named **delta-cka** with the following:

* Labels: `app=delta`, `tier=web`
* Volume `web-vol` using hostPath `/mnt/delta-html` with type `DirectoryOrCreate`
* Container `delta-nginx` using `nginx` mounting `web-vol` at `/usr/share/nginx/html`
* Expose port 80

### Step 5: Create a Service exposing the nginx Pod

Create a Service named **delta-svc-cka** with the following:

* Type `ClusterIP`
* Selector `app=delta`
* Port 80/TCP

### Step 6: Use cases demonstrated

* Downward API exposing pod labels into files for dynamic context
* Using hostPath for inter-pod communication by sharing files at node level
* Privileged containers for deep host access (admin/debug scenarios)
* Serving static content directly from hostPath volumes via nginx
* Exposing nginx Pod internally using a ClusterIP service

20. ### Step 1: Create a Pod with subPath usage in shared hostPath

Create a Pod named **omega-cka** with the following:

* Labels: `app=omega`, `tier=shared-storage`
* A volume `shared-host` using hostPath `/mnt/omega-data` with type `DirectoryOrCreate`
* Two containers:

  * **writer** using `busybox` with command looping to append `"writer container active"` every 10 seconds into `/mnt/data/output.log`
  * **reader** using `busybox` with command `tail -f /mnt/data/output.log` to continuously read logs
* Mount the `shared-host` volume differently using subPath:

  * Container **writer** mounts `/mnt/data` with `subPath=writer`
  * Container **reader** mounts `/mnt/data` with `subPath=reader`

### Step 2: Create a Pod demonstrating separate directories within the same hostPath

Create a Pod named **theta-cka** with the following:

* Labels: `app=theta`, `tier=experiment`
* Volume `host-shared` pointing to `/mnt/theta-data` (type `DirectoryOrCreate`)
* Two containers:

  * **producer** (`busybox`) writing random numbers into `/mnt/producer/numbers.txt`
  * **consumer** (`busybox`) reading from `/mnt/consumer/numbers.txt`
* Use `subPath=producer` for producer and `subPath=consumer` for consumer so both share the same hostPath but are isolated into different directories

### Step 3: Create a Pod mixing subPath and full mount

Create a Pod named **sigma-cka** with the following:

* Labels: `app=sigma`, `tier=mixed`
* Volume `sigma-vol` pointing to `/mnt/sigma-data`
* Container **logger** (`busybox`) mounts the full volume at `/mnt/all` and writes log files with timestamps
* Container **archiver** (`busybox`) mounts the same volume with `subPath=archive` at `/mnt/archive` and periodically compresses old logs

### Step 4: Use cases demonstrated

* Using `subPath` to isolate different containers into separate directories within a single hostPath volume
* Producer/consumer style communication by writing into isolated subPath directories
* Mounting full hostPath for one container and subPath for another in the same Pod to demonstrate mixed access
* Practical patterns for multi-container Pods: logging + tailing, producer + consumer, logger + archiver
* Learning how subPath provides flexibility for organizing data in shared storage without creating multiple volumes



21. Mega Task: PVC, PV, and SC Deep Dive

### Step 1: StorageClasses

* Create **sc-manual-cka** with provisioner `kubernetes.io/no-provisioner`, reclaimPolicy `Retain`, volumeBindingMode `WaitForFirstConsumer`
* Create **sc-local-cka** with provisioner `kubernetes.io/no-provisioner`, reclaimPolicy `Retain`, volumeBindingMode `WaitForFirstConsumer`, restricted to node `worker1`
* Create **sc-minikube-cka** using minikube default provisioner, reclaimPolicy `Delete`, volumeBindingMode `Immediate`
* Create **sc-fast-cka** simulating SSD with reclaimPolicy `Delete`, volumeBindingMode `WaitForFirstConsumer`, annotation `tier=fast`
* Create **sc-slow-cka** simulating HDD with reclaimPolicy `Retain`, volumeBindingMode `WaitForFirstConsumer`, annotation `tier=slow`
* Create **sc-backup-cka** using no-provisioner with reclaimPolicy `Retain`, volumeBindingMode `WaitForFirstConsumer`, dedicated for backup workloads


### Step 2: PersistentVolumes (static)

* **pv-alpha**: 200Mi, RWO, SC=sc-manual-cka, hostPath `/mnt/pv-alpha` on control-plane
* **pv-beta**: 500Mi, RWX, SC=sc-manual-cka, hostPath `/mnt/pv-beta` on worker1
* **pv-gamma**: 1Gi, RWO, SC=sc-manual-cka, hostPath `/mnt/pv-gamma`, reclaimPolicy=Recycle
* **pv-delta**: 2Gi, RWO, SC=sc-local-cka, type=local, nodeAffinity `hostname=worker1`
* **pv-epsilon**: 1Gi, RWX, SC=sc-manual-cka, hostPath `/mnt/pv-epsilon` on worker2
* **pv-theta**: 5Gi, RWO, SC=sc-slow-cka, hostPath `/mnt/pv-theta` on worker1
* **pv-zeta**: 10Gi, RWX, SC=sc-fast-cka, hostPath `/mnt/pv-zeta` on control-plane
* **pv-backup**: 2Gi, RWO, SC=sc-backup-cka, hostPath `/mnt/backup` on worker2


### Step 3: PersistentVolumeClaims (static binding)

* **pvc-alpha**: 100Mi, RWO, SC=sc-manual-cka → bound to pv-alpha
* **pvc-beta**: 300Mi, RWX, SC=sc-manual-cka → bound to pv-beta
* **pvc-gamma**: 900Mi, RWO, SC=sc-manual-cka → bound to pv-gamma
* **pvc-delta**: 2Gi, RWO, SC=sc-local-cka → bound to pv-delta
* **pvc-epsilon**: 1Gi, RWX, SC=sc-manual-cka → bound to pv-epsilon
* **pvc-theta**: 5Gi, RWO, SC=sc-slow-cka → bound to pv-theta
* **pvc-zeta**: 10Gi, RWX, SC=sc-fast-cka → bound to pv-zeta
* **pvc-backup**: 2Gi, RWO, SC=sc-backup-cka → bound to pv-backup


### Step 4: PersistentVolumeClaims (dynamic provisioning)

* **pvc-dyn1**: 1Gi, RWO, SC=sc-minikube-cka
* **pvc-dyn2**: 2Gi, RWO, SC=sc-minikube-cka
* **pvc-fast**: 500Mi, RWO, SC=sc-fast-cka
* **pvc-rwx**: 1Gi, RWX, SC=sc-minikube-cka
* **pvc-analytics**: 5Gi, RWX, SC=sc-fast-cka
* **pvc-cache**: 2Gi, RWO, SC=sc-minikube-cka


### Step 5: Pods consuming PVCs

* **pod-single**: nginx on control-plane, mounts pvc-alpha at `/usr/share/nginx/html`, serves static index.html
* **pod-fast**: busybox on worker2, mounts pvc-fast at `/mnt/fast`, simulates DB writing random data
* **pod-local**: busybox constrained to worker1, mounts pvc-delta at `/data/local.txt`, writes timestamps
* **pod-dyn**: busybox on worker2, mounts pvc-dyn1 at `/dyn/data.txt`, writes timestamps


### Step 6: Multi-container Pods with shared PVCs

* **pod-shared**: on worker1, writer container appends "hello from writer" to `/mnt/shared/logs.txt` every 5s, reader container tails same file, both mount pvc-beta
* **pod-cache**: busybox with 2 containers, one writes JSON to `/mnt/cache/data.json`, second validates file contents, both mount pvc-cache


### Step 7: Multi-PVC Pods

* **multi-pvc**: nginx on worker2 mounting pvc-alpha at `/mnt/config`, pvc-beta at `/mnt/logs`, pvc-dyn2 at `/mnt/cache`, pvc-fast at `/mnt/db`
* **multi-tenant-pod**: 2 containers on worker1, tenantA mounts pvc-epsilon with subPath=tenantA, tenantB mounts pvc-epsilon with subPath=tenantB for isolation


### Step 8: SubPath usage Pods

* **subpath-pod**: busybox on control-plane mounting pvc-gamma using subPaths `/app/logs`, `/app/config`, `/app/tmp`
* **pod-archiver**: busybox mounting pvc-theta fully at `/mnt/all` and subPath=archive at `/mnt/archive`, compresses logs periodically


### Step 9: Deployments with PVCs

* **deploy-nginx-pvc**: 3 replicas nginx across worker1 and worker2, mount pvc-beta at `/usr/share/nginx/html`, InitContainer seeds index.html with `"Hello from $(POD_NAME)"`
* **svc-nginx-pvc**: ClusterIP service port 80 exposing deploy-nginx-pvc
* **deploy-cms**: 2 replicas nginx on worker1 mounting pvc-rwx at `/var/www/html` for CMS content
* **cms-svc**: ClusterIP service port 80 exposing deploy-cms
* **deploy-db**: 1 replica busybox on worker2 mounting pvc-fast at `/var/lib/mysql`, writes structured DB-like data
* **db-svc**: ClusterIP service port 3306 exposing deploy-db
* **deploy-logs**: 2 replicas busybox on worker2 tailing pvc-beta at `/mnt/logs/logs.txt` concurrently
* **deploy-analytics**: 3 replicas on worker2 mounting pvc-beta at `/mnt/logs` and pvc-analytics at `/mnt/results`, simulate log processing pipeline
* **analytics-svc**: ClusterIP service port 8080 exposing deploy-analytics
* **deploy-zeta**: 2 replicas nginx on control-plane mounting pvc-zeta at `/usr/share/nginx/html`, validate RWX PV across replicas
* **deploy-backup**: 1 replica busybox on worker2 mounting pvc-backup at `/mnt/backup`, simulates backup of DB content


### Step 10: PVC resizing

* Expand pvc-alpha 100Mi → 300Mi
* Expand pvc-dyn1 1Gi → 2Gi
* Expand pvc-analytics 5Gi → 10Gi
* Expand pvc-zeta 10Gi → 20Gi


### Step 11: Reclaim policy checks

* Delete pvc-gamma → pv-gamma recycled
* Delete pvc-alpha → pv-alpha retained
* Delete pvc-dyn1 → PV deleted
* Delete pvc-backup → pv-backup retained


### Step 12: Validation and troubleshooting scenarios

* Create **broken-pod** requesting non-existent PVC, validate Pending state
* Simulate conflict: run 2 Pods using pvc-alpha (RWO), confirm only one succeeds
* Simulate oversize request: create pvc-huge requesting 50Gi, verify unbound
* Restart pods in deploy-nginx-pvc and verify content persists via pvc-beta
* Validate deploy-cms shares content across replicas via pvc-rwx
* Verify deploy-db retains structured data across pod restarts
* Validate deploy-analytics processes logs from pvc-beta and writes results to pvc-analytics
* Validate subPath in multi-tenant-pod ensures isolation
* Confirm deploy-zeta replicas share RWX pvc-zeta correctly


### Step 13: Service integrations

* **svc-nginx-pvc** provides frontend persistence test
* **cms-svc** provides CMS workload
* **db-svc** simulates DB backend
* **analytics-svc** exposes log analytics
* Ensure Pods and Deployments scale horizontally while maintaining persistent data integrity


This mega-task covers: multiple StorageClasses (manual, local, minikube dynamic, fast/slow tiers, backup), multiple PersistentVolumes and PersistentVolumeClaims (static and dynamic binding, hostPath and local, RWX vs RWO, Retain/Recycle/Delete policies), Pods (single, multi-container, multi-PVC), Deployments with InitContainers, subPath isolation, RWX vs RWO access, resizing, reclaim policy testing, Services (ClusterIP and NodePort), node affinity for local PVs, validation across control-plane and worker nodes, troubleshooting unbound PVCs, and data persistence across replicas.























