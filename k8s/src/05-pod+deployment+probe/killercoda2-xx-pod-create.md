https://killercoda.com/sachin/course/CKA/pod-create


controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k run sleep-pod --image nginx --command -- "sleep" "300"
pod/sleep-pod created
controlplane:~$ k get pods
NAME        READY   STATUS              RESTARTS   AGE
sleep-pod   0/1     ContainerCreating   0          2s
controlplane:~$ k get pods -w
NAME        READY   STATUS              RESTARTS   AGE
sleep-pod   0/1     ContainerCreating   0          5s
sleep-pod   1/1     Running             0          6s
^Ccontrolplane:~$ 



