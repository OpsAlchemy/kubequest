Network Policy for 

``` yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  creationTimestamp: "2025-09-02T07:01:00Z"
  generation: 2
  name: np-100x
  namespace: default
  resourceVersion: "3994"
  uid: 9690d367-a171-4fd9-a9e8-e3c162fb0a65
spec:
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: level-1000
      podSelector:
        matchLabels:
          level: 100x
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: level-1001
      podSelector:
        matchLabels:
          level: 100x
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: level-1002
      podSelector:
        matchLabels:
          level: 100x
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  podSelector:
    matchLabels:
      level: 100x
  policyTypes:
  - Egress
```