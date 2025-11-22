

https://killercoda.com/chadmcrowell/course/cka/persistent-volumes


controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: PersistentVolume
> metadata:
>   name: pv-volume
> spec:
>   persistentVolumeReclaimPolicy: Delete
>   storageClassName: "local-path"
>   hostPath:
>     path: "/mnt/data"
>   capacity:
>     storage: 1Gi
>   accessModes:
>     - ReadWriteOnce
> EOF
persistentvolume/pv-volume created
controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: PersistentVolumeClaim
> metadata:
>   name: pv-claim
>   namespace: default
> spec:
>   storageClassName: "local-path"
>   accessModes:
>     - ReadWriteOnce
>   resources:
>     requests:
>       storage: 1Gi
> EOF
persistentvolumeclaim/pv-claim created
controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: Pod
> metadata:
>   name: pv-pod
> spec:
>   containers:
>     - name: pv-container
>       image: nginx
>       volumeMounts:
>         - mountPath: "/usr/share/nginx/html"
>           name: pv-storage
>   volumes:
>     - name: pv-storage
>       persistentVolumeClaim:
>         claimName: pv-claim
> EOF
pod/pv-pod created
controlplane:~$ 













controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: PersistentVolume
> metadata:
>   name: pv-volume
> spec:
>   persistentVolumeReclaimPolicy: Delete
>   storageClassName: "local-path"
>   hostPath:
>     path: "/mnt/data"
>   capacity:
>     storage: 1Gi
>   accessModes:
>     - ReadWriteOnce
> EOF
persistentvolume/pv-volume created
controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: PersistentVolumeClaim
> metadata:
>   name: pv-claim
>   namespace: default
> spec:
>   storageClassName: "local-path"
>   accessModes:
>     - ReadWriteOnce
>   resources:
>     requests:
>       storage: 1Gi
> EOF
persistentvolumeclaim/pv-claim created
controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: Pod
> metadata:
>   name: pv-pod
> spec:
>   containers:
>     - name: pv-container
>       image: nginx
>       volumeMounts:
>         - mountPath: "/usr/share/nginx/html"
>           name: pv-storage
>   volumes:
>     - name: pv-storage
>       persistentVolumeClaim:
>         claimName: pv-claim
> EOF
pod/pv-pod created
controlplane:~$ ^C
controlplane:~$ k exec -it pv-pod -- sh
# echo "<h1>This is my website!</h1>" > /usr/share/nginx/html/index.html
# 
# exit
controlplane:~$ k delete po pv-pod
pod "pv-pod" deleted
controlplane:~$ cat <<EOF | k apply -f -
> apiVersion: v1
> kind: Pod
> metadata:
>   name: pv-pod2
> spec:
>   containers:
>     - name: pv-container
>       image: nginx
>       volumeMounts:
>         - mountPath: "/usr/share/nginx/html"
>           name: pv-storage
>   volumes:
>     - name: pv-storage
>       persistentVolumeClaim:
>         claimName: pv-claim
> EOF
pod/pv-pod2 created
controlplane:~$ k exec -it pv-pod2 -- sh
# ls /usr/share/nginx/html/
index.html
# cat index.html
cat: index.html: No such file or directory
# ls
bin   dev                  docker-entrypoint.sh  home  lib64  mnt  proc  run   srv  tmp  var
boot  docker-entrypoint.d  etc                   lib   media  opt  root  sbin  sys  usr
# cd /usr/share/nginx/html
# ls
index.html
# cat index.html
<h1>This is my website!</h1>
# 