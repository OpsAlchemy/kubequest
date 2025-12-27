# RBAC Gotchas and Common Mistakes

## 4.1 Core API Group Empty String Requirement

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-access
  namespace: default
rules:
- apiGroups: ["v1"]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**Explanation:** The empty string `""` represents the core API group, which contains fundamental resources like pods, services, and configmaps. Using `"v1"` instead of `""` will cause the RBAC rule to be ignored, resulting in access denial without clear error messages.

## 4.2 ServiceAccount Subject API Group Omission

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-app
  namespace: default
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-app
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** ServiceAccount resources exist in the core API group, not the RBAC API group. The apiGroup field must be omitted when referencing ServiceAccounts as subjects. For Users and Groups, the apiGroup must be `rbac.authorization.k8s.io`.

## 4.3 RoleBinding Scope Limitation

### Incorrect Expectation
User creates a RoleBinding in the development namespace and expects access to production namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-access
  namespace: development
subjects:
- kind: User
  name: developer
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Result:** The developer only has access in the development namespace, not in production or any other namespace.

### Correct Approach for Multi-Namespace Access
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-access-dev
  namespace: development
subjects:
- kind: User
  name: developer
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-access-prod
  namespace: production
subjects:
- kind: User
  name: developer
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** RoleBindings are always namespace-scoped. A single RoleBinding cannot grant access across multiple namespaces. To provide access in multiple namespaces, either create multiple RoleBindings or use a ClusterRoleBinding for cluster-wide access.

## 4.4 ClusterRole with RoleBinding Scope Limitation

### Misunderstanding
Assuming ClusterRole automatically provides cluster-wide access.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-manager-binding
  namespace: staging
subjects:
- kind: User
  name: operator
roleRef:
  kind: ClusterRole
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
```

**Result:** The operator only has pod management permissions in the staging namespace, not cluster-wide.

### Correct Implementation for Cluster-Wide Access
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-manager-global
subjects:
- kind: User
  name: operator
roleRef:
  kind: ClusterRole
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** The scope of permissions is determined by the binding type, not the role type. A ClusterRole bound with a RoleBinding becomes namespace-scoped. For cluster-wide access, a ClusterRoleBinding must be used.

## 4.5 Subresource Permission Requirements

### Incorrect Implementation
Assuming pod access includes subresource access.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**Result:** Users can see pods but cannot view logs or execute commands inside containers.

### Correct Implementation with Subresources
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
```

**Explanation:** Subresources like logs, exec, port-forward, and attach require explicit permissions separate from the parent resource. Each subresource must be listed individually with appropriate verbs.

## 4.6 ResourceNames Limitation with List Verb

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["db-credentials", "api-key"]
  verbs: ["get", "list"]
```

**Result:** Users can get specific secrets by name but cannot list all secrets.

### Correct Implementation Separating Actions
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["list"]
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["db-credentials", "api-key"]
  verbs: ["get"]
```

**Explanation:** The list verb is incompatible with resourceNames. When resourceNames is specified, users can only access the named resources individually, not list all resources of that type. For list access, a separate rule without resourceNames is required.

## 4.7 Cross-Namespace Role Reference Prohibition

### Incorrect Setup
Attempting to reference a Role from another namespace.

```yaml
# Role exists in development namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: development
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

```yaml
# RoleBinding attempts to reference it from production namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: production
subjects:
- kind: User
  name: operator
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Result:** The binding fails validation or becomes invalid.

### Correct Solution
```yaml
# Option 1: Create duplicate Role in production namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]

# Option 2: Use ClusterRole and RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: production
subjects:
- kind: User
  name: operator
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** Role resources are namespace-scoped and cannot be referenced across namespace boundaries. A RoleBinding can only reference a Role in the same namespace. For cross-namespace permission reuse, ClusterRoles should be used.

## 4.8 Cluster-Scoped Resource Access with RoleBinding

### Incorrect Expectation
Attempting to grant node access through a RoleBinding.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-viewer
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: node-access
  namespace: default
subjects:
- kind: User
  name: viewer
roleRef:
  kind: ClusterRole
  name: node-viewer
  apiGroup: rbac.authorization.k8s.io
```

**Result:** The user cannot access nodes despite the binding.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-access-global
subjects:
- kind: User
  name: viewer
roleRef:
  kind: ClusterRole
  name: node-viewer
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** Cluster-scoped resources like nodes, persistentvolumes, and namespaces cannot be accessed through namespace-scoped bindings. RoleBindings can only grant access to namespace-scoped resources, even when referencing a ClusterRole. For cluster-scoped resource access, ClusterRoleBinding must be used.

## 4.9 Missing Default ServiceAccount Permissions

### Common Misunderstanding
Assuming ServiceAccounts have default permissions.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: default
spec:
  serviceAccountName: my-app-sa
  containers:
  - name: app
    image: myapp:latest
