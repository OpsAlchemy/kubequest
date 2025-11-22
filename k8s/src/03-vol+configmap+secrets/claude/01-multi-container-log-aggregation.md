
## Scenario 1: Multi-Container Log Aggregation
**Images to use:**
- Main container: `nginx:1.20-alpine` 
- Sidecar container: `busybox:1.35`

**What's happening:**
- Nginx serves web traffic and writes access logs to `/var/log/nginx/access.log`
- Busybox sidecar runs `tail -f /var/log/nginx/access.log` to monitor logs
- Both containers share an emptyDir volume mounted at `/var/log/nginx/`
- Simulate traffic: `while true; do wget -q -O- http://localhost; sleep 2; done`

**Expected behavior:** Both containers can see the same log files, sidecar outputs nginx logs to stdout

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multicontainer-pod
spec:
  restartPolicy: Never
  volumes:
  - name: local-volume
    emptyDir: {}
  containers:
  - image: nginx:1.20-alpine
    name: nginx
    volumeMounts:
    - name: local-volume
      mountPath: /var/log/nginx/
  - image: busybox:1.35
    name: traffic-generator
    command: ["/bin/sh"]
    args: ["-c", "while true; do wget -q -O- http://localhost; sleep 2; done"]
  - image: busybox:1.35
    name: log-reader
    volumeMounts:
    - name: local-volume
      mountPath: /var/log/nginx/
    command: ["/bin/sh"]
    args: ["-c", "while true; do tail -f /var/log/nginx/access.log 2>/dev/null || sleep 1; done"]
```