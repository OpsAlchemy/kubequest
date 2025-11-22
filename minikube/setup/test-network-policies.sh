#!/bin/bash

set -euo pipefail

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

K="kubectl"
DEBUG_IMAGE="nicolaka/netshoot:latest"

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v kubectl >/dev/null 2>&1; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "kubectl is not configured properly"
        exit 1
    fi
    
    # Check if deployments exist
    if ! kubectl get deployment frontend >/dev/null 2>&1; then
        log_error "Frontend deployment not found. Please deploy the applications first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Function to verify NetworkPolicies are applied
verify_network_policies() {
    log_info "Verifying NetworkPolicies..."
    
    local policies=("netpol1" "netpol2" "netpol3")
    
    for policy in "${policies[@]}"; do
        if kubectl get networkpolicy "$policy" >/dev/null 2>&1; then
            log_success "NetworkPolicy $policy is applied"
        else
            log_error "NetworkPolicy $policy not found"
            exit 1
        fi
    done
    
    # Show all NetworkPolicies
    log_info "Current NetworkPolicies:"
    kubectl get networkpolicies -o wide
}

# Function to get pod names
get_pod_names() {
    FRONTEND_POD=$(kubectl get pods -l tier=frontend -o jsonpath='{.items[0].metadata.name}')
    BACKEND_POD=$(kubectl get pods -l tier=backend -o jsonpath='{.items[0].metadata.name}')
    DATABASE_POD=$(kubectl get pods -l tier=database -o jsonpath='{.items[0].metadata.name}')
    
    log_info "Frontend Pod: $FRONTEND_POD"
    log_info "Backend Pod: $BACKEND_POD"
    log_info "Database Pod: $DATABASE_POD"
}

# Function to test connectivity from a pod
test_connectivity_from_pod() {
    local source_pod="$1"
    local source_tier="$2"
    local target_service="$3"
    local target_port="${4:-80}"
    
    log_info "Testing connectivity from $source_tier to $target_service..."
    
    if kubectl exec "$source_pod" -c debug -- \
        curl -s --connect-timeout 5 "http://${target_service}:${target_port}" >/dev/null 2>&1; then
        log_success "✓ $source_tier can connect to $target_service"
        return 0
    else
        log_error "✗ $source_tier cannot connect to $target_service"
        return 1
    fi
}

# Function to test pod-to-pod connectivity
test_pod_to_pod() {
    local source_pod="$1"
    local source_tier="$2"
    local target_pod="$3"
    local target_tier="$4"
    local target_port="${5:-5678}"
    
    # Get target pod IP
    local target_ip=$(kubectl get pod "$target_pod" -o jsonpath='{.status.podIP}')
    
    log_info "Testing pod-to-pod connectivity from $source_tier to $target_tier..."
    
    if kubectl exec "$source_pod" -c debug -- \
        curl -s --connect-timeout 5 "http://${target_ip}:${target_port}" >/dev/null 2>&1; then
        log_success "✓ $source_tier can connect to $target_tier pod directly"
        return 0
    else
        log_error "✗ $source_tier cannot connect to $target_tier pod directly"
        return 1
    fi
}

# Function to test ingress connectivity
test_ingress_connectivity() {
    local ingress_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [[ -z "$ingress_ip" ]]; then
        log_warning "Ingress IP not available, skipping ingress tests"
        return 0
    fi
    
    log_info "Testing ingress connectivity to frontend..."
    
    if curl -s --connect-timeout 5 "http://${ingress_ip}/app1" >/dev/null 2>&1; then
        log_success "✓ External clients can connect to frontend via ingress"
    else
        log_error "✗ External clients cannot connect to frontend via ingress"
    fi
}

