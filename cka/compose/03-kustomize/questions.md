# Kustomize Practice Questions

## Dependent Question Set (1-5) – Build a Complete Multi-Environment Application

These questions build progressively. Complete them in order.

---

## Question 1 – Base Application with ConfigMap & Redis

**Task**: Create a production-ready base Kustomize directory with Node.js API, ConfigMap, and Redis services.

**Requirements**:

1. Create `base/` directory with:
   - `deployment.yaml`: Node.js API (image: `node:18-alpine`, port: `3000`, replicas: `1`)
   - `service.yaml`: ClusterIP service (port `80` → `3000`)
   - `configmap.yaml`: App config with `APP_NAME=myapp`, `LOG_LEVEL=info`, `REDIS_HOST=redis-service`
   - `redis-deployment.yaml`: Redis (image: `redis:7-alpine`, port: `6379`)
   - `redis-service.yaml`: Redis ClusterIP service (port `6379`)
   - `kustomization.yaml`: Reference all 5 resources

2. Verify with: `kubectl kustomize base/` (no errors, all resources present)

**Deliverables**:
- Base directory fully functional
- All resources render correctly
- ConfigMap properly referenced in API deployment

---

## Question 2 – ConfigMap and Environment Variables

**Task**: Add ConfigMap to inject environment variables into deployment.

**Steps**:

1. Create `base/configmap.yaml` with keys:
   - `APP_NAME`: `myapp`
   - `LOG_LEVEL`: `debug`
   - `REDIS_HOST`: `redis-service`
2. Update `base/deployment.yaml` to mount ConfigMap as environment variables
3. Update `base/kustomization.yaml` to include ConfigMap
4. Verify with `kustomize build base/`

**Deliverables**:

- ConfigMap with 3 environment variables
- Deployment references ConfigMap
- Build succeeds with all resources

---

## Question 3 – Redis Sidecar Service

**Task**: Add Redis as a supporting service with environment variable injection.

**Steps**:

1. Create `base/redis-deployment.yaml`:
   - Image: `redis:7-alpine`
   - Port: `6379`
   - Replicas: `1`
2. Create `base/redis-service.yaml`:
   - Service type: `ClusterIP`
   - Port: `6379`
   - Selector: `app: redis`
3. Update `base/kustomization.yaml` to include both
4. Apply ConfigMap `REDIS_HOST=redis-service` to API deployment

**Deliverables**:

- Redis deployment and service working
- API deployment can reference `REDIS_HOST` from ConfigMap
- All 4 resources (API deploy, API svc, Redis deploy, Redis svc) in kustomization

---

## Question 4 – Development Overlay with Patches

**Task**: Create development overlay with different replica counts and labels.

**Steps**:

1. Create `overlays/dev/` directory
2. Create `overlays/dev/kustomization.yaml`:
   - Use `bases: ../../base`
   - Add namespace: `dev`
   - Add label: `env: dev`
   - Add name prefix: `dev-`
3. Create `overlays/dev/deployment-patch.yaml`:
   - Patch API deployment replicas to `2`
4. Include patch in `kustomization.yaml` using the newer `patches` field (recommended).

    Example (reference file):

    ```yaml
    patches:
       - path: deployment-patch.yaml
          target:
             kind: Deployment
             name: myapp-deployment
    ```

    Or inline patch:

    ```yaml
    patches:
       - target:
             kind: Deployment
             name: myapp-deployment
          patch: |-
             spec:
                replicas: 2
    ```

    Note: `patchesStrategicMerge` is deprecated in recent Kustomize versions — prefer `patches`.
5. Test with `kustomize build overlays/dev/`

**Deliverables**:

- Dev overlay directory created
- All resources prefixed with `dev-`
- API deployment has 2 replicas in dev
- Build succeeds

---

## Question 5 – Production Overlay

**Task**: Create production overlay with higher replicas and resource limits.

**Steps**:

1. Create `overlays/prod/` directory
2. Create `overlays/prod/kustomization.yaml`:
   - Use `bases: ../../base`
   - Add namespace: `prod`
   - Add label: `env: prod`
   - Add name prefix: `prod-`
3. Create `overlays/prod/deployment-patch.yaml`:
   - Patch API deployment replicas to `4`
4. Create `overlays/prod/resources-patch.yaml`:
   - Add resource requests: `cpu: 100m`, `memory: 128Mi`
   - Add resource limits: `cpu: 500m`, `memory: 512Mi`
5. Test with `kustomize build overlays/prod/`

**Deliverables**:

- Prod overlay with higher replicas
- Resource limits configured
- All resources prefixed with `prod-`

---

## Question 6 – Image Tag Management

**Task**: Use different container image versions for dev and prod.

