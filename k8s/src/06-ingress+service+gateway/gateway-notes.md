Of course. Here are practical, code-centric notes on the Kubernetes Gateway API.

***

### **Kubernetes Gateway API: Practical Implementation**

**Prerequisites:**
*   A Kubernetes cluster (v1.24+ recommended for full stability).
*   `kubectl` configured to talk to your cluster.
*   An installed Gateway API controller. Common options include:
    *   Istio
    *   NGINX Kubernetes Gateway
    *   Emissary-ingress
    *   HAProxy Ingress
    *   Cilium
    *   KONG

*These examples assume an NGINX Gateway controller is installed. Always check your specific controller's documentation for any nuances.*

---

### **1. Installing the Gateway API CRDs**

The first step is to install the Gateway API definitions themselves. Many controllers bundle these, but you can also install them directly.

```bash
# Install the core Gateway API CRDs (Custom Resource Definitions)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# Verify the CRDs are installed
kubectl get crd gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io
```

---

### **2. Example 1: Basic HTTP Routing**

This example mirrors a simple Ingress, routing traffic for a hostname to a service.

**a) Deploy a Sample Application**
```yaml
# app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Apply it: `kubectl apply -f app-deployment.yaml`

**b) Define the Infrastructure (GatewayClass & Gateway)**
The Cluster Admin or Operator typically creates this. It defines the entry point.

```yaml
# gateway-resource.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: company-gateway
  namespace: default # Gateway is often in a shared namespace like 'infra'
spec:
  gatewayClassName: nginx # Must match a installed GatewayClass
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same # Allows HTTPRoutes from the SAME namespace as the Gateway
# 'from: All' would allow from any namespace
```

Apply it: `kubectl apply -f gateway-resource.yaml`

**Check the status. The controller should provision an external IP/LB.**
```bash
kubectl get gateway company-gateway
```
Output will show the address once provisioned:
```
NAME              CLASS    ADDRESS         READY
company-gateway   nginx    192.0.2.100     True
```

**c) Define the Application Routing (HTTPRoute)**
The Application Developer creates this to define how their app is reached.

```yaml
# web-app-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-app-route
  namespace: default # Must be allowed by the Gateway's namespace selector
spec:
  parentRefs:
  - name: company-gateway # Attaches this route to our Gateway
    namespace: default
  hostnames:
  - "web.example.com" # The virtual hostname to match
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-app-service # The Kubernetes Service to route to
      port: 80
```

Apply it: `kubectl apply -f web-app-route.yaml`

**Test the configuration:**
```bash
# Use the Gateway's ADDRESS and the hostname from the HTTPRoute
curl -H "Host: web.example.com" http://192.0.2.100
```

---

### **3. Example 2: Advanced Routing (Header-Based & Traffic Splitting)**

This shows the expressive power beyond basic Ingress.

**a) Deploy Two Application Versions (v1 and v2)**
```yaml
# canary-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: canary-app
      version: v1
  template:
    metadata:
      labels:
        app: canary-app
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: canary-app
      version: v2
  template:
    metadata:
      labels:
        app: canary-app
        version: v2
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        # In a real scenario, this would be a different image/version
        command: ['/bin/sh', '-c', 'echo "Hello from V2!" > /usr/share/nginx/html/index.html && nginx -g "daemon off;"']
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: canary-service
spec:
  selector:
    app: canary-app # Selects pods from both v1 and v2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Apply it: `kubectl apply -f canary-deployment.yaml`

**b) Create a Complex HTTPRoute**
This route will:
1.  Send all internal users (with a specific header) to the new v2 version.
2.  Split all other traffic 80% to v1 and 20% to v2.

```yaml
# canary-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
  - name: company-gateway
  hostnames:
  - "canary.example.com"
  rules:
  # Rule 1: Header-based match for internal testing
  - matches:
    - headers:
      - name: env
        value: internal
    backendRefs:
    - name: canary-service
      port: 80
      filters:
      - type: RequestHeaderModifier
        requestHeaderModifier:
          set:
          - name: version
            value: v2 # Adds a header to the request before sending it upstream
  # Rule 2: Default traffic splitting (canary release)
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: canary-service
      port: 80
      weight: 80 # 80% of traffic
      filters:
      - type: RequestHeaderModifier
        requestHeaderModifier:
          set:
          - name: version
            value: v1
    - name: canary-service
      port: 80
      weight: 20 # 20% of traffic
      filters:
      - type: RequestHeaderModifier
        requestHeaderModifier:
          set:
          - name: version
            value: v2
```

Apply it: `kubectl apply -f canary-route.yaml`

