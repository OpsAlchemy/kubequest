#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Variables
MINIKUBE_PROFILE="minikube-calico"
INGRESS_NAMESPACE="ingress-nginx"
INGRESS_SERVICE_NAME="ingress-nginx-controller"

# Function to check if kubectl is configured
check_kubectl() {
    if ! command -v kubectl >/dev/null 2>&1; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "kubectl is not configured properly"
        exit 1
    fi
    
    log_success "kubectl is configured properly"
}

# Function to wait for ingress controller to be ready
wait_for_ingress_ready() {
    log_info "Waiting for NGINX Ingress Controller to be ready..."
    
    # Wait for the pod to be running
    kubectl wait --namespace="$INGRESS_NAMESPACE" \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    # Additional wait for the webhook to be ready
    log_info "Waiting for admission webhook to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if kubectl get pod -n "$INGRESS_NAMESPACE" -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].status.containerStatuses[0].ready}' | grep -q "true"; then
            log_success "NGINX Ingress Controller is fully ready"
            return 0
        fi
        log_info "Attempt $attempt/$max_attempts: Waiting for controller to be ready..."
        sleep 5
        ((attempt++))
    done
    
    log_error "Timeout waiting for Ingress Controller to be ready"
    return 1
}

# Function to install NGINX Ingress Controller
install_nginx_ingress() {
    log_info "Installing NGINX Ingress Controller..."
    
    # Create namespace if it doesn't exist
    kubectl create namespace "$INGRESS_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Add the ingress-nginx Helm repository
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    # Install NGINX Ingress Controller
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace "$INGRESS_NAMESPACE" \
        --set controller.service.type=LoadBalancer \
        --set controller.service.externalTrafficPolicy=Local \
        --set controller.ingressClassResource.default=true \
        --set controller.ingressClassByName=true \
        --set controller.watchIngressWithoutClass=true \
        --set controller.electionID=ingress-controller-leader \
        --set controller.ingressClass=nginx \
        --set controller.admissionWebhooks.enabled=false \
        --set controller.metrics.enabled=true \
        --set controller.resources.requests.cpu=100m \
        --set controller.resources.requests.memory=90Mi \
        --set controller.resources.limits.cpu=500m \
        --set controller.resources.limits.memory=512Mi
    
    log_success "NGINX Ingress Controller installed via Helm"
}

# Function to install NGINX Ingress Controller without Helm (alternative method)
install_nginx_ingress_no_helm() {
    log_info "Installing NGINX Ingress Controller (without Helm)..."
    
    # Apply the official NGINX Ingress Controller manifest
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
    
    wait_for_ingress_ready
    log_success "NGINX Ingress Controller installed successfully"
}

