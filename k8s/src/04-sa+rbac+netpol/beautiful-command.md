

                                       [/version]                             []               [get]
controlplane:~$ ^C
controlplane:~$ kubectl auth can-i --as=Sandra --list -n default
Resources                                       Non-Resource URLs   Resource Names   Verbs
serviceaccounts                                 []                  []               [create]
selfsubjectreviews.authentication.k8s.io        []                  []               [create]
selfsubjectaccessreviews.authorization.k8s.io   []                  []               [create]
selfsubjectrulesreviews.authorization.k8s.io    []                  []               [create]
                                                [/api/*]            []               [get]
                                                [/api]              []               [get]
                                                [/apis/*]           []               [get]
                                                [/apis]             []               [get]
                                                [/healthz]          []               [get]
                                                [/healthz]          []               [get]
                                                [/livez]            []               [get]
                                                [/livez]            []               [get]
                                                [/openapi/*]        []               [get]
                                                [/openapi]          []               [get]
                                                [/readyz]           []               [get]
                                                [/readyz]           []               [get]
                                                [/version/]         []               [get]
                                                [/version/]         []               [get]
                                                [/version]          []               [get]
                                                [/version]          []               [get]
controlplane:~$ ^C
controlplane:~$ 


lane:~$ kubectl create sa dev
error: failed to create serviceaccount: serviceaccounts "dev" already exists
controlplane:~$ 
controlplane:~$ # create a role binding named 'dev-view-binding' to allow the 'dev' service account to view resources in the default namespace
controlplane:~$ kubectl create rolebinding dev-view-binding --clusterrole=view --serviceaccount=default:dev --namespace=default
error: failed to create rolebinding: rolebindings.rbac.authorization.k8s.io "dev-view-binding" already exists
controlplane:~$ 
controlplane:~$ # verify the 'dev' service account can view pods in the default namespace
controlplane:~$ kubectl auth can-i get po --namespace default --as=system:serviceaccount:default:dev
yes
controlplane:~$ 
controlplane:~$ # verify the 'dev' service account can view services in the default namespace
controlplane:~$ kubectl auth can-i get svc --namespace default --as=system:serviceaccount:default:dev
yes
controlplane:~$ 
controlplane:~$ # verify that the 'dev' service account CANNOT view the pods in the 'kube-system' namespace
controlplane:~$ kubectl auth can-i get po --namespace kube-system --as=system:serviceaccount:default:dev
no
controlplane:~$ 


# create a service account named dev
kubectl create sa dev

# create a role binding named 'dev-view-binding' to allow the 'dev' service account to view resources in the default namespace
kubectl create rolebinding dev-view-binding --clusterrole=view --serviceaccount=default:dev --namespace=default

# verify the 'dev' service account can view pods in the default namespace
kubectl auth can-i get po --namespace default --as=system:serviceaccount:default:dev

# verify the 'dev' service account can view services in the default namespace
kubectl auth can-i get svc --namespace default --as=system:serviceaccount:default:dev

# verify that the 'dev' service account CANNOT view the pods in the 'kube-system' namespace
kubectl auth can-i get po --namespace kube-system --as=system:serviceaccount:default:devs