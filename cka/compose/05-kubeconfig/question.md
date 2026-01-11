# Kubeconfig & Kubernetes PKI - Practical Challenges

Hands-on exercises for mastering Kubernetes certificate management and kubeconfig operations. All scenarios use kind clusters.

---

## Challenge 1: Certificate Analysis in Running Cluster

Create a kind cluster and investigate its PKI infrastructure.

**What you need to do:**

1. Create a kind cluster named `cka-cluster`
2. Find all certificate files in the cluster's PKI directory
3. Determine the CN (Common Name) of the cluster CA
4. Verify whether the CA certificate is self-signed
5. Check what the API server certificate's issuer is
6. Extract the CA certificate from your kubeconfig and verify its validity dates
7. Calculate how many days until the CA certificate expires
8. List all DNS names that the API server certificate is valid for
9. List all IP addresses that the API server certificate is valid for
10. Explain why multiple DNS names and IPs are needed in the API server certificate

**Deliverables:**

- Write a script that extracts and prints:
  - Certificate validity dates
  - Certificate CN
  - Days until expiration
  - All SANs (DNS names and IPs)
  - Whether cert is self-signed
  
**Success criteria:**

- Your script runs without errors
- Output is human-readable and formatted
- You understand why each certificate component matters

---

## Challenge 2: Multi-Cluster Kubeconfig Management

Manage three separate kind clusters with merged kubeconfigs.

**What you need to do:**

1. Create three kind clusters: `prod-cluster`, `staging-cluster`, `dev-cluster`
2. Get individual kubeconfigs for each cluster
3. Merge all three kubeconfigs into a single file
4. Create separate contexts for each cluster, each pointing to a different default namespace:
   - prod-cluster → production namespace
   - staging-cluster → staging namespace
   - dev-cluster → development namespace
5. Switch between contexts and verify that the active namespace changes
6. Write a function that lets you interactively select and switch to any context
7. Display current cluster, user, and namespace information after each switch
8. Make the function persistent so it loads every time you open a shell

**Deliverables:**

- Merged kubeconfig file
- Function in your shell rc file
- Demonstrate switching between all three clusters

**Success criteria:**

- All contexts work without errors
- Switching contexts changes both the active cluster and namespace
- Function shows context info after switching

---

## Challenge 3: Create Users Using Kubernetes CSR API

Provision three new users with certificate-based authentication using the Kubernetes CSR API.

**User specifications:**

- User 1: `alice` with group `developers` - needs read-only pod access
- User 2: `bob` with group `developers` - needs read-only pod access
- User 3: `admin-carol` with group `kubeadm:cluster-admins` - needs full cluster admin

**What you need to do:**

1. Generate private key for each user
2. Create a certificate signing request for each user with proper CN and Organization fields
3. Submit each CSR to the Kubernetes API as a CertificateSigningRequest object
4. Approve the CSRs
5. Extract the signed certificates from Kubernetes
6. Add each user to your kubeconfig
7. Create contexts for each user
8. Apply RBAC permissions so developers can only view pods and admin has full access
9. Test that alice can list pods but cannot delete them
10. Test that admin-carol can delete pods
11. Test that alice cannot access nodes or other resources

**Deliverables:**

- Three working user contexts in kubeconfig
- RBAC permissions applied correctly
- Test results showing permission enforcement

**Success criteria:**

- All users can authenticate
- Permissions match the intended roles
- Developer users are restricted, admin user has full access

---

## Challenge 4: Build a User Provisioning Automation Script

Create a fully automated script that provisions a complete user with certificate and RBAC.

**Script must:**

1. Accept username, group, and cluster as arguments
2. Generate a private key
3. Create a CSR with the specified CN and Organization
4. Submit CSR to Kubernetes
5. Wait for CSR approval (manual or automatic)
6. Extract the signed certificate
7. Configure the user's kubeconfig
8. Create appropriate RBAC rolebindings based on the group
9. Test authentication by attempting to list pods
10. Output clear messages showing each step
11. Save the private key with restrictive permissions
12. Generate a warning about key security

**Test your script:**

- Provision 3 different users with different groups
- Verify each user context works
- Verify permissions are enforced

**Deliverables:**

- Single script file that handles complete provisioning
- Usage documentation (how to run the script)
- Script output showing all 10+ steps

**Success criteria:**

- Script runs without manual intervention (except CSR approval)
- All users are properly configured and have correct permissions
- Script output is clear and useful for understanding what happened

---

## Challenge 5: Troubleshoot Certificate Mismatches

You have a certificate problem to solve.

**Scenario 1: Connection fails with certificate signed by unknown authority**

Your developer cannot connect to the cluster. They're getting an error about the certificate not being signed by a known authority.

