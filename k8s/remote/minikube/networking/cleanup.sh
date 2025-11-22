ns=${1:-playground}
kubectl delete all -n $ns --all
kubectl delete ing -n$ns --all
kubectl delete secret -n $ns --all
kubectl delete gateway -n $ns --all
kubectl delete httproute -n $ns --all
