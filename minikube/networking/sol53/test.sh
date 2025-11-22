#!/bin/bash

echo "=== Task 1: Network Policy Testing ==="

# Function to test connectivity
test_connectivity() {
    local from_ns=$1
    local from_pod_label=$2
    local to_service=$3
    local port=$4
    local description=$5
    local should_succeed=$6
    
    echo "Testing: $description"
    
    # Get pod name
    pod_name=$(kubectl get pod -n $from_ns -l $from_pod_label -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$pod_name" ]; then
        echo "ERROR: No pod found in namespace $from_ns with label $from_pod_label"
        return 1
    fi
    
    # Test connectivity
    if kubectl exec -n $from_ns $pod_name -- timeout 5 bash -c "echo 'connectivity test' | nc -w 3 $to_service $port" 2>/dev/null; then
        result="SUCCESS"
        actual_result=0
    else
        result="FAILED"
        actual_result=1
    fi
    
    if [ "$should_succeed" = "true" ] && [ $actual_result -eq 0 ]; then
        echo "✓ PASS: Connection $description - $result (as expected)"
        return 0
    elif [ "$should_succeed" = "true" ] && [ $actual_result -eq 1 ]; then
        echo "✗ FAIL: Connection $description - $result (expected success)"
        return 1
    elif [ "$should_succeed" = "false" ] && [ $actual_result -eq 1 ]; then
        echo "✓ PASS: Connection $description - $result (expected failure)"
        return 0
    else
        echo "✗ FAIL: Connection $description - $result (expected failure)"
        return 1
    fi
}

# Wait a bit for policies to take effect
echo "Waiting for network policies to stabilize..."
sleep 10

# Test 1: Frontend to Backend (should succeed)
test_connectivity "frontend" "app=frontend" "backend-service.backend.svc.cluster.local" "8080" "Frontend -> Backend:8080" "true"

# Test 2: Backend to Database (should succeed)
test_connectivity "backend" "app=backend" "database-service.database.svc.cluster.local" "3306" "Backend -> Database:3306" "true"

# Test 3: Frontend to Database (should fail)
test_connectivity "frontend" "app=frontend" "database-service.database.svc.cluster.local" "3306" "Frontend -> Database:3306" "false"

# Test 4: Backend to Frontend (should fail)
test_connectivity "backend" "app=backend" "frontend-service.frontend.svc.cluster.local" "80" "Backend -> Frontend:80" "false"

# Test 5: Database to Backend (should fail)
test_connectivity "database" "app=database" "backend-service.backend.svc.cluster.local" "8080" "Database -> Backend:8080" "false"

# Test 6: External to Frontend (simulate with test pod)
echo "Testing external access to frontend..."
kubectl run test-curl -n frontend --image=radial/busyboxplus:curl -i --rm --restart=Never -- curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 frontend-service
external_result=$?
if [ $external_result -eq 0 ]; then
    echo "✓ PASS: External access to Frontend succeeded"
else
    echo "✗ FAIL: External access to Frontend failed"
fi

# Test 7: Intra-namespace communication (should work)
echo "Testing intra-namespace communication in frontend..."
frontend_pod1=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')
frontend_pod2=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[1].metadata.name}')
if kubectl exec -n frontend $frontend_pod1 -- ping -c 2 $frontend_pod2 >/dev/null 2>&1; then
    echo "✓ PASS: Intra-namespace communication works"
else
    echo "✗ FAIL: Intra-namespace communication failed"
fi

# Display current network policies
echo ""
echo "=== Current Network Policies ==="
kubectl get networkpolicies --all-namespaces

echo ""
echo "=== Pod IPs for manual testing ==="
echo "Frontend pods:"
kubectl get pods -n frontend -o wide
echo ""
echo "Backend pods:"
kubectl get pods -n backend -o wide
echo ""
echo "Database pod:"
kubectl get pods -n database -o wide

echo ""
echo "=== Testing complete ==="
