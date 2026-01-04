Here are 20 YAML examples with detailed explanations and 20 CLI examples with explanations, properly formatted.

## YAML Examples with Explanations

### Example 1: Basic Role for Pod Reading
This creates a Role that allows reading pods in the default namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```
The Role defines permissions but does not grant access. It specifies get, list, and watch verbs on pods in the core API group.

### Example 2: RoleBinding for User
This binds the pod-reader Role to a user named alice.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: User
  name: alice
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
The RoleBinding grants alice the permissions defined in the pod-reader Role, but only in the default namespace.

### Example 3: ClusterRole for Node Reading
This creates a ClusterRole that allows reading nodes cluster-wide.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```
ClusterRoles exist at cluster scope and can reference cluster-scoped resources like nodes.

### Example 4: ClusterRoleBinding for Group
This grants node-reader permissions to all users in the monitoring group.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-reader-binding
subjects:
- kind: Group
  name: monitoring
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```
The binding is cluster-wide, so group members can read nodes in any namespace.

### Example 5: Role with Multiple Resources
This Role allows management of both pods and services.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: resource-manager
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["create", "get", "update", "delete", "list"]
```
A single Role can contain rules for multiple resources in the same API group.

### Example 6: Role with Specific Resource Names
This Role allows access only to specific ConfigMaps by name.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: config-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["app-config", "database-config"]
  verbs: ["get"]
```
The resourceNames field restricts access to only those named resources, not all ConfigMaps.

### Example 7: Role for Subresources
This Role allows accessing pod logs and execution.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-debugger
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods/log", "pods/exec"]
  verbs: ["get", "create"]
```
Subresources like logs and exec require explicit permissions separate from the parent resource.

### Example 8: ServiceAccount Binding
This binds a ServiceAccount to a Role in its namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-app-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
ServiceAccounts must specify their namespace when referenced in bindings.

### Example 9: Cross-Namespace ServiceAccount Access
This allows a ServiceAccount from monitoring namespace to read pods in default namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cross-ns-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
ServiceAccounts can be granted permissions in namespaces other than where they exist.

### Example 10: ClusterRole Bound to Namespace
This uses a ClusterRole but limits it to a specific namespace via RoleBinding.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: limited-clusterrole
  namespace: staging
subjects:
- kind: User
  name: tester
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
```
Even though admin is a ClusterRole, the RoleBinding limits its permissions to the staging namespace only.

### Example 11: Role with API Group Specific Resources
This Role manages resources from the apps API group.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: apps-manager
  namespace: default
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "create", "update", "delete"]
```
Different API groups require separate rules or comma-separated entries in the apiGroups array.

### Example 12: Role with Multiple API Groups
This Role covers resources from multiple API groups.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: multi-group-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
```
Each distinct API group requires a separate rule entry in the rules array.

### Example 13: ClusterRole for Non-Resource URLs
This ClusterRole allows access to health check endpoints.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: health-checker
rules:
- nonResourceURLs: ["/healthz", "/readyz", "/livez"]
  verbs: ["get"]
```
Non-resource URLs represent API endpoints that aren't tied to specific resources.

### Example 14: Role with All Verbs
This Role grants all actions on pods within a namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-admin
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["*"]
```
The asterisk wildcard grants all available verbs for the specified resource.

### Example 15: Role with All Resources
This Role grants read access to all resources in a namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-reader
  namespace: default
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```
Wildcards in both apiGroups and resources grant access across all API groups and resources.

### Example 16: Binding Multiple Subjects
This RoleBinding grants access to both a user and a ServiceAccount.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: multi-subject-binding
  namespace: default
subjects:
- kind: User
  name: developer
- kind: ServiceAccount
  name: automation
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
A single binding can reference multiple subjects of different kinds.

### Example 17: Role for PersistentVolumeClaims
This Role manages PersistentVolumeClaims in a namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pvc-manager
  namespace: storage
rules:
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["create", "delete", "get", "list"]
```
PersistentVolumeClaims are namespaced resources in the core API group.

### Example 18: Role for Secrets Management
This Role allows reading and creating secrets.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-manager
  namespace: default
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create"]
```
Secret management requires explicit permissions as secrets are sensitive resources.

