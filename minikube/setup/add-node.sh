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
NODE_NAME="${MINIKUBE_PROFILE}-m02"

# Function to check minikube status
check_minikube() {
    if ! minikube status --profile="$MINIKUBE_PROFILE" | grep -q "Running"; then
        log_error "Minikube cluster is not running. Please start it first."
        exit 1
    fi
    log_success "Minikube cluster is running"
}

# Function to enable metrics server
enable_metrics() {
    log_info "Enabling metrics server..."
    
    # Check if metrics server is already enabled
    if minikube addons list --profile="$MINIKUBE_PROFILE" | grep -q "metrics-server.*enabled"; then
        log_info "Metrics server is already enabled"
        return 0
    fi
    
    # Enable metrics server addon
    minikube addons enable metrics-server --profile="$MINIKUBE_PROFILE"
    
    # Wait for metrics server to be ready
    log_info "Waiting for metrics server to be ready..."
    kubectl wait --namespace kube-system \
        --for=condition=ready pod \
        --selector=k8s-app=metrics-server \
        --timeout=300s
    
    # Patch metrics server to work with Minikube (if needed)
    kubectl patch deployment metrics-server -n kube-system --type='json' \
        -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
        "--cert-dir=/tmp",
        "--secure-port=4443",
        "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
        "--kubelet-use-node-status-port",
        "--metric-resolution=15s",
        "--kubelet-insecure-tls"
    ]}]' 2>/dev/null || true
    
    # Restart metrics server to apply changes
    kubectl rollout restart deployment/metrics-server -n kube-system
    
    # Wait for metrics server to be ready again
    kubectl wait --namespace kube-system \
        --for=condition=ready pod \
        --selector=k8s-app=metrics-server \
        --timeout=300s
    
    log_success "Metrics server enabled and configured"
}

# Function to add worker node
add_worker_node() {
    log_info "Adding worker node: $NODE_NAME"
    
    # Check if node already exists
    if minikube node list --profile="$MINIKUBE_PROFILE" | grep -q "$NODE_NAME"; then
        log_warning "Node $NODE_NAME already exists. Deleting it first..."
        minikube node delete "$NODE_NAME" --profile="$MINIKUBE_PROFILE" 2>/dev/null || true
    fi
    
    # Add new node
    minikube node add --profile="$MINIKUBE_PROFILE" --worker
    
    # Wait for node to be ready
    log_info "Waiting for worker node to be ready..."
    kubectl wait --for=condition=Ready node/"$NODE_NAME" --timeout=300s
    
    log_success "Worker node $NODE_NAME added successfully"
}

# Function to configure Calico for multi-node
configure_calico_multi_node() {
    log_info "Configuring Calico for multi-node cluster..."
    
    # Wait for Calico pods to be ready on new node
    log_info "Waiting for Calico to be ready on all nodes..."
    kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s
    
    # Check Calico node status
    log_info "Calico node status:"
    kubectl get nodes -o wide
    
    log_success "Calico configured for multi-node cluster"
}

# Function to verify metrics
verify_metrics() {
    log_info "Verifying metrics collection..."
    
    # Wait a bit for metrics to start being collected
    sleep 30
    
    # Check if metrics are available
    if kubectl top nodes 2>/dev/null; then
        log_success "Metrics are being collected successfully"
    else
        log_warning "Metrics are not available yet. It may take a few minutes..."
        log_info "You can check later with: kubectl top nodes"
    fi
    
    # Show node metrics (if available)
    log_info "Node metrics:"
    kubectl top nodes --use-protocol-buffers 2>/dev/null || kubectl top nodes 2>/dev/null || true
    
    log_info "Pod metrics:"
    kubectl top pods -A --use-protocol-buffers 2>/dev/null || kubectl top pods -A 2>/dev/null || true
}

