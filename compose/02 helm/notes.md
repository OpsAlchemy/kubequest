### `sed` (surface newlines, no duplicates)

```bash
helm template . | sed -n 'l'
```

Shows line endings explicitly (`$` = `\n`, `\r$` = CRLF) without printing each line twice; works consistently on Linux, WSL, and macOS.

---

### yamllint

Validates rendered output for basic YAML syntax and indentation errors before Kubernetes processing.

---

### kubeconform

Validates rendered manifests against Kubernetes API schemas to catch invalid kinds, fields, or apiVersions.

Output only the final content. No preface, no acknowledgements, no closing remarks.