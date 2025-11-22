controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pod
E0907 02:41:52.172209   16463 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://172.30.1.2:644333/api?timeout=32s\": dial tcp: address 644333: invalid port"
E0907 02:41:52.174925   16463 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://172.30.1.2:644333/api?timeout=32s\": dial tcp: address 644333: invalid port"
E0907 02:41:52.176281   16463 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://172.30.1.2:644333/api?timeout=32s\": dial tcp: address 644333: invalid port"
E0907 02:41:52.179577   16463 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://172.30.1.2:644333/api?timeout=32s\": dial tcp: address 644333: invalid port"
E0907 02:41:52.180778   16463 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://172.30.1.2:644333/api?timeout=32s\": dial tcp: address 644333: invalid port"
Unable to connect to the server: dial tcp: address 644333: invalid port
controlplane:~$ cat .kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSDRsNEtBS08yVjB3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBNE1Ua3dPRFU0TXpKYUZ3MHpOVEE0TVRjd09UQXpNekphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUM1MVZjQlBOVDZtU2c1MS9ubzZzSGc2a0NjY1VXNGRmSGVqYUVLbHdDblU1bzJmdmp6N2lCc3gzTEIKWGhqL3FZRWxidzhFa2FaSWZQNHFQeDVBVzhJVVRxdVNveDFvUEhVTGdnVmdWaHpVOW1uN0JuSlJvR05vbEgvNgpiK2FTbk1Ga3Q2N0c2dFBwdW5KMWs1U2h0R2loblYrNkF6QTRvUHZXMTFyWmdZV21yT3FNcXRhdWdPVGJFVHA3Cm01MEFMaUVyTk1hVGtuQkJlenZpamw0dDdKTkhUOGdWa1J1bHJyeHJTY0tPREQ1b1ZESjJIYkpZV011Uk9ienYKTThnYTAzNU1hN2FpM1hOVUw1QXNUbk1KZTd3eHhpbU42aVVzcnhTajQzTFVlbFFmOFdiWlovRFZmUTYwdG1TTApPZzlXbmQ5dHpRTFZzcGVxbk45ZDJLeERLOXJuQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTaW9DTXVhalpTbkFkTFdaRXdsV3lYUDdJTS9UQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVBZUUsrclhQZQp2T3RtVlVxUDlsbzdQQ1dZcDdsTHIxR3RLSzVTK0FnYjZONDNoSlZsR0tFMU9ZR3dwU0xkUEFpaTEvcVJFQTU4CjlhcjYxbWppSDFGZ1hNTUdSNlhRcDYrbDFjbXRmL3JSZjBQQ3J3NUN5VVhtTzBacDArd1dHcG5hUDdnclg4NG8KZzJNYU1xMTVHR0hudUpNczVDOWxldVNPUWJvaXVhNFZlbkNqZ3NIK0FCMC9OdmU3YXZ3Zk4xa0tIaTN2TWwrLwpmQkdXNHBqbDJzU1BkNjVuQVNrUkJ3dVBONW9qSDVieXFBNEt6VXIrYjZkY1RpcDUwTy9oTFRRNzZkNDIrR2dECjIramswTGowakFVUmJEeUcyMmJmQXo4UWo3NmVJd1pNSm9XKzhlOUFCSUp6TjlNS1lKYnY0cXFvb2x1blljOFAKU3FKSkdMTUY0bDJuCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://172.30.1.2:644333
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJYTVHemJGbmFDVll3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBNE1Ua3dPRFU0TXpKYUZ3MHlOakE0TVRrd09UQXpNekphTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDOE5BZkUKSDEvOXBiYmVLMUpJaHozYmcvTFdZcWFMa2ZsM1F4cnFlcHRVZXpHdXlqMDdXTVhIQmFUeWVHaWtGdWtiM0pBTgoxRG5rS1l2NHIyM2NscDhmWGxHWDlVVHdkVmZkamlXYTVzUmpDSVF1MmoxWjZSMi84bzZCVy8rT0FVYms2TmFGCkFqVXJQbVVZbHJ5UG5lMGRYRG5GbzdqUEJGY0lNaThqUzl3eXRCTWtlc0lBbGlnUzU3YStEZllKWjk1OEtWZUUKSnVOcm93ZmJiYlVMS1FnbS9aT3czb21MV0hZUFl6aHluS2IvMDNkbWFYWHcxWDNycjVOeXl2aXRTMGk5Z3RrLwo1aTJUQ2hZRExHc0IvenJmRmRydTlXZkpMQ2V1MGkzVHdwWUJ3MHRIWUZnN291WHJ4U21xMEZQZW8zUWozSWtXCmMrT1BkczVBM1o3T1paTGZBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRktLZ0l5NXFObEtjQjB0WgprVENWYkpjL3NnejlNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUEvUEQyUG5heldySTZkNGU3dEV2cEl5YnA3Ck1XY2poQUlUenlia050bkZNWlUvdTZ1cTBkRlUzRTJFNG93UVVLS3Q4TnhiV1dsZUx1aWlQQ1RjVklvV0t5R1gKdnVtd25QTHJRZitNem0yeFMwTlFQdGtkcXBGTTQzcWgvUWRycG5YeWlZWTlOWFVoWklLRnR5aTBiZnkwcWxWRgpIOXpVQ1FrS1pqTGJ5V0UrcE5NMEp6SmM4SmZGWC9MQTNDaHdJSXdNRlZSbnFvSkl4cVdpcWNkZGRMVytWalhBCmxQZW5zNGtYVkhPUldWaEdIa0ZtSDZMRFYwL3NhVDR6RUZtQk9RUXVZMnlYL1lhaWt4OWduc3VIRm5ONkJWcUgKa1ZFR3QrTVBWTzVsMjRoNkhYWmNCcHpmOGFRQlorYlhxcXkxejBUR2V4TmZUK25EQmRBMk5NRW5FOTRsCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdkRRSHhCOWYvYVcyM2l0U1NJYzkyNFB5MW1LbWk1SDVkME1hNm5xYlZIc3hyc285Ck8xakZ4d1drOG5ob3BCYnBHOXlRRGRRNTVDbUwrSzl0M0phZkgxNVJsL1ZFOEhWWDNZNGxtdWJFWXdpRUx0bzkKV2VrZHYvS09nVnYvamdGRzVPaldoUUkxS3o1bEdKYThqNTN0SFZ3NXhhTzR6d1JYQ0RJdkkwdmNNclFUSkhyQwpBSllvRXVlMnZnMzJDV2ZlZkNsWGhDYmphNk1IMjIyMUN5a0lKdjJUc042SmkxaDJEMk00Y3B5bS85TjNabWwxCjhOVjk2NitUY3NyNHJVdEl2WUxaUCtZdGt3b1dBeXhyQWY4NjN4WGE3dlZueVN3bnJ0SXQwOEtXQWNOTFIyQlkKTzZMbDY4VXBxdEJUM3FOMEk5eUpGblBqajNiT1FOMmV6bVdTM3dJREFRQUJBb0lCQUZZOERQYnJYV051by96bQpvcnhDNDdBS3BLRmc4R2p4U1BwQmtEcXlWU3YvaXNOSlBZZE01TXFOcG9mSGJrTUprR1JJeXVUYlFtOXVMZ21UCjhHWHJ5aHRvYjBDT2pMa1ZPMTUwUEh6ZWtrdkNZamJKbnVUc3NNbjd6Um91MmtqcUF0N3VaU1RxM3d2aWVoWXIKTTFrbkJyZTJRMjV3MTBSYis3andyYktobHRMUDczY0VSbWxDWDNROXlpWnU0YXptZ3h4Tzh1N3ptYitPRzVMMQo5eWtaWjVMWGcrZzZkM1E3QkVmNVgzTFV5UVVYb3hPT1NEOU9HcU82aExmazBYMmV2YUNrd21GRTB6UlI4MWZiClIzaVJWdkZwQVhOMGNzNFRWUWdjWlNVeGNab3ZTTWpnT0lDcTZKcWsvUkQxcDE4c2xBL3hjWE9SbnczUmJDOXAKUjVDTURkRUNnWUVBOTlFVXY3Wmk3V1JTNXVPY0JlalFTdUVxc1lyQjNEOWthN1YwMUZTS09ORXYzZjFuelc5Mwp6V0pVRFVkWkhUN1kwTUVvdFVzdjR5bDV1NkhXbzMzY3F3a3pOc0FlS0RZV0xTWHlMK21WQ08xaWd0aVgvQm56CmJWV2ZZMFNwMTZId3oyMWdGWE1Ialdic2lUTjcvWllEUjYzWFRCWWtqbVEvVTJUSmJ5VVdIN2NDZ1lFQXdtc0IKdFNSSVI3WXFveGc4RTFaNlJHaXJxK3JDMHRwZTdXODdjdjZ2eVVFeW1Remx1Y2FONzRDbnJjNUhWVUhocFRxTQp3V0k4YWZRek93VHJOMVhQWWRyYnRkblNWUkFkWXhjT2IwVXVnOTBuMEttUFhmQUMyVEpzTW5EVDJxZTdlWTZVCldOYkgwYUZVL2tzeWltN2kvL2JRTVJtZXlpNDBlSFQvZk1vVFZoa0NnWUJzVGdKRmJ3NTVOWmxOc3pmakZVYkQKRXZrM3NxN2E5UkdNU1RlUC9JcVVIa2hQT29wOUxEUXRuTVdqTUFWd1ZLRXBTdUhocWNSNkFReGt4bXdwODczWApPaVFaejRqZWhoVFhFbmh3SENPNFRSYjZuSEtBQ1U5ci96bXpoclM3dXRpbHJ1V0pPa2FZczl5NGNibkVzQ1VxCjFIejlrY2ZVTzFlNXVKaVliSnJvclFLQmdIV0FhTnJLMytoL2Y4dHNwVHBteEtTOXdpdTRTaUZYbTVIUzdWSTEKL1pZY0VuR1A2dlBadmdUbmMvQkd3TFFWaWtQclhCQ3d4NlNkMDZ5eTcxcFZRVzU1OE5vNm1MV1NkTUJqdWZTawpFbFhkL3VkTTQzbzV5ZTd0VzVrc3VjM29IQlYraDhnZG4wemlQZFVuSzVlaEp3N2VZN3VaS1hBMmRyM3FzRk1DCmFxZFpBb0dCQVBWS3I0R0xMSDUvK01jM2JSQmdzZ0hPOWd1LytIOTBMRTlDbnBDNGg3VG5rb0F0ZExFMk1sTHMKTm1hSmxjeHArL0pTKzhtRkF5dGtSZUlCVlR6WVVZWXJVODY3SGRFbklsaE4wTWpZNHZMdkFlRVQySXpieVlaWgp2TTV5QW9LS0NoTHFscU9VWFNiM0c1V1ZxdFRWZ01NVVpVbHZ4Tks5ZWN1SUkycUQrRTFKCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
controlplane:~$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
18a7ec6b3933f       3461b62f768ea       30 minutes ago      Running             local-path-provisioner    2                   fa576d67fb7d2       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
82952ce234f07       f9c3c1813269c       30 minutes ago      Running             calico-kube-controllers   2                   25a6daa33b986       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
dd4824a0b954f       e6ea68648f0cd       31 minutes ago      Running             kube-flannel              1                   5195edaf5ff09       canal-5q8x5                               kube-system
22f7b4104eed2       75392e3500e36       31 minutes ago      Running             calico-node               1                   5195edaf5ff09       canal-5q8x5                               kube-system
5768c96d0d8e2       661d404f36f01       31 minutes ago      Running             kube-proxy                2                   4e41314cb8b52       kube-proxy-7kdz8                          kube-system
081c5d11a2919       cfed1ff748928       31 minutes ago      Running             kube-scheduler            2                   a555a2506b88e       kube-scheduler-controlplane               kube-system
491eaf573a451       ff4f56c76b82d       31 minutes ago      Running             kube-controller-manager   2                   06c485635a6f7       kube-controller-manager-controlplane      kube-system
e0ccb390ccc96       ee794efa53d85       31 minutes ago      Running             kube-apiserver            2                   9a5c59aed98aa       kube-apiserver-controlplane               kube-system
e5ebc04d1c560       499038711c081       31 minutes ago      Running             etcd                      2                   b524f8dcd2c63       etcd-controlplane                         kube-system
controlplane:~$ ^C        
controlplane:~$ vi .kube/config
controlplane:~$ k get no
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   18d   v1.33.2
node01         Ready    <none>          18d   v1.33.2
controlplane:~$ 

https://killercoda.com/sachin/course/CKA/kubectl-issue