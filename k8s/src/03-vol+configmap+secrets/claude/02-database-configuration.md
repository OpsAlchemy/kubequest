## Scenario 2: Database Configuration Management
**Images to use:**
- Database container: `postgres:13-alpine`

**What's happening:**
- PostgreSQL needs environment variables: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- Custom config file for connection limits, memory settings mounted at `/etc/postgresql/postgresql.conf`
- ConfigMap contains: `max_connections=100`, `shared_buffers=128MB`
- Secret contains: database credentials in base64

**Expected behavior:** PostgreSQL starts successfully with custom config and can accept connections with provided credentials

---
```sh
kubectl create secret generic dbcreds \
  --from-literal=POSTGRES_USER=user \
  --from-literal=POSTGRES_PASSWORD=password \
  --from-literal=POSTGRES_DB=postgres
```

```yaml
# cm-dbconfigs.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dbconfigs
data:
  postgresql.conf: |
    max_connections=100
    shared_buffers=128MB
```

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
spec:
  containers:
  - name: postgres
    image: postgres:13-alpine
    envFrom:
    - secretRef:
        name: dbcreds
    args: ["-c","config_file=/etc/postgresql/postgresql.conf"]
    volumeMounts:
    - name: config-volume
      mountPath: /etc/postgresql
  volumes:
  - name: config-volume
    configMap:
      name: dbconfigs
      items:
      - key: postgresql.conf
        path: postgresql.conf
```



kubectl apply -f pod.yaml
kubectl get pods -w


kubectl logs db-pod
kubectl exec -it db-pod -- env PGPASSWORD=password psql -U user -d postgres -c "SHOW max_connections;"
kubectl exec -it db-pod -- env PGPASSWORD=password psql -U user -d postgres -c "SHOW shared_buffers;"



kubectl exec -it db-pod -- env PGPASSWORD=password psql -U user -d postgres -c "CREATE TABLE sanity(id int); DROP TABLE sanity;"


kubectl apply -f cm-dbconfigs.yaml
kubectl exec -it db-pod -- env PGPASSWORD=password psql -U user -d postgres -c "SELECT pg_reload_conf();"
