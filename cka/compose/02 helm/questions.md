# Helm Practice Questions

---

## Question 1 – MinIO Helm Install

**Task**: Install MinIO on namespace `storage` with credentials and 10Gi storage.

**Steps**:

1. Add Bitnami repo: `https://charts.bitnami.com/bitnami`
2. Create namespace `storage`
3. Install chart `bitnami/minio` as release `minio-app`

**Value keys to override**:

| Key | Value |
|-----|-------|
| `auth.rootUser` | `minioadmin` |
| `auth.rootPassword` | `miniosecret` |
| `persistence.enabled` | `true` |
| `persistence.size` | `10Gi` |

---

## Question 2 – PostgreSQL Helm Install

**Task**: Install PostgreSQL on namespace `databases` with user `appuser`, password `apppass`, database `appdb`, and 5Gi storage.

**Steps**:

1. Add Bitnami repo: `https://charts.bitnami.com/bitnami`
2. Create namespace `databases`
3. Install chart `bitnami/postgresql` as release `pg-app`

**Value keys to override**:

| Key | Value |
|-----|-------|
| `auth.username` | `appuser` |
| `auth.password` | `apppass` |
| `auth.database` | `appdb` |
| `primary.persistence.size` | `5Gi` |

---

## Question 3 – Redis Helm Upgrade

**Task**: Upgrade existing `redis-app` release to enable authentication with password `redispass` and increase storage to 8Gi.

**Steps**:

1. Assume `redis-app` is already installed in namespace `databases` from `bitnami/redis`
2. Use `helm upgrade` to update the release
3. Make sure authentication is enabled

**Value keys to change**:

| Key | Value |
|-----|-------|
| `auth.enabled` | `true` |
| `auth.password` | `redispass` |
| `primary.persistence.size` | `8Gi` |

---

## Question 4 – Create and Use a Simple Helm Chart

**Task**: Create a Helm chart named `simple-app`, install to namespace `demo` with 2 replicas, image tag `1.0.0`, then upgrade to tag `1.1.0`.

**Steps**:

1. Create new chart using `helm create`
2. Create namespace `demo`
3. Install the chart as release `simple-release`
4. Then upgrade the release to new image tag

**Value keys to set**:

| Key | Value |
|-----|-------|
| `replicaCount` | `2` |
| `image.repository` | `myorg/simple-app` |
| `image.tag` | `1.0.0` → upgrade to `1.1.0` |
| `service.port` | `8080` |

---

## Question 5 – Multi-Environment Helm Deployment

**Task**: Deploy MinIO Operator v4.3.7 to three environments (dev, staging, prod) with different replica counts and tenant configurations.

**Steps**:

1. Add MinIO Operator repo: `https://operator.min.io`
2. Create three namespaces: `minio-dev`, `minio-staging`, `minio-prod`
3. Install same chart to each namespace with different configurations

**Environment-specific values**:

| Environment | `operator.replicaCount` | `tenants[0].pools[0].servers` |
|-------------|:-----:|:-----:|
| Dev | `1` | `1` |
| Staging | `2` | `2` |
| Prod | `3` | `4` |

**Also set for all environments**:

- `tenants[0].secrets.accessKey`
- `tenants[0].secrets.secretKey`

---

## Question 6 – Helm Search and Show Commands

**Task**: Search for Helm charts and inspect their values.

**Practice**:

1. Search for `nginx` chart in Bitnami repo
2. Search for all PostgreSQL versions available
3. Show the values for `redis` chart
4. Show the README for `postgresql` chart
5. Show chart metadata for `nginx`

---

## Question 7 – Helm Template Rendering

**Task**: Render Helm templates locally without installing.

**Practice**:

1. Render `nginx` template with 3 replicas locally
2. Render `postgresql` template and save output to a file
3. Render `redis` template with custom namespace
4. Run `helm lint` on chart directory to check syntax

---

## Question 8 – Helm Rollback

**Task**: Rollback a release to previous version.

**Scenario**: Release `simple-release` has been upgraded and something broke.

**Practice**:

1. View release history of `simple-release`
2. Rollback to previous revision
3. Rollback to specific revision number
4. Verify current values after rollback

---

## Question 9 – Helm Uninstall and Cleanup

**Task**: Uninstall releases and clean up resources.

**Practice**:

1. Uninstall `minio-app` from namespace `storage`
2. Uninstall `pg-app` but keep release history
3. List all releases including uninstalled ones
4. Delete the namespace

---

## Question 10 – Helm Repository Management

**Task**: Manage Helm repositories.

**Practice**:

1. Add Bitnami repo
2. Add MinIO Operator repo
3. Add Stable repo
4. List all repos
5. Update repos to get latest versions
6. Search in specific repo
7. Remove a repo

---

## Question 11 – Helm Get Commands

**Task**: Retrieve information about installed releases.

**Scenario**: Get details about installed releases

**Practice**:

1. Get current values of `minio-app` release
2. Get all Kubernetes manifests created by `pg-app`
3. Get hooks from `pg-app` (if any)
4. Get release notes from `simple-release`
5. Get all information about a release

---

## Question 12 – Multi-Value Files Deployment

**Task**: Deploy using multiple values files with layering.

**Scenario**: Base values + environment-specific overrides

**Practice**:

1. Create `values.yaml` with base configuration
2. Create `values-dev.yaml` with dev overrides
3. Create `values-prod.yaml` with prod overrides
4. Install chart using multiple `--values` files (base + prod)
5. Understand value precedence (later files override earlier ones)