```

**Result:** The pod cannot access any Kubernetes API resources.

### Required RBAC Setup
```yaml
# First, create the ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: default
---
# Then, create permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
# Finally, bind them
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-app-sa
  namespace: default
roleRef:
  kind: Role
  name: my-app-role
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** ServiceAccounts have no permissions by default. Unlike some cloud providers' IAM systems, Kubernetes RBAC requires explicit granting of all permissions. Each ServiceAccount starts with zero access and must be explicitly bound to Roles or ClusterRoles.

## 4.10 Verb Wildcard Incompatibility

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: wildcard-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["app-config"]
  verbs: ["*"]
```

**Result:** The wildcard verb may not work as expected with resourceNames.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: config-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["app-config"]
  verbs: ["get", "update", "patch", "delete"]
```

**Explanation:** When using resourceNames, explicitly list the required verbs instead of using wildcards. Some verbs like list and watch may not be compatible with resourceNames restrictions.

## 4.11 API Group Specification for Custom Resources

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: crd-access
rules:
- apiGroups: [""]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "list"]
```

**Result:** Cannot access CRDs or custom resources.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: crd-access
rules:
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: custom-resource-access
rules:
- apiGroups: ["mycompany.com"]
  resources: ["myresources"]
  verbs: ["get", "list", "create"]
```

**Explanation:** CustomResourceDefinitions are in the apiextensions.k8s.io API group, not the core group. Custom resources themselves are in their own API groups defined by their CRD. Both the CRD access and the custom resource access require separate rules with correct API groups.

## 4.12 Role Binding Subject Namespace Requirement

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: invalid-binding
  namespace: app-ns
subjects:
- kind: ServiceAccount
  name: monitor-sa
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Result:** Binding fails validation or ServiceAccount reference is invalid.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: valid-binding
  namespace: app-ns
subjects:
- kind: ServiceAccount
  name: monitor-sa
  namespace: monitoring-ns
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** When referencing a ServiceAccount in a RoleBinding, the namespace field is required in the subject definition. This is because ServiceAccounts are namespace-scoped resources, and the binding needs to know which namespace contains the ServiceAccount being referenced.

## 4.13 Non-Resource URL Access Requirements

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: health-checker
  namespace: default
rules:
- apiGroups: [""]
  resources: ["/healthz"]
  verbs: ["get"]
```

**Result:** Cannot access health check endpoints.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: health-checker
rules:
- nonResourceURLs: ["/healthz", "/readyz", "/livez"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: health-check-binding
subjects:
- kind: User
  name: health-monitor
roleRef:
  kind: ClusterRole
  name: health-checker
  apiGroup: rbac.authorization.k8s.io
```

**Explanation:** Non-resource URLs like health check endpoints require ClusterRoles with nonResourceURLs field instead of resources field. They also require ClusterRoleBindings since these endpoints exist at the cluster level, not within namespaces.

## 4.14 Missing API Group for Apps Resources

### Incorrect Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["deployments"]
  verbs: ["get", "list"]
```

**Result:** Cannot access deployments.

### Correct Implementation
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-access
  namespace: default
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
```

**Explanation:** Deployments, StatefulSets, and DaemonSets are in the apps API group, not the core API group. Many resources that were originally in extensions/v1beta1 have moved to stable API groups like apps/v1.

## 4.15 Aggregated ClusterRole Rule Inheritance

### Incorrect Expectation
Assuming aggregated ClusterRoles automatically update.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aggregated-role
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**Result:** The rules are not aggregated to other ClusterRoles.

### Correct Aggregation Setup
```yaml
# Base ClusterRole that will receive aggregated rules
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-role
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitoring: "true"
rules: []  # Rules will be aggregated here
---
# ClusterRole that contributes rules
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-pods
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
# Another contributing ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-services
  labels:
    rbac.example.com/aggregate-to-monitoring: "true"
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
```

**Explanation:** Aggregated ClusterRoles use the aggregationRule field to dynamically collect rules from other ClusterRoles with matching labels. The base ClusterRole has empty rules initially, and contributing ClusterRoles must have the matching label. The aggregation is not automatic for regular ClusterRoles.

## Summary of Key RBAC Principles

1. Empty string represents the core API group
2. ServiceAccount subjects do not use apiGroup field
3. RoleBindings are always namespace-scoped
4. ClusterRoles become namespace-scoped when bound with RoleBindings
5. Subresources require explicit permissions
6. ResourceNames is incompatible with list verb
7. Roles cannot be referenced across namespaces
8. Cluster-scoped resources require ClusterRoleBindings
9. ServiceAccounts have no default permissions
10. Custom resources have specific API groups
11. Non-resource URLs require ClusterRoles with nonResourceURLs field
12. Apps resources are in the apps API group, not core

Each example demonstrates a specific gotcha with both incorrect and correct implementations, showing exactly what fails and how to fix it.