# **Groups in Kubernetes (for permissions)**

## **1. Built-in System Groups**
- `system:authenticated` (all authenticated users)
- `system:unauthenticated` (unauthenticated requests)
- `system:masters` (full cluster admin - bypasses RBAC)
- `system:serviceaccounts` (all service accounts)
- `system:serviceaccounts:<namespace>` (service accounts in namespace)
- `system:nodes` (kubelets)
- `system:bootstrappers` (bootstrap users)

## **2. Service Account Groups**
Auto-generated for each service account:
- `system:serviceaccount:<namespace>:<sa-name>`

## **3. Certificate Groups**
From client certificate `O` (Organization) field:
- Any group name can be in certificate
- Example: `O=developers,O=qa-team`

## **4. External Authentication Groups**
From external providers:
- LDAP/AD groups
- OIDC groups
- GitHub teams
- etc.

## **5. RBAC can bind to:**
```yaml
subjects:
- kind: Group
  name: "developers"  # ← Group name
  apiGroup: rbac.authorization.k8s.io
```

**Groups are just strings - you define them in certificates or external auth.**