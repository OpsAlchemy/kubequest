controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k apply -f postgres-pod.yaml 
Error from server (BadRequest): error when creating "postgres-pod.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.containers[0].livenessProbe.tcpSocket.command", unknown field "spec.containers[0].readinessProbe.exec.cmd"
controlplane:~$ vi postgres-pod.yaml 
controlplane:~$ k apply -f postgres-pod.yaml 
Error from server (BadRequest): error when creating "postgres-pod.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.containers[0].livenessProbe.exec.cmd", unknown field "spec.containers[0].readinessProbe.tcpSocket.command"
controlplane:~$ vi postgres-pod.yaml 
controlplane:~$ k apply -f postgres-pod.yaml 
pod/postgres-pod created
controlplane:~$ cat postgres-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
spec:
  containers:
    - name: postgres
      image: postgres:latest
      env:
        - name: POSTGRES_PASSWORD
          value: dbpassword
        - name: POSTGRES_DB
          value: database
      ports:
        - containerPort: 5432
      readinessProbe:
        tcpSocket:
          port : 5432
        initialDelaySeconds: 30
        periodSeconds: 10
      livenessProbe:
        exec:
          command:
            - "psql"
            - "-h"
            - "localhost"
            - "-U"
            - "postgres"
            - "-c"
            - "SELECT 1"
        initialDelaySeconds: 5
        periodSeconds: 5
controlplane:~$ 



https://killercoda.com/sachin/course/CKA/pod-issue-4