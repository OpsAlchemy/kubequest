head -c 100 /dev/urandom > /tmp/example.bin

kubectl create configmap binary-example --from-file=/tmp/example.bin --dry-run=client -o yaml