**Steps**:

1. In `overlays/dev/kustomization.yaml`:
   - Add `images` section
   - Set image: `node` tag to `18-alpine`
2. In `overlays/prod/kustomization.yaml`:
   - Add `images` section
   - Set image: `node` tag to `18.20.0-alpine`
3. Keep base using generic tag
4. Verify tags are correctly applied with `kustomize build`

**Deliverables**:

- Dev uses `node:18-alpine`
- Prod uses `node:18.20.0-alpine`
- Image tag transformer working correctly

---

## Question 7 – ConfigMap Generator

**Task**: Use Kustomize ConfigMap generator instead of static YAML.

**Steps**:

1. In base directory, create `.env.dev` file with environment variables
2. In `overlays/dev/kustomization.yaml`:
   - Use `configMapGenerator` section
   - Name: `app-config`
   - Load from `files: .env.dev`
3. Update deployment to reference generated ConfigMap
4. Remove static configmap.yaml from base
5. Test build and verify ConfigMap is generated with hash suffix

**Deliverables**:

- ConfigMap generated from file
- Deployment references generated ConfigMap
- Build shows hash suffix on ConfigMap name

---

## Question 8 – Secret Generator

**Task**: Create secrets for database passwords using generator.

**Steps**:

1. Create files in `overlays/dev/`:
   - `.env.secrets` with `DB_PASSWORD=devpass123`
2. In `overlays/dev/kustomization.yaml`:
   - Use `secretGenerator`
   - Name: `db-credentials`
   - Load from `files: .env.secrets`
3. Create `overlays/prod/`:
   - `.env.secrets` with `DB_PASSWORD=prod-secure-pass`
4. Both overlays generate Secrets with hash suffix
5. Verify with `kustomize build`

**Deliverables**:

- Dev and Prod Secrets generated separately
- Secrets have hash suffixes
- Passwords differ between environments

---

## Question 9 – Patches (strategic merge)

**Task**: Apply strategic merge-style patches to multiple resources (use the `patches` field; `patchesStrategicMerge` is deprecated).

**Steps**:

1. Create `overlays/prod/patches/deployment-patch.yaml`:
   - Patch replicas
   - Patch resource limits
   - Patch image tag
2. Create `overlays/prod/patches/service-patch.yaml`:
   - Change service type to `LoadBalancer`
3. In `overlays/prod/kustomization.yaml`:
   - Use the `patches` section and reference both patch files (with `path` and an optional `target`)
4. Verify patches apply correctly

**Deliverables**:

- Multiple patches defined
- All patches apply without errors
- Service type changed in prod only

---

## Question 10 – JSON Patches (RFC 6902)

**Task**: Use JSON patches for more precise modifications.

**Steps**:

1. Create `overlays/staging/patches.yaml`:
   - Add annotation to all Pods
   - Add label to all Deployments
   - Modify security context
2. In `overlays/staging/kustomization.yaml`:
   - Use `patchesJson6902` section
   - Reference patch file
3. Apply patches to Deployment and Service
4. Verify annotations and labels applied

**Deliverables**:

- JSON patches defined correctly
- Annotations added to resources
- Labels applied to Deployments

---

## Question 11 – Kustomization Bases & Cross-Overlay Composition

**Task**: Create multiple overlay layers with base composition.

**Steps**:

1. Create `overlays/staging/` that uses `../../base`
2. Create `overlays/qa/` that uses `../../base`
3. Each overlay has unique:
   - Namespace
   - Name prefix
   - Labels
   - Resource patches
4. Build all three overlays and verify no conflicts
5. Compare outputs of dev, staging, prod, qa

**Deliverables**:

- 4 overlays (dev, staging, prod, qa) working
- Each has unique configuration
- All build without errors

---

## Question 12 – CommonLabels and CommonAnnotations

**Task**: Apply labels and annotations to all resources globally.

**Steps**:

1. In `overlays/prod/kustomization.yaml`:
   - Add `commonLabels`:
     - `app: myapp`
     - `env: prod`
     - `version: 1.0.0`
   - Add `commonAnnotations`:
     - `description: Production deployment`
     - `owner: platform-team`
2. Verify all resources get these labels/annotations
3. In `overlays/dev/kustomization.yaml`:
   - Set different commonLabels
4. Compare label differences between overlays

**Deliverables**:

- All resources labeled with common labels
- All resources annotated with common annotations
- Dev and Prod have different labels

---

## Question 13 – Namespace Management

**Task**: Configure namespace handling across overlays.

**Steps**:

1. In `overlays/dev/kustomization.yaml`:
   - Set `namespace: dev`
2. In `overlays/prod/kustomization.yaml`:
   - Set `namespace: prod`
