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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

# Variables
LIBVIRT_NETWORK_NAME="minikube-net"
LIBVIRT_NETWORK_XML="/tmp/${LIBVIRT_NETWORK_NAME}.xml"
MINIKUBE_PROFILE="minikube-calico"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command_exists virsh; then
        log_info "Installing libvirt..."
        sudo apt-get update
        sudo apt-get install -y \
            libvirt-clients \
            libvirt-daemon-system \
            qemu-kvm \
            qemu-utils \
            virt-manager
    fi

    if ! command_exists docker; then
        log_info "Docker is not installed. Please install Docker first."
        log_info "You can install Docker using: sudo apt-get install docker.io"
        log_info "Then add your user to docker group: sudo usermod -aG docker $USER"
        log_info "And restart your session or run: newgrp docker"
        exit 1
    fi

    # Add user to libvirt group if not already
    if ! groups $USER | grep -q libvirt; then
        sudo usermod -aG libvirt $USER
        log_info "Added user to libvirt group. Please restart your session or run: newgrp libvirt"
    fi
}

# Function to install Minikube
install_minikube() {
    log_info "Installing Minikube..."
    
    if ! command_exists minikube; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        log_success "Minikube installed successfully"
    else
        log_info "Minikube is already installed"
    fi

    # Install kubectl if not present
    if ! command_exists kubectl; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        log_success "kubectl installed successfully"
    fi
}

# Function to create libvirt network
create_libvirt_network() {
    log_info "Creating libvirt network: $LIBVIRT_NETWORK_NAME"
    
    # Check if network already exists
    if virsh net-info "$LIBVIRT_NETWORK_NAME" >/dev/null 2>&1; then
        log_warning "Network $LIBVIRT_NETWORK_NAME already exists. Destroying and recreating..."
        virsh net-destroy "$LIBVIRT_NETWORK_NAME" || true
        virsh net-undefine "$LIBVIRT_NETWORK_NAME" || true
    fi

    # Create network XML
    cat > "$LIBVIRT_NETWORK_XML" << EOF
<network>
  <name>$LIBVIRT_NETWORK_NAME</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr-minikube' stp='on' delay='0'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.100.2' end='192.168.100.254'/>
    </dhcp>
  </ip>
</network>
EOF

    # Define and start the network
    virsh net-define "$LIBVIRT_NETWORK_XML"
    virsh net-autostart "$LIBVIRT_NETWORK_NAME"
    virsh net-start "$LIBVIRT_NETWORK_NAME"
    
    log_success "Libvirt network $LIBVIRT_NETWORK_NAME created and started"
}

# Function to start Minikube with custom configuration
start_minikube() {
    log_info "Starting Minikube with Calico and custom network..."
    
    # Stop minikube if it's running
    minikube stop --profile="$MINIKUBE_PROFILE" 2>/dev/null || true
    
    # Delete existing profile if it exists
    minikube delete --profile="$MINIKUBE_PROFILE" 2>/dev/null || true

    # Start minikube with custom configuration
    minikube start --profile="$MINIKUBE_PROFILE" \
        --driver=kvm2 \
        --network="$LIBVIRT_NETWORK_NAME" \
        --disk-size=20g \
        --memory=4g \
        --cpus=2 \
        --kubernetes-version=stable \
        --container-runtime=containerd \
        --embed-certs=true \
        --force-systemd=true \
        --extra-config=kubelet.cgroup-driver=systemd

    # Set kubectl context to use this profile
    minikube kubectl --profile="$MINIKUBE_PROFILE" -- get nodes >/dev/null 2>&1
    
    log_success "Minikube started successfully"
}

# Function to install Calico
install_calico() {
    log_info "Installing Calico CNI..."
    
    # First, disable minikube's default CNI
    minikube ssh --profile="$MINIKUBE_PROFILE" "sudo rm -f /etc/cni/net.d/*" || true
    
    # Install Calico
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    
    # Wait for Calico to be ready
    log_info "Waiting for Calico to be ready..."
    sleep 30  # Give some time for pods to start
    
    # Wait for Calico pods to be ready
    kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s
    kubectl wait --for=condition=ready pod -l k8s-app=calico-kube-controllers -n kube-system --timeout=300s
    
    log_success "Calico installed successfully"
}