**Test the configuration:**
```bash
# Test the header-based rule (should be directed to v2 logic)
curl -H "Host: canary.example.com" -H "env: internal" http://192.0.2.100

# Test the weighted rule. Run multiple times to see the distribution.
curl -H "Host: canary.example.com" http://192.0.2.100
```

### **Key Commands for Inspection & Debugging**

```bash
# Get a high-level status of all Gateway resources
kubectl get gateways -A

# Describe a Gateway to see its listeners and status conditions
kubectl describe gateway <gateway-name> -n <namespace>

# List all HTTPRoutes and see which Gateway they are attached to
kubectl get httproutes -A

# See detailed status and potential errors on an HTTPRoute
kubectl describe httproute <route-name> -n <namespace>

# Check the logs of your Gateway controller pod for detailed processing info
kubectl logs -n <controller-namespace> <controller-pod-name>
```









Of course. Here are more diverse and advanced examples showcasing the power of the Kubernetes Gateway API.

***

### **Kubernetes Gateway API: Advanced Examples**

This section builds upon the previous examples, assuming a Gateway named `company-gateway` and a controller are already installed.

---

### **Example 3: Cross-Namespace Routing**

This demonstrates how a central platform team can manage the Gateway while application teams manage their own routes.

**a) Cluster Admin creates a Gateway allowing routes from specific namespaces.**
```yaml
# gateway-cross-ns.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: infra-team-ns # Gateway lives in a dedicated infra namespace
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Selector # Allows routes only from namespaces with a specific label
        selector:
          matchLabels:
            shared-gateway-access: "true"
```

Apply and label a namespace:
```bash
kubectl create namespace app-team-a
kubectl label namespace app-team-a shared-gateway-access=true

kubectl create namespace infra-team-ns
kubectl apply -f gateway-cross-ns.yaml -n infra-team-ns
```

**b) App Team A deploys their service in their own namespace.**
```yaml
# app-team-a/web-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: app-team-a
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: app-team-a
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
`kubectl apply -f web-app.yaml -n app-team-a`

**c) App Team A creates an HTTPRoute in THEIR namespace, attaching to the central Gateway.**
Note the `parentRef` specifies the namespace of the Gateway.
```yaml
# app-team-a/route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: team-a-route
  namespace: app-team-a # Route is in the app team's namespace
spec:
  parentRefs:
  - name: shared-gateway   # Name of the Gateway
    namespace: infra-team-ns # Namespace where the Gateway lives
  hostnames:
  - "team-a.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-app-service
      port: 80
      namespace: app-team-a # Critical: The backendRef must also specify its namespace
```
`kubectl apply -f route.yaml -n app-team-a`

---

### **Example 4: TLS Termination & HTTPS Listener**

**a) Create a Kubernetes Secret holding a TLS private key and certificate.**
*(For testing, you can use a self-signed cert. In production, use cert-manager with Let's Encrypt)*
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout tls.key -out tls.crt \
    -subj "/CN=secure.example.com/O=Example Org"

kubectl create secret tls example-com-tls --cert=tls.crt --key=tls.key -n infra-team-ns
```

**b) Update the Gateway listener to support HTTPS.**
```yaml
# gateway-https.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: infra-team-ns
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            shared-gateway-access: "true"
  # New HTTPS Listener
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate # Gateway will terminate TLS
      certificateRefs:
      - kind: Secret
        name: example-com-tls # Reference the secret created above
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            shared-gateway-access: "true"
```
`kubectl apply -f gateway-https.yaml -n infra-team-ns`

**c) Create an HTTPRoute that uses the HTTPS listener.**
The route itself doesn't change; the protocol is handled by the Gateway listener.
```yaml
# app-team-a/route-https.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: team-a-https-route
  namespace: app-team-a
spec:
  parentRefs:
  - name: shared-gateway
    namespace: infra-team-ns
    sectionName: https # Explicitly attach to the 'https' listener
  hostnames:
  - "secure.example.com" # Must match the CN in the TLS certificate
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-app-service
      port: 80
      namespace: app-team-a
```
`kubectl apply -f route-https.yaml -n app-team-a`

---

### **Example 5: TCP Traffic (Non-HTTP)**

This example routes raw TCP traffic, like for a database or custom TCP service, using a `TCPRoute`.

**a) Deploy a simple TCP echo server.**
```yaml
# tcp-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tcp-echo-server
  namespace: app-team-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tcp-echo-server
  template:
    metadata:
      labels:
        app: tcp-echo-server
    spec:
      containers:
      - name: echo
        image: hashicorp/tcp-echo:1.2
        args: ["-listen", ":8080"]
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tcp-echo-service
  namespace: app-team-b
spec:
  selector:
    app: tcp-echo-server
  ports:
    - protocol: TCP
      port: 27017 # External port exposed by the Gateway
      targetPort: 8080 # Port the pod is listening on
```