# Function to deploy test workload
deploy_test_workload() {
    log_info "Deploying test workload to verify multi-node functionality..."
    
    # Create a namespace for testing
    kubectl create namespace multi-node-test --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy a test deployment with multiple replicas
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-node-test
  namespace: multi-node-test
spec:
  replicas: 6
  selector:
    matchLabels:
      app: multi-node-test
  template:
    metadata:
      labels:
        app: multi-node-test
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: multi-node-test-service
  namespace: multi-node-test
spec:
  selector:
    app: multi-node-test
  ports:
  - port: 80
    targetPort: 80
EOF

    # Wait for pods to be distributed across nodes
    log_info "Waiting for pods to be distributed across nodes..."
    sleep 30
    
    # Show pod distribution
    log_info "Pod distribution across nodes:"
    kubectl get pods -n multi-node-test -o wide
    
    log_success "Test workload deployed"
}

# Function to show cluster information
show_cluster_info() {
    log_info "Cluster Information:"
    echo "================================"
    
    # Show nodes
    log_info "Nodes:"
    kubectl get nodes -o wide
    
    # Show node roles
    log_info "Node roles:"
    kubectl get nodes --show-labels | grep -E "NAME|role"
    
    # Show cluster info
    log_info "Cluster version:"
    kubectl version --short 2>/dev/null || true
    
    # Show addons status
    log_info "Minikube addons:"
    minikube addons list --profile="$MINIKUBE_PROFILE" | grep -E "(metrics-server|dashboard)"
    
    echo "================================"
}

# Function to create monitoring script
create_monitoring_script() {
    cat > cluster-monitor.sh << 'EOF'
#!/bin/bash

echo "=== Minikube Cluster Monitor ==="
echo "Timestamp: $(date)"
echo ""

echo "📊 Node Status:"
kubectl get nodes -o wide
echo ""

echo "📈 Node Metrics:"
kubectl top nodes --use-protocol-buffers 2>/dev/null || kubectl top nodes 2>/dev/null || echo "Metrics not available yet"
echo ""

echo "🐳 Pod Distribution:"
kubectl get pods -A -o wide | awk '{print $1,$2,$3,$4,$7}' | column -t
echo ""

echo "🔧 Cluster Info:"
minikube status --profile=minikube-calico
echo ""

echo "🌐 Services:"
kubectl get svc -A | grep -v none | column -t
EOF

    chmod +x cluster-monitor.sh
    log_info "Created cluster monitoring script: ./cluster-monitor.sh"
}

# Main function
main() {
    log_info "Starting Minikube cluster enhancement..."
    
    # Check if minikube is running
    check_minikube
    
    # Enable metrics server
    enable_metrics
    
    # Add worker node
    add_worker_node
    
    # Configure Calico for multi-node
    configure_calico_multi_node
    
    # Verify metrics
    verify_metrics
    
    # Deploy test workload
    deploy_test_workload
    
    # Show cluster information
    show_cluster_info
    
    # Create monitoring script
    create_monitoring_script
    
    log_success "Minikube cluster enhancement completed!"
    log_info ""
    log_info "Usage commands:"
    log_info "  ./cluster-monitor.sh                 # Monitor cluster status"
    log_info "  kubectl top nodes                    # Show node metrics"
    log_info "  kubectl top pods -A                  # Show pod metrics"
    log_info "  kubectl get pods -A -o wide          # Show pod distribution"
    log_info "  minikube dashboard --profile=$MINIKUBE_PROFILE  # Open dashboard"
    log_info ""
    log_info "To ssh into nodes:"
    log_info "  minikube ssh --profile=$MINIKUBE_PROFILE --node=minikube-calico"
    log_info "  minikube ssh --profile=$MINIKUBE_PROFILE --node=minikube-calico-m02"
}

# Help function
show_help() {
    echo "Usage: $0"
    echo ""
    echo "This script will:"
    echo "  1. Enable metrics server"
    echo "  2. Add a worker node to create a multi-node cluster"
    echo "  3. Configure Calico for multi-node networking"
    echo "  4. Deploy test workloads"
    echo "  5. Create monitoring scripts"
    echo ""
    echo "Prerequisites:"
    echo "  - Minikube cluster must be running"
    echo "  - kubectl must be configured"
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
