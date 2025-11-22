https://killercoda.com/chadmcrowell/course/cka/configmaps

controlplane:~$ echo "Deploying scenario..."
Deploying scenario...
controlplane:~$ k create cm redis-config --from-literal=maxmemory=2mb --from-literal=maxmemory-policy=allkeys-lru
configmap/redis-config created
controlplane:~$ 