**b) Create a TCPRoute resource.**
Note: Not all Gateway controllers support `TCPRoute`. Check your provider's documentation.
```yaml
# tcp-route.yaml
apiVersion: gateway.networking.k8s.io/v1alpha2 # Note: TCPRoute was alpha2 at last major release
kind: TCPRoute
metadata:
  name: mongo-tcp-route
  namespace: app-team-b
spec:
  parentRefs:
  - name: shared-gateway
    namespace: infra-team-ns
  rules:
  - backendRefs:
    - name: tcp-echo-service
      port: 27017 # The Service port to forward traffic to
      namespace: app-team-b
```
`kubectl apply -f tcp-route.yaml -n app-team-b`

**Test the TCP connection:**
```bash
# Get the Gateway's external IP
GATEWAY_IP=$(kubectl get gateway -n infra-team-ns shared-gateway -o jsonpath='{.status.addresses[0].value}')

# Use netcat or telnet to test the raw TCP connection
echo "Hello Gateway API" | nc $GATEWAY_IP 27017
```

---

### **Example 6: Request Redirect & URL Rewrite**

This uses filters to modify requests before they are forwarded.

**a) Redirect HTTP to HTTPS automatically.**
```yaml
# http-to-https-redirect.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http-redirect
  namespace: infra-team-ns
spec:
  parentRefs:
  - name: shared-gateway
    namespace: infra-team-ns
    sectionName: http # Attach to the HTTP listener
  hostnames:
  - "secure.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    filters:
    - type: RequestRedirect
      requestRedirect:
        scheme: https # Change the scheme
        port: 443    # Change the port
        statusCode: 301 # Permanent redirect
```
`kubectl apply -f http-to-https-redirect.yaml -n infra-team-ns`

**b) Rewrite the path before forwarding the request.**
```yaml
# url-rewrite.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: rewrite-path-route
  namespace: app-team-a
spec:
  parentRefs:
  - name: shared-gateway
    namespace: infra-team-ns
  hostnames:
  - "api.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1/old-api/
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /v2/new-api/ # Changes /v1/old-api/users to /v2/new-api/users
    backendRefs:
    - name: web-app-service
      port: 80
      namespace: app-team-a
```
`kubectl apply -f url-rewrite.yaml -n app-team-a`














Here are clean, structured notes on **Gateway API in Kubernetes**, formatted properly with explanations and coding examples.

---

# Gateway API in Kubernetes

## What is Gateway API

* Gateway API is the evolution of Kubernetes Ingress.
* It provides a **more expressive, role-oriented, and extensible** way to manage north-south (external) and east-west (internal) traffic.
* It introduces new resources:

  * **GatewayClass**: Defines the type of Gateway (implementation by a controller like NGINX, Istio, or Envoy).
  * **Gateway**: An instance of a GatewayClass, representing a load balancer or proxy.
  * **HTTPRoute**, **TCPRoute**, **UDPRoute**, **TLSRoute**, **GRPCRoute**: Define how traffic is routed to backends.
  * **ReferenceGrant**: Grants permission for cross-namespace references.

---

## Why Gateway API

* Ingress was limited: mostly HTTP-only, lacked role separation, hard to extend.
* Gateway API allows:

  * Multiple protocols (HTTP, TCP, UDP, gRPC).
  * Clear separation of roles between **infrastructure providers** and **application developers**.
  * Stronger extensibility through CRDs and standardization.

---

## Core Resources Overview

1. **GatewayClass**
   Defines a class of Gateways managed by a controller. Similar to `StorageClass` in storage.

2. **Gateway**
   Represents a request for a load balancer or proxy instance. Binds listeners to routes.

3. **Routes (HTTPRoute, TCPRoute, etc.)**
   Attach to Gateways, defining how requests are matched and forwarded to backends.

4. **ReferenceGrant**
   Allows cross-namespace references for security and isolation.

---

## Example: Basic HTTP Gateway

### GatewayClass

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s.io/ingress-nginx
```

### Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same
```

### HTTPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: default
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: app-service
      port: 80
```

Explanation:

* `GatewayClass` defines NGINX as the implementation.
* `Gateway` creates a gateway called `web-gateway` with an HTTP listener on port 80.
* `HTTPRoute` matches `/app` and sends traffic to `app-service`.

---

## Example: Cross-Namespace Routing with ReferenceGrant

Namespace: `frontend` has the Gateway.
Namespace: `backend` has the Service.

**ReferenceGrant in backend namespace**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: ReferenceGrant
metadata:
  name: allow-frontend-to-backend
  namespace: backend
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: frontend
  to:
  - group: ""
    kind: Service
```