- Diagnose what's wrong
- Verify the user's certificate was signed by the correct CA
- Verify the CA certificate in their kubeconfig matches the cluster CA
- Fix the issue and test that they can connect

**Scenario 2: API server hostname mismatch**

Someone tries connecting to the API server using a hostname that's not in the certificate SAN.

- Determine why the connection fails
- Show what hostname they're using
- Show what hostnames are valid in the certificate
- Explain why this is a security feature
- Find a valid way to connect using information from the certificate

**Scenario 3: Kubeconfig context is missing**

A user's kubeconfig is missing the context they need.

- Determine what context is missing
- Determine what cluster and user it should reference
- Create the missing context
- Test that it works

**Deliverables:**

- Document each problem
- Show diagnostic steps you took
- Show how you fixed each issue
- Prove the issue is resolved with a successful test

**Success criteria:**

- You fix each problem correctly
- You understand why each problem occurred
- You demonstrate the solution works

---

## Challenge 6: Monitor Certificate Expiration

Create a monitoring script that tracks certificate expiration across multiple users.

**Your script must:**

1. Read all users from your kubeconfig
2. For each user, extract their certificate
3. Determine when each certificate expires
4. Calculate days remaining until expiration
5. Highlight certificates expiring within 30 days
6. Show expired certificates
7. Output a formatted report
8. Color-code the output (OK/Warning/Critical)

**Deliverables:**

- Script that produces an expiration report
- Sample output showing multiple users with different expiration times
- Proof that it correctly identifies soon-to-expire certificates

**Success criteria:**

- Script runs without errors
- Output is clear and actionable
- Dates are accurate and correct

---

## Challenge 7: Certificate Renewal Workflow

Renew an expiring user certificate.

**What you need to do:**

1. Identify a user certificate that will expire soon (or create one with short validity)
2. Generate a new private key for renewal
3. Create a new CSR with the same CN and Organization as the original
4. Submit the renewal CSR to Kubernetes
5. Approve the new CSR
6. Extract the new certificate
7. Update the user's kubeconfig with the new certificate
8. Verify the user can still authenticate with the new certificate
9. Compare the old and new certificates - show what changed and what stayed the same

**Deliverables:**

- Completed renewal process
- Comparison of old and new certificates
- Proof that the renewed certificate works

**Success criteria:**

- Renewal process completes without errors
- User can authenticate with the new certificate
- You understand the renewal workflow

---

## Challenge 8: Custom Certificate with Specific SANs

Create a custom server certificate with specific Subject Alternative Names.

**What you need to do:**

1. Create an OpenSSL config file that specifies custom SANs including:
   - Multiple DNS names
   - Multiple IP addresses
   - Specific key usage and extended key usage extensions
2. Generate a private key
3. Create a CSR using your config
4. Sign the certificate with the cluster CA
5. Verify that all your specified SANs are in the final certificate
6. Verify the key usage extensions are correct

**Deliverables:**

- OpenSSL config file
- Generated certificate
- Verification that SANs match what you specified

**Success criteria:**

- Certificate contains all specified SANs
- Certificate is properly signed by cluster CA
- Extensions are exactly as you configured them

---

## Challenge 9: Embedded vs Referenced Certificates in Kubeconfig

Compare and convert between embedded and referenced certificates.

**What you need to do:**

1. Create a user context with embedded certificates (full base64 data in kubeconfig file)
2. Create another user context with referenced certificates (file paths in kubeconfig)
3. Compare the kubeconfig files - show size differences
4. Show which approach is portable (can move kubeconfig to another machine)
5. Show which approach requires external files
6. Convert an embedded certificate to a referenced one
7. Verify both approaches work for authentication

**Deliverables:**

- Two kubeconfigs (one embedded, one referenced)
- Size comparison
- Explanation of when to use each approach
- Proof both work for authentication

**Success criteria:**

- You understand the trade-offs between the two approaches
- Both approaches authenticate successfully
- You can explain when to use each one

---

## Challenge 10: Complete User Lifecycle

Create, manage, monitor, and eventually retire a user account.

**What you need to do:**

1. Create a new user with full provisioning automation
2. Add the user to your kubeconfig
3. Create RBAC permissions for the user
4. Verify the user can authenticate and has correct permissions
5. Monitor the user's certificate expiration date
6. Track the certificate through its lifecycle
7. Renew the certificate before it expires
8. Verify the renewed certificate works
9. Create a report showing certificate history
10. Demonstrate removing the user from kubeconfig

**Deliverables:**

- Complete user lifecycle documentation
- Provisioning script that handles all steps
- Expiration monitoring report
- Certificate renewal proof
- User removal process

