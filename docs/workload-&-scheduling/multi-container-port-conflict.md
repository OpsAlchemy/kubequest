# CrashLoopBackOff Due to Port Conflict in Multi-Container Pod

### Symptom

* Deployment `collect-data` shows:

  ```
  READY   UP-TO-DATE   AVAILABLE
  0/2     2            0
  ```
* Pods stuck in:

  ```
  CrashLoopBackOff
  ```
* Each Pod shows `1/2` containers running.

---

### Pod Specification

The Pod template defines **two containers**:

```
containers:
- name: nginx
  image: nginx:1.21.6-alpine
- name: httpd
  image: httpd:2.4.52-alpine
```

Both containers attempt to bind to **port 80** inside the same Pod.

---

### Root Cause

Containers within a Pod **share the same network namespace**.

* `nginx` binds to `0.0.0.0:80`
* `httpd` also tries to bind to `0.0.0.0:80`
* Second container fails with:

  ```
  (98) Address in use: could not bind to address 0.0.0.0:80
  ```

This causes the failing container to restart repeatedly, putting the Pod into `CrashLoopBackOff`.

---

### Evidence from Logs

```
(98)Address in use: AH00072: make_sock: could not bind to address [::]:80
(98)Address in use: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
```

---

### Fix Applied

The Deployment was edited to remove the conflicting container, resulting in Pods with **one container only**.

This triggered:

* New ReplicaSet creation
* Old Pods termination
* New Pods reaching `Running` state

---

### Alternative Valid Fixes

* Run only one web server per Pod
* Change one container to listen on a different port
* Use separate Deployments for nginx and httpd

---

### Key Notes

* Pods have **one IP, one network namespace**
* Multiple containers cannot bind to the same port
* `CrashLoopBackOff` with one container running usually indicates:

  * Port conflict
  * Invalid command
  * Missing config
* Always inspect container-specific logs:

  ```
  kubectl logs <pod> -c <container>
  ```

---


