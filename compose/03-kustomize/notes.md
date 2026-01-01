# **Kustomize Master Guide: Advanced Patterns & Modern Practices**

## **🚀 Overview & Philosophy**
Kustomize is a **declarative configuration overlay system** for Kubernetes, not a templating engine. It follows the **"Everything as YAML"** philosophy with **patch-based inheritance**.

```bash
# Modern installation (standalone)
brew install kustomize  # macOS
# or
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Built-in (kubectl v1.14+)
kubectl kustomize <dir>
```

## **📁 Advanced Project Structure**

```
k8s/
├── base/
│   ├── kustomization.yaml          # Base resources
│   ├── namespace.yaml
│   ├── rbac/
│   │   ├── kustomization.yaml      # Component composition
│   │   ├── serviceaccount.yaml
│   │   └── rolebinding.yaml
│   ├── networking/
│   ├── deployments/
│   └── monitoring/
├── components/                      # Reusable transformations
│   ├── ingress-ssl/
│   ├── pod-security/
│   └── resource-limits/
├── overlays/
│   ├── region/                     # Multi-dimensional overlays
│   │   ├── us-west/
│   │   └── eu-central/
│   ├── environment/
│   │   ├── dev/
│   │   │   ├── kustomization.yaml  # Environment config
│   │   │   ├── namespace.yaml
│   │   │   └── patch-deployment.yaml
│   │   ├── staging/
│   │   └── production/
│   └── tenant/                     # Multi-tenancy
│       ├── team-a/
│       └── team-b/
├── clusters/                       # Cluster-specific configs
│   ├── cluster-01/
│   └── cluster-02/
└── generators/                     # Dynamic resource generation
    ├── helm-charts/
    └── jsonnet/
```

## **⚡ Modern kustomization.yaml Features**

### **Components (Kustomize v4+)**
```yaml
# components/pod-security/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

patches:
  - target:
      kind: Pod
    patch: |
      - op: add
        path: /spec/securityContext
        value:
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
  - target:
      kind: Deployment
    patch: |
      - op: add
        path: /spec/template/spec/containers/0/securityContext
        value:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
```

### **Replacements (Kustomize v4.5+) - Advanced Variable Substitution**
```yaml
# Base configmap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  appVersion: "2.1.0"
  logLevel: "INFO"
  replicas: "3"

# Overlay using replacements
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - configmap.yaml

replacements:
  # Simple value copy
  - source:
      kind: ConfigMap
      name: app-config
      fieldPath: data.appVersion
    targets:
      - select:
          kind: Deployment
          name: app-deployment
        fieldPaths:
          - spec.template.metadata.labels.version
          
  # Multiple field mapping
  - source:
      kind: ConfigMap
      name: app-config
      fieldPath: data.replicas
    targets:
      - select:
          kind: Deployment
        fieldPaths:
          - spec.replicas
        
  # Complex transformations
  - source:
      kind: ConfigMap
      name: app-config
      fieldPath: data.logLevel
    targets:
      - select:
          kind: Deployment
        fieldPaths:
          - spec.template.spec.containers.[name=app].env.[name=LOG_LEVEL].value
        options:
          create: true  # Create if doesn't exist
```

### **Generators - Dynamic Resource Creation**

```yaml
# generators/secrets/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

secretGenerator:
  - name: tls-certs
    type: "kubernetes.io/tls"
    files:
      - tls.crt=./certs/server.crt
      - tls.key=./certs/server.key
    options:
      annotations:
        sealedsecrets.bitnami.com/managed: "true"
      labels:
        cert-manager.io/certificate-name: "app-tls"
        
  - name: dynamic-secret
    type: Opaque
    literals:
      - DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
      - API_KEY=$(openssl rand -base64 32)
    behavior: create  # create, merge, or replace

configMapGenerator:
  - name: app-config
    envs:
      - .env.production
      - .env.secrets
    files:
      - config.yaml
      - "*.conf"  # Wildcard support
    options:
      immutable: true  # Kubernetes 1.19+ feature

generators:
  - |  # Inline generators
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: db-migration
    spec:
      template:
        spec:
          containers:
          - name: migrator
            image: alpine:latest
          restartPolicy: Never
```

## **🎯 Advanced Patching Techniques**

