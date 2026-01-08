# Kustomize Practice Questions (Compressed)

---

## Question 1 – Multi-Environment Base + Overlays with Patches

**Task**: Build a complete base application with dev/prod overlays using patches and ConfigMap generators. This is a **dependent** question—your solution here becomes the foundation for Q2 and Q3.

**Steps**:

1. **Create base structure:**
   ```
   base/
     deployment.yaml       # API server: node:18-alpine, port 3000, 1 replica
     service.yaml          # ClusterIP service on port 80→3000
     configmap.yaml        # APP_NAME, LOG_LEVEL, REDIS_HOST
     redis-deployment.yaml # Redis: redis:7-alpine, port 6379
     redis-service.yaml    # Redis ClusterIP service
     kustomization.yaml    # resources: [all above]
   ```

2. **Create dev overlay with patches:**
   ```
   overlays/dev/
     kustomization.yaml    # resources: ../../base, namespace: dev, namePrefix: dev-, patches: [deployment-patch.yaml]
     patches/
       deployment-patch.yaml    # Patch replicas: 2
   ```

3. **Create prod overlay with patches + resource limits:**
   ```
   overlays/prod/
     kustomization.yaml    # resources: ../../base, namespace: prod, namePrefix: prod-, patches: [deployment-patch.yaml, resources-patch.yaml]
     patches/
       deployment-patch.yaml    # Patch replicas: 4
       resources-patch.yaml     # CPU: 100m→500m, Memory: 128Mi→512Mi
   ```

4. **Add labels to both overlays using `labels` field (no deprecation warnings)**

5. **Test:**
   ```bash
   kustomize build overlays/dev/
   kustomize build overlays/prod/
   ```

**Deliverables**:

- ✅ Base with 5 resources (2 deployments, 2 services, 1 configmap)
- ✅ Dev overlay: 2 replicas, dev namespace, dev- prefix, labels applied
- ✅ Prod overlay: 4 replicas, prod namespace, prod- prefix, resource limits, labels applied
- ✅ Both build cleanly with no warnings

---

## Question 2 – ConfigMap/Secret Generators + Image Patching (Dependent on Q1)

**Task**: Extend your Q1 solution to replace static ConfigMaps with generators and manage image tags per environment.

**Steps**:

1. **Create environment config files:**
   ```
   overlays/dev/.env.config      # APP_NAME=myapp-dev, LOG_LEVEL=debug, REDIS_HOST=redis-service
   overlays/prod/.env.config     # APP_NAME=myapp-prod, LOG_LEVEL=info, REDIS_HOST=redis-service
   ```

2. **Create secret files:**
   ```
   overlays/dev/.env.secrets     # DB_PASSWORD=devpass123, DB_USER=dev
   overlays/prod/.env.secrets    # DB_PASSWORD=prod-secure-xyz, DB_USER=prod
   ```

3. **Update overlays/dev/kustomization.yaml:**
   - Add `configMapGenerator:` with `.env.config` file
   - Add `secretGenerator:` with `.env.secrets` file
   - Add `images:` section: change `node` tag to `18-alpine`
   - Update deployment to reference generated ConfigMap name (with hash)

4. **Update overlays/prod/kustomization.yaml:**
   - Same generators as dev (but different .env files)
   - `images:` change `node` tag to `18.20.0-alpine`
   - Add `kustomization` flag to **not** add hash suffix (optional, for stable names)

5. **Test:**
   ```bash
   kustomize build overlays/dev/ | grep ConfigMap
   kustomize build overlays/prod/ | grep ConfigMap
   kustomize build overlays/dev/ | grep image:
   kustomize build overlays/prod/ | grep image:
   ```

**Deliverables**:

- ✅ ConfigMaps generated from files (show hash suffix)
- ✅ Secrets generated from files  
- ✅ Image tags differ: dev uses `18-alpine`, prod uses `18.20.0-alpine`
- ✅ Deployment references generated ConfigMap correctly
- ✅ Both build successfully

---

## Question 3 – Advanced: Composable Multi-Base + JSON Patches (Independent)

**Task**: Build a **separate** advanced project that demonstrates multi-base composition, JSON patches (RFC 6902), and cross-cutting concerns (monitoring, security policies).

**Steps**:

1. **Create separate project structure:**
   ```
   advanced/
     bases/
       core/
         deployment.yaml    # Generic stateless app (no image hardcoded)
         service.yaml
         kustomization.yaml
       monitoring/
         servicemonitor.yaml (Prometheus)
         kustomization.yaml
       security/
         networkpolicy.yaml
         podsecuritypolicy.yaml
         kustomization.yaml
     overlays/
       staging/
         kustomization.yaml  # bases: [../../bases/core, ../../bases/monitoring], patches: [security-patch.json]
       prod/
         kustomization.yaml  # bases: [../../bases/core, ../../bases/monitoring, ../../bases/security]
   ```

2. **Create JSON patches for staging (RFC 6902):**
   - Add annotation `monitoring: "true"` to all Pods
   - Add label `env: staging` to Deployments
   - Patch service type to `LoadBalancer` (optional, for staging only)

3. **Use `patchesJson6902` in overlays/staging/kustomization.yaml to apply JSON patches**

4. **Prod overlay combines all bases directly (no JSON patches needed)**

5. **Test:**
   ```bash
   kustomize build overlays/staging/ | grep annotation
   kustomize build overlays/prod/ | grep NetworkPolicy
   ```

**Deliverables**:

- ✅ Multi-base composition working (core + monitoring + security)
- ✅ Staging applies JSON patches correctly
- ✅ Prod includes all security bases
- ✅ Both build without errors
- ✅ Clear separation of concerns: core app / monitoring / security

---

## How to Approach:

1. **Q1 (Foundation)**: Build everything from scratch. Learn base → overlay → patches workflow.
2. **Q2 (Extend Q1)**: Use your Q1 solution as base. Add generators and image management.
3. **Q3 (Standalone Deep Dive)**: Start fresh. Focus on advanced patterns: multi-base, JSON patches, composition.

**Time estimate**: Q1: 30min, Q2: 20min (extending Q1), Q3: 25min (independent exploration)