# Function to install and configure MetalLB
install_metallb() {
    log_info "Installing and configuring MetalLB..."
    
    # Install MetalLB
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
    
    # Wait for MetalLB to be ready
    log_info "Waiting for MetalLB to be ready..."
    sleep 30  # Give some time for pods to start
    
    kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=300s
    
    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip --profile="$MINIKUBE_PROFILE")
    NETWORK_BASE=$(echo $MINIKUBE_IP | cut -d. -f1-3)
    
    log_info "Minikube IP: $MINIKUBE_IP"
    log_info "Using IP range: ${NETWORK_BASE}.100-${NETWORK_BASE}.110"
    
    # Create MetalLB IPAddressPool
    cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: minikube-pool
  namespace: metallb-system
spec:
  addresses:
  - ${NETWORK_BASE}.100-${NETWORK_BASE}.110
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: minikube-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - minikube-pool
EOF
    
    log_success "MetalLB configured successfully with IP range: ${NETWORK_BASE}.100-${NETWORK_BASE}.110"
}

# Function to verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check Minikube status
    if minikube status --profile="$MINIKUBE_PROFILE" | grep -q "Running"; then
        log_success "Minikube is running"
    else
        log_error "Minikube is not running"
        exit 1
    fi
    
    # Check nodes
    log_info "Kubernetes nodes:"
    kubectl get nodes
    
    # Check pods in kube-system
    log_info "Pods in kube-system:"
    kubectl get pods -n kube-system
    
    # Check MetalLB
    log_info "MetalLB status:"
    kubectl get pods -n metallb-system
    
    # Check Calico
    log_info "Calico pods:"
    kubectl get pods -n kube-system -l k8s-app=calico-node
    
    log_success "Verification completed!"
}

# Function to create test deployment
create_test_deployment() {
    log_info "Creating test deployment to verify MetalLB..."
    
    # Create test namespace
    kubectl create namespace test-lb --dry-run=client -o yaml | kubectl apply -f -
    
    # Create test deployment and service
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
  namespace: test-lb
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: test-lb
spec:
  selector:
    app: nginx-test
  ports:
  - name: http
    port: 80
    targetPort: 80
  type: LoadBalancer
EOF
    
    # Wait for service to get external IP
    log_info "Waiting for LoadBalancer IP assignment..."
    for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get svc nginx-service -n test-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
        if [[ ! -z "$EXTERNAL_IP" ]]; then
            log_success "Test LoadBalancer got external IP: $EXTERNAL_IP"
            log_info "You can test with: curl http://$EXTERNAL_IP"
            break
        fi
        sleep 5
    done
    
    if [[ -z "$EXTERNAL_IP" ]]; then
        log_warning "LoadBalancer IP not assigned yet. It may take a few more minutes."
        log_info "You can check later with: kubectl get svc nginx-service -n test-lb"
    fi
}

# Function to display usage information
show_usage() {
    log_info "Setup completed!"
    log_info "Minikube profile: $MINIKUBE_PROFILE"
    log_info "Libvirt network: $LIBVIRT_NETWORK_NAME"
    log_info ""
    log_info "Usage commands:"
    log_info "  minikube status --profile=$MINIKUBE_PROFILE"
    log_info "  kubectl get nodes"
    log_info "  kubectl get pods -A"
    log_info "  minikube dashboard --profile=$MINIKUBE_PROFILE"
    log_info ""
    log_info "To clean up everything:"
    log_info "  minikube delete --profile=$MINIKUBE_PROFILE"
    log_info "  virsh net-destroy $LIBVIRT_NETWORK_NAME"
    log_info "  virsh net-undefine $LIBVIRT_NETWORK_NAME"
}

# Main execution
main() {
    log_info "Starting Minikube with Calico and MetalLB setup..."
    
    # Install dependencies
    install_dependencies
    
    # Install Minikube
    install_minikube
    
    # Create libvirt network
    create_libvirt_network
    
    # Start Minikube
    start_minikube
    
    # Install Calico
    install_calico
    
    # Install MetalLB
    install_metallb
    
    # Verify installation
    verify_installation
    
    # Create test deployment
    create_test_deployment
    
    # Show usage information
    show_usage
    
    log_success "Setup completed successfully!"
}

# Run main function
main "$@"