**Success criteria:**

- User provisioning is fully automated
- Certificate is successfully renewed before expiration
- All steps are documented and reproducible

---

## Challenge 11: CSR Management in Kubernetes

Work directly with Kubernetes CSR objects.

**What you need to do:**

1. Create multiple CSRs in the cluster
2. List all pending CSRs
3. View details of specific CSRs (including the original request)
4. Approve some CSRs
5. Deny other CSRs
6. Delete CSRs
7. Extract certificates from approved CSRs
8. Create a script that auto-approves CSRs from specific users or groups

**Deliverables:**

- Demonstration of CSR operations
- Script for automated CSR approval
- Proof that extracted certificates work for authentication

**Success criteria:**

- You understand the CSR API
- You can perform all CSR operations
- Auto-approval script works correctly

---

## Challenge 12: Multi-Cluster User Management

Manage the same user across multiple clusters.

**What you need to do:**

1. Create the same user (same CN, same group) in both prod and dev clusters
2. Generate certificates for this user in each cluster
3. Create a single kubeconfig that has contexts for both clusters with the same user
4. Test that the user can authenticate to both clusters
5. Verify that RBAC permissions are enforced independently in each cluster
6. Apply different permissions to the same user in each cluster
7. Verify that the user's permissions match what you set in each cluster

**Deliverables:**

- Kubeconfig with user contexts for both clusters
- RBAC configuration for both clusters
- Test results showing user works in both clusters with different permissions

**Success criteria:**

- Same user authenticates to both clusters
- Permissions are independent per cluster
- You understand how RBAC works across clusters

---

## Challenge 13: Kubeconfig Recovery and Backup

Backup your kubeconfig and recover from corruption.

**What you need to do:**

1. Create a backup strategy for your kubeconfig
2. Create automated backups
3. Intentionally corrupt your kubeconfig
4. Attempt to use the corrupted kubeconfig (should fail)
5. Recover from your backup
6. Verify all contexts work after recovery
7. Create a script that verifies kubeconfig integrity
8. Create a validation function that tests all contexts can connect

**Deliverables:**

- Backup script
- Recovery script
- Validation script
- Proof that recovery works

**Success criteria:**

- Backup and recovery process works
- Validation correctly identifies working and broken contexts
- You can recover from corruption

---

## Challenge 14: Understanding Certificate Authorities

Work with multiple CAs.

**What you need to do:**

1. Extract the cluster CA
2. Extract other CAs from the cluster (ETCD CA, front-proxy CA, etc.)
3. Understand which certificates are signed by which CA
4. Verify that API server cert is signed by cluster CA
5. Verify that kubelet cert is signed by cluster CA
6. Understand what would happen if a certificate was signed by a different CA
7. Create a script that validates all system certificates are signed by expected CAs

**Deliverables:**

- List of all CAs in cluster
- Which certificates are signed by which CA
- Validation script

**Success criteria:**

- You understand the CA hierarchy
- Your validation script correctly checks certificate chains

---

## Challenge 15: Real-World Incident Response

Simulate and respond to certificate-related incidents.

**Incident 1: Kubelet certificate expires**

- A kubelet certificate expires
- Node goes NotReady
- Diagnose why (certificate expiration)
- Fix the issue
- Restore node to Ready state

**Incident 2: User certificate theft**

- Assume a user's certificate was compromised
- Revoke the user's access (remove RBAC and kubeconfig)
- Provision the user with a new certificate
- Verify old certificate no longer works

**Incident 3: Certificate configuration mistake**

- Someone created a certificate without the correct SANs
- Connections fail with hostname mismatch
- Diagnose the problem
- Create a new certificate with correct SANs
- Update configuration to use new certificate

**Deliverables:**

- Diagnosis and resolution for each incident
- Steps you took to fix each problem
- Proof that each issue is resolved

**Success criteria:**

- You successfully diagnose and fix all incidents
- You understand how to prevent each incident in the future

---

## Challenge 16: Kubelet Client Certificate Rotation

Investigate and manage kubelet client certificates which authenticate the kubelet to the API server.

**What you need to do:**

1. Create a kind cluster with kubelet client certificate rotation enabled
2. Find the kubelet client certificate in the node
3. Extract and examine the kubelet client certificate (CN should be system:node:NODENAME)
4. Verify the certificate is signed by the cluster CA
5. Simulate certificate rotation by manually creating a new CSR from the kubelet's key
6. Understand what happens when kubelet certificate expires without rotation
7. Create a monitoring script that tracks kubelet certificate expiration dates
8. Compare kubelet certs across multiple nodes (if multi-node cluster)

**Deliverables:**