# Function to run comprehensive tests
run_comprehensive_tests() {
    log_info "Starting comprehensive NetworkPolicy tests..."
    echo "================================================"
    
    get_pod_names
    
    echo ""
    log_info "Testing Service connectivity (ClusterIP)..."
    echo "----------------------------------------"
    
    # Test frontend pod connectivity
    test_connectivity_from_pod "$FRONTEND_POD" "frontend" "frontend" "80"
    test_connectivity_from_pod "$FRONTEND_POD" "frontend" "backend" "80"
    test_connectivity_from_pod "$FRONTEND_POD" "frontend" "database" "80"
    
    echo ""
    # Test backend pod connectivity
    test_connectivity_from_pod "$BACKEND_POD" "backend" "frontend" "80"
    test_connectivity_from_pod "$BACKEND_POD" "backend" "backend" "80"
    test_connectivity_from_pod "$BACKEND_POD" "backend" "database" "80"
    
    echo ""
    # Test database pod connectivity
    test_connectivity_from_pod "$DATABASE_POD" "database" "frontend" "80"
    test_connectivity_from_pod "$DATABASE_POD" "database" "backend" "80"
    test_connectivity_from_pod "$DATABASE_POD" "database" "database" "80"
    
    echo ""
    log_info "Testing direct pod-to-pod connectivity..."
    echo "----------------------------------------"
    
    # Test pod-to-pod connectivity (bypassing services)
    test_pod_to_pod "$FRONTEND_POD" "frontend" "$BACKEND_POD" "backend" "5678"
    test_pod_to_pod "$FRONTEND_POD" "frontend" "$DATABASE_POD" "database" "5678"
    test_pod_to_pod "$BACKEND_POD" "backend" "$FRONTEND_POD" "frontend" "5678"
    test_pod_to_pod "$BACKEND_POD" "backend" "$DATABASE_POD" "database" "5678"
    test_pod_to_pod "$DATABASE_POD" "database" "$FRONTEND_POD" "frontend" "5678"
    test_pod_to_pod "$DATABASE_POD" "database" "$BACKEND_POD" "backend" "5678"
    
    echo ""
    log_info "Testing ingress connectivity..."
    echo "----------------------------------------"
    test_ingress_connectivity
    
    echo ""
    log_info "Testing same-tier connectivity..."
    echo "----------------------------------------"
    
    # Test same-tier connectivity
    local second_frontend_pod=$(kubectl get pods -l tier=frontend -o jsonpath='{.items[1].metadata.name}')
    local second_backend_pod=$(kubectl get pods -l tier=backend -o jsonpath='{.items[1].metadata.name}')
    local second_database_pod=$(kubectl get pods -l tier=database -o jsonpath='{.items[1].metadata.name}')
    
    if [[ -n "$second_frontend_pod" ]]; then
        test_pod_to_pod "$FRONTEND_POD" "frontend" "$second_frontend_pod" "frontend" "5678"
    fi
    
    if [[ -n "$second_backend_pod" ]]; then
        test_pod_to_pod "$BACKEND_POD" "backend" "$second_backend_pod" "backend" "5678"
    fi
    
    if [[ -n "$second_database_pod" ]]; then
        test_pod_to_pod "$DATABASE_POD" "database" "$second_database_pod" "database" "5678"
    fi
}

# Function to test NetworkPolicy rules specifically
test_network_policy_rules() {
    log_info "Testing NetworkPolicy rules compliance..."
    echo "================================================"
    
    get_pod_names
    
    # Expected behavior based on your NetworkPolicies:
    # netpol1 (frontend): Allows ingress from frontend pods and ingress-nginx
    # netpol2 (backend): Allows ingress from backend and frontend pods  
    # netpol3 (database): Allows ingress from database and backend pods
    
    log_info "Expected behavior:"
    log_info "- Frontend: can connect to itself, backend, database, and be reached by ingress"
    log_info "- Backend: can connect to itself, frontend, database"
    log_info "- Database: can connect to itself and backend"
    
    echo ""
    log_info "Testing critical paths..."
    echo "----------------------------------------"
    
    # Critical path 1: Frontend -> Backend (should work)
    if test_connectivity_from_pod "$FRONTEND_POD" "frontend" "backend" "80"; then
        log_success "✓ Critical path: Frontend -> Backend ✓"
    else
        log_error "✗ Critical path broken: Frontend -> Backend ✗"
    fi
    
    # Critical path 2: Backend -> Database (should work)
    if test_connectivity_from_pod "$BACKEND_POD" "backend" "database" "80"; then
        log_success "✓ Critical path: Backend -> Database ✓"
    else
        log_error "✗ Critical path broken: Backend -> Database ✗"
    fi
    
    # Critical path 3: Database -> Backend (should work)
    if test_connectivity_from_pod "$DATABASE_POD" "database" "backend" "80"; then
        log_success "✓ Critical path: Database -> Backend ✓"
    else
        log_error "✗ Critical path broken: Database -> Backend ✗"
    fi
    
    # Should be blocked: Database -> Frontend
    if test_connectivity_from_pod "$DATABASE_POD" "database" "frontend" "80"; then
        log_warning "⚠ Database can connect to Frontend (might be unexpected)"
    else
        log_success "✓ Security control: Database -> Frontend blocked ✓"
    fi
}

