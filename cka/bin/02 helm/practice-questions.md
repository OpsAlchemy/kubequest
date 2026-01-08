# Helm Practice Questions - Progressive Learning Path

## Level 1: Fundamentals (Basic Templates & Values)

### Question 1.1: Simple Deployment Chart
**Objective**: Create a basic Helm chart that deploys a single Nginx application.

**Requirements**:
- Chart should accept the following configurable parameters through `values.yaml`:
  - Application name
  - Container image and tag
  - Number of replicas
  - Container port
  - Service type (ClusterIP, NodePort, or LoadBalancer)
- Generate Deployment and Service manifests
- Service should expose the application on the configured port
- Use proper naming conventions with release name and chart name

**Constraints**:
- Do not hardcode any values in templates
- All configuration must come from `values.yaml`

---

### Question 1.2: ConfigMap and Environment Variables
**Objective**: Deploy an application that uses ConfigMap for configuration management.

**Requirements**:
- Create a chart that deploys an application with environment variables
- ConfigMap should store:
  - Application log level
  - API endpoint URL
  - Database host
- Deployment should inject these values as environment variables
- Allow overriding all ConfigMap values through `values.yaml`

**Constraints**:
- ConfigMap data must be stored separately from deployment spec
- Environment variables should be clearly documented

---

### Question 1.3: Multi-Container Pod
**Objective**: Create a Deployment with multiple containers in a single pod.

**Requirements**:
- Main application container (app container)
- Sidecar container (logging aggregator or monitoring agent)
- Both containers should have:
  - Configurable image and tag
  - Configurable resource requests/limits
  - Configurable container port
- Pod should expose both container ports through the Service

**Constraints**:
- Each container must have its own configuration section in `values.yaml`
- Resource limits must be mandatory (not optional)

---

## Level 2: Template Logic & Control Flow

### Question 2.1: Conditional Template Rendering
**Objective**: Create a chart that conditionally includes/excludes Kubernetes resources based on configuration.

**Requirements**:
- Deployment should only include:
  - Ingress resource when `ingress.enabled` is true
  - HorizontalPodAutoscaler when `autoscaling.enabled` is true
  - ResourceQuota when `resourceQuota.enabled` is true
- Each optional resource must have its complete configuration in `values.yaml`
- Template conditions should be clear and documented

**Constraints**:
- Use only Helm template conditionals (if/else)
- No resource duplication

---

### Question 2.2: Loops and Template Iteration
**Objective**: Deploy an application with multiple configuration volumes and volume mounts.

**Requirements**:
- Support mounting multiple ConfigMaps as volumes
- Support mounting multiple Secrets as volumes
- Each volume should be independently configurable with:
  - Name
  - Mount path
  - Permissions (optional)
- Deployment spec should iterate through all configured volumes

**Constraints**:
- Volumes list must be defined in `values.yaml` as an array
- Template must use range/loop constructs

---

### Question 2.3: Template Functions and Filters
**Objective**: Create templates that transform and format values using Helm functions.

**Requirements**:
- Application labels should be generated dynamically with:
  - Proper casing transformations
  - Version tagging
  - Environment tagging
- Resource names should be truncated to valid Kubernetes length (using trunc function)
- Annotations should concatenate multiple values
- Template should include:
  - String manipulation (upper, lower, title case)
  - Quote functions for proper YAML formatting
  - Default value handling

**Constraints**:
- Must demonstrate at least 5 different Helm template functions
- All transformations must be properly quoted for YAML validity

---

## Level 3: Advanced Templating & Helm Features

### Question 3.1: Helm Hooks and Lifecycle
**Objective**: Create a chart that executes pre and post deployment tasks.

**Requirements**:
- Pre-install hook: Job to validate prerequisites
- Pre-upgrade hook: Job to backup current state
- Post-install hook: Job to initialize application
- Each hook should:
  - Have appropriate `deletion-policy` annotation
  - Be weight-ordered for execution sequence
  - Include proper RBAC if needed
- Hooks should be optional (can be disabled via `values.yaml`)

**Constraints**:
- Hooks must not cause deployment failure if they fail (unless critical)
- Proper cleanup policies must be defined