### Example 19: ClusterRole for Namespace Operations
This ClusterRole allows creating and listing namespaces.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-admin
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["create", "get", "list"]
```
Namespace operations require cluster-wide permissions since namespaces are cluster-scoped.

### Example 20: Aggregated ClusterRole
This ClusterRole uses aggregation to combine rules from other ClusterRoles.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-aggregated
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.monitoring.io/aggregate-to-monitoring: "true"
rules: []
```
Aggregated ClusterRoles dynamically collect rules from other ClusterRoles with matching labels.

## CLI Examples with Explanations

### Example 1: Create Basic Role
```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods --namespace=default
```
Creates a Role named pod-reader in the default namespace with read-only pod permissions.

### Example 2: Create RoleBinding for User
```bash
kubectl create rolebinding pod-reader-binding --role=pod-reader --user=alice --namespace=default
```
Binds the pod-reader Role to user alice in the default namespace.

### Example 3: Create ClusterRole
```bash
kubectl create clusterrole node-reader --verb=get,list,watch --resource=nodes
```
Creates a ClusterRole that allows reading nodes across the entire cluster.

### Example 4: Create ClusterRoleBinding
```bash
kubectl create clusterrolebinding node-reader-binding --clusterrole=node-reader --group=monitoring
```
Grants node-reader permissions to all users in the monitoring group cluster-wide.

### Example 5: Create Role with Multiple Resources
```bash
kubectl create role resource-manager --verb=create,get,update,delete,list --resource=pods,services --namespace=production
```
Creates a Role that manages both pods and services in the production namespace.

### Example 6: Create Role with Specific Resource Names
```bash
kubectl create role config-reader --verb=get --resource=configmaps --resource-name=app-config,database-config --namespace=default
```
Creates a Role that only allows accessing specific ConfigMaps by name.

### Example 7: Create Role for Subresources
```bash
kubectl create role pod-debugger --verb=get,create --resource=pods/log,pods/exec --namespace=default
```
Creates a Role for accessing pod logs and exec subresources.

### Example 8: Create ServiceAccount Binding
```bash
kubectl create rolebinding sa-binding --role=pod-reader --serviceaccount=default:my-app-sa --namespace=default
```
Binds a ServiceAccount to a Role using the serviceaccount:namespace:name format.

### Example 9: Test Permissions
```bash
kubectl auth can-i create pods --namespace=default
```
Checks if the current user has permission to create pods in the default namespace.

### Example 10: Test Permissions as Different User
```bash
kubectl auth can-i delete deployments --as=system:serviceaccount:default:my-app-sa --namespace=default
```
Tests permissions for a specific ServiceAccount rather than the current user.

### Example 11: List All Permissions
```bash
kubectl auth can-i --list --namespace=default
```
Lists all permissions the current user has in the specified namespace.

### Example 12: Create Role for All Resources
```bash
kubectl create role namespace-reader --verb=get,list,watch --resource='*' --namespace=default
```
Creates a Role with read access to all resources in the namespace.

### Example 13: Create ClusterRole for Non-Resource URLs
```bash
kubectl create clusterrole health-checker --verb=get --non-resource-url=/healthz,/readyz,/livez
```
Creates a ClusterRole for accessing health check endpoints.

### Example 14: Bind ClusterRole to Namespace
```bash
kubectl create rolebinding admin-in-staging --clusterrole=admin --user=admin --namespace=staging
```
Binds a ClusterRole to a user but limits it to a specific namespace via RoleBinding.

### Example 15: Create Role with API Group
```bash
kubectl create role deployment-manager --verb=get,list,create,update,delete --resource=deployments.apps --namespace=production
```
Specifies the API group (apps) for deployments resource.

### Example 16: Check Cross-Namespace Permissions
```bash
kubectl auth can-i get pods --namespace=production --as=system:serviceaccount:monitoring:prometheus
```
Checks if a ServiceAccount from one namespace has permissions in another namespace.

### Example 17: Create Role for Specific Verbs Only
```bash
kubectl create role pod-lister --verb=list --resource=pods --namespace=default
```
Creates a Role with only list permission, not get or watch.

### Example 18: Update Role Rules
```bash
kubectl edit role pod-reader --namespace=default
```
Opens the Role definition in an editor for modification.

### Example 19: Describe RBAC Resources
```bash
kubectl describe role pod-reader --namespace=default
```
Shows detailed information about a Role including its rules.

### Example 20: Delete RBAC Resources
```bash
kubectl delete rolebinding pod-reader-binding --namespace=default
```
Removes a RoleBinding, which revokes the permissions it was granting.

Each CLI command corresponds to creating, testing, or managing RBAC resources with specific parameters and options. The explanations detail what each command does and when to use it.