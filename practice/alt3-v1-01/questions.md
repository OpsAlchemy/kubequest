TASK 1
1. Scale the dragon Deployment to 8 pods

TASK 2 
1. Modify the existing Deployment named deppy to expose TCP traffic on port 80, and assign the name http to this port.
2. Create a NodePort Service named deppysvc that exposes the pods managed by the deppy Deployment.

TASK 3 
CKA EXAM OBJECTIVE: Manage persistent volumes and persistent volume claims 
TASK:
1. Create a PersistentVolumeClaim named rwopvc that does the following:
2. Capacity of 4Gi
3. Access Mode of ReadWriteOnce
4. mount to a pod named rwopod at the mount path /var/www/html

TASK 4 
1. Create a PersistentVolume named rompv with the access mode ReadOnlyMany and a capacity of 6 Gi.

TASK 5 
1. Create an Ingress resource named luau that routes traffic on the path /aloha to the aloha service on port 54321.

TASK 6 
1. Identify all Pods in the integration namespace that have the label app=intensive.
2. From those Pods, determine which one is consuming the most CPU resources.
3. Write the name of the Pod using the most CPU to the file:
/opt/cka/answers/cpu_pod_01.txt.

TASK 7
1. Create a Pod named noded that uses the nginx image
2. Ensure the pod is scheduled to a node labeled disk=nvme

TASK 8 
1. Create a Pod named multicontainer that has two containers:
2. A Container running redis:6.2.6 image.
3. A Container running nginx:1.21.6 image.

TASK 9
1. Add a sidecar container using the busybox image to the existing Pod logger
2. The container should be mounted at the path /var/log and the command /bin/sh -c tail -f /var/log/log01.log 

TASK 10 
1. Create a ClusterRole named app-creator that allows create permission for Deployments, StatefulSets, and DaemonSets
2. Create a ServiceAccount named app-dev 
3. Bind the ServiceAccount app-dev to the ClusterRole app-creator using a ClusterRoleBinding.

TASK 11 
1. Create a ConfigMap called metal-cm containing the file ~/mycode/yaml/metal.html 
2. To the deployment "enter-sandman" add the metal-cm configmap mounted to the path /var/www/index.html 
3. Create the deployment in the metallica namespace.

TASK 12 
1. You will adjust an existing pod named kiwi-secret-pod in the namespace kiwi.
2. Make a new secret named juicysecret. It must contain the following key/value pairs:
3. username=kiwis, password=aredelicious
4. Make this content available in the pod kiwi-secret-pod as the following environment variables: USERKIWI and PASSKIWI.

TASK 13 
1. In namespace cherry you'll find two deployments named pit and stem. Both deployments are exposed via a service.
2. Make a NetworkPolicy named cherry-control that:
3. that prevents outgoing traffic from deployment pit...
4. ...EXPECT to that of deployment stem

TASK 14 
1. Modify the Helm Chart configuration located at ~/ckad-helm-task to ensure the deployment creates 3 replicas of a pod ...
2. ... then install the chart into the cluster.
3. The resources will be created in the battleofhelmsdeep namespace.

TASK 15
1. There is an existing deployment named mufasa in namespace king-of-lion.
2. Check the deployment history and rollback to a version that actually works.

TASK 16 ( Can't do it now )
1. Join node-2 to your existing kubeadm cluster. It has been already pre-provisioned with all necessary installation.

TASK 17
A developer needs a persistent volume for an application. Create a PeristentVolumeClaim with:
- Size 100Mi 
- Access mode ReadWriteOnce
- Using the storage class "local-path"

Create a Pod that mounts this PVC at /data and verify that the volume is automatically created and mounted
