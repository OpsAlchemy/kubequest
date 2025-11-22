1. ### CKA Practice Question

A Kubernetes cluster is already running and is accessible using `kubectl`. Complete the following tasks:

**Task 1: Create Deployments**

* Work in the namespace called `world`.
* Create a deployment named `asia` with exactly 2 replicas. The application must serve HTTP traffic and return the text response `hello, you reached ASIA`.
* Create another deployment named `europe` with exactly 2 replicas. The application must serve HTTP traffic and return the text response `hello, you reached EUROPE`.
* Ensure both deployments are created successfully and that their pods are running.

**Task 2: Expose Deployments as Services**

* Expose the `asia` deployment as a service of type `ClusterIP` on port 80. The service name must be `asia`.
* Expose the `europe` deployment as a service of type `ClusterIP` on port 80. The service name must be `europe`.
* Confirm that the services correctly forward traffic to their respective pods.

**Task 3: Configure Ingress**

* Create an Ingress resource named `world` in the `world` namespace.
* The Ingress must use the `nginx` ingress controller class.
* Configure routing rules so that:

  * Requests to the host `world.universe.mine` with the path `/asia` are routed to the `asia` service on port 80.
  * Requests to the host `world.universe.mine` with the path `/europe` are routed to the `europe` service on port 80.
* Verify that the Ingress resource is properly configured and points to the correct backend services.

**Task 4: Validate Traffic Routing**

* Send a request to `http://world.universe.mine:30080/asia` and confirm the response contains `hello, you reached ASIA`.
* Send a request to `http://world.universe.mine:30080/europe` and confirm the response contains `hello, you reached EUROPE`.

**Task 5: Verify Context and Namespace**

* Display the current Kubernetes context in use.
* Verify that the namespace associated with the current context is set to `world`.

Ref: https://killercoda.com/killer-shell-cka/scenario/ingress-create

2. Single Service Exposure (Basic Ingress)

* Create a Deployment `nginx-deploy` with image `nginx:1.21`, 3 replicas.
* Expose it as a Service `nginx-svc` on port 80 (ClusterIP).
* Create an Ingress `nginx-ingress` that routes all traffic from `/` to `nginx-svc`.
* Namespace: `default`.
* Validation:

  * Run `kubectl get ingress nginx-ingress` → verify `ADDRESS` is assigned.
  * Run `curl http://<ingress-ip>/` → should return the NGINX welcome page.

3. Path-Based Routing (Two Apps)**

* Deploy:

  * `api-deploy`: `hashicorp/http-echo:0.2.3` with `-text="API Response"`.
  * `ui-deploy`: `hashicorp/http-echo:0.2.3` with `-text="UI Response"`.
* Expose both as Services `api-svc` and `ui-svc`.
* Create Ingress `multi-app-ingress`:

  * `/api` → `api-svc:5678`
  * `/ui` → `ui-svc:5678`
* Validation:

  * `curl http://<ingress-ip>/api` → returns `API Response`.
  * `curl http://<ingress-ip>/ui` → returns `UI Response`.

4. Host-Based Routing**

* Deploy:

  * `red-app` → `hashicorp/http-echo` with `-text="Red App"`.
  * `blue-app` → `hashicorp/http-echo` with `-text="Blue App"`.
* Expose Services `red-svc` and `blue-svc`.
* Create Ingress `color-ingress`:

  * Host `red.example.com` → `red-svc`.
  * Host `blue.example.com` → `blue-svc`.
* Validation:

  * Add entries to `/etc/hosts` → `<ingress-ip> red.example.com blue.example.com`.
  * `curl -H "Host: red.example.com" http://<ingress-ip>` → returns `Red App`.
  * `curl -H "Host: blue.example.com" http://<ingress-ip>` → returns `Blue App`.

5. TLS-Enabled Ingress**

* Generate self-signed certs for `secure.example.com`.

  ```bash
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out tls.crt -keyout tls.key -subj "/CN=secure.example.com"
  kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
  ```
