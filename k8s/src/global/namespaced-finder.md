**How to check if a Kubernetes resource is namespaced or not:**

## 1. **Using kubectl api-resources** (Best Method)
```bash
# Check specific resource
kubectl api-resources --namespaced=true | grep <resource-name>
kubectl api-resources --namespaced=false | grep <resource-name>

# Examples:
kubectl api-resources --namespaced=true | grep pods
kubectl api-resources --namespaced=false | grep nodes

# Check all resources with namespace info
kubectl api-resources -o wide | grep <resource-name>
```

## 2. **Using kubectl explain** (Alternative)
```bash
# Check if metadata.namespace field exists
kubectl explain <resource>.metadata.namespace

# If it returns documentation, the resource is namespaced
# If it returns "error: couldn't find resource", it's cluster-scoped
```

## 3. **Quick Check Commands**
```bash
# Try to create in namespace (will fail if cluster-scoped)
kubectl get <resource> -n <namespace>

# Try to get without namespace (will fail if namespaced)
kubectl get <resource>
```

## 4. **Common Namespaced Resources** (usually)
- Pods
- Services
- Deployments
- ConfigMaps
- Secrets
- PersistentVolumeClaims
- ReplicaSets
- StatefulSets
- Jobs
- CronJobs
- Ingresses

## 5. **Common Cluster-Scoped Resources** (usually)
- Nodes
- PersistentVolumes
- StorageClasses
- Namespaces
- ClusterRoles
- ClusterRoleBindings
- CustomResourceDefinitions (CRDs)
- PriorityClasses
- RuntimeClasses

## 6. **Quick Reference Table**
```bash
# View complete list with namespace info
kubectl api-resources --verbs=list --namespaced -o name
kubectl api-resources --verbs=list --namespaced=false -o name
```

## 7. **API Discovery Command**
```bash
# Check specific API group
kubectl api-resources --api-group=apps
kubectl api-resources --api-group=storage.k8s.io
```

The **most reliable method** is `kubectl api-resources --namespaced=true|false` as it directly queries the API server for the current cluster's resource definitions.