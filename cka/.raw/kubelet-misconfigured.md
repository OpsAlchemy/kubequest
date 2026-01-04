rver" err="Post \"https://172.30.1.2:6443/api/v1/nodes\": dial tcp 172.30.1.2:6443: connect: network is unreachable" node="node01"
Dec 13 09:15:03 node01 kubelet[685]: E1213 09:15:03.988511     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.089181     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.138610     685 controller.go:145] "Failed to ensure lease exists, will retry" err="Get \"https://172.30.1.2:6443/apis/coordination.k8s.io/v1/namespaces/kube-node-lease/leases/node01?timeout=10s\": dial tcp 172.30.1.2:6443: connect: network is unreachable" interval="800ms"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.190260     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.290847     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.378831     685 kubelet_node_status.go:677] "Failed to set some node status fields" err="can't get ip address of node node01. error: no default routes found in \"/proc/net/route\" or \"/proc/net/ipv6_route\"" node="node01"
Dec 13 09:15:04 node01 kubelet[685]: I1213 09:15:04.380085     685 kubelet_node_status.go:75] "Attempting to register node" node="node01"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.380304     685 kubelet_node_status.go:107] "Unable to register node with API server" err="Post \"https://172.30.1.2:6443/api/v1/nodes\": dial tcp 172.30.1.2:6443: connect: network is unreachable" node="node01"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.391623     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.413122     685 reflector.go:205] "Failed to watch" err="failed to list *v1.Node: Get \"https://172.30.1.2:6443/api/v1/nodes?fieldSelector=metadata.name%3Dnode01&limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.Node"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.492611     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.593144     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.694025     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.742865     685 reflector.go:205] "Failed to watch" err="failed to list *v1.Service: Get \"https://172.30.1.2:6443/api/v1/services?fieldSelector=spec.clusterIP%21%3DNone&limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.Service"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.795245     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.808608     685 kubelet_node_status.go:677] "Failed to set some node status fields" err="can't get ip address of node node01. error: no default routes found in \"/proc/net/route\" or \"/proc/net/ipv6_route\"" node="node01"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.836267     685 reflector.go:205] "Failed to watch" err="failed to list *v1.CSIDriver: Get \"https://172.30.1.2:6443/apis/storage.k8s.io/v1/csidrivers?limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.CSIDriver"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.895892     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.939403     685 controller.go:145] "Failed to ensure lease exists, will retry" err="Get \"https://172.30.1.2:6443/apis/coordination.k8s.io/v1/namespaces/kube-node-lease/leases/node01?timeout=10s\": dial tcp 172.30.1.2:6443: connect: network is unreachable" interval="1.6s"
Dec 13 09:15:04 node01 kubelet[685]: E1213 09:15:04.996086     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.096702     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.181272     685 kubelet_node_status.go:677] "Failed to set some node status fields" err="can't get ip address of node node01. error: no default routes found in \"/proc/net/route\" or \"/proc/net/ipv6_route\"" node="node01"
Dec 13 09:15:05 node01 kubelet[685]: I1213 09:15:05.181985     685 kubelet_node_status.go:75] "Attempting to register node" node="node01"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.182336     685 kubelet_node_status.go:107] "Unable to register node with API server" err="Post \"https://172.30.1.2:6443/api/v1/nodes\": dial tcp 172.30.1.2:6443: connect: network is unreachable" node="node01"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.197832     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.268462     685 reflector.go:205] "Failed to watch" err="failed to list *v1.RuntimeClass: Get \"https://172.30.1.2:6443/apis/node.k8s.io/v1/runtimeclasses?limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.RuntimeClass"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.298769     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.399612     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.500926     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.601665     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.702442     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.803291     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:05 node01 kubelet[685]: E1213 09:15:05.904098     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.005245     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.106008     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.206685     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.307724     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.408761     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.509013     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.540682     685 controller.go:145] "Failed to ensure lease exists, will retry" err="Get \"https://172.30.1.2:6443/apis/coordination.k8s.io/v1/namespaces/kube-node-lease/leases/node01?timeout=10s\": dial tcp 172.30.1.2:6443: connect: network is unreachable" interval="3.2s"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.610050     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.710888     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.782622     685 kubelet_node_status.go:677] "Failed to set some node status fields" err="can't get ip address of node node01. error: no default routes found in \"/proc/net/route\" or \"/proc/net/ipv6_route\"" node="node01"
Dec 13 09:15:06 node01 kubelet[685]: I1213 09:15:06.783149     685 kubelet_node_status.go:75] "Attempting to register node" node="node01"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.783381     685 kubelet_node_status.go:107] "Unable to register node with API server" err="Post \"https://172.30.1.2:6443/api/v1/nodes\": dial tcp 172.30.1.2:6443: connect: network is unreachable" node="node01"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.811801     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:06 node01 kubelet[685]: E1213 09:15:06.912631     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.013579     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.067224     685 kubelet_node_status.go:677] "Failed to set some node status fields" err="can't get ip address of node node01. error: no default routes found in \"/proc/net/route\" or \"/proc/net/ipv6_route\"" node="node01"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.077465     685 reflector.go:205] "Failed to watch" err="failed to list *v1.RuntimeClass: Get \"https://172.30.1.2:6443/apis/node.k8s.io/v1/runtimeclasses?limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.RuntimeClass"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.114817     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.189548     685 reflector.go:205] "Failed to watch" err="failed to list *v1.CSIDriver: Get \"https://172.30.1.2:6443/apis/storage.k8s.io/v1/csidrivers?limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.CSIDriver"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.216072     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.317069     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.418161     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.520814     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.562818     685 reflector.go:205] "Failed to watch" err="failed to list *v1.Node: Get \"https://172.30.1.2:6443/api/v1/nodes?fieldSelector=metadata.name%3Dnode01&limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.Node"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.596140     685 reflector.go:205] "Failed to watch" err="failed to list *v1.Service: Get \"https://172.30.1.2:6443/api/v1/services?fieldSelector=spec.clusterIP%21%3DNone&limit=500&resourceVersion=0\": dial tcp 172.30.1.2:6443: connect: network is unreachable" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:160" type="*v1.Service"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.621691     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.722834     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.824003     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:07 node01 kubelet[685]: E1213 09:15:07.924719     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:08 node01 kubelet[685]: E1213 09:15:08.025611     685 reconstruct.go:189] "Failed to get Node status to reconstruct device paths" err="Get \"https://172.30.1.2:6443/api/v1/nodes/node01\": dial tcp 172.30.1.2:6443: connect: network is unreachable"
Dec 13 09:15:10 node01 kubelet[685]: I1213 09:15:10.424345     685 kubelet_node_status.go:75] "Attempting to register node" node="node01"
Dec 13 09:15:14 node01 kubelet[685]: E1213 09:15:14.121636     685 eviction_manager.go:292] "Eviction manager: failed to get summary stats" err="failed to get node info: node \"node01\" not found"
Dec 13 09:15:20 node01 kubelet[685]: E1213 09:15:20.180980     685 controller.go:145] "Failed to ensure lease exists, will retry" err="Get \"https://172.30.1.2:6443/apis/coordination.k8s.io/v1/namespaces/kube-node-lease/leases/node01?timeout=10s\": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)" interval="6.4s"
Dec 13 09:15:24 node01 kubelet[685]: E1213 09:15:24.121896     685 eviction_manager.go:292] "Eviction manager: failed to get summary stats" err="failed to get node info: node \"node01\" not found"
Dec 13 09:15:32 node01 kubelet[685]: I1213 09:15:32.931910     685 apiserver.go:52] "Watching apiserver"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.278018     685 desired_state_of_world_populator.go:154] "Finished populating initial desired state of world"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316361     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-lib-modules\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316573     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"sys-fs\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-sys-fs\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316589     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"policysync\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-policysync\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316615     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"var-lib-calico\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-var-lib-calico\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316721     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"bpffs\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-bpffs\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316728     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"nodeproc\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-nodeproc\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316744     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/64cb9d39-55e0-4ec2-94ac-bd22d2328010-xtables-lock\") pod \"kube-proxy-cf4m9\" (UID: \"64cb9d39-55e0-4ec2-94ac-bd22d2328010\") " pod="kube-system/kube-proxy-cf4m9"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316885     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"var-run-calico\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-var-run-calico\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316896     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"xtables-lock\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-xtables-lock\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316905     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"cni-bin-dir\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-cni-bin-dir\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316917     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"cni-net-dir\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-cni-net-dir\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316924     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"cni-log-dir\" (UniqueName: \"kubernetes.io/host-path/229dfffc-1591-44ca-94e5-4c635a6e1899-cni-log-dir\") pod \"canal-hwn8t\" (UID: \"229dfffc-1591-44ca-94e5-4c635a6e1899\") " pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: I1213 09:15:33.316931     685 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"lib-modules\" (UniqueName: \"kubernetes.io/host-path/64cb9d39-55e0-4ec2-94ac-bd22d2328010-lib-modules\") pod \"kube-proxy-cf4m9\" (UID: \"64cb9d39-55e0-4ec2-94ac-bd22d2328010\") " pod="kube-system/kube-proxy-cf4m9"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.710686     685 status_manager.go:1018] "Failed to get status for pod" err="pods \"canal-hwn8t\" is forbidden: User \"system:node:node01\" cannot get resource \"pods\" in API group \"\" in the namespace \"kube-system\": no relationship found between node 'node01' and this object" podUID="229dfffc-1591-44ca-94e5-4c635a6e1899" pod="kube-system/canal-hwn8t"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.710860     685 reflector.go:205] "Failed to watch" err="failed to list *v1.ConfigMap: configmaps \"kubernetes-services-endpoint\" is forbidden: User \"system:node:node01\" cannot list resource \"configmaps\" in API group \"\" in the namespace \"kube-system\": no relationship found between node 'node01' and this object" logger="UnhandledError" reflector="object-\"kube-system\"/\"kubernetes-services-endpoint\"" type="*v1.ConfigMap"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.710922     685 reflector.go:205] "Failed to watch" err="failed to list *v1.ConfigMap: configmaps \"canal-config\" is forbidden: User \"system:node:node01\" cannot list resource \"configmaps\" in API group \"\" in the namespace \"kube-system\": no relationship found between node 'node01' and this object" logger="UnhandledError" reflector="object-\"kube-system\"/\"canal-config\"" type="*v1.ConfigMap"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.710962     685 reflector.go:205] "Failed to watch" err="failed to list *v1.ConfigMap: configmaps \"kube-root-ca.crt\" is forbidden: User \"system:node:node01\" cannot list resource \"configmaps\" in API group \"\" in the namespace \"kube-system\": no relationship found between node 'node01' and this object" logger="UnhandledError" reflector="object-\"kube-system\"/\"kube-root-ca.crt\"" type="*v1.ConfigMap"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.711056     685 reflector.go:205] "Failed to watch" err="failed to list *v1.ConfigMap: configmaps \"coredns\" is forbidden: User \"system:node:node01\" cannot list resource \"configmaps\" in API group \"\" in the namespace \"kube-system\": no relationship found between node 'node01' and this object" logger="UnhandledError" reflector="object-\"kube-system\"/\"coredns\"" type="*v1.ConfigMap"
Dec 13 09:15:33 node01 kubelet[685]: E1213 09:15:33.738688     685 reflector.go:205] "Failed to watch" err=<
Dec 13 09:15:33 node01 kubelet[685]:         failed to list *v1.ConfigMap: configmaps "kube-proxy" is forbidden: User "system:node:node01" cannot list resource "configmaps" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object
Dec 13 09:15:33 node01 kubelet[685]:         RBAC: [clusterrole.rbac.authorization.k8s.io "system:basic-user" not found, clusterrole.rbac.authorization.k8s.io "system:public-info-viewer" not found, clusterrole.rbac.authorization.k8s.io "system:discovery" not found, clusterrole.rbac.authorization.k8s.io "system:certificates.k8s.io:certificatesigningrequests:selfnodeclient" not found]
Dec 13 09:15:33 node01 kubelet[685]:  > logger="UnhandledError" reflector="object-\"kube-system\"/\"kube-proxy\"" type="*v1.ConfigMap"
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.318878     685 configmap.go:193] Couldn't get configMap kube-system/coredns: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.318970     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/configmap/6dcc1e47-5e55-4c36-9130-d73aa97415b1-config-volume podName:6dcc1e47-5e55-4c36-9130-d73aa97415b1 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:34.818951832 +0000 UTC m=+32.205866644 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "config-volume" (UniqueName: "kubernetes.io/configmap/6dcc1e47-5e55-4c36-9130-d73aa97415b1-config-volume") pod "coredns-76bb9b6fb5-zsjp6" (UID: "6dcc1e47-5e55-4c36-9130-d73aa97415b1") : failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.318991     685 configmap.go:193] Couldn't get configMap kube-system/canal-config: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.319012     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/configmap/229dfffc-1591-44ca-94e5-4c635a6e1899-flannel-cfg podName:229dfffc-1591-44ca-94e5-4c635a6e1899 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:34.819006151 +0000 UTC m=+32.205920965 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "flannel-cfg" (UniqueName: "kubernetes.io/configmap/229dfffc-1591-44ca-94e5-4c635a6e1899-flannel-cfg") pod "canal-hwn8t" (UID: "229dfffc-1591-44ca-94e5-4c635a6e1899") : failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.319023     685 configmap.go:193] Couldn't get configMap kube-system/coredns: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.319042     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/configmap/63e271fb-2abd-4bc2-965e-684013fde600-config-volume podName:63e271fb-2abd-4bc2-965e-684013fde600 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:34.819037429 +0000 UTC m=+32.205952242 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "config-volume" (UniqueName: "kubernetes.io/configmap/63e271fb-2abd-4bc2-965e-684013fde600-config-volume") pod "coredns-76bb9b6fb5-6hd7r" (UID: "63e271fb-2abd-4bc2-965e-684013fde600") : failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.319052     685 configmap.go:193] Couldn't get configMap kube-system/kube-proxy: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.319067     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/configmap/64cb9d39-55e0-4ec2-94ac-bd22d2328010-kube-proxy podName:64cb9d39-55e0-4ec2-94ac-bd22d2328010 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:34.819061791 +0000 UTC m=+32.205976603 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "kube-proxy" (UniqueName: "kubernetes.io/configmap/64cb9d39-55e0-4ec2-94ac-bd22d2328010-kube-proxy") pod "kube-proxy-cf4m9" (UID: "64cb9d39-55e0-4ec2-94ac-bd22d2328010") : failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: I1213 09:15:34.607206     685 kubelet_node_status.go:124] "Node was previously registered" node="node01"
Dec 13 09:15:34 node01 kubelet[685]: I1213 09:15:34.607317     685 kubelet_node_status.go:78] "Successfully registered node" node="node01"
Dec 13 09:15:34 node01 kubelet[685]: I1213 09:15:34.607337     685 kuberuntime_manager.go:1828] "Updating runtime config through cri with podcidr" CIDR="192.168.1.0/24"
Dec 13 09:15:34 node01 kubelet[685]: I1213 09:15:34.608084     685 kubelet_network.go:47] "Updating Pod CIDR" originalPodCIDR="" newPodCIDR="192.168.1.0/24"
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711652     685 projected.go:291] Couldn't get configMap kube-system/kube-root-ca.crt: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711678     685 projected.go:196] Error preparing data for projected volume kube-api-access-9tdbv for pod kube-system/kube-proxy-cf4m9: [failed to fetch token: serviceaccounts "kube-proxy" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711737     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/projected/64cb9d39-55e0-4ec2-94ac-bd22d2328010-kube-api-access-9tdbv podName:64cb9d39-55e0-4ec2-94ac-bd22d2328010 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:35.211724676 +0000 UTC m=+32.598639490 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "kube-api-access-9tdbv" (UniqueName: "kubernetes.io/projected/64cb9d39-55e0-4ec2-94ac-bd22d2328010-kube-api-access-9tdbv") pod "kube-proxy-cf4m9" (UID: "64cb9d39-55e0-4ec2-94ac-bd22d2328010") : [failed to fetch token: serviceaccounts "kube-proxy" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711752     685 projected.go:291] Couldn't get configMap kube-system/kube-root-ca.crt: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711757     685 projected.go:196] Error preparing data for projected volume kube-api-access-f7s8z for pod kube-system/coredns-76bb9b6fb5-zsjp6: [failed to fetch token: serviceaccounts "coredns" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711771     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/projected/6dcc1e47-5e55-4c36-9130-d73aa97415b1-kube-api-access-f7s8z podName:6dcc1e47-5e55-4c36-9130-d73aa97415b1 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:35.211767363 +0000 UTC m=+32.598682176 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "kube-api-access-f7s8z" (UniqueName: "kubernetes.io/projected/6dcc1e47-5e55-4c36-9130-d73aa97415b1-kube-api-access-f7s8z") pod "coredns-76bb9b6fb5-zsjp6" (UID: "6dcc1e47-5e55-4c36-9130-d73aa97415b1") : [failed to fetch token: serviceaccounts "coredns" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711779     685 projected.go:291] Couldn't get configMap kube-system/kube-root-ca.crt: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711784     685 projected.go:196] Error preparing data for projected volume kube-api-access-czgll for pod kube-system/canal-hwn8t: [failed to fetch token: serviceaccounts "canal" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711796     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/projected/229dfffc-1591-44ca-94e5-4c635a6e1899-kube-api-access-czgll podName:229dfffc-1591-44ca-94e5-4c635a6e1899 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:35.211793453 +0000 UTC m=+32.598708266 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "kube-api-access-czgll" (UniqueName: "kubernetes.io/projected/229dfffc-1591-44ca-94e5-4c635a6e1899-kube-api-access-czgll") pod "canal-hwn8t" (UID: "229dfffc-1591-44ca-94e5-4c635a6e1899") : [failed to fetch token: serviceaccounts "canal" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711804     685 projected.go:291] Couldn't get configMap kube-system/kube-root-ca.crt: failed to sync configmap cache: timed out waiting for the condition
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711808     685 projected.go:196] Error preparing data for projected volume kube-api-access-fqh49 for pod kube-system/coredns-76bb9b6fb5-6hd7r: [failed to fetch token: serviceaccounts "coredns" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:34 node01 kubelet[685]: E1213 09:15:34.711818     685 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/projected/63e271fb-2abd-4bc2-965e-684013fde600-kube-api-access-fqh49 podName:63e271fb-2abd-4bc2-965e-684013fde600 nodeName:}" failed. No retries permitted until 2025-12-13 09:15:35.211815086 +0000 UTC m=+32.598729891 (durationBeforeRetry 500ms). Error: MountVolume.SetUp failed for volume "kube-api-access-fqh49" (UniqueName: "kubernetes.io/projected/63e271fb-2abd-4bc2-965e-684013fde600-kube-api-access-fqh49") pod "coredns-76bb9b6fb5-6hd7r" (UID: "63e271fb-2abd-4bc2-965e-684013fde600") : [failed to fetch token: serviceaccounts "coredns" is forbidden: User "system:node:node01" cannot create resource "serviceaccounts/token" in API group "" in the namespace "kube-system": no relationship found between node 'node01' and this object, failed to sync configmap cache: timed out waiting for the condition]
Dec 13 09:15:35 node01 kubelet[685]: I1213 09:15:35.960066     685 scope.go:117] "RemoveContainer" containerID="6e06632f702a3a0e60fb0aecad488fd4c1f36c36b91777ecd287f176b2461190"
Dec 13 09:15:36 node01 kubelet[685]: I1213 09:15:36.087785     685 scope.go:117] "RemoveContainer" containerID="3d0cfe1600be448308a9ccbded6ede99c7645c708382c7b92c90344c9e44200f"
Dec 13 09:15:42 node01 kubelet[685]: I1213 09:15:42.294024     685 scope.go:117] "RemoveContainer" containerID="432f9c3373256a501102f6afcd0a5eefacba4b623899cbf43a2f87fe772752b8"
Dec 13 09:15:42 node01 kubelet[685]: I1213 09:15:42.294045     685 scope.go:117] "RemoveContainer" containerID="96e71f3b37a1691cb41f7b619f5af76766925623086eb79ee5e8fea331d103de"
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.799695     685 log.go:32] "StopPodSandbox from runtime service failed" err="rpc error: code = Unknown desc = failed to destroy network for sandbox \"3ea07279b7bc7167dfb5dc4b009ae0719cab4e0dd508bb195ffe6f157c929059\": plugin type=\"calico\" failed (delete): error getting ClusterInformation: Get \"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\": dial tcp 10.96.0.1:443: i/o timeout" podSandboxID="3ea07279b7bc7167dfb5dc4b009ae0719cab4e0dd508bb195ffe6f157c929059"
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.799735     685 kuberuntime_manager.go:1665] "Failed to stop sandbox" podSandboxID={"Type":"containerd","ID":"3ea07279b7bc7167dfb5dc4b009ae0719cab4e0dd508bb195ffe6f157c929059"}
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.799785     685 kuberuntime_manager.go:1233] "killPodWithSyncResult failed" err="failed to \"KillPodSandbox\" for \"6dcc1e47-5e55-4c36-9130-d73aa97415b1\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"3ea07279b7bc7167dfb5dc4b009ae0719cab4e0dd508bb195ffe6f157c929059\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\""
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.799816     685 pod_workers.go:1324] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"6dcc1e47-5e55-4c36-9130-d73aa97415b1\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"3ea07279b7bc7167dfb5dc4b009ae0719cab4e0dd508bb195ffe6f157c929059\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="kube-system/coredns-76bb9b6fb5-zsjp6" podUID="6dcc1e47-5e55-4c36-9130-d73aa97415b1"
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.827049     685 log.go:32] "StopPodSandbox from runtime service failed" err="rpc error: code = Unknown desc = failed to destroy network for sandbox \"a51d8a5cd7b59c6a814c36a2ef6611f27009a24357638745a0fc79f77463da7c\": plugin type=\"calico\" failed (delete): error getting ClusterInformation: Get \"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\": dial tcp 10.96.0.1:443: i/o timeout" podSandboxID="a51d8a5cd7b59c6a814c36a2ef6611f27009a24357638745a0fc79f77463da7c"
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.827099     685 kuberuntime_manager.go:1665] "Failed to stop sandbox" podSandboxID={"Type":"containerd","ID":"a51d8a5cd7b59c6a814c36a2ef6611f27009a24357638745a0fc79f77463da7c"}
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.827128     685 kuberuntime_manager.go:1233] "killPodWithSyncResult failed" err="failed to \"KillPodSandbox\" for \"63e271fb-2abd-4bc2-965e-684013fde600\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"a51d8a5cd7b59c6a814c36a2ef6611f27009a24357638745a0fc79f77463da7c\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\""
Dec 13 09:16:06 node01 kubelet[685]: E1213 09:16:06.828227     685 pod_workers.go:1324] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"63e271fb-2abd-4bc2-965e-684013fde600\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"a51d8a5cd7b59c6a814c36a2ef6611f27009a24357638745a0fc79f77463da7c\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="kube-system/coredns-76bb9b6fb5-6hd7r" podUID="63e271fb-2abd-4bc2-965e-684013fde600"
Dec 13 09:18:42 node01 systemd[1]: Stopping kubelet.service - kubelet: The Kubernetes Node Agent...
Dec 13 09:18:42 node01 systemd[1]: kubelet.service: Deactivated successfully.
Dec 13 09:18:42 node01 systemd[1]: Stopped kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:18:42 node01 systemd[1]: kubelet.service: Consumed 1.820s CPU time.
Dec 13 09:18:42 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:18:42 node01 kubelet[3315]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:18:42 node01 kubelet[3315]: E1213 09:18:42.995889    3315 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:18:42 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:18:42 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:18:53 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 1.
Dec 13 09:18:53 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:18:53 node01 kubelet[3342]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:18:53 node01 kubelet[3342]: E1213 09:18:53.235195    3342 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:18:53 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:18:53 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:03 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 2.
Dec 13 09:19:03 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:03 node01 kubelet[3368]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:03 node01 kubelet[3368]: E1213 09:19:03.476575    3368 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:03 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:03 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:13 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 3.
Dec 13 09:19:13 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:13 node01 kubelet[3390]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:13 node01 kubelet[3390]: E1213 09:19:13.731818    3390 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:13 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:13 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:23 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 4.
Dec 13 09:19:23 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:23 node01 kubelet[3411]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:23 node01 kubelet[3411]: E1213 09:19:23.984695    3411 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:23 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:23 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:34 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 5.
Dec 13 09:19:34 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:34 node01 kubelet[3431]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:34 node01 kubelet[3431]: E1213 09:19:34.240513    3431 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:34 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:34 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:44 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 6.
Dec 13 09:19:44 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:44 node01 kubelet[3462]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:44 node01 kubelet[3462]: E1213 09:19:44.477234    3462 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:44 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:44 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:19:54 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 7.
Dec 13 09:19:54 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:19:54 node01 kubelet[3489]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:19:54 node01 kubelet[3489]: E1213 09:19:54.724722    3489 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:19:54 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:19:54 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:04 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 8.
Dec 13 09:20:04 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:04 node01 kubelet[3518]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:04 node01 kubelet[3518]: E1213 09:20:04.988665    3518 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:04 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:04 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:15 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 9.
Dec 13 09:20:15 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:15 node01 kubelet[3564]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:15 node01 kubelet[3564]: E1213 09:20:15.234799    3564 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:15 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:15 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:25 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 10.
Dec 13 09:20:25 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:25 node01 kubelet[3588]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:25 node01 kubelet[3588]: E1213 09:20:25.480737    3588 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:25 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:25 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:35 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 11.
Dec 13 09:20:35 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:35 node01 kubelet[3622]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:35 node01 kubelet[3622]: E1213 09:20:35.730002    3622 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:35 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:35 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:45 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 12.
Dec 13 09:20:45 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:45 node01 kubelet[3645]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:45 node01 kubelet[3645]: E1213 09:20:45.980080    3645 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:45 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:45 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:20:56 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 13.
Dec 13 09:20:56 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:20:56 node01 kubelet[3666]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:20:56 node01 kubelet[3666]: E1213 09:20:56.228221    3666 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:20:56 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:20:56 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:06 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 14.
Dec 13 09:21:06 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:06 node01 kubelet[3692]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:06 node01 kubelet[3692]: E1213 09:21:06.478817    3692 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:06 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:06 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:16 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 15.
Dec 13 09:21:16 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:16 node01 kubelet[3738]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:16 node01 kubelet[3738]: E1213 09:21:16.735216    3738 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:16 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:16 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:26 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 16.
Dec 13 09:21:26 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:26 node01 kubelet[3760]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:26 node01 kubelet[3760]: E1213 09:21:26.982470    3760 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:26 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:26 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:37 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 17.
Dec 13 09:21:37 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:37 node01 kubelet[3781]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:37 node01 kubelet[3781]: E1213 09:21:37.231220    3781 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:37 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:37 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:47 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 18.
Dec 13 09:21:47 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:47 node01 kubelet[3809]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:47 node01 kubelet[3809]: E1213 09:21:47.476462    3809 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:47 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:47 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:21:57 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 19.
Dec 13 09:21:57 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:21:57 node01 kubelet[3842]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:21:57 node01 kubelet[3842]: E1213 09:21:57.731171    3842 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:21:57 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:21:57 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:07 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 20.
Dec 13 09:22:07 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:07 node01 kubelet[3880]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:07 node01 kubelet[3880]: E1213 09:22:07.978203    3880 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:07 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:07 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:18 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 21.
Dec 13 09:22:18 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:18 node01 kubelet[3904]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:18 node01 kubelet[3904]: E1213 09:22:18.228391    3904 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:18 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:18 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:28 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 22.
Dec 13 09:22:28 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:28 node01 kubelet[3926]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:28 node01 kubelet[3926]: E1213 09:22:28.488644    3926 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:28 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:28 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:38 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 23.
Dec 13 09:22:38 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:38 node01 kubelet[3948]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:38 node01 kubelet[3948]: E1213 09:22:38.728903    3948 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:38 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:38 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:48 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 24.
Dec 13 09:22:48 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:48 node01 kubelet[3970]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:48 node01 kubelet[3970]: E1213 09:22:48.978560    3970 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:48 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:48 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:22:59 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 25.
Dec 13 09:22:59 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:22:59 node01 kubelet[3990]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:22:59 node01 kubelet[3990]: E1213 09:22:59.231772    3990 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:22:59 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:22:59 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:23:09 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 26.
Dec 13 09:23:09 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:23:09 node01 kubelet[4019]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:23:09 node01 kubelet[4019]: E1213 09:23:09.487958    4019 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:23:09 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:23:09 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
Dec 13 09:23:19 node01 systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 27.
Dec 13 09:23:19 node01 systemd[1]: Started kubelet.service - kubelet: The Kubernetes Node Agent.
Dec 13 09:23:19 node01 kubelet[4042]: Flag --pod-infra-container-image has been deprecated, will be removed in 1.35. Image garbage collector will get sandbox image information from CRI.
Dec 13 09:23:19 node01 kubelet[4042]: E1213 09:23:19.732258    4042 run.go:72] "command failed" err="failed to parse kubelet flag: unknown flag: --improve-speed"
Dec 13 09:23:19 node01 systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Dec 13 09:23:19 node01 systemd[1]: kubelet.service: Failed with result 'exit-code'.
node01:~$ systemctl cat kubelet
# /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/ku>
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamic>
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this>
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
node01:~$ systemctl cat kubelet --no-pager
# /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
node01:~$ cat /etc/kubernetes/   
cat: /etc/kubernetes/: Is a directory
node01:~$ ls
filesystem
node01:~$ cd /etc/kubernetes/
node01:/etc/kubernetes$ ls
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ ls
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ cat kubelet.conf 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUytlNHFCRmpjeEl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1UY3hPVEEwTURsYUZ3MHpOVEV4TVRVeE9UQTVNRGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURYbVpLaHBkTkRTRTVaT1JRU05wWTk4M01MZFJWWUROWERxWGlnME0rUDM1a2hObWJ6Qm1PeXpwM2QKVG1pWVRTNzBvK2tLRjlKWjZrQk9NbFVsdHljMVJVU094SmZ6MExvZENwRWlSc1BIbDUxaUp1aExZREFhSTBxeApxck1hcEVmUEYxc3ZhTHQycGh1bW9OdVV6MlQxUW90aks3akpBR0dSMVVoLzAzVEd4UnJLYVhha2xOUVpQTk1lCm1mS3dOa2NYbWNCRWY0YTNxWDY4M29RVHJTbTdJMGtQWGt4UHpmVXlyNkdrVjJKejdCWlNkRXhrUHd5Q29RM2UKSVZnVnd6em5DbVVjeTJOTXJnL3FoL3ZBM1ZvbENra3B4UkZzNVpDYmRFckJ2R28vV2RVeEQyWVBTdFRWZ2JJbQozdTJoVjVRcmp6bG9zOGErOFNKd1MxaUUwejg5QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTTnRvVkpad3J1SHMvbHZ5Q1dwckNaeVJZOHp6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hWM2Z4c2RHUwp3WXhQc3JkZzhPSnlUWGxiWlhyVEVsWndsWTJ5ZHVXQ0ZuY2o1dWhwRGpZWXJ0c1k0dDZBNUtZMmdERFFYRldpCncvbXp0Q2xSa1BReENVYnZFUXJQem9Db1lpTjV4S29PeFRxVU5qT004cmNZNk1HN1VYRVQ4bm1NV1lCRzQ2RXQKc1d1anEva3ZQU0ljSmpZNWVzdHppRXdlVjA3Vzc3N0hIY25aMlhVNHg0SVQzcmlYSmtZbHBIM1V1ZUpmalo4LwpoWFdCZnpiVEMyLzNCRDBZTy9BV1dacTN3M2l0dmF4dDFrTWhnS2wzWkpxZUkyZkIzcnEyZkljTmJRMHRBb2VoCkRkQ2Qza2VYOC9Md2RJZCsyWjR6U3JRQVBUN2FrQUo1ckFnTEpTS1VlSGtKMzNicERQb1FGVmFiSTZVVmZtYVkKaGI1M0ljOFB1NFNQCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://172.30.1.2:6443
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
users:
- name: default-auth
  user:
    client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
    client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