### **JSON Patch (RFC 6902) - Most Powerful**
```yaml
patches:
  - target:
      kind: Deployment
      name: ".*"  # Regex support
      labelSelector: "app=frontend"
    patch: |
      [
        {
          "op": "add",
          "path": "/spec/template/spec/tolerations",
          "value": [
            {
              "key": "gpu",
              "operator": "Equal",
              "value": "nvidia",
              "effect": "NoSchedule"
            }
          ]
        },
        {
          "op": "replace",
          "path": "/spec/template/spec/containers/0/resources/limits/memory",
          "value": "2Gi"
        },
        {
          "op": "copy",
          "from": "/spec/replicas",
          "path": "/spec/template/metadata/annotations/initialReplicas"
        },
        {
          "op": "test",  # Conditional - only apply if condition matches
          "path": "/metadata/namespace",
          "value": "production"
        }
      ]
      
  # Inline YAML patch
  - patch: |
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: app
      spec:
        template:
          spec:
            containers:
            - name: main
              envFrom:
              - configMapRef:
                  name: dynamic-config-$(CONFIG_HASH)
    target:
      name: app
```

### **Strategic Merge Patch - Kubernetes-Specific**
```yaml
patchesStrategicMerge:
  # Add sidecar container (K8s knows how to merge arrays)
  - |
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
    spec:
      template:
        spec:
          containers:
          - name: istio-proxy
            image: istio/proxyv2:1.16
            resources:
              requests:
                cpu: 100m
                memory: 128Mi
                
  # Add volume (merged by name)
  - |
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
    spec:
      template:
        spec:
          volumes:
          - name: nginx-config
            configMap:
              name: nginx-config
```

## **🔗 Multi-Base Composition & Cross-Cutting**

### **Cross-Cutting Concerns as Components**
```yaml
# components/istio-sidecar-injection/kustomization.yaml (Component)
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

namespace: istio-system

patches:
  - target:
      kind: Namespace
    patch: |
      - op: add
        path: /metadata/labels/istio-injection
        value: enabled
        
# components/linkerd-proxy/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - https://raw.githubusercontent.com/linkerd/linkerd2/main/manifests/linkerd-crds.yaml
  - https://raw.githubusercontent.com/linkerd/linkerd2/main/manifests/linkerd-control-plane.yaml

transformers:
  - |  # Inline transformer
    apiVersion: builtin
    kind: LabelTransformer
    metadata:
      name: linkerd-injection
    labels:
      linkerd.io/inject: enabled
    fieldSpecs:
    - path: metadata/labels
      create: true
```

### **Dynamic Resource Inclusion**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Include remote bases
resources:
  - github.com/kubernetes-sigs/cluster-api//config/default?ref=v1.4.0
  - https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/setup/prometheus-operator-0servicemonitorCustomResourceDefinition.yaml
  
# Include local generated manifests
resources:
  - ../manifests-generated/  # Helm output
  - ../jsonnet-output/
  - ./dynamic/  # Generated by scripts
  
# Conditional inclusion using build args
vars:
  - name: FEATURE_FLAG
    objref:
      kind: ConfigMap
      name: feature-flags
    fieldref:
      fieldpath: data.enableMonitoring
  
resources:
  - name: monitoring
    resource: ../monitoring/
    if: $(FEATURE_FLAG) == "true"
```

## **🔄 CI/CD Integration Patterns**

### **GitHub Actions Workflow**
```yaml
name: Kustomize CI/CD
on: [push, pull_request]