# Function to wait for ingress controller IP
wait_for_ingress_ip() {
    log_info "Waiting for Ingress Controller to get an external IP..."
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        local ingress_ip=$(kubectl get svc "$INGRESS_SERVICE_NAME" \
            -n "$INGRESS_NAMESPACE" \
            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
        
        if [[ -n "$ingress_ip" ]]; then
            log_success "Ingress Controller got external IP: $ingress_ip"
            echo "$ingress_ip"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: Waiting for IP assignment..."
        sleep 10
        ((attempt++))
    done
    
    log_error "Timeout waiting for Ingress Controller IP assignment"
    return 1
}

# Function to create test ingress resource
create_test_ingress() {
    local ingress_ip=$1
    
    log_info "Creating test ingress resources..."
    
    # Create namespace for test
    kubectl create namespace ingress-test --dry-run=client -o yaml | kubectl apply -f -
    
    # Wait a moment for namespace to be ready
    sleep 5
    
    # Create test deployment 1
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app1
  namespace: ingress-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-app1
  template:
    metadata:
      labels:
        app: nginx-app1
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: NGINX_CONTENT
          value: "Hello from App 1 - NGINX Server"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service1
  namespace: ingress-test
spec:
  selector:
    app: nginx-app1
  ports:
  - port: 80
    targetPort: 80
EOF

    # Create test deployment 2
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-app2
  namespace: ingress-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-app2
  template:
    metadata:
      labels:
        app: httpd-app2
    spec:
      containers:
      - name: httpd
        image: httpd:alpine
        ports:
        - containerPort: 80
        env:
        - name: HTTPD_CONTENT
          value: "Hello from App 2 - Apache Server"
---
apiVersion: v1
kind: Service
metadata:
  name: httpd-service2
  namespace: ingress-test
spec:
  selector:
    app: httpd-app2
  ports:
  - port: 80
    targetPort: 80
EOF

    # Wait for test pods to be ready
    log_info "Waiting for test applications to be ready..."
    kubectl wait --namespace=ingress-test \
        --for=condition=ready pod \
        --selector=app=nginx-app1 \
        --timeout=120s
    
    kubectl wait --namespace=ingress-test \
        --for=condition=ready pod \
        --selector=app=httpd-app2 \
        --timeout=120s

    # Create ingress resource with retry logic
    local max_retries=5
    local retry_count=0
    
    while [[ $retry_count -lt $max_retries ]]; do
        log_info "Creating ingress resource (attempt $((retry_count + 1))/$max_retries)..."
        
        cat <<EOF | kubectl apply -f - && break
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: ingress-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: app1.test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service1
            port:
              number: 80
  - host: app2.test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: httpd-service2
            port:
              number: 80
  - http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: nginx-service1
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: httpd-service2
            port:
              number: 80
EOF
        
        if [[ $? -eq 0 ]]; then
            log_success "Ingress resource created successfully"
            break
        else
            ((retry_count++))
            if [[ $retry_count -eq $max_retries ]]; then
                log_error "Failed to create ingress resource after $max_retries attempts"
                log_warning "Creating simple ingress without webhook validation..."
                create_simple_ingress "$ingress_ip"
                return
            fi
            log_warning "Failed to create ingress, retrying in 10 seconds..."
            sleep 10
        fi
    done

    log_success "Test ingress resources created"
    display_test_info "$ingress_ip"
}

# Function to create a simple ingress without webhook validation
create_simple_ingress() {
    local ingress_ip=$1
    
    log_info "Creating simple ingress resource without webhook validation..."
    
    # Disable webhook validation temporarily
    kubectl delete validatingwebhookconfiguration ingress-nginx-admission 2>/dev/null || true
    
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-test-ingress
  namespace: ingress-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: nginx-service1
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: httpd-service2
            port:
              number: 80
EOF
    
    log_success "Simple ingress resource created"
    display_test_info "$ingress_ip"
}

# Function to display test information
display_test_info() {
    local ingress_ip=$1
    
    # Display test information
    log_info "Test applications deployed:"
    log_info "NGINX App: http://$ingress_ip/app1"
    log_info "Apache App: http://$ingress_ip/app2"
    
    # Create a simple test script
    cat > test-ingress.sh << EOF
#!/bin/bash
echo "Testing Ingress Controller..."
echo "Ingress IP: $ingress_ip"
echo ""
echo "Testing NGINX app (via path):"
curl -s http://$ingress_ip/app1 | grep -o "Welcome to nginx"
echo ""
echo "Testing Apache app (via path):"
curl -s http://$ingress_ip/app2 | grep -o "It works"
echo ""
echo "Testing direct access:"
curl -s http://$ingress_ip/app1
echo ""
EOF
    
    chmod +x test-ingress.sh
    log_info "Created test script: ./test-ingress.sh"
}

# Function to verify installation
verify_ingress_installation() {
    log_info "Verifying Ingress Controller installation..."
    
    # Check ingress controller pods
    log_info "Checking ingress controller pods:"
    kubectl get pods -n "$INGRESS_NAMESPACE"
    
    # Check ingress service
    log_info "Checking ingress service:"
    kubectl get svc -n "$INGRESS_NAMESPACE"
    
    # Check ingress class
    log_info "Checking ingress classes:"
    kubectl get ingressclass
    
    log_success "Ingress Controller verification completed"
}

# Function to install Helm if not present
install_helm() {
    if command -v helm >/dev/null 2>&1; then
        log_info "Helm is already installed"
        return 0
    fi
    
    log_info "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "Helm installed successfully"
}

# Function to show usage information
show_usage() {
    local ingress_ip=$1
    
    log_info "Ingress Controller Setup Completed!"
    log_info "Ingress Controller IP: $ingress_ip"
    log_info ""
    log_info "Usage commands:"
    log_info "  kubectl get pods -n $INGRESS_NAMESPACE"
    log_info "  kubectl get svc -n $INGRESS_NAMESPACE"
    log_info "  kubectl get ingress -A"
    log_info ""
    log_info "Test the ingress:"
    log_info "  curl http://$ingress_ip/app1"
    log_info "  curl http://$ingress_ip/app2"
    log_info ""
    log_info "Or run the test script: ./test-ingress.sh"
    log_info ""
    log_info "To access via browser, use the IP directly or add to /etc/hosts:"
    log_info "  sudo bash -c 'echo \"$ingress_ip app1.test.local app2.test.local\" >> /etc/hosts'"
}

# Main function
main() {
    local ingress_type=${1:-nginx}
    
    log_info "Starting Ingress Controller installation..."
    
    # Check prerequisites
    check_kubectl
    install_helm
    
    case $ingress_type in
        nginx)
            install_nginx_ingress
            ;;
        nginx-no-helm)
            install_nginx_ingress_no_helm
            ;;
        *)
            log_error "Unknown ingress type: $ingress_type. Use 'nginx' or 'nginx-no-helm'"
            exit 1
            ;;
    esac
    
    # Wait for ingress to be ready
    wait_for_ingress_ready
    
    # Wait for IP assignment
    local ingress_ip=$(wait_for_ingress_ip)
    
    # Verify installation
    verify_ingress_installation
    
    # Create test resources
    create_test_ingress "$ingress_ip"
    
    # Show usage information
    show_usage "$ingress_ip"
    
    log_success "Ingress Controller setup completed successfully!"
}

# Help function
show_help() {
    echo "Usage: $0 [ingress-type]"
    echo ""
    echo "Options:"
    echo "  nginx           Install NGINX Ingress Controller using Helm (default)"
    echo "  nginx-no-helm   Install NGINX Ingress Controller without Helm"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install NGINX Ingress (default)"
    echo "  $0 nginx        # Install NGINX Ingress"
}

# Parse command line arguments
case "${1:-}" in
    help|--help|-h)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