node01:/etc/kubernetes$ ls
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ systemctl cat kubelet --no-pager
# /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
node01:/etc/kubernetes$ cd /var/lib/kubelet/
node01:/var/lib/kubelet$ cat config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
cpuManagerReconcilePeriod: 0s
crashLoopBackOff: {}
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMaximumGCAge: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
    text:
      infoBufferSize: "0"
  verbosity: 0
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
node01:/var/lib/kubelet$ cat config.yaml | grep improve
node01:/var/lib/kubelet$ ls
actuated_pods_state   checkpoints  cpu_manager_state  dra_manager_state     kubeadm-flags.env     pki      plugins_registry  pods
allocated_pods_state  config.yaml  device-plugins     instance-config.yaml  memory_manager_state  plugins  pod-resources
node01:/var/lib/kubelet$ systemctl cat kubelet --no-pager
# /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
node01:/var/lib/kubelet$ cat /var/lib/kubelet/kubeadm-flags.env 
KUBELET_KUBEADM_ARGS="--pod-infra-container-image=registry.k8s.io/pause:3.10.1 --improve-speed"
node01:/var/lib/kubelet$ vi /var/lib/kubelet/kubeadm-flags.env 
node01:/var/lib/kubelet$ systemctl start kubelet
node01:/var/lib/kubelet$ k get no
E1213 09:26:49.733448    4853 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:26:49.733683    4853 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:26:49.735316    4853 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:26:49.735483    4853 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:26:49.736938    4853 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:/var/lib/kubelet$ k get pods
E1213 09:27:01.959594    4901 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:01.960605    4901 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:01.962060    4901 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:01.962469    4901 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:01.963992    4901 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:/var/lib/kubelet$ systemctl status kubelet
��� kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             ������10-kubeadm.conf
     Active: active (running) since Sat 2025-12-13 09:26:34 UTC; 39s ago
       Docs: https://kubernetes.io/docs/
   Main PID: 4542 (kubelet)
      Tasks: 10 (limit: 2240)
     Memory: 26.0M (peak: 26.3M)
        CPU: 460ms
     CGroup: /system.slice/kubelet.service
             ������4542 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/ku>

Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.718801    4542 scope.go:117] "RemoveContainer" containerID="34c1e64f953226de4>
Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.744597    4542 scope.go:117] "RemoveContainer" containerID="3baebae192abe9096>
Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.759683    4542 scope.go:117] "RemoveContainer" containerID="34c1e64f953226de4>
Dec 13 09:26:41 node01 kubelet[4542]: E1213 09:26:41.760521    4542 log.go:32] "ContainerStatus from runtime service failed" err=">
Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.760586    4542 pod_container_deletor.go:53] "DeleteContainer returned error" >
Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.760607    4542 scope.go:117] "RemoveContainer" containerID="3baebae192abe9096>
Dec 13 09:26:41 node01 kubelet[4542]: E1213 09:26:41.761205    4542 log.go:32] "ContainerStatus from runtime service failed" err=">
Dec 13 09:26:41 node01 kubelet[4542]: I1213 09:26:41.761232    4542 pod_container_deletor.go:53] "DeleteContainer returned error" >
Dec 13 09:26:42 node01 kubelet[4542]: I1213 09:26:42.521681    4542 kubelet_volumes.go:163] "Cleaned up orphaned pod volumes dir" >
Dec 13 09:26:42 node01 kubelet[4542]: I1213 09:26:42.522530    4542 kubelet_volumes.go:163] "Cleaned up orphaned pod volumes dir" >
node01:/var/lib/kubelet$ cd /etc/kubernetes/manifests/
node01:/etc/kubernetes/manifests$ ls
node01:/etc/kubernetes/manifests$ cd ..
node01:/etc/kubernetes$ ls
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ k get pods
E1213 09:27:39.672645    5198 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:39.672894    5198 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:39.674361    5198 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:39.674919    5198 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:27:39.676364    5198 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:/etc/kubernetes$ ^C
node01:/etc/kubernetes$ ls
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ cat kubelet.conf 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUytlNHFCRmpjeEl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1UY3hPVEEwTURsYUZ3MHpOVEV4TVRVeE9UQTVNRGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURYbVpLaHBkTkRTRTVaT1JRU05wWTk4M01MZFJWWUROWERxWGlnME0rUDM1a2hObWJ6Qm1PeXpwM2QKVG1pWVRTNzBvK2tLRjlKWjZrQk9NbFVsdHljMVJVU094SmZ6MExvZENwRWlSc1BIbDUxaUp1aExZREFhSTBxeApxck1hcEVmUEYxc3ZhTHQycGh1bW9OdVV6MlQxUW90aks3akpBR0dSMVVoLzAzVEd4UnJLYVhha2xOUVpQTk1lCm1mS3dOa2NYbWNCRWY0YTNxWDY4M29RVHJTbTdJMGtQWGt4UHpmVXlyNkdrVjJKejdCWlNkRXhrUHd5Q29RM2UKSVZnVnd6em5DbVVjeTJOTXJnL3FoL3ZBM1ZvbENra3B4UkZzNVpDYmRFckJ2R28vV2RVeEQyWVBTdFRWZ2JJbQozdTJoVjVRcmp6bG9zOGErOFNKd1MxaUUwejg5QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTTnRvVkpad3J1SHMvbHZ5Q1dwckNaeVJZOHp6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hWM2Z4c2RHUwp3WXhQc3JkZzhPSnlUWGxiWlhyVEVsWndsWTJ5ZHVXQ0ZuY2o1dWhwRGpZWXJ0c1k0dDZBNUtZMmdERFFYRldpCncvbXp0Q2xSa1BReENVYnZFUXJQem9Db1lpTjV4S29PeFRxVU5qT004cmNZNk1HN1VYRVQ4bm1NV1lCRzQ2RXQKc1d1anEva3ZQU0ljSmpZNWVzdHppRXdlVjA3Vzc3N0hIY25aMlhVNHg0SVQzcmlYSmtZbHBIM1V1ZUpmalo4LwpoWFdCZnpiVEMyLzNCRDBZTy9BV1dacTN3M2l0dmF4dDFrTWhnS2wzWkpxZUkyZkIzcnEyZkljTmJRMHRBb2VoCkRkQ2Qza2VYOC9Md2RJZCsyWjR6U3JRQVBUN2FrQUo1ckFnTEpTS1VlSGtKMzNicERQb1FGVmFiSTZVVmZtYVkKaGI1M0ljOFB1NFNQCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://172.30.1.2:6443
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
users:
- name: default-auth
  user:
    client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
    client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