* Create an Ingress `secure-ingress`:

  * Host `secure.example.com` → `nginx-svc`.
  * Use TLS with `tls-secret`.
* Validation:

  * `curl -k https://secure.example.com --resolve "secure.example.com:<ingress-ip>"`
  * Response should be the NGINX welcome page.

6. Ingress with Default Backend**

* Deploy `default-backend` → `k8s.gcr.io/defaultbackend-amd64:1.5`.
* Expose it as `default-svc`.
* Update `multi-app-ingress`:

  * `/api` → `api-svc`.
  * `/ui` → `ui-svc`.
  * Any other path → `default-svc`.
* Validation:

  * `/api` → API Response.
  * `/ui` → UI Response.
  * `/foo` → returns Default backend.

7. Rewrite Target Example**

* Deploy `echo-app`: `hashicorp/http-echo -text="Echo Service"`.
* Expose as `echo-svc`.
* Create Ingress `rewrite-ingress` with:

  * Path `/foo(/|$)(.*)` → rewrite to `/\2` (using annotation `nginx.ingress.kubernetes.io/rewrite-target: /$2`).
* Validation:

  * `curl http://<ingress-ip>/foo/hello` → should return `"hello"`.

8. Multiple Hosts with TLS**

* Deploy:

  * `shop-app`: `hashicorp/http-echo -text="Shop Service"`.
  * `blog-app`: `hashicorp/http-echo -text="Blog Service"`.
* Expose Services `shop-svc`, `blog-svc`.
* Create two TLS secrets: `shop-tls`, `blog-tls`.
* Create Ingress `multi-host-ingress`:

  * `shop.example.com` → `shop-svc` (TLS `shop-tls`).
  * `blog.example.com` → `blog-svc` (TLS `blog-tls`).
* Validation:

  * `curl -k --resolve shop.example.com:<ip> https://shop.example.com` → Shop Service.
  * `curl -k --resolve blog.example.com:<ip> https://blog.example.com` → Blog Service.

9. Ingress with Custom Annotations (Rate Limit)**

* Deploy `rate-limited-app` → `nginx`.
* Expose as `rate-svc`.
* Create Ingress `rate-ingress` with annotation:

  * `nginx.ingress.kubernetes.io/limit-rps: "1"`.
* Validation:

  * Send 5 rapid requests:

    ```bash
    for i in {1..5}; do curl -s http://<ingress-ip>/; done
    ```
  * Some requests should be throttled (HTTP 503).

10. Canary Ingress (Traffic Splitting)**

* Deploy two versions:

  * `web-v1` → `hashicorp/http-echo -text="Web v1"`.
  * `web-v2` → `hashicorp/http-echo -text="Web v2"`.
* Expose Services `web-v1-svc` and `web-v2-svc`.
* Create Ingress `canary-ingress`:

  * Main Ingress sends all traffic to `web-v1-svc`.
  * Add a second Ingress with annotation `nginx.ingress.kubernetes.io/canary: "true"` and `nginx.ingress.kubernetes.io/canary-weight: "20"`.
* Validation:

  * Run 10 requests:

    ```bash
    for i in {1..10}; do curl -s http://<ingress-ip>/; done
    ```
  * \~20% should return `"Web v2"`.

11. Ingress with Multiple Paths and Different Services/Ports**

* Deploy two apps:

  * `metrics-app` (image: `prom/prometheus`) exposed on port **9090**.
  * `docs-app` (image: `httpd`) exposed on port **80**.
* Create an Ingress `mixed-ingress` with:

  * `/metrics` → `metrics-svc:9090`.
  * `/docs` → `docs-svc:80`.
* Validation:

  * `curl http://<ingress-ip>/metrics` shows Prometheus metrics.
  * `curl http://<ingress-ip>/docs` shows Apache index page.

12. Ingress in a Non-Default Namespace**

* Create a namespace `apps-ns`.
* Deploy `hello-app` (`hashicorp/http-echo -text="Hello App"`) into `apps-ns`.
* Expose it as `hello-svc`.
* Create an Ingress `hello-ingress` in `apps-ns` to expose `/hello`.
* Validation:

  * `kubectl get ingress -n apps-ns` shows rules.
  * `curl http://<ingress-ip>/hello` returns `Hello App`.

