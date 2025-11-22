Understood — let me present it in **properly structured formatting** (clear separation of code blocks and explanations).

---

# Task: StatefulSet & Headless Service

**Requirement Recap:**

* Create a StatefulSet named `web` with **2 replicas** using the **nginx image**.
* Each Pod must have its own **1Gi persistent volume** mounted at `/usr/share/nginx/html`.
* Pods must have **stable identities** and storage that persists even after rescheduling.
* A **headless Service** named `web` should provide stable networking for the StatefulSet.

---

## 1. Headless Service (web-svc.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  labels:
    app: web
spec:
  clusterIP: None   # makes this a headless service
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: 80
```

**Explanation:**

* `clusterIP: None` → This makes the Service **headless**. Instead of a single virtual IP, each Pod gets its own **DNS record** like `web-0.web` and `web-1.web`.
* This enables direct addressing of Pods by their **stable names**.
* The selector `app: web` ensures the Service picks up Pods from the StatefulSet.

---

## 2. StatefulSet (web-sts.yaml)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  labels:
    app: web
spec:
  serviceName: web
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      initContainers:
        - name: init-index
          image: busybox:1.36
          command: ["sh", "-c"]
          args:
            - echo "Hello from $(hostname) at $(date)" > /workdir/index.html
          volumeMounts:
            - name: web-data
              mountPath: /workdir
      containers:
        - name: nginx
          image: nginx:1.25-alpine
          ports:
            - name: http
              containerPort: 80
          volumeMounts:
            - name: web-data
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: web-data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

**Explanation:**

* **`serviceName: web`** → Binds this StatefulSet to the headless Service we created.
* **Stable Pod identity** → Pods will always come up as `web-0`, `web-1`.
* **initContainer** → Writes a simple `index.html` to the PVC before nginx starts. This guarantees testable output.
* **volumeClaimTemplates** → Each replica gets a **separate PVC** (`web-data-web-0`, `web-data-web-1`) with **1Gi** size. These claims persist even if Pods are deleted.
* **volumeMounts** → nginx serves files from `/usr/share/nginx/html`, which is backed by each pod’s PVC.

---

## 3. Applying Resources

```bash
kubectl apply -f web-svc.yaml
kubectl apply -f web-sts.yaml
```

Check objects:

```bash
kubectl get statefulsets
kubectl get pods
kubectl get pvc
kubectl get pv
```

---

## 4. Testing

Start a test Pod:

```bash
kubectl run -it tester --image=busybox:1.36 --restart=Never -- sh
```

Inside tester:

```sh
nslookup web-0.web
nslookup web-1.web
wget -qO- http://web-0.web
wget -qO- http://web-1.web
```

You should see unique HTML pages, each showing the hostname (`web-0` or `web-1`) and a timestamp.

---

## 5. Persistence Check

Delete a Pod:

```bash
kubectl delete pod web-0
kubectl wait --for=condition=ready pod/web-0 --timeout=120s
```

Run tester again:

```sh
wget -qO- http://web-0.web
```

You’ll still see the **same index page** because the PVC is tied to the ordinal identity (`web-0`).

---

✅ With this setup, you’ve implemented:

* A **headless Service** for stable DNS.
* A **StatefulSet** with stable Pod identities.
* **Persistent storage per replica** that survives rescheduling.
* A **verifiable test** via `busybox`.

---

Do you want me to also prepare a **condensed exam-style solution** (just the YAML, no explanations), so you can use it directly during CKA practice?
