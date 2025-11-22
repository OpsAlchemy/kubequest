Create a new service account named ’secure-sa’ in the default namespace that will not automatically mount the service account token.


Solution

Create a YAML manifest file named sa.yaml that creates a new service account named secure-sa in the default namespace

# create the YAML for a service account named 'secure-sa' with the '--dry-run=client' option, saving it to a file named 'sa.yaml'
kubectl -n default create sa secure-sa --dry-run=client -o yaml > sa.yaml
Add the line automountServiceAccountToken: false to the YAML file sa.yaml

# add the automountServiceAccountToken: false to the end of the file 'sa.yaml'
echo "automountServiceAccountToken: false" >> sa.yaml
Create the service account with the correct kubectl command-line argument.

# create the service account from the file 'sa.yaml'
kubectl create -f sa.yaml

# list the newly created service account
kubectl -n default get sa

Create a pod that uses the previously created ‘secure-sa’ service account. Make sure the token is not exposed to the pod!

Verify that the service account token is not mounted to the pod


Solution

Create the YAML for a pod named secure-pod specifying the service account name

# create the YAML for a pod named 'secure-pod' by using kubectl with the '--dry-run=client' option, output to YAML and saved to a file 'pod.yaml'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  serviceAccountName: secure-sa
  containers:
  - image: nginx
    name: secure-pod
EOF


List the pods in the default namespace, waiting for the pod to appear as running

# list the pods in the default namespace and wait until the pod is running
kubectl -n default get po
Verify that the service account token is NOT mounted to the pod

# get a shell to the pod and output the token (if mounted)
kubectl exec secure-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
You should get the following, indidcating that the service account token was not mounted

controlplane $ kubectl exec secure-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
cat: /var/run/secrets/kubernetes.io/serviceaccount/token: No such file or directory
command terminated with exit code 1