node01:/etc/kubernetes$ ^C
node01:/etc/kubernetes$ export KUBECONFIG=/etc/kubernetes/admin.conf
node01:/etc/kubernetes$ k get no
E1213 09:32:50.456383    6408 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:50.456633    6408 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:50.458155    6408 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:50.458429    6408 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:50.459853    6408 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:/etc/kubernetes$ k get po
E1213 09:32:53.629531    6442 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:53.630012    6442 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:53.631565    6442 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:53.631893    6442 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
E1213 09:32:53.633391    6442 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp 127.0.0.1:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01:/etc/kubernetes$ mkdir -p $HOME/.kube
node01:/etc/kubernetes$ cp /etc/kubernetes/manifests/admin.conf
cp: missing destination file operand after '/etc/kubernetes/manifests/admin.conf'
Try 'cp --help' for more information.
node01:/etc/kubernetes$ cp /etc/kubernetes/admin.conf .        
cp: cannot stat '/etc/kubernetes/admin.conf': No such file or directory
node01:/etc/kubernetes$ ls                   
kubelet.conf  manifests  pki
node01:/etc/kubernetes$ cat kubelet.conf 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUytlNHFCRmpjeEl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1UY3hPVEEwTURsYUZ3MHpOVEV4TVRVeE9UQTVNRGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURYbVpLaHBkTkRTRTVaT1JRU05wWTk4M01MZFJWWUROWERxWGlnME0rUDM1a2hObWJ6Qm1PeXpwM2QKVG1pWVRTNzBvK2tLRjlKWjZrQk9NbFVsdHljMVJVU094SmZ6MExvZENwRWlSc1BIbDUxaUp1aExZREFhSTBxeApxck1hcEVmUEYxc3ZhTHQycGh1bW9OdVV6MlQxUW90aks3akpBR0dSMVVoLzAzVEd4UnJLYVhha2xOUVpQTk1lCm1mS3dOa2NYbWNCRWY0YTNxWDY4M29RVHJTbTdJMGtQWGt4UHpmVXlyNkdrVjJKejdCWlNkRXhrUHd5Q29RM2UKSVZnVnd6em5DbVVjeTJOTXJnL3FoL3ZBM1ZvbENra3B4UkZzNVpDYmRFckJ2R28vV2RVeEQyWVBTdFRWZ2JJbQozdTJoVjVRcmp6bG9zOGErOFNKd1MxaUUwejg5QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTTnRvVkpad3J1SHMvbHZ5Q1dwckNaeVJZOHp6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hWM2Z4c2RHUwp3WXhQc3JkZzhPSnlUWGxiWlhyVEVsWndsWTJ5ZHVXQ0ZuY2o1dWhwRGpZWXJ0c1k0dDZBNUtZMmdERFFYRldpCncvbXp0Q2xSa1BReENVYnZFUXJQem9Db1lpTjV4S29PeFRxVU5qT004cmNZNk1HN1VYRVQ4bm1NV1lCRzQ2RXQKc1d1anEva3ZQU0ljSmpZNWVzdHppRXdlVjA3Vzc3N0hIY25aMlhVNHg0SVQzcmlYSmtZbHBIM1V1ZUpmalo4LwpoWFdCZnpiVEMyLzNCRDBZTy9BV1dacTN3M2l0dmF4dDFrTWhnS2wzWkpxZUkyZkIzcnEyZkljTmJRMHRBb2VoCkRkQ2Qza2VYOC9Md2RJZCsyWjR6U3JRQVBUN2FrQUo1ckFnTEpTS1VlSGtKMzNicERQb1FGVmFiSTZVVmZtYVkKaGI1M0ljOFB1NFNQCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://172.30.1.2:6443
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: default
    user: default-auth
  name: default-context
current-context: default-context
kind: Config
users:
- name: default-auth
  user:
    client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
    client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
node01:/etc/kubernetes$ export KUBECONFIG=/etc/kubernetes/kubelet.conf
node01:/etc/kubernetes$ k get po
Error from server (Forbidden): pods is forbidden: User "system:node:node01" cannot list resource "pods" in API group "" in the namespace "default": can only list/watch pods with spec.nodeName field selector
node01:/etc/kubernetes$ k get no
Error from server (Forbidden): nodes is forbidden: User "system:node:node01" cannot list resource "nodes" in API group "" at the cluster scope: node 'node01' cannot read all nodes, only its own Node object
node01:/etc/kubernetes$ k get  
You must specify the type of resource to get. Use "kubectl api-resources" for a complete list of supported resources.

error: Required resource not specified.
Use "kubectl explain <resource>" for a detailed description of that resource (e.g. kubectl explain pods).
See 'kubectl get -h' for help and examples
node01:/etc/kubernetes$ 