---

### Question 3.2: Named Templates and Template Reuse
**Objective**: Create reusable template components for common patterns.

**Requirements**:
- Create named templates for:
  - Pod label generation
  - Common annotations generation
  - Resource requests/limits
  - Security context
  - Probe configuration
- Main templates should use these named templates extensively
- Support both individual container probes and pod-wide security settings

**Constraints**:
- Each named template must be in separate `_*.tpl` file
- Demonstrate template scope and parameter passing
- Minimize code duplication

---

### Question 3.3: Helm Values Validation & Defaults
**Objective**: Create a chart with complex nested values and validation.

**Requirements**:
- Define a complex `values.yaml` with:
  - Nested objects for database configuration
  - Nested objects for cache configuration
  - Nested arrays for multiple environments
  - Proper defaults for all optional values
- Template must:
  - Validate that required values are provided
  - Apply defaults for missing optional values
  - Handle type mismatches gracefully
- Include template that documents all available values

**Constraints**:
- Use `required` function for mandatory values
- Use nested object structure (3+ levels deep)

---

### Question 3.4: Multi-Chart Dependencies
**Objective**: Create a parent chart that depends on child charts.

**Requirements**:
- Create main application chart
- Create dependency charts for:
  - Database (PostgreSQL/MySQL)
  - Cache (Redis)
  - Message Queue (RabbitMQ)
- Parent chart should:
  - Declare dependencies in `Chart.yaml`
  - Override dependency values from parent `values.yaml`
  - Control which dependencies are installed
  - Pass values to child charts with proper scoping

**Constraints**:
- Dependencies must be properly versioned
- Parent chart must demonstrate selective dependency enablement

---

## Level 4: Production Patterns & Advanced Features

### Question 4.1: Multi-Environment & Namespace Strategy
**Objective**: Create a single chart that deploys across development, staging, and production environments.

**Requirements**:
- Chart should support values files for each environment:
  - `values-dev.yaml` - for development
  - `values-stg.yaml` - for staging
  - `values-prod.yaml` - for production
- Each environment should have different:
  - Replica counts
  - Resource limits
  - Security policies
  - Ingress configurations
  - Storage configurations
- Template should conditionally include environment-specific ConfigMaps and Secrets

**Constraints**:
- Single chart.yaml, multiple values files
- No environment hardcoding in templates

---

### Question 4.2: Secrets Management Integration
**Objective**: Create templates that integrate with external secret management systems.

**Requirements**:
- Support multiple secret backends:
  - Kubernetes native Secrets
  - External Secrets Operator references
  - HashiCorp Vault integration
- Templates should:
  - Reference secrets by name/path
  - Handle secret rotation annotations
  - Support sealed secrets compatibility
- Deployment should mount secrets:
  - As environment variables
  - As volume mounts
  - Both methods should be configurable

**Constraints**:
- No secret values in `values.yaml`
- Template must support switching between secret backends via configuration

---

### Question 4.3: RBAC and Security Context Templates
**Objective**: Create comprehensive RBAC and security-focused templates.

**Requirements**:
- Generate:
  - ServiceAccount
  - Role/ClusterRole (with appropriate permissions)
  - RoleBinding/ClusterRoleBinding
  - Pod Security Policy or Security Context
  - Network Policy (optional)
- Configuration should include:
  - Custom RBAC rules (configurable)
  - Pod security context (read-only filesystem, non-root user)
  - Container security context (capabilities dropping)
  - Service Account Token automounting control

**Constraints**:
- RBAC rules must be minimal and specific
- Security context must follow Kubernetes best practices

---

### Question 4.4: Complex Deployment Strategy
**Objective**: Create templates supporting multiple deployment strategies.

**Requirements**:
- Support multiple deployment patterns:
  - Rolling update (standard)
  - Blue-green deployment (two separate deployments)
  - Canary deployment (with weighted traffic)
  - Feature flag driven releases
- For each strategy:
  - Define required configuration in `values.yaml`
  - Template conditionally generates appropriate resources
  - Support gradual traffic shifting
- Include status tracking resources (optional)

**Constraints**:
- Single chart must support all strategies
- Switching strategies should only require values.yaml changes

