#!/bin/bash

# K8s Connectivity Checker - Supports Pods, Deployments, and Services
# Usage: ./connect.sh <source> <target> [options]

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
PORT=""
PROTOCOL="tcp"
TIMEOUT=3
VERBOSE=false
CLEANUP=true
TEST_PORTS=("80" "443" "8080" "8443")

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { if $VERBOSE; then echo -e "${CYAN}[DEBUG]${NC} $1"; fi; }

# Usage function
usage() {
    cat << 'EOF'
K8s Connectivity Checker - Supports Pods, Deployments, and Services

Usage: $0 <source> <target> [options]
       $0 -f <pairs-file> [options]

Arguments:
  <source>        Source (pod, deployment, or service in name or namespace/name format)
  <target>        Target (pod, deployment, or service in name or namespace/name format)

Supported formats:
  pod-name                        Pod in current/default namespace
  namespace/pod-name              Pod in specific namespace
  deployment/deploy-name          Deployment in current namespace  
  namespace/deployment/deploy-name Deployment in specific namespace
  service/svc-name                Service in current namespace
  namespace/service/svc-name      Service in specific namespace

Options:
  -p, --port PORT[,PORT...]    Port(s) to test (comma-separated)
  -P, --protocol PROTOCOL      Protocol (tcp/udp, default: tcp)
  -t, --timeout SEC            Connection timeout (default: 3)
  -f, --file FILE              Test multiple pairs from file
  --common-ports               Test common ports (80,443,8080,8443)
  --no-cleanup                 Keep test pods for debugging
  -v, --verbose                Verbose output
  -h, --help                   Show this help

Examples:
  ./connect.sh web-app-abc123 database-xyz789
  ./connect.sh tenant-a/backend tenant-b/database -p 80,443
  ./connect.sh deployment/backend service/database --common-ports
  ./connect.sh tenant-a/deployment/backend tenant-b/service/database -p 5432
  ./connect.sh -f pairs.txt --verbose

Pairs file format (one per line):
  source target [options]
  web-pod db-pod -p 5432
  deployment/frontend service/backend --common-ports
  tenant-a/deployment/app tenant-b/service/db -p 3306

EOF
}

