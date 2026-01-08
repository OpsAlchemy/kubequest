# **Creating Helm Charts**

## **Basic Chart Structure**
```bash
helm create firstchart
tree firstchart/
firstchart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl    # Helper templates
│   └── tests/          # Test files
│       └── test-connection.yaml
└── charts/             # Subcharts/dependencies
```

## **Chart.yaml - Essential Fields**
```yaml
apiVersion: v2
name: firstchart
description: A Helm chart for Kubernetes
type: application        # application or library
version: 0.1.0           # Chart version
appVersion: "1.0.0"      # Application version
```

## **Packaging Charts**
```bash
# Create .tgz package
helm package firstchart/
# Output: firstchart-0.1.0.tgz

# Package with custom directory
helm package firstchart/ -d ./packaged

# Update dependencies in chart
helm package firstchart/ -u     # Update dependencies first
```

## **Testing & Linting**
```bash
# Test a release (requires release name, not version)
helm test chart          # Not v1.0.0 or v2

# Lint your chart
helm lint firstchart/

# Lint with strict mode
helm lint firstchart/ --strict

# Dry run install
helm install myrelease firstchart/ --dry-run

# Template rendering
helm template myrelease firstchart/
```

## **Chart Development Workflow**
```bash
# 1. Create chart
helm create myapp

# 2. Edit Chart.yaml, values.yaml, templates

# 3. Lint
helm lint myapp/

# 4. Dry run
helm install myapp myapp/ --dry-run

# 5. Package
helm package myapp/

# 6. Install
helm install myapp myapp-0.1.0.tgz

# 7. Test (after install)
helm test myapp
```

## **Quick Tips**
1. **Test command** needs release name (not version number)
2. **Package creates** .tgz file in current directory
3. **Lint catches** YAML syntax errors
4. **Dry-run** shows what will be deployed
5. **port-forward** from NOTES.txt to test locally