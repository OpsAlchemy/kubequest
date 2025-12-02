# Network Policy
37. https://killercoda.com/sachin/course/CKA/network-policy

my-app-deployment and cache-deployment deployed, and my-app-deployment deployment exposed through a service named my-app-service . Create a NetworkPolicy named my-app-network-policy to restrict incoming and outgoing traffic to my-app-deployment pods with the following specifications:

    Allow incoming traffic only from pods.
    Allow incoming traffic from a specific pod with the label app=trusted
    Allow outgoing traffic to pods.
    Deny all other incoming and outgoing traffic.

38. Multi-tier isolation for acme-three-tier

Namespace: production
Application name: acme-three-tier (three deployments: frontend, backend, database)
Labels:

- Frontend pods: app=acme, tier=frontend
- Backend pods: app=acme, tier=backend
- Database pods: app=acme, tier=database

Revised Requirements:
Frontend (ingress)

- Allow ingress to frontend pods only from the cluster ingress/load-balancer (for example, the Ingress controller) and from other frontend pods (intra-tier).

- Deny ingress from backend pods and from any other namespaces/pods.

Backend (ingress)

- Allow ingress to backend pods only from frontend pods in the production namespace and from other backend pods (intra-tier).

- Do not allow general access from other namespaces or from database pods (unless you explicitly require a reverse/management path — see note).

Database (ingress)

- Allow ingress to database pods only from backend pods in the production namespace on TCP port 5432 (Postgres).

- Deny ingress from frontend pods and from all other sources.

Intra-tier communication

- Preserve same-tier communication: pods that share the same tier label must be able to talk to each other (frontend↔frontend, backend↔backend, database↔database).

Egress

Do not apply any egress restrictions as part of this task; pods may make outbound connections unless you add explicit egress NetworkPolicies later.

39. ## **Task: Multi-Tenant SaaS Platform Network Isolation**

### **Setup**
**Namespaces:**
- `tenant-a` - Company Alpha
- `tenant-b` - Company Beta  
- `shared-services` - Platform services

**Applications in each tenant namespace:**
- `web-app` (nginx:alpine) - labels: `app=web, tenant=alpha`
- `backend` (node:18-alpine) - labels: `app=api, tenant=alpha` 
- `database` (postgres:15) - labels: `app=database, tenant=alpha`

**Shared services:**
- `auth-service` (go:1.21) - labels: `app=auth, shared=true`
- `notification` (python:3.11) - labels: `app=notifications, shared=true`

### **Requirements**

**What MUST work:**
- Web-app can talk to backend (same tenant)
- Backend can talk to database (same tenant)
- Backend can talk to auth-service and notification service

**What MUST be blocked:**
- Any communication between tenant-a and tenant-b
- Web-app cannot talk directly to shared services
- Shared services cannot talk to each other
- Shared services cannot initiate connections to tenants

### **Test this by:**
1. Deploy all applications in correct namespaces
2. Create NetworkPolicies to enforce the rules
3. Verify allowed connections work
4. Verify blocked connections are actually blocked

**Goal:** Complete isolation between tenants while allowing controlled access to shared services. 

40. Basic Default Deny
You want to create a "default deny all" rule for all pods in the production namespace. No pod should be able to communicate with any other pod. Write the NetworkPolicy YAML to achieve this.

41. Your api pods (label app: api) in the backend namespace need to receive traffic only from the frontend pods (label app: frontend) within the same namespace. All other incoming traffic should be blocked. Write the NetworkPolicy for the api pods.

42. A cache pod (label app: redis) should only:
Accept incoming connections on port 6379 from app pods (label app: api).
Initiate outgoing connections only to a specific external time server (NTP) at time.example.com on UDP port 123.
Write a single NetworkPolicy that implements both of these requirements.

43. Create a NetworkPolicy in the namespace secure-app that denies all incoming and outgoing traffic to all Pods. This is the first step in implementing a zero-trust model.

44. In the frontend namespace, you have Pods labeled app=frontend. Create a NetworkPolicy that allows these Pods to receive traffic only from Pods labeled app=backend in the same namespace. Deny all other ingress.

45. Your Pods need to perform DNS lookups. Create a NetworkPolicy that allows all Pods in the default namespace to egress to the Kubernetes DNS service (port 53 UDP) on the kube-system namespace, but to no other destinations.

46. You have a Pod labeled app=api-server that exposes two ports: 80 for HTTP and 443 for HTTPS. Write a NetworkPolicy that allows ingress to this Pod on both ports from any Pod in the cluster, but denies ingress on any other port.

47. Task: Prevent all Pods in the tenant-a namespace from communicating with any Pods in the tenant-b namespace. Pods within each namespace should still be able to talk to each other. INTERESTING QUESTION!!

48. Create a NetworkPolicy that allows Pods with label app=isolated to only send DNS queries to the cluster DNS service IP and nothing else.
- kubectl get svc -n kube-system kube-dns -o jsonpath='{.spec.clusterIP}'

49. Create a NetworkPolicy that blocks all Pods in namespace-a from communicating with Pod IPs in namespace-b.
- kubectl get pods -n namespace-b -o wide

50. Namespace tenant-a and tenant-b:
    Deny all cross-namespace pod communication.
    Allow intra-namespace communication.
Exception: pods in tenant-a with label role=auditor may query tenant-b pods on port 443.

51. Multi-Tier Application Segmentation

You have three tiers:
    frontend (label: tier=frontend)
    backend (label: tier=backend)
    database (label: tier=database)

Rules:
    Frontend → Backend only on port 8080.
    Backend → Database only on port 5432.
    No direct frontend → database.
Deny all else.

52. Egress Control with External Services

Pods in namespace payments:
    Can call external payment gateway (203.0.113.25/32) on TCP 443.
    Can query DNS (UDP 53).
Everything else (internet + cluster traffic) denied.

53. Task 1: Multi-Tier Application Network Isolation
Create a complete 3-tier application setup with strict network policies:

Deploy frontend (nginx), backend (API server), and database (mysql) pods in separate namespaces
Implement network policies so that:

Frontend can only communicate with backend on port 8080
Backend can only communicate with database on port 3306
Database accepts connections only from backend
No other inter-namespace communication is allowed
External traffic can reach frontend on port 80 only


Test connectivity between all components and verify isolation