jobs:
  kustomize-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Kustomize
        uses: imranismail/setup-kustomize@v2
        with:
          kustomize-version: 'v5.0.0'
          
      - name: Validate All Overlays
        run: |
          for overlay in overlays/*/; do
            echo "Validating $overlay"
            kustomize build $overlay --load-restrictor=LoadRestrictionsNone | \
              kubectl apply --dry-run=server --validate=true -f -
          done
          
  kustomize-diff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
          
      - name: Generate Kustomize Diff
        run: |
          git diff --name-only HEAD^ HEAD | grep -E '(kustomization\.yaml|\.yaml$|\.yml$)' | \
            while read file; do
              dir=$(dirname "$file")
              if [ -f "$dir/kustomization.yaml" ]; then
                echo "Changes detected in $dir"
                kustomize build "$dir" --load-restrictor=LoadRestrictionsNone > /tmp/new.yaml
                git checkout HEAD^ -- "$dir"
                kustomize build "$dir" --load-restrictor=LoadRestrictionsNone > /tmp/old.yaml
                diff -u /tmp/old.yaml /tmp/new.yaml || true
              fi
            done
```

### **ArgoCD Integration**
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: production-app
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo.git
    targetRevision: main
    path: k8s/overlays/production
    kustomize:
      # ArgoCD-specific kustomize options
      namePrefix: prod-
      nameSuffix: -v1
      images:
        - nginx:1.21.0
      commonAnnotations:
        deployed-by: argocd
      commonLabels:
        environment: production
      # Force common labels/annotations on all resources
      forceCommonLabels: true
      forceCommonAnnotations: true
      # Replicas override
      replicas:
        - name: app-deployment
          count: 5
  destination:
    server: https://kubernetes.default.svc
    namespace: production
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
```

## **🔐 Security & Compliance Patterns**

### **Pod Security Standards (K8s 1.23+)**
```yaml
# components/psa-baseline/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

patches:
  - target:
      kind: Namespace
    patch: |
      - op: add
        path: /metadata/labels
        value:
          pod-security.kubernetes.io/enforce: baseline
          pod-security.kubernetes.io/enforce-version: latest
          pod-security.kubernetes.io/audit: restricted
          
  - target:
      kind: Pod
    patch: |
      - op: add
        path: /spec/securityContext
        value:
          seccompProfile:
            type: RuntimeDefault
          runAsNonRoot: true
```

### **Secrets Management with External Secrets**
```yaml
# overlays/production/secrets/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

generators:
  - |  # ExternalSecret (external-secrets.io)
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: database-credentials
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: vault-backend
        kind: SecretStore
      target:
        name: database-secret
        creationPolicy: Owner
      data:
        - secretKey: password
          remoteRef:
            key: /secrets/production/db
            property: password
        - secretKey: username
          remoteRef:
            key: /secrets/production/db
            property: username
            
configMapGenerator:
  - name: sealed-secret-params
    literals:
      - namespace=production
      - scope=strict
```

## **🚨 Production-Grade Patterns**

### **Multi-Cluster Management with Kustomize**
```yaml
# clusters/aws-us-west-2/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Import environment overlay
resources:
  - ../../../overlays/production

# Cluster-specific patches
patches:
  - target:
      kind: Ingress
    patch: |
      - op: replace
        path: /metadata/annotations/nginx.ingress.kubernetes.io~1load-balancer-id
        value: alb-1234567890
        
  - target:
      kind: PersistentVolumeClaim
    patch: |
      - op: replace
        path: /spec/storageClassName
        value: gp3
        
# Cluster-specific generators
configMapGenerator:
  - name: cluster-info
    literals:
      - CLUSTER_NAME=aws-us-west-2
      - REGION=us-west-2
      - PROVIDER=aws
      - VPC_ID=vpc-123456
```

### **Feature Flag Management**
```yaml
# kustomization.yaml with feature flags
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Feature flag ConfigMap
configMapGenerator:
  - name: feature-flags
    literals:
      - enableNewUI=true
      - enableBetaFeatures=false
      - maintenanceMode=false

# Conditional resources based on feature flags
transformers:
  - target:
      kind: Deployment
      name: app
    patch: |
      - op: add
        path: /spec/template/spec/containers/0/env
        value:
          - name: FEATURE_NEW_UI
            valueFrom:
              configMapKeyRef:
                name: feature-flags
                key: enableNewUI
          - name: BETA_FEATURES
            valueFrom:
              configMapKeyRef:
                name: feature-flags
                key: enableBetaFeatures
                
# Remove resources if feature is disabled
patches:
  - target:
      kind: Deployment
      name: beta-service
    patch: |
      - op: remove
        path: /spec
    options:
      allowMissingTarget: true
```

## **🧪 Testing & Validation**

### **Kustomize Test Framework**
```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  
# tests/test.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: KustomizationTest

tests:
  - name: deployment-has-correct-replicas
    resources:
      - ../deployment.yaml
    asserts:
      - equals:
          fieldPath: spec.replicas
          value: 3
          
  - name: service-selector-matches-deployment
    resources:
      - ../deployment.yaml
      - ../service.yaml
    asserts:
      - and:
        - equals:
            fieldPath: spec.selector.matchLabels.app
            value: myapp
        - exists:
            fieldPath: metadata.labels.app
```

### **Conftest Integration (Open Policy Agent)**
```bash
# conftest-policy.rego
package main

deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot
  msg := "Deployment must set runAsNonRoot"
}

# Test with
kustomize build overlays/production | conftest test -
```

## **⚙️ Performance Optimizations**

```yaml
# .kustomizerc (global config)
apiVersion: kustomize.config.k8s.io/v1beta1
kind: KustomizationConfig

buildMetadata: [originAnnotations, transformerAnnotations]
loadRestrictor: LoadRestrictionsNone
enableExec: true
enableStar: true

# Use caching for remote resources
reorder: legacy

# In production builds
kustomize build \
  --enable-alpha-plugins \
  --load-restrictor=LoadRestrictionsNone \
  --reorder=legacy \
  --enable-exec \
  overlays/production
```

## **🔧 Custom Transformers & Generators (Go Plugins)**

```go
// main.go
package main

import (
    "sigs.k8s.io/kustomize/api/types"
    "sigs.k8s.io/kustomize/kyaml/fn/framework"
    "sigs.k8s.io/kustomize/kyaml/yaml"
)

type AnnotationTransformer struct {
    Annotations map[string]string `yaml:"annotations,omitempty"`
}

func (at *AnnotationTransformer) Filter(objects []*yaml.RNode) ([]*yaml.RNode, error) {
    for _, obj := range objects {
        meta, err := obj.GetMeta()
        if err != nil {
            return nil, err
        }
        if meta.Annotations == nil {
            meta.Annotations = make(map[string]string)
        }
        for k, v := range at.Annotations {
            meta.Annotations[k] = v
        }
        err = obj.SetAnnotations(meta.Annotations)
        if err != nil {
            return nil, err
        }
    }
    return objects, nil
}

func main() {
    resource := &framework.ResourceList{
        FunctionConfig: &AnnotationTransformer{},
    }
    framework.Command(resource, func() error {
        return resource.Filter(&AnnotationTransformer{})
    }).Execute()
}
```

```yaml
# Use custom transformer
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

transformers:
  - kind: AnnotationTransformer
    annotations:
      managed-by: kustomize
      git-sha: $(git rev-parse HEAD)
```

## **📊 Comparison with Modern Alternatives**

| Feature | Kustomize | Helm | Carvel ytt | CUE |
|---------|-----------|------|------------|-----|
| **Paradigm** | Overlay/Patch | Templating | Templating | Configuration Language |
| **Learning Curve** | Low | Medium | High | Very High |
| **GitOps Ready** | ✅ Excellent | ⚠️ Needs Tillerless | ✅ Good | ✅ Good |
| **Multi-Environment** | ✅ Native | ⚠️ Values files | ✅ Good | ✅ Excellent |
| **Type Safety** | ❌ | ❌ | ⚠️ Limited | ✅ Excellent |
| **Secret Management** | ⚠️ Basic | ⚠️ Basic | ✅ Good | ✅ Good |
| **Community Adoption** | ✅ High | ✅ Very High | ⚠️ Moderate | ⚠️ Moderate |

## **🎯 Best Practices Summary**

1. **Use components** for cross-cutting concerns (v4+)
2. **Leverage replacements** over vars (deprecated)
3. **Structure overlays** by concern: environment × region × tenant
4. **Always validate** with `kustomize build --load-restrictor=LoadRestrictionsNone`
5. **Use generators** for dynamic content
6. **Implement testing** with kustomize test framework
7. **Cache remote resources** in CI/CD
8. **Seal secrets** before committing
9. **Use JSON patches** for complex transformations
10. **Monitor kustomize releases** - rapid evolution

This master guide covers advanced modern patterns for enterprise-grade Kubernetes management with Kustomize. The key is embracing its **declarative, patch-based philosophy** while leveraging new features like **components, replacements, and generators** for maximum power and flexibility.


When you use:

yaml
secretGenerator:
  - name: app-secret
    behavior: merge
    envs:
      - prod-secret.txt
The behavior field controls how Kustomize handles the existing secret in your manifests, NOT the source file. Here's what happens:

1. If the secret DOES NOT exist in base manifests:
With behavior: merge → Will create the secret

With behavior: create → Will create the secret

With behavior: replace → Will fail (no secret to replace)

2. If the secret DOES exist in base manifests:
With behavior: merge → Merge values from generator with base secret

With behavior: create → Error (can't create, already exists)

With behavior: replace → Replace base secret completely