# Function to detect resource type and get pod IP
get_resource_info() {
    local input="$1"
    local namespace=""
    local resource_name=""
    local resource_type=""
    
    log_debug "Processing resource: $input"
    
    # Parse namespace if provided
    if [[ "$input" == *"/"* ]]; then
        local parts=($(echo "$input" | tr '/' ' '))
        if [[ ${#parts[@]} -eq 2 ]]; then
            # Format: namespace/resource-name
            namespace="${parts[0]}"
            resource_name="${parts[1]}"
        elif [[ ${#parts[@]} -eq 3 ]]; then
            # Format: namespace/resource-type/resource-name
            namespace="${parts[0]}"
            resource_type="${parts[1]}"
            resource_name="${parts[2]}"
        else
            log_error "Invalid format: $input"
            return 1
        fi
    else
        resource_name="$input"
        namespace="default"
    fi
    
    # Detect resource type if not specified
    if [[ -z "$resource_type" ]]; then
        # Try to detect type by checking what exists
        if kubectl get pod "$resource_name" -n "$namespace" >/dev/null 2>&1; then
            resource_type="pod"
        elif kubectl get deployment "$resource_name" -n "$namespace" >/dev/null 2>&1; then
            resource_type="deployment"
        elif kubectl get service "$resource_name" -n "$namespace" >/dev/null 2>&1; then
            resource_type="service"
        else
            # Try across all namespaces
            namespace=$(kubectl get pod --all-namespaces -o jsonpath="{.items[?(@.metadata.name=='$resource_name')].metadata.namespace}" 2>/dev/null | head -1)
            if [[ -n "$namespace" ]]; then
                resource_type="pod"
            else
                namespace=$(kubectl get deployment --all-namespaces -o jsonpath="{.items[?(@.metadata.name=='$resource_name')].metadata.namespace}" 2>/dev/null | head -1)
                if [[ -n "$namespace" ]]; then
                    resource_type="deployment"
                else
                    namespace=$(kubectl get service --all-namespaces -o jsonpath="{.items[?(@.metadata.name=='$resource_name')].metadata.namespace}" 2>/dev/null | head -1)
                    if [[ -n "$namespace" ]]; then
                        resource_type="service"
                    else
                        log_error "Resource '$resource_name' not found as pod, deployment, or service"
                        return 1
                    fi
                fi
            fi
        fi
    fi
    
    # Validate resource exists
    if ! kubectl get "$resource_type" "$resource_name" -n "$namespace" >/dev/null 2>&1; then
        log_error "$resource_type '$resource_name' not found in namespace '$namespace'"
        return 1
    fi
    
    local pod_ip=""
    local service_ip=""
    local service_ports=""
    
    case "$resource_type" in
        "pod")
            pod_ip=$(kubectl get pod "$resource_name" -n "$namespace" -o jsonpath='{.status.podIP}')
            local pod_status=$(kubectl get pod "$resource_name" -n "$namespace" -o jsonpath='{.status.phase}')
            echo "pod:$namespace:$resource_name:$pod_ip:$pod_status"
            ;;
        "deployment")
            # Get a random pod from the deployment
            local selector=$(kubectl get deployment "$resource_name" -n "$namespace" -o jsonpath='{.spec.selector.matchLabels}' | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]')
            local pod_name=$(kubectl get pod -n "$namespace" -l "$selector" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
            if [[ -z "$pod_name" ]]; then
                log_error "No pods found for deployment $resource_name"
                return 1
            fi
            pod_ip=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.podIP}')
            local pod_status=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.phase}')
            echo "deployment:$namespace:$resource_name:$pod_ip:$pod_status:$pod_name"
            ;;
        "service")
            service_ip=$(kubectl get service "$resource_name" -n "$namespace" -o jsonpath='{.spec.clusterIP}')
            service_ports=$(kubectl get service "$resource_name" -n "$namespace" -o jsonpath='{.spec.ports[0].port}')
            echo "service:$namespace:$resource_name:$service_ip:::$service_ports"
            ;;
        *)
            log_error "Unsupported resource type: $resource_type"
            return 1
            ;;
    esac
}

# Function to create test container
create_test_container() {
    local namespace="$1"
    local pod_name="net-test-$(date +%s)-$RANDOM"
    
    log_debug "Creating test container: $pod_name in namespace $namespace"
    
    cat <<EOF | kubectl apply -f - > /dev/null
apiVersion: v1
kind: Pod
metadata:
  name: $pod_name
  namespace: $namespace
  labels:
    app: connectivity-test
    temporary: "true"
spec:
  containers:
  - name: test
    image: nicolaka/netshoot:latest
    command: ["/bin/sleep", "3600"]
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
  restartPolicy: Never
  terminationGracePeriodSeconds: 0
EOF
    
    # Wait for pod to be ready
    local attempts=0
    while [[ $attempts -lt 30 ]]; do
        local status=$(kubectl get pod -n "$namespace" "$pod_name" -o jsonpath='{.status.phase}' 2>/dev/null || true)
        if [[ "$status" == "Running" ]]; then
            log_debug "Test container $pod_name is running"
            echo "$pod_name"
            return 0
        fi
        sleep 1
        ((attempts++))
    done
    
    log_error "Failed to start test container"
    return 1
}

# Function to test connectivity
test_connectivity() {
    local test_pod="$1"
    local test_namespace="$2"
    local target_ip="$3"
    local target_port="$4"
    local protocol="$5"
    local target_name="$6"
    
    log_debug "Testing $protocol connectivity: $test_pod -> $target_ip:$target_port"
    
    local cmd=""
    if [[ "$protocol" == "udp" ]]; then
        cmd="timeout $TIMEOUT nc -u -z -w $TIMEOUT $target_ip $target_port"
    else
        cmd="timeout $TIMEOUT nc -z -w $TIMEOUT $target_ip $target_port"
    fi
    
    if kubectl exec -n "$test_namespace" "$test_pod" -- sh -c "$cmd" > /dev/null 2>&1; then
        log_success "$protocol/$target_port - $test_namespace -> $target_name ($target_ip:$target_port) ✓"
        return 0
    else
        log_error "$protocol/$target_port - $test_namespace -> $target_name ($target_ip:$target_port) ✗"
        return 1
    fi
}

# Function to test DNS resolution
test_dns() {
    local test_pod="$1"
    local test_namespace="$2"
    local target_name="$3"
    local target_namespace="$4"
    
    local dns_name="${target_name}.${target_namespace}.svc.cluster.local"
    
    log_debug "Testing DNS resolution for: $dns_name"
    
    if kubectl exec -n "$test_namespace" "$test_pod" -- nslookup "$dns_name" > /dev/null 2>&1; then
        log_success "DNS resolution - $dns_name ✓"
        return 0
    else
        log_error "DNS resolution - $dns_name ✗"
        return 1
    fi
}

# Function to check network policies
check_network_policies() {
    local source_namespace="$1"
    local target_namespace="$2"
    local target_port="${3:-}"
    
    log_info "Checking network policies..."
    
    local source_policies=$(kubectl get networkpolicies -n "$source_namespace" -o name 2>/dev/null | wc -l || echo "0")
    local target_policies=$(kubectl get networkpolicies -n "$target_namespace" -o name 2>/dev/null | wc -l || echo "0")
    
    echo "Network policies in $source_namespace: $source_policies"
    echo "Network policies in $target_namespace: $target_policies"
    
    if [[ $source_policies -gt 0 ]]; then
        kubectl get networkpolicies -n "$source_namespace" -o custom-columns=NAME:.metadata.name,POD-SELECTOR:.spec.podSelector.matchLabels 2>/dev/null || true
    fi
    
    if [[ $target_policies -gt 0 ]]; then
        kubectl get networkpolicies -n "$target_namespace" -o custom-columns=NAME:.metadata.name,POD-SELECTOR:.spec.podSelector.matchLabels 2>/dev/null || true
    fi
}

# Function to cleanup test pods
cleanup() {
    local namespace="$1"
    local pod_name="$2"
    
    if $CLEANUP && [[ -n "$pod_name" ]]; then
        log_debug "Cleaning up test pod: $pod_name"
        kubectl delete pod -n "$namespace" "$pod_name" --force --grace-period=0 > /dev/null 2>&1 || true
    elif [[ -n "$pod_name" ]]; then
        log_warn "Test pod $pod_name left running (use --no-cleanup to keep it)"
    fi
}

# Main connectivity test function
test_connectivity() {
    local source_input="$1"
    local target_input="$2"
    
    log_info "Testing connectivity: $source_input -> $target_input"
    
    # Get source information
    local source_info
    if ! source_info=$(get_resource_info "$source_input"); then
        return 1
    fi
    
    IFS=':' read -r source_type source_namespace source_name source_ip source_status source_extra <<< "$source_info"
    
    # Get target information  
    local target_info
    if ! target_info=$(get_resource_info "$target_input"); then
        return 1
    fi
    
    IFS=':' read -r target_type target_namespace target_name target_ip target_status target_extra target_ports <<< "$target_info"
    
    log_info "Source: $source_type/$source_name ($source_ip) in $source_namespace"
    log_info "Target: $target_type/$target_name ($target_ip) in $target_namespace"
    
    # For services, use ClusterIP and get ports
    local target_ports_array=()
    if [[ "$target_type" == "service" ]]; then
        if [[ -z "$target_ports" ]]; then
            target_ports=$(kubectl get service "$target_name" -n "$target_namespace" -o jsonpath='{.spec.ports[0].port}')
        fi
        IFS=',' read -ra target_ports_array <<< "$target_ports"
    fi
    
    # Create test container in source namespace
    local test_pod=""
    if [[ "$source_type" == "pod" ]]; then
        # Use the actual pod for testing
        test_pod="$source_name"
        log_info "Using existing pod $source_name for testing"
    else
        # Create test pod
        test_pod=$(create_test_container "$source_namespace")
        if [[ $? -ne 0 ]]; then
            log_error "Failed to create test container"
            return 1
        fi
        # Setup cleanup trap
        trap 'cleanup "$source_namespace" "$test_pod"' EXIT
    fi
    
    # Test DNS resolution for services
    if [[ "$target_type" == "service" ]]; then
        log_info "=== Testing DNS Resolution ==="
        test_dns "$test_pod" "$source_namespace" "$target_name" "$target_namespace"
    fi
    
    # Test connectivity
    log_info "=== Testing Network Connectivity ==="
    
    local ports_to_test=()
    if [[ -n "$PORT" ]]; then
        IFS=',' read -ra ports_to_test <<< "$PORT"
    elif [[ "$target_type" == "service" && ${#target_ports_array[@]} -gt 0 ]]; then
        ports_to_test=("${target_ports_array[@]}")
    elif $COMMON_PORTS; then
        ports_to_test=("${TEST_PORTS[@]}")
    else
        ports_to_test=("80")
    fi
    
    local success_count=0
    local total_tests=0
    
    for test_port in "${ports_to_test[@]}"; do
        ((total_tests++))
        if test_connectivity "$test_pod" "$source_namespace" "$target_ip" "$test_port" "$PROTOCOL" "$target_name"; then
            ((success_count++))
        fi
    done
    
    # Check network policies
    log_info "=== Network Policy Analysis ==="
    check_network_policies "$source_namespace" "$target_namespace" "$PORT"
    
    # Summary
    log_info "=== Test Summary ==="
    if [[ $success_count -eq $total_tests ]]; then
        log_success "All tests passed! ($success_count/$total_tests)"
    elif [[ $success_count -gt 0 ]]; then
        log_warn "Partial success: $success_count/$total_tests tests passed"
    else
        log_error "All tests failed! (0/$total_tests)"
    fi
    
    # Cleanup if we created a test pod
    if [[ "$source_type" != "pod" ]]; then
        cleanup "$source_namespace" "$test_pod"
    fi
    
    return $((total_tests - success_count))
}

# Function to process pairs file
process_pairs_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    local line_num=0
    while IFS= read -r line; do
        ((line_num++))
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        log_info "Processing line $line_num: $line"
        
        # Parse line
        eval set -- $line 2>/dev/null || {
            log_error "Invalid syntax on line $line_num"
            continue
        }
        
        local source="$1"
        local target="$2"
        shift 2
        
        if [[ -z "$source" || -z "$target" ]]; then
            log_error "Invalid line $line_num: missing source or target"
            continue
        fi
        
        # Save current arguments and set new ones
        local saved_args=("$@")
        set -- "$@"
        
        # Test this pair
        if test_connectivity "$source" "$target"; then
            log_success "Line $line_num: PASSED"
        else
            log_error "Line $line_num: FAILED"
        fi
        
        echo "----------------------------------------"
        
    done < "$file"
}

# Parse command line arguments
COMMON_PORTS=false
SOURCE=""
TARGET=""
PAIRS_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -P|--protocol)
            PROTOCOL="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -f|--file)
            PAIRS_FILE="$2"
            shift 2
            ;;
        --common-ports)
            COMMON_PORTS=true
            shift
            ;;
        --no-cleanup)
            CLEANUP=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$SOURCE" ]]; then
                SOURCE="$1"
            elif [[ -z "$TARGET" ]]; then
                TARGET="$1"
            else
                log_error "Too many arguments"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Main execution
if [[ -n "$PAIRS_FILE" ]]; then
    process_pairs_file "$PAIRS_FILE"
elif [[ -n "$SOURCE" && -n "$TARGET" ]]; then
    test_connectivity "$SOURCE" "$TARGET"
else
    log_error "Either provide source and target or use --file option"
    usage
    exit 1
fi