**HTTPRoute in frontend namespace**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: frontend
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - backendRefs:
    - name: backend-service
      namespace: backend
      port: 80
```

This setup allows a frontend Gateway to route traffic to a backend Service in a different namespace, securely enabled by ReferenceGrant.

---

## Key Advantages

* Multi-protocol support (HTTP, TCP, UDP, gRPC, TLS).
* Role-oriented design: infra team manages GatewayClasses and Gateways, app team manages Routes.
* Better separation of concerns than Ingress.
* Security and flexibility with ReferenceGrants.
* Consistent APIs across different implementations (NGINX, Istio, Envoy, Cilium, etc.).

---

Would you like me to extend these notes with a **side-by-side comparison of Ingress vs Gateway API** so you can easily see where Gateway improves?




















Here’s a full set of **Gateway API notes with a wide range of coding examples** to help you master it. No emojis, no break lines, just structured content.

---

# Gateway API Notes

## Core Concepts

* **GatewayClass**: Defines a type of Gateway (like ingress controller type).
* **Gateway**: Defines how traffic enters the cluster, binds listeners to routes.
* **Route Types**: Define how traffic is matched and sent to backends (HTTPRoute, TCPRoute, UDPRoute, TLSRoute, GRPCRoute).
* **ReferenceGrant**: Enables safe cross-namespace service references.

---

## Example 1: Basic HTTP Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
  namespace: default
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: app-service
      port: 80
```

---

## Example 2: HTTPS Gateway with TLS Termination

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: https-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - name: tls-secret
    allowedRoutes:
      namespaces:
        from: Same
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: secure-route
  namespace: default
spec:
  parentRefs:
  - name: https-gateway
  rules:
  - matches:
    - path:
        type: Exact
        value: /secure
    backendRefs:
    - name: secure-service
      port: 443
```

---

## Example 3: Multiple Listeners (HTTP and HTTPS)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: multi-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
  - name: https
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - name: multi-tls-secret
```

---

## Example 4: Multiple Backends with Traffic Splitting

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
  namespace: default
spec:
  parentRefs:
  - name: multi-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: app-v1
      port: 80
      weight: 80
    - name: app-v2
      port: 80
      weight: 20
```

This sends 80% of traffic to app-v1 and 20% to app-v2.

---

## Example 5: Hostname Based Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: host-based-route
  namespace: default
spec:
  parentRefs:
  - name: my-gateway
  hostnames:
  - "api.example.com"
  - "shop.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: api-service
      port: 80
```

---

## Example 6: TCP Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: tcp-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: tcp-listener
    port: 3306
    protocol: TCP
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: TCPRoute
metadata:
  name: mysql-route
  namespace: default
spec:
  parentRefs:
  - name: tcp-gateway
  rules:
  - backendRefs:
    - name: mysql-service
      port: 3306
```

---

## Example 7: UDP Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: udp-gateway
  namespace: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: udp-listener
    port: 53
    protocol: UDP
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: UDPRoute
metadata:
  name: dns-route
  namespace: default
spec:
  parentRefs:
  - name: udp-gateway
  rules:
  - backendRefs:
    - name: dns-service
      port: 53
```

---

## Example 8: Cross-Namespace Routing with ReferenceGrant

In namespace `frontend` you have Gateway and Route, backend Service is in `backend` namespace.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: ReferenceGrant
metadata:
  name: allow-frontend-to-backend
  namespace: backend
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: frontend
  to:
  - group: ""
    kind: Service
```

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: frontend
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - backendRefs:
    - name: backend-service
      namespace: backend
      port: 80
```

---

## Example 9: GRPC Routing

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-route
  namespace: default
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - method:
        service: com.example.MyService
        method: GetData
    backendRefs:
    - name: grpc-service
      port: 50051
```

---

## Example 10: Weighted Hostname Based Split

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: split-host-route
  namespace: default
spec:
  parentRefs:
  - name: my-gateway
  hostnames:
  - "beta.example.com"
  rules:
  - backendRefs:
    - name: beta-service
      port: 80
      weight: 50
    - name: stable-service
      port: 80
      weight: 50
```

---

## Key Takeaways

* Gateway API extends Ingress to multiple protocols.
* Separation of responsibility: infra team manages GatewayClasses and Gateways, app team manages Routes.
* Can express traffic policies like host-based, path-based, weighted routing, TLS, and cross-namespace routing.
* Secure delegation via ReferenceGrant.
* Flexible and consistent API across multiple implementations (NGINX, Istio, Envoy, Cilium).

---

Do you want me to also create a **Ingress vs Gateway API side-by-side comparison with examples** so you can directly contrast both?









