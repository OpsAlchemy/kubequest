# DaemonSet YAML Troubleshooting Notes

## Troubleshooting DaemonSet Configuration in Kubernetes

**Scenario Overview:** Creating a DaemonSet named "configurator" in the "configurator" namespace to run a bash container on each node that writes a specific string to a host directory.

### Final Correct DaemonSet YAML Configuration

**File:** `sol.yaml`

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: configurator
  namespace: configurator
spec:
  selector:
    matchLabels:
      app: configurator
  template:
    metadata:
      labels:
        app: configurator
    spec:
      volumes:
      - name: common
        hostPath:
          path: /configurator
          type: DirectoryOrCreate
      containers:
      - name: bash
        image: bash
        volumeMounts:
        - mountPath: /configurator
          name: common
        command:
        - bash
        - -c
        - |
          echo "aba997ac-1c89-4d64" > /configurator/config
          sleep 1d
```

### Error Analysis and Resolution Process

During the development process, several errors were encountered and resolved systematically:

#### Error 1: Incorrect API Version and Resource Kind
```
error: resource mapping not found for name: "configurator" namespace: "configurator" from "sol.yaml": no matches for kind "DaemonSets" in version "v1"
```
**Root Cause:** Using incorrect API version (`v1` instead of `apps/v1`) and incorrect resource kind (plural "DaemonSets" instead of singular "DaemonSet").

**Solution:** Corrected `apiVersion` to `apps/v1` and `kind` to `DaemonSet`.

#### Error 2: Typographical Error in Field Name
```
Error from server (BadRequest): error when creating "sol.yaml": DaemonSet in version "v1" cannot be handled as a DaemonSet: strict decoding error: unknown field "spec.templates"
```
**Root Cause:** Field name `templates` is incorrect (should be singular `template`).

**Solution:** Changed `spec.templates` to `spec.template`.

#### Error 3: Incorrect Volume and VolumeMount Structure
```
Error from server (BadRequest): error when creating "sol.yaml": DaemonSet in version "v1" cannot be handled as a DaemonSet: strict decoding error: unknown field "spec.template.spec.containers[0].volumeMounts[0].volume", unknown field "spec.template.spec.volumes[0].emptyDir.directoryOrCreate", unknown field "spec.template.spec.volumes[0].emptyDir.path"
```
**Root Cause:** Volume and volumeMount definitions had incorrect nesting and field names.

**Solution:** 
- For `volumeMounts`: Simplified structure to only include `mountPath` and `name`
- For `volumes`: Used correct `hostPath` structure instead of `emptyDir`

#### Error 4: Incorrect hostPath Array Syntax
```
Error from server (BadRequest): error when creating "sol.yaml": DaemonSet in version "v1" cannot be handled as a DaemonSet: json: cannot unmarshal array into Go struct field Volume.spec.template.spec.volumes.hostPath of type v1.HostPathVolumeSource
```
**Root Cause:** `hostPath` was incorrectly defined as an array/list instead of a map/dictionary.

**Solution:** Changed from array format:
```yaml
hostPath:
  - path: /configurator
    DirectoryOrCreate: true
```
To correct map format:
```yaml
hostPath:
  path: /configurator
  type: DirectoryOrCreate
```

### Key Debugging Commands Used

The following kubectl explain commands were instrumental in troubleshooting:

1. **Checking DaemonSet API structure:**
   ```bash
   k explain ds
   # Revealed: GROUP: apps, KIND: DaemonSet, VERSION: v1
   ```

2. **Understanding Pod template structure:**
   ```bash
   k explain ds.spec.template.spec
   # Confirmed the location of pod specification within DaemonSet
   ```

3. **Investigating volume configuration:**
   ```bash
   k explain ds.spec.template.spec.volumes.hostPath
   # Provided exact syntax for hostPath volumes including required fields
   ```

### Key Learning Points

1. **API Version Specificity:** DaemonSet requires `apiVersion: apps/v1` not just `v1`
2. **Selector-Template Relationship:** The `spec.selector.matchLabels` must match the `spec.template.metadata.labels` for the DaemonSet to manage the pods correctly
3. **hostPath Syntax:** The `hostPath` volume must be defined as a map with `path` and `type` fields, not as a list item
4. **Volume Mount References:** The `volumeMounts.name` must correspond exactly to a volume name defined in `spec.volumes`
5. **Iterative Debugging:** Fix errors sequentially from top to bottom as earlier errors can mask later ones

### Best Practices Demonstrated

1. **Using kubectl explain:** Leveraging Kubernetes' built-in documentation to understand resource structure
2. **Namespace Specification:** Defining the namespace at the metadata level rather than relying on default namespace
3. **Command Formatting:** Using the multi-line YAML block scalar (`|`) for complex container commands
4. **Resource Cleanup:** Using `k delete -f sol.yaml` to remove incorrectly created resources before fixing and re-applying

### Common DaemonSet Patterns Illustrated

1. **Node-Level Operations:** Using DaemonSet for tasks that need to run on every node (like configuration management)
2. **HostPath Volumes:** Mounting host directories for node-specific operations
3. **Long-Running Maintenance Containers:** Using `sleep 1d` pattern for containers that need to persist for maintenance/debugging purposes