# Function to create a test report
create_test_report() {
    log_info "Creating detailed test report..."
    
    cat > network-policy-test-report.txt << EOF
Network Policy Test Report
Generated: $(date)
Cluster: $(kubectl config current-context)

Network Policies Applied:
$(kubectl get networkpolicies -o wide)

Pod Information:
$(kubectl get pods -l app=acme -o wide)

Service Information:
$(kubectl get svc -l app=acme -o wide)

Expected Connectivity Matrix:
┌───────────┬──────────┬─────────┬──────────┐
│ From/To   │ Frontend │ Backend │ Database │
├───────────┼──────────┼─────────┼──────────┤
│ Frontend  │    ✓     │    ✓    │    ✓     │
├───────────┼──────────┼─────────┼──────────┤
│ Backend   │    ✓     │    ✓    │    ✓     │
├───────────┼──────────┼─────────┼──────────┤
│ Database  │    ✗     │    ✓    │    ✓     │
└───────────┴──────────┴─────────┴──────────┘

Key:
✓ = Allowed by NetworkPolicy
✗ = Blocked by NetworkPolicy

Test Commands:
# Test from frontend to backend:
kubectl exec $FRONTEND_POD -c debug -- curl -s http://backend:80

# Test from backend to database:
kubectl exec $BACKEND_POD -c debug -- curl -s http://database:80

# Test from database to frontend (should fail):
kubectl exec $DATABASE_POD -c debug -- curl -s http://frontend:80

Debug Tips:
# Get shell in debug container:
kubectl exec -it $FRONTEND_POD -c debug -- bash

# Check iptables rules (on node):
kubectl get nodes -o wide
# Then ssh into node and check calico rules

EOF

    log_success "Test report saved to: network-policy-test-report.txt"
}

# Function to show quick test commands
show_quick_commands() {
    log_info "Quick test commands for manual verification:"
    echo ""
    echo "1. Test frontend to backend:"
    echo "   kubectl exec $FRONTEND_POD -c debug -- curl -s http://backend:80"
    echo ""
    echo "2. Test backend to database:"
    echo "   kubectl exec $BACKEND_POD -c debug -- curl -s http://database:80"
    echo ""
    echo "3. Test database to frontend (should fail):"
    echo "   kubectl exec $DATABASE_POD -c debug -- curl -s http://frontend:80"
    echo ""
    echo "4. Get debug shell:"
    echo "   kubectl exec -it $FRONTEND_POD -c debug -- bash"
    echo ""
    echo "5. Monitor NetworkPolicy events:"
    echo "   kubectl get networkpolicies --watch"
}

# Main function
main() {
    local test_type="${1:-comprehensive}"
    
    log_info "Starting NetworkPolicy testing..."
    
    check_prerequisites
    verify_network_policies
    
    case "$test_type" in
        "comprehensive")
            run_comprehensive_tests
            ;;
        "rules")
            test_network_policy_rules
            ;;
        "quick")
            get_pod_names
            show_quick_commands
            return 0
            ;;
        *)
            log_error "Unknown test type: $test_type. Use 'comprehensive', 'rules', or 'quick'"
            exit 1
            ;;
    esac
    
    create_test_report
    
    log_success "NetworkPolicy testing completed!"
    log_info "Detailed report: network-policy-test-report.txt"
    echo ""
    show_quick_commands
}

# Help function
show_help() {
    echo "Usage: $0 [test-type]"
    echo ""
    echo "Test types:"
    echo "  comprehensive  Run all tests (default)"
    echo "  rules          Test only NetworkPolicy rules compliance"
    echo "  quick          Show quick test commands only"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Run comprehensive tests"
    echo "  $0 rules              # Test NetworkPolicy rules"
    echo "  $0 quick              # Show quick commands"
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