13. Ingress with Redirect to HTTPS**

* Deploy `nginx-secure-app`.
* Expose it via `secure-svc`.
* Create Ingress `https-redirect` with annotation:

  * `nginx.ingress.kubernetes.io/force-ssl-redirect: "true"`.
* Validation:

  * `curl -I http://<ingress-ip>/` should return `301 Moved Permanently` redirecting to HTTPS.

14. Ingress with ExternalName Service**

* Create an ExternalName Service `external-svc` pointing to `www.google.com`.
* Create Ingress `external-ingress` routing `/google` → `external-svc`.
* Validation:

  * `curl http://<ingress-ip>/google` returns Google HTML.

15. Ingress with Custom Error Pages**

* Deploy `error-app` (`nginx`).
* Expose as `error-svc`.
* Create Ingress `error-ingress` with annotation:

  * `nginx.ingress.kubernetes.io/custom-http-errors: "404,503"`.
* Deploy a custom backend (`hashicorp/http-echo -text="Custom Error"`) as `error-backend-svc`.
* Configure Ingress Controller to redirect 404/503 to `error-backend-svc`.
* Validation:

  * `curl http://<ingress-ip>/nonexistent` → returns `"Custom Error"`.

16. Ingress with Whitelist (IP Restriction)**

* Deploy `restricted-app` (`nginx`).
* Expose as `restricted-svc`.
* Create Ingress `restricted-ingress` with annotation:

  * `nginx.ingress.kubernetes.io/whitelist-source-range: "<your-ip>/32"`.
* Validation:

  * From your IP → `curl` should succeed.
  * From another pod (simulate with busybox) → request should be denied.

17. Ingress with Backend Timeout**

* Deploy `slow-app` (`hashicorp/http-echo -text="Slow Response" --delay=10s`).
* Expose as `slow-svc`.
* Create Ingress `timeout-ingress` with annotation:

  * `nginx.ingress.kubernetes.io/proxy-read-timeout: "5"`.
* Validation:

  * `curl -m 6 http://<ingress-ip>/` → should timeout.

18. Ingress with Weighted Load Balancing (Non-Canary)**

* Deploy two versions:

  * `v1-app` → `hashicorp/http-echo -text="Version 1"`.
  * `v2-app` → `hashicorp/http-echo -text="Version 2"`.
* Expose both.
* Create Ingress with annotation:

  * `nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"`.
* Validation:

  * Requests with same URI always go to same backend.
  * Different URIs distribute load across versions.


19. Ingress with gRPC Backend**

* Deploy a gRPC app (e.g., `grpc-hello-world`).
* Expose as `grpc-svc`.
* Create Ingress `grpc-ingress` with annotation:

  * `nginx.ingress.kubernetes.io/backend-protocol: "GRPC"`.
* Validation:

  * Use `grpcurl -plaintext <ingress-ip>:80 list` to query service.

20. CKA Practice — Gateway API (Traefik) 
A Kubernetes cluster is accessible via `kubectl`. Use **Gateway API** with **Traefik** (no Ingress) to complete the tasks below. Do not include commands or code — describe resources and expected outcomes.

1. **Namespace & workloads**

   * Namespace: `world`.
   * Deploy `asia` (2 replicas) serving HTTP; response body exactly `hello, you reached ASIA`.
   * Deploy `europe` (2 replicas) serving HTTP; response body exactly `hello, you reached EUROPE`.

2. **Services**

   * Create `ClusterIP` services `asia` and `europe`, each exposing port 80 and selecting their pods.

3. **GatewayClass & Gateway**

   * Create a `GatewayClass` implemented by Traefik.
   * Create a `Gateway` in namespace `world` named `world-gateway` that references the Traefik `GatewayClass`, listens HTTP port 80, and accepts host `world.universe.mine`.

