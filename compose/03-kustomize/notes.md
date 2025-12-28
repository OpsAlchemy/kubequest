When you use:

yaml
secretGenerator:
  - name: app-secret
    behavior: merge
    envs:
      - prod-secret.txt
The behavior field controls how Kustomize handles the existing secret in your manifests, NOT the source file. Here's what happens:

1. If the secret DOES NOT exist in base manifests:
With behavior: merge → Will create the secret

With behavior: create → Will create the secret

With behavior: replace → Will fail (no secret to replace)

2. If the secret DOES exist in base manifests:
With behavior: merge → Merge values from generator with base secret

With behavior: create → Error (can't create, already exists)

With behavior: replace → Replace base secret completely

