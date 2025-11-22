controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k edit pvc yellow-pvc-cka 
persistentvolumeclaim/yellow-pvc-cka edited
controlplane:~$ k get pvc -w
NAME             STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS     VOLUMEATTRIBUTESCLASS   AGE
yellow-pvc-cka   Bound    yellow-pv-cka   100Mi      RWO            yellow-stc-cka   <unset>                 48s
^Ccontrolplane:~$ k get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS     VOLUMEATTRIBUTESCLASS   REASON   AGE
yellow-pv-cka   100Mi      RWO            Retain           Bound    default/yellow-pvc-cka   yellow-stc-cka   <unset>                          53s
controlplane:~$ 


https://killercoda.com/sachin/course/CKA/pvc-resize