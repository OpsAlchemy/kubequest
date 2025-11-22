ns=${1:-playground}
kubectl delete all -n $ns --all --ignore-not-found
kubectl delete ing -n$ns --all --ignore-not-found
kubectl delete secret -n $ns --all --ignore-not-found
kubectl delete gateway -n $ns --all --ignore-not-found
kubectl delete httproute -n $ns --all --ignore-not-found