4. **HTTPRoute(s)**

   * Create HTTPRoute(s) in namespace `world` attached to `world-gateway` that:

     * match host `world.universe.mine`;
     * route path prefix `/asia` → service `asia`:80;
     * route path prefix `/europe` → service `europe`:80.

5. **Validation**

   * Confirm Gateway and HTTPRoute status show Ready/Accepted by Traefik.
   * From the cluster entrypoint (or Traefik’s exposed address) request:

     * `http://world.universe.mine:30080/asia` → body contains `hello, you reached ASIA`.
     * `http://world.universe.mine:30080/europe` → body contains `hello, you reached EUROPE`.

6. **Context check**

   * Show current kubectl context and confirm its current namespace is `world`.

**Success criteria:** deployments have 2 ready replicas each, services forward to correct pods, Gateway/HTTPRoute are accepted by Traefik, and both HTTP endpoints return their exact expected responses.

21. Host-Based Routing

Create two Deployments: red ("red app") and blue ("blue app").

Expose as services red-svc and blue-svc.

Create a Gateway named color-gateway that listens on port 80 for hosts red.example.com and blue.example.com.

Create two HTTPRoute resources:

red-route → red-svc for Host: red.example.com.

blue-route → blue-svc for Host: blue.example.com.

Validate with curl using --resolve.

22. TLS-Enabled Gateway

Generate a self-signed TLS certificate for secure.example.com and store it in a secret secure-tls.

Deploy an nginx app and expose it as secure-svc.

Create a Gateway secure-gateway with a listener on port 443 (TLS) for secure.example.com.

Create an HTTPRoute secure-route mapping all traffic (/) to secure-svc.

Validate using curl -k --resolve secure.example.com:443:<gateway-ip> https://secure.example.com.

23. you need to migrate an existing Ingress for the api-demo application to the Gateway API. The application runs in namespace playground with:

Deployment: api-demo-deployment exposing container port 5000 (label app: api-demo)

Service: api-demo (ClusterIP) on port 5000 selecting app: api-demo

Convert the Ingress (host app.example.com, path /api(/|$)(.*), rewrite /api/$2) into Gateway API resources by:

Creating a Gateway using the cluster’s gatewayClassName, listening on HTTP port 80 for app.example.com.

Creating an HTTPRoute variant that forwards requests with /api intact to api-demo:5000.

Creating an HTTPRoute variant that strips /api before forwarding using URLRewrite.

Explaining the limitation that Gateway API supports prefix/full-path rewrites but not regex capture-group rewrites like nginx Ingress.

https://gateway-api.sigs.k8s.io/guides/http-redirect-rewrite/
---

24. Route with Multiple Matches

Deploy api (responds "API response") and ui ("UI response").

Expose as services api-svc, ui-svc.

Create multi-route with:

Path /api → api-svc.

Path /ui → ui-svc.

Attach multi-route to an existing gateway.

Validate /api and /ui.

25. Weighted Traffic Split

Deploy two versions of web: web-v1 ("v1") and web-v2 ("v2").

Expose as web-v1-svc, web-v2-svc.

Create a single HTTPRoute web-route:

80% traffic to web-v1-svc.

20% traffic to web-v2-svc.

Validate by sending multiple curl requests and checking distribution.

26. Route with Header-Based Matching

Deploy header-app ("Header matched!").

Expose as header-svc.

Create HTTPRoute header-route that only forwards traffic when header X-Env: test is present.

Validate:

curl -H "X-Env: test" http://<gateway-ip>/ → "Header matched!".

Without header → no route match.

27. TCP Gateway Route

Deploy a redis pod and expose as redis-svc on port 6379.

Create a Gateway tcp-gateway listening on port 6379 (protocol TCP).

Create a TCPRoute redis-route forwarding to redis-svc.

Validate connectivity using redis-cli -h <gateway-ip>.

28. Cross-Namespace Route Attachment

Create namespace team-a and team-b.

Deploy an app hello-a in team-a, expose as hello-a-svc.

Create a shared Gateway in team-b namespace.

Create an HTTPRoute in team-a namespace attaching to that gateway.

