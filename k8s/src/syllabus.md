Here’s how you can find the **exact topics** covered in the **2025 Certified Kubernetes Administrator (CKA)** exam, based on the **official sources**:

---

## Official CKA Curriculum Overview (Post-Feb 18, 2025)

According to the **Linux Foundation / CNCF**, the CKA exam domains and their weightage remain officially established as:

* **Cluster Architecture, Installation & Configuration** – 25%
* **Workloads & Scheduling** – 15%
* **Services & Networking** – 20%
* **Storage** – 10%
* **Troubleshooting** – 30% ([CNCF][1], [Linux Foundation - Education][2])

After the **February 18, 2025** update, each domain now includes an enhanced list of competencies:

**Cluster Architecture, Installation & Configuration (25%)**

* Manage RBAC
* Prepare infrastructure
* Create/manage clusters via kubeadm
* Cluster lifecycle management
* Implement highly available control planes
* Use Helm and Kustomize for component installation
* Understand CNI, CSI, CRI extensions
* Work with CRDs and operators ([Linux Foundation - Education][2])

**Workloads & Scheduling (15%)**

* Application deployments, rolling updates, rollbacks
* ConfigMaps and Secrets for app configuration
* Autoscaling (HPA/VPA)
* Replicasets, Deployments, StatefulSets, DaemonSets — robust, self-healing workloads
* Pod admission and scheduling (resource limits, affinity, priority) ([Linux Foundation - Education][2])

**Services & Networking (20%)**

* Pod-to-Pod connectivity
* Network Policies
* Service types: ClusterIP, NodePort, LoadBalancer
* Gateway API for Ingress traffic management
* Ingress controllers/resources
* CoreDNS setup & usage ([Linux Foundation - Education][2])

**Storage (10%)**

* StorageClasses and dynamic provisioning
* Volume types, access modes, and reclaim policies
* PersistentVolumes (PV) and PersistentVolumeClaims (PVC) ([Linux Foundation - Education][2])

**Troubleshooting (30%)**

* Troubleshoot clusters and nodes
* Troubleshoot control plane components
* Monitor resource usage (cluster and application)
* Inspect container output streams (logs, events)
* Troubleshoot networking and services ([Linux Foundation - Education][2])

---

## Where to Access the Official, Detailed Curriculum

1. **CNCF / Linux Foundation Official CKA Page**
   This includes domain weights and basic curriculum overview: ([CNCF][1], [Linux Foundation - Education][3])

2. **CNCF Curriculum Repository (GitHub)**
   You can directly access the full, version-specific CKA curriculum document, such as the **CKA\_Curriculum\_v1.33.pdf** — this is the canonical, downloadable outline of all topics, subtopics, and competencies: ([GitHub][4])

3. **Program Changes (February 18, 2025 Official Announcement)**
   Detailed competencies within each domain are explicitly listed here: ([Linux Foundation - Education][2])

---

## Steps You Can Follow Right Now

* **Visit the official CKA page** on the CNCF or Linux Foundation site to confirm domains and syllabus.
* **Download the CKA\_Curriculum PDF** from the **cncf/curriculum GitHub repo** — this provides the most comprehensive and precise topic breakdown for your targeted Kubernetes version.
* **Study** domain-wise — paying special attention to new additions post-February 18, 2025 (e.g., Gateway API, Helm & Kustomize, advanced autoscaling concepts).

---

Would you like me to **open the curriculum PDF** from the CNCF GitHub or help you explore any specific domain in more detail (like "Services & Networking" or "Workloads & Scheduling")? Just let me know!

[1]: https://www.cncf.io/training/certification/cka/?utm_source=chatgpt.com "Certified Kubernetes Administrator (CKA)"
[2]: https://training.linuxfoundation.org/certified-kubernetes-administrator-cka-program-changes/?utm_source=chatgpt.com "Certified Kubernetes Administrator (CKA) Program Changes"
[3]: https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/?utm_source=chatgpt.com "Certified Kubernetes Administrator (CKA)"
[4]: https://github.com/cncf/curriculum?utm_source=chatgpt.com "Open Source Curriculum for CNCF Certification Courses"
