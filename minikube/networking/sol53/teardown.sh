#!/bin/bash

echo "=== Task 1: Teardown ==="

# Delete namespaces (this will clean up everything)
echo "Deleting namespaces..."
kubectl delete namespace frontend backend database

# Verify cleanup
echo "Verifying cleanup..."
kubectl get namespaces | grep -E "(frontend|backend|database)" && echo "Namespaces still exist!" || echo "Namespaces cleaned up successfully"

echo "=== Task 1 Teardown Complete ==="
