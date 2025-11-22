https://killercoda.com/sachin/course/CKA/network-policy

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-app-network-policy
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {}
    - from:
        - podSelector:
            matchLabels:
              app: trusted
  egress:
    - to:
        - podSelector: {}