3. Create `overlays/staging/kustomization.yaml`:
   - Set `namespace: staging`
4. Build all three and verify namespace in output
5. Ensure all resources are in correct namespace

**Deliverables**:

- Each overlay in separate namespace
- All resources correctly namespaced
- Build outputs show correct namespace

---

## Question 14 – Resource Composition with Multiple Bases

**Task**: Extend base with additional resource generator.

**Steps**:

1. Create `base/monitoring.yaml` with:
   - ConfigMap for monitoring settings
   - ServiceMonitor reference (Prometheus)
2. Add to `base/kustomization.yaml`
3. In `overlays/prod/kustomization.yaml`:
   - Add `resources:` section
   - Include additional monitoring resources
4. Ensure monitoring not in dev overlay
5. Verify Prod has monitoring, Dev doesn't

**Deliverables**:

- Monitoring resources in base (or prod-specific)
- Monitoring ConfigMap generated
- Prod overlay includes monitoring

---

## Question 15 – Ingress with Custom Hosts

**Task**: Create overlay-specific Ingress configurations.

**Steps**:

1. Create `base/ingress.yaml` with template host: `example.com`
2. In `overlays/dev/ingress-patch.yaml`:
   - Patch to use `dev.example.com`
3. In `overlays/prod/ingress-patch.yaml`:
   - Patch to use `api.example.com`
   - Add TLS configuration
4. Include patches in respective kustomizations
5. Verify Ingress hosts differ per environment

**Deliverables**:

- Dev Ingress uses `dev.example.com`
- Prod Ingress uses `api.example.com` with TLS
- Patches applied correctly

---

## Question 16 – PersistentVolume and StatefulSet

**Task**: Add stateful components with volume management.

**Steps**:

1. Create `base/statefulset.yaml` for Redis or PostgreSQL
2. Create `base/storageclass.yaml`
3. Create `base/persistentvolumeclaim.yaml`
4. In `overlays/dev/`:
   - Override storage size to `5Gi`
5. In `overlays/prod/`:
   - Override storage size to `100Gi`
   - Add volume snapshots patch
6. Verify storage configurations differ

**Deliverables**:

- StatefulSet defined with PVC
- Dev has 5Gi, Prod has 100Gi storage
- StorageClass configured

---

## Question 17 – Environment-Specific Files with SecretGenerator

**Task**: Load environment-specific configuration files for different secrets.

**Steps**:

1. Create environment files:
   - `overlays/dev/.env.prod-secrets`
   - `overlays/prod/.env.prod-secrets`
2. In each overlay's kustomization:
   - Use `secretGenerator` with `envs:`
   - Reference respective `.env` files
3. Secrets differ between dev/prod
4. Verify with `kustomize build`

**Deliverables**:

- Separate secrets per environment
- Secrets loaded from files
- Build shows correct secret values

---

## Question 18 – Post-Renderer and Replacements

**Task**: Apply post-generation replacements for placeholder values.

**Steps**:

1. In `base/configmap.yaml`:
   - Use placeholder: `CLUSTER_NAME: REPLACE_ME`
2. In `overlays/dev/kustomization.yaml`:
   - Use `replacements` section
   - Replace `REPLACE_ME` with `dev-cluster`
3. In `overlays/prod/kustomization.yaml`:
   - Replace `REPLACE_ME` with `prod-cluster`
4. Build and verify replacements applied

**Deliverables**:

- Placeholders replaced per overlay
- Dev has `dev-cluster`
- Prod has `prod-cluster`

---

## Question 19 – Full End-to-End Build and Deploy

**Task**: Build complete manifests for all overlays and prepare for deployment.

**Steps**:

1. Build all overlays:
   - `kustomize build overlays/dev/`
   - `kustomize build overlays/staging/`
   - `kustomize build overlays/prod/`
2. Save outputs to files:
   - `dev-manifest.yaml`
   - `staging-manifest.yaml`
   - `prod-manifest.yaml`
3. Verify each manifest has correct:
   - Namespace
   - Replicas
   - Image tags
   - Labels
4. Check for no duplicated resources

**Deliverables**:

- 3+ manifests built successfully
- Each manifest is complete and deployable
- No resource conflicts

---

## Question 20 – Kustomization Best Practices

**Task**: Apply best practices to the entire Kustomize structure.

**Steps**:

1. Organize directory structure properly
2. Document each kustomization with comments
3. Use meaningful names for patches
4. Avoid hardcoded values in base
5. Keep overlays independent
6. Use generators for dynamic content
7. Verify no duplicate resources across overlays
8. Test all builds together

**Deliverables**:

- Clean directory structure
- Well-documented kustomizations
- All best practices applied
- Complete working practice package