- Script that monitors kubelet certificate expiration
- Report showing certificate details for all kubelet certs
- Explanation of how kubelet certificate rotation prevents service disruption

**Success criteria:**

- You can locate and analyze kubelet certificates
- You understand the CN format for kubelet certificates
- Your monitoring script correctly identifies all kubelet certs

---

## Challenge 17: Service Account Token and RBAC Integration

Connect service account tokens to RBAC permissions.

**What you need to do:**

1. Create a service account in a namespace
2. Extract its token from the secret
3. Create a kubeconfig that uses the service account token for authentication
4. Use this kubeconfig to attempt API calls (will be denied without RBAC)
5. Create a Role with specific pod permissions
6. Bind the Role to the service account
7. Verify the service account can now perform only the permitted actions
8. Create another service account with different permissions in the same namespace
9. Verify each service account has different access levels
10. Mount a service account in a pod and test it can access the API

**Deliverables:**

- Kubeconfig using service account token
- RBAC Role and RoleBinding
- Test results showing permission enforcement
- Pod that successfully uses the mounted service account

**Success criteria:**

- Service account token works for authentication
- RBAC permissions are enforced correctly
- Tokens are properly scoped to their permissions

---

## Challenge 18: Kube-Controller-Manager and Kube-Scheduler Authentication

Understand how system components authenticate.

**What you need to do:**

1. Create a kind cluster
2. Find the certificates used by kube-controller-manager to authenticate to the API server
3. Find the certificates used by kube-scheduler to authenticate to the API server
4. Examine CN and Organization fields - they should be `system:kube-controller-manager` and `system:kube-scheduler`
5. Verify these certificates are signed by the cluster CA
6. Understand what permissions these components need (check RBAC clusterroles)
7. Extract these certificates and create kubeconfigs using them
8. Test that you can use these kubeconfigs to authenticate as the components
9. Verify that each component can only do what their RBAC roles allow
10. Explain why system components use certificates instead of service accounts

**Deliverables:**

- Analysis of system component certificates
- Kubeconfigs for kube-controller-manager and kube-scheduler
- RBAC permissions for each component
- Explanation of component authentication design

**Success criteria:**

- You can locate all system component certificates
- You understand the CN format for system components (system:COMPONENTNAME)
- You understand why each component needs its own identity

---

## Challenge 19: Network Policy and Certificate-Based Service Communication

Restrict communication between pods based on network policies while using certificate authentication.

**What you need to do:**

1. Create a kind cluster with CNI that supports network policies (e.g., Calico)
2. Create three namespaces: frontend, backend, database
3. Deploy applications in each namespace
4. Create network policies that:
   - Allow frontend → backend communication
   - Allow backend → database communication
   - Deny frontend → database communication
   - Deny database → anything
5. Create certificates for each service
6. Configure services to use mutual TLS (mTLS) for communication
7. Test that allowed traffic flows but restricted traffic is blocked by network policy
8. Verify that even though some pods could communicate at layer 3, network policy prevents it
9. Create a network policy audit script that shows allowed and denied traffic

**Deliverables:**

- Network policy definitions
- Certificates for each service
- Test results showing allowed/denied connections
- Audit script output

**Success criteria:**

- Network policies enforce correct traffic restrictions
- You understand the relationship between network policies and application-level authentication
- All tests show expected behavior

---

## Challenge 20: Audit Logging of Authentication Events

Monitor and analyze authentication events in your cluster.

**What you need to do:**

1. Create a kind cluster with audit logging enabled
2. Configure audit logging to capture:
   - All authentication events
   - All certificate-based authentication
   - All service account token usage
3. Perform various authentication actions:
   - Connect as a user with certificate
   - Use service account token from a pod
   - Attempt unauthenticated connection (should fail)
   - Use wrong certificate (should fail)
4. Review audit logs and identify authentication events
5. Parse audit logs to extract:
   - User identity
   - Timestamp
   - Whether it succeeded or failed
   - API action attempted
6. Create a script that generates an authentication report
7. Identify suspicious authentication patterns
8. Create alerts for failed authentication attempts

**Deliverables:**

- Audit logging configuration
- Audit log parser script
- Authentication report showing all login events
- Security analysis of authentication patterns

**Success criteria:**

- Audit logging captures all authentication events
- You can parse and analyze audit logs
- You understand what to look for in authentication logs
- Your report clearly shows who accessed the cluster and when

---

**Notes for all challenges:**

- Use kind clusters - no special production setup required
- Refer to `notes.md` for technical background and reference commands
- Use `solutions.md` for hints if you get stuck
- All challenges should be completed using a kind cluster you create
- Document your work as you go
- Test each step to ensure it works before moving to the next