---

### Question 4.5: Helm Testing & Validation
**Objective**: Create test charts and validation templates.

**Requirements**:
- Create Helm test pods that validate:
  - Application connectivity
  - Configuration correctness
  - Environment variables
  - Volume mounts
  - Security context
- Test pod should:
  - Run after deployment
  - Have proper cleanup policies
  - Exit with appropriate status
  - Generate meaningful output
- Include template that validates values.yaml schema

**Constraints**:
- Tests must not require external dependencies
- Test cleanup must be automatic

---

## Level 5: Expert Scenarios & Real-World Patterns

### Question 5.1: Stateful Application with Storage
**Objective**: Create a chart for a stateful application with persistent storage.

**Requirements**:
- Statefulset for ordered, stable Pod identities
- Storage configuration:
  - PersistentVolumeClaim generation
  - Storage class selection
  - Mount path configuration
- Support:
  - StatefulSet specific features (headless service, pod DNS)
  - Rolling updates with PVC retention
  - Backup/restore hooks
  - Data migration between storage classes

**Constraints**:
- Must use StatefulSet (not Deployment)
- Storage configuration must be flexible

---

### Question 5.2: Helm Plugins and Custom Functions
**Objective**: Create templates that use custom plugin functions or advanced templating.

**Requirements**:
- Implement custom template functions for:
  - Environment-specific variable substitution
  - Kubernetes resource validation
  - Image digest resolution
  - Custom label generation
- Template must:
  - Use these custom functions effectively
  - Handle function failures gracefully
  - Document custom function usage

**Constraints**:
- Must create actual working functions (not pseudocode)
- Functions must be reusable across templates

---

### Question 5.3: GitOps and Helm Operator Integration
**Objective**: Create a chart designed for GitOps workflow.

**Requirements**:
- Chart structure optimized for:
  - Flux CD or ArgoCD integration
  - HelmRelease resource generation
  - Automated sync and monitoring
- Include:
  - Health check configuration
  - Sync behavior controls
  - Rollback capabilities
  - Notification annotations
- Support value-driven deployments from Git

**Constraints**:
- Chart must be compatible with popular GitOps tools
- Proper CRD references if needed

---

### Question 5.4: Umbrella Chart with Microservices
**Objective**: Create a parent chart managing multiple microservices.

**Requirements**:
- Parent chart (umbrella) that orchestrates:
  - API service
  - Frontend service
  - Backend service
  - Worker service
  - Database
  - Cache
- Features:
  - Selective component enablement
  - Shared configuration management
  - Service discovery and DNS configuration
  - Cross-service communication security
  - Centralized logging configuration

**Constraints**:
- Must handle 6+ child charts
- Shared values must be properly scoped

---

### Question 5.5: Production Readiness Checklist
**Objective**: Create a comprehensive production-ready Helm chart.

**Requirements**:
- Chart must include and configure:
  - Health checks (liveness and readiness probes)
  - Resource requests and limits
  - Horizontal Pod Autoscaling
  - Pod Disruption Budgets
  - Affinity rules (node/pod affinity)
  - Tolerations for node taints
  - Proper logging and monitoring hooks
  - RBAC and security contexts
  - Network policies
  - Service mesh integration (if applicable)
- Documentation:
  - Values.yaml documentation
  - Deployment guide
  - Troubleshooting guide
  - Upgrade procedure

**Constraints**:
- All components must be optional (configurable)
- Security requirements must be non-negotiable
- Performance/reliability cannot be compromised

---

## Learning Path Recommendation

1. **Start with Level 1** (1.1 → 1.2 → 1.3) to understand basic Helm mechanics
2. **Progress to Level 2** (2.1 → 2.2 → 2.3) to learn template logic and features
3. **Move to Level 3** (3.1 → 3.2 → 3.3 → 3.4) for advanced templating patterns
4. **Explore Level 4** (4.1 → 4.2 → 4.3 → 4.4 → 4.5) for production scenarios
5. **Master Level 5** (5.1 → 5.2 → 5.3 → 5.4 → 5.5) for expert implementations

Each level builds on previous knowledge. Complete at least 2-3 questions per level before advancing.
