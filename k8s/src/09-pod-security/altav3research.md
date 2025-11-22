https://www.youtube.com/watch?v=eGv6iPWQKyo
16:23

https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-namespace-labels/


Enforce the Restricted Pod Security Standard on the namespace `restricted-ns`. Pods in that namespace cannot: have privileged access, host networking, have any elevated rights.

Of course. Here is the solution to enforce the Restricted Pod Security Standard and an example of a Pod that would violate it.

### Solution: Apply the Pod Security Standard

The modern, preferred way to enforce Pod Security Standards is by applying a **Pod Security Admission (PSA)** label to the namespace. This is a feature built into the Kubernetes API server that replaces the older PodSecurityPolicies.

You will label the `restricted-ns` namespace to enforce the `restricted` policy level.

**Step 1: Create the Namespace (if it doesn't exist)**
```bash
kubectl create namespace restricted-ns
```

**Step 2: Apply the Pod Security Admission Label**
This label tells the Kubernetes API server to enforce the `restricted` policy and to **reject** any Pod that does not meet the standard.
```bash
kubectl label --overwrite namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=v1.28 # Use your cluster's version
```

**What this command does:**
*   `pod-security.kubernetes.io/enforce=restricted`: The action to take. `enforce` will outright reject any non-compliant Pod.
*   `pod-security.kubernetes.io/enforce-version=v1.28`: The version of the policy to use. It's best practice to set this to your current cluster version to ensure consistency. (Replace `v1.28` with your server's version. Use `kubectl version --short` to check).

**Complete namespace definition for clarity:**
You could also achieve this by applying a YAML file:
```yaml
# restricted-ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-ns
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: "v1.28"
```
Apply it with: `kubectl apply -f restricted-ns.yaml`

---

### Example of a Pod that Violates the Restricted Policy

The Restricted policy is very strict. Here is an example of a Pod that would be **blocked** from being created in the `restricted-ns` namespace.

**Violating Pod Manifest:**
```yaml
# violating-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-violator
  namespace: restricted-ns # This is the key - it's trying to run in our restricted namespace
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      runAsUser: 0 # VIOLATION: Runs as root (uid 0) - "have any elevated rights"
      privileged: true # VIOLATION: Requests privileged mode - "have privileged access"
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"] # VIOLATION: Adds Linux capabilities - "elevated rights"
  hostNetwork: true # VIOLATION: Uses the node's network namespace - "host networking"
  hostPID: true # VIOLATION: Uses the node's PID namespace - an additional privilege
```

**Why it will be rejected:**
1.  `privileged: true`: This gives the container nearly all available Linux capabilities, violating the "no privileged access" rule.
2.  `hostNetwork: true`: This shares the host's network stack, violating the "no host networking" rule.
3.  `runAsUser: 0`: The container runs as the root user, violating the "no elevated rights" rule.
4.  `capabilities.add`: Adding capabilities like `NET_ADMIN` is explicitly forbidden as it grants elevated rights.
5.  `hostPID: true`: Sharing the host's process ID namespace is a form of elevated privilege.

**What happens when you try to create it?**
When you run `kubectl apply -f violating-pod.yaml`, the Kubernetes API server will intercept the request, validate it against the Pod Security Admission controller, and immediately reject it with an error message similar to this:

```
Error from server (Forbidden): error when creating "violating-pod.yaml": pods "security-violator" is forbidden: violates PodSecurity "restricted:v1.28": host namespaces (hostNetwork=true, hostPID=true), privileged (container "nginx" must not set securityContext.privileged=true), allowed capabilities (container "nginx" must not include "NET_ADMIN", "SYS_TIME" in securityContext.capabilities.add), runAsUser=0 (container "nginx" must not set runAsUser=0)
```

The error message is very clear and lists every specific violation.

---

### Example of a Compliant Pod

For contrast, here is a Pod that **would be allowed** in the `restricted-ns` namespace.

**Compliant Pod Manifest:**
```yaml
# compliant-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-compliant
  namespace: restricted-ns
spec:
  securityContext:
    runAsNonRoot: true # Ensures the pod doesn't run as root
    seccompProfile: # Another good practice often required by restricted policy
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:alpine # Using a smaller, less privileged image
    securityContext:
      allowPrivilegeEscalation: false # Explicitly false
      runAsUser: 1000 # Runs as a non-root user
      capabilities:
        drop: ["ALL"] # Drops all capabilities
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```
This pod meets all the requirements of the Restricted policy: no privilege, no host access, and no elevated rights.