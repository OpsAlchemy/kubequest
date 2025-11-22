## All Ways to Pass Environment Variables

### 1. **Direct Hardcoded Values** (`value`)
```yaml
env:
- name: APP_NAME
  value: "my-app"
```

### 2. **From ConfigMap Key** (`valueFrom.configMapKeyRef`)
```yaml
env:
- name: DB_HOST
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database-host
```

### 3. **From Secret Key** (`valueFrom.secretKeyRef`)
```yaml
env:
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: api-token
```

### 4. **From Pod Fields** (`valueFrom.fieldRef`)
```yaml
env:
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
```

### 5. **From Resource Fields** (`valueFrom.resourceFieldRef`)
```yaml
env:
- name: CPU_LIMIT
  valueFrom:
    resourceFieldRef:
      containerName: my-container
      resource: limits.cpu
```

### 6. **Bulk Load from ConfigMap** (`envFrom.configMapRef`)
```yaml
envFrom:
- configMapRef:
    name: app-config  # Loads ALL key-value pairs
```

### 7. **Bulk Load from Secret** (`envFrom.secretRef`)
```yaml
envFrom:
- secretRef:
    name: app-secrets  # Loads ALL key-value pairs
```

### 8. **From ConfigMap with Prefix** (Kubernetes 1.23+)
```yaml
envFrom:
- prefix: CONFIG_
  configMapRef:
    name: app-config  # Keys become CONFIG_KEY_NAME
```

### 9. **From Secret with Prefix** (Kubernetes 1.23+)
```yaml
envFrom:
- prefix: SECRET_
  secretRef:
    name: app-secrets  # Keys become SECRET_KEY_NAME
```

### 10. **From Downward API** (Advanced field references)
```yaml
env:
- name: POD_LABELS
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels
```

### 11. **From Container Resources** (Multiple containers)
```yaml
env:
- name: MEMORY_REQUEST
  valueFrom:
    resourceFieldRef:
      containerName: sidecar-container
      resource: requests.memory
```

## 📊 Summary Table

| Method | Use Case | Example |
|--------|----------|---------|
| `value` | Static values | `value: "production"` |
| `configMapKeyRef` | Single config value | From ConfigMap key |
| `secretKeyRef` | Single secret value | From Secret key |
| `fieldRef` | Pod metadata | Pod IP, Node name |
| `resourceFieldRef` | Resource limits | CPU/memory limits |
| `configMapRef` (envFrom) | Bulk config | All ConfigMap values |
| `secretRef` (envFrom) | Bulk secrets | All Secret values |
| `prefix + configMapRef` | Bulk with prefix | `PREFIX_KEY` |
| `prefix + secretRef` | Bulk secrets with prefix | `SECRET_KEY` |

## 🎯 Complete Example Showing Multiple Methods

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: comprehensive-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: nginx
        env:
          # 1. Direct value
          - name: ENVIRONMENT
            value: "production"
          
          # 2. From ConfigMap key
          - name: DB_HOST
            valueFrom:
              configMapKeyRef:
                name: app-config
                key: database-host
          
          # 3. From Secret key
          - name: API_KEY
            valueFrom:
              secretKeyRef:
                name: app-secrets
                key: api-key
          
          # 4. From Pod field
          - name: HOST_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          
          # 5. From resource field
          - name: MEMORY_LIMIT
            valueFrom:
              resourceFieldRef:
                resource: limits.memory
        
        # 6. Bulk load from ConfigMap (all keys)
        envFrom:
        - configMapRef:
            name: common-config
        - secretRef:
            name: common-secrets
        - prefix: APP_
          configMapRef:
            name: app-config
```
