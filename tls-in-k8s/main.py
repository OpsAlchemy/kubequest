from certgen.ca import ensure_ca
from certgen.clients import generate_client_cert
from certgen.servers import generate_server_cert

# Step 1: Ensure CA exists
ensure_ca()

# Step 2: Generate client certificates
generate_client_cert("admin", "admin", "system:masters")
generate_client_cert("scheduler", "system:kube-scheduler", "system:kube-scheduler")
generate_client_cert("controller-manager", "system:kube-controller-manager", "system:kube-controller-manager")
generate_client_cert("kube-proxy", "system:kube-proxy", "system:node-proxier")
generate_client_cert("apiserver-etcd-client", "apiserver-etcd-client", "kubernetes")
generate_client_cert("apiserver-kubelet-client", "apiserver-kubelet-client", "kubernetes")
generate_client_cert("kubelet-client-node01", "system:node:node01", "system:nodes")

# Step 3: Generate server certificates
generate_server_cert(
    name="kube-apiserver",
    cn="kube-apiserver",
    san_dns=[
        "kubernetes", "kubernetes.default",
        "kubernetes.default.svc", "kubernetes.default.svc.cluster.local"
    ],
    san_ips=["10.96.0.1", "127.0.0.1"]
)

generate_server_cert(
    name="etcd",
    cn="etcd",
    san_ips=["127.0.0.1"]
)

generate_server_cert(
    name="kubelet-server-node01",
    cn="node01",
    san_dns=["node01"],
    san_ips=["192.168.56.101"]
)

print("\n[✓] All certificates generated.")