Validate that the app in team-a is exposed via the gateway in team-b.

29. (Rewrite target — Gateway API equivalent of your Ingress rewrite example)

HTTPRoute supports path rewrites via filters (URL rewrite / path prefix rewrite). Implement a Gateway-style rewrite scenario:

Task 1 — Deploy & Service

Namespace: rewrite-ns.

Deploy echo-app using hashicorp/http-echo (or any simple echo that returns the path) configured so responses include the request path or the request body. Example behavior expected: when backend receives path /hello it returns hello.

Expose as echo-svc on port 5678 (or port the echo image uses).

Task 2 — Gateway

Create a Gateway resource named rewrite-gw in rewrite-ns that listens on port 80 for host rewrite.example.com.

Task 3 — HTTPRoute with URLRewrite

Create an HTTPRoute named rewrite-route in rewrite-ns that:

attaches to rewrite-gw (use parentRefs).

matches path prefix /foo (so requests like /foo/hello match).

uses a URLRewrite (path rewrite) filter to strip the /foo prefix before forwarding to the backend. The intended rewrite behavior: /foo/hello → upstream path /hello.

forwards to echo-svc:5678.

Validation

curl --resolve rewrite.example.com:80:<gateway-ip> http://rewrite.example.com/foo/hello → backend should receive /hello and respond accordingly (e.g., hello).

curl --resolve rewrite.example.com:80:<gateway-ip> http://rewrite.example.com/foo/ → forwarded as / (or as configured).

Notes / Implementation hints

The Gateway API has canonical support for redirects and path rewrites via HTTPRoute filters (URL rewrite / path prefix rewrite). Many Gateway implementations (Envoy Gateway, Cilium Gateway, NGINX/Gateway API controllers, cloud providers) implement URLRewrite or equivalent. Use filters in the HTTPRoute rule to set path rewrite semantics. 
Kubernetes Gateway API
+1


29. Redirect HTTP → HTTPS using Gateway API

Gateway with two listeners: 80 (HTTP) and 443 (TLS).

HTTPRoute with a redirect filter on HTTP listener to redirect / → https://....

Validation: HTTP request returns 301 to HTTPS.

30. Request Header / Host Rewrite (host rewrite filter)

Deploy svc-a.

Create HTTPRoute that rewrites the Host header to an internal host expected by the backend (host rewrite filter).

Validation: backend sees rewritten host header (check logs/response).

31. Request Mirroring (traffic shadow)

Deploy primary and shadow apps; expose as primary-svc and shadow-svc.

Create HTTPRoute rule that forwards to primary and uses a mirror filter to mirror traffic to shadow.

Validation: primary responds; shadow receives mirrored requests (logs show mirrored hits).

32. Request Header Modifier (add/remove headers)

Deploy hdr-app that echoes request headers.

Create HTTPRoute that adds X-From-Gateway: true and removes X-Drop-Me before forwarding.

Validation: curl with header X-Drop-Me: yes and verify backend sees only X-From-Gateway.

33. Path Prefix Stripping + Upstream Path Replace

Deploy service-a expecting upstream path /app/.

Create HTTPRoute that matches /app-a(/|$)(.*) and rewrites to /app/$2 before forwarding.

Validation: curl /app-a/metrics forwarded as /app/metrics upstream.

34. Per-route Timeouts and Retries (filters)

Deploy slow-app that sleeps for 8s then responds.

Create HTTPRoute with filter-level timeout = 5s and retry policy = 1 retry with 2s per try.

Validation: first request times out at gateway, or gateway retries per configured policy.

35. Weighted Canary using two HTTPRoutes and canary annotation/filter

Use one primary HTTPRoute for v1 and a second HTTPRoute with a canary label or specific weights (depends on controller) to send 10% traffic to v2.

Validation: multiple requests show ~10% to v2.

36. ExternalName backend via HTTPRoute (forward to external DNS)

Create Service of type ExternalName pointing to api.external.local.

Create HTTPRoute forwarding /ext to this service.

Validation: requests to /ext reach the external host.

