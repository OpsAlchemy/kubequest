### Ingress Default Backend Behavior

* `spec.defaultBackend` is global to the Ingress → applies to all hosts defined in that Ingress.

  ```yaml
  spec:
    defaultBackend:
      service: shared-default-svc:80
  rules:
  - host: app.example.com
  - host: other.example.com
  ```

* To have different defaults per host, use one of:

  1. Separate Ingresses, each with its own default backend.

     ```yaml
     # ingress-a
     defaultBackend: default-app-svc
     host: app.example.com
     # ingress-b
     defaultBackend: default-other-svc
     host: other.example.com
     ```

  2. Single Ingress with explicit `/` catch-all path under each host.

     ```yaml
     rules:
     - host: app.example.com
       http:
         paths:
         - path: /
           backend: default-app-svc
     - host: other.example.com
       http:
         paths:
         - path: /
           backend: default-other-svc
     ```

* If neither `defaultBackend` nor per-host `/` path is present, unmatched requests return 404.

* Imperative `--default-backend` sets global default; for per-host defaults split into multiple Ingresses or use `/` path rules.
