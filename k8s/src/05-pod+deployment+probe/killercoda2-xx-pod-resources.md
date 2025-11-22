https://killercoda.com/sachin/course/CKA/pod-resource


controlplane:~$ k top pods
error: Metrics API not available
controlplane:~$ k get pod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
httpd   1/1     Running   0          35s   192.168.1.4   node01   <none>           <none>
nginx   1/1     Running   0          35s   192.168.1.5   node01   <none>           <none>
redis   1/1     Running   0          35s   192.168.1.6   node01   <none>           <none>
controlplane:~$ k get pods
NAME    READY   STATUS    RESTARTS   AGE
httpd   1/1     Running   0          52s
nginx   1/1     Running   0          52s
redis   1/1     Running   0          52s
controlplane:~$ k top pods
NAME    CPU(cores)   MEMORY(bytes)   
httpd   1m           6Mi             
nginx   0m           2Mi             
redis   3m           4Mi             
controlplane:~$ k top pods -A --sort-by=cpu
NAMESPACE            NAME                                      CPU(cores)   MEMORY(bytes)   
kube-system          kube-apiserver-controlplane               21m          273Mi           
kube-system          canal-hvvtk                               16m          124Mi           
kube-system          canal-5q8x5                               14m          127Mi           
kube-system          etcd-controlplane                         12m          53Mi            
kube-system          kube-controller-manager-controlplane      8m           94Mi            
kube-system          kube-scheduler-controlplane               5m           45Mi            
kube-system          metrics-server-695744b77d-9tbpk           4m           12Mi            
default              redis                                     3m           4Mi             
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   2m           50Mi            
kube-system          coredns-6ff97d97f9-gq4nd                  1m           62Mi            
kube-system          coredns-6ff97d97f9-hcn7j                  1m           13Mi            
default              httpd                                     1m           6Mi             
kube-system          kube-proxy-7kdz8                          1m           17Mi            
kube-system          kube-proxy-lg8cx                          1m           70Mi            
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1m           43Mi            
default              nginx                                     0m           2Mi             
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1
kube-system          kube-apiserver-controlplane               22m          273Mi           
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1       
kube-system          kube-apiserver-controlplane               22m          228Mi           
controlplane:~$ echo "kube-apiserver-controlplane,ontrolplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get group1-sa
error: the server doesn't have a resource type "group1-sa"
controlplane:~$ k get sa group1-sa -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2025-09-03T10:52:34Z"
  name: group1-sa
  namespace: default
  resourceVersion: "2941"
  uid: 7c1a2622-0b94-4616-878f-9b9c5bd1c6e8
controlplane:~$ k get clusterrole group1-role-cka
NAME              CREATED AT
group1-role-cka   2025-09-03T10:52:35Z
controlplane:~$ k get clusterrole group1-role-cka -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: "2025-09-03T10:52:35Z"
  name: group1-role-cka
  resourceVersion: "2942"
  uid: 66595125-78bd-4901-9a9c-15c6c1c787ab
rules:
- apiGroups:
  - apps
  resources:
  - deployments
controlplane:~$       ^Czation.k8s.io/group1-role-cka edited
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1
kube-system          kube-apiserver-controlplane               21m          228Mi           
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1 | awk
Usage: awk [POSIX or GNU style options] -f progfile [--] file ...
Usage: awk [POSIX or GNU style options] [--] 'program' file ...
POSIX options:          GNU long options: (standard)
        -f progfile             --file=progfile
        -F fs                   --field-separator=fs
        -v var=val              --assign=var=val
Short options:          GNU long options: (extensions)
        -b                      --characters-as-bytes
        -c                      --traditional
        -C                      --copyright
        -d[file]                --dump-variables[=file]
        -D[file]                --debug[=file]
        -e 'program-text'       --source='program-text'
        -E file                 --exec=file
        -g                      --gen-pot
        -h                      --help
        -i includefile          --include=includefile
        -I                      --trace
        -l library              --load=library
        -L[fatal|invalid|no-ext]        --lint[=fatal|invalid|no-ext]
        -M                      --bignum
        -N                      --use-lc-numeric
        -n                      --non-decimal-data
        -o[file]                --pretty-print[=file]
        -O                      --optimize
        -p[file]                --profile[=file]
        -P                      --posix
        -r                      --re-interval
        -s                      --no-optimize
        -S                      --sandbox
        -t                      --lint-old
        -V                      --version

To report bugs, use the `gawkbug' program.
For full instructions, see the node `Bugs' in `gawk.info'
which is section `Reporting Problems and Bugs' in the
printed version.  This same information may be found at
https://www.gnu.org/software/gawk/manual/html_node/Bugs.html.
PLEASE do NOT try to report bugs by posting in comp.lang.awk,
or by using a web forum such as Stack Overflow.

gawk is a pattern scanning and processing language.
By default it reads standard input and writes standard output.

Examples:
        awk '{ sum += $1 }; END { print sum }' file
        awk -F: '{ print $1 }' /etc/passwd
tail: write error: Broken pipe
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1 | awk '{ print $1 $2 }'
kube-systemkube-apiserver-controlplane
controlplane:~$ k top pods -A --sort-by=cpu | head -n 2 | tail -n 1 | awk '{ print $1; print $2 }'
kube-system
kube-apiserver-controlplane
controlplane:~$ ^C
controlplane:~$ ^C
controlplane:~$ k top pods -A --sort-by=cpu --no-headers | head -n1 | awk '{print $2, $3}'
kube-apiserver-controlplane 24m
controlplane:~$ k top pods -A --sort-by=cpu --no-headers | head -n1 | awk -v OFS=',' '{print $2,$3}'
kube-apiserver-controlplane,20m
controlplane:~$ k top pods -A --sort-by=cpu --no-headers | head -n1 | awk -v OFS=',' '{print $2,$3}' > high_cpu_pod.txt
controlplane:~$ 