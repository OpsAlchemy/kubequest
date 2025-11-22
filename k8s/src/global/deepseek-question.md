***

### 1. The Phoenix Deployment
**Image:** `phoenix-app:prod-v3.2` (A critical API application)
**ConfigMap:** `phoenix-env` - Contains a key `DB_URL` with the value `postgres-prod:5432`.
**Secret:** `phoenix-db-creds` - Contains the keys `username: cG9zdGdyZXM=` (postgres) and `password: UEVSU0VVU0NPTlNURUxMQVRJT04=` (a very secret password).
**Scenario:** The database password has been rotated. The `phoenix-db-creds` Secret was updated but is marked as `immutable`. The Pods are now crash-looping because they can't connect to the database.
**Question:** What is the fundamental reason the Pods cannot pick up the new password, and what is the two-step process to force the Deployment to use the new credentials?

### 2. The Ambassador's Briefing
**Image:** `envoy-proxy:latest` (A sidecar proxy handling TLS termination)
**ConfigMap:** `envoy-config` - Contains a full YAML configuration file for the proxy under the key `envoy.yaml`.
**Secret:** `diplomatic-tls` - A TLS Secret with `tls.crt` and `tls.key` for the domain `secure.embassy.org`.
**Scenario:** The Envoy proxy is configured via the mounted ConfigMap. It is failing to start, logging the error: "failed to load certificate chain from /etc/envoy/tls/tls.crt".
**Question:** The files are mounted. Assuming the certificate is valid, what is the most likely ownership or file permission issue preventing Envoy from reading the files, and what Pod securityContext field could solve it?

### 3. The Librarian's Manuscript
**Image:** `content-manager:1.8` (An application that reads its config from a file)
**ConfigMap:** `app-settings` - Created from a local file `application.properties`. It has no explicit keys defined.
**Secret:** *None used in this scenario.*
**Scenario:** The Pod mounts the `app-settings` ConfigMap on the path `/app/config`. The application is looking for its configuration file at `/app/config/application.properties` but reports the file is not found.
**Question:** What is the actual name of the file that was created inside the `/app/config` directory, and why did this happen?

### 4. The Cartographer's Volatile Map
**Image:** `tile-generator:3.1` (A graphics-intensive process that creates map images)
**ConfigMap:** `render-settings` - Contains performance tuning parameters.
**Secret:** `map-api-key` - Contains a single key `key` with a value for a third-party service.
**Scenario:** The application is security-hardened and runs with a `readOnlyRootFilesystem: true`. It needs a place to write large temporary map image files that can be discarded when the Pod terminates.
**Question:** Which volume type is most appropriate for providing this temporary, writable, ephemeral storage, and on which directory path should it typically be mounted (e.g., `/tmp` or `/var/tmp`)?

### 5. The Spy's Dead Drop
**Image:** `signal-processor:blackops` (A sensitive workload)
**ConfigMap:** `mission-parameters` - Contains non-sensitive operational data.
**Secret:** `covert-credentials` - Contains a highly sensitive key `identity` with a value that must never be stored on disk.
**Scenario:** The security team's policy states that the value of the `identity` key must exist only in memory.
**Question:** To comply with this policy, should the `identity` key be exposed to the container as an environment variable or as a mounted file? Justify your answer based on how Kubernetes handles these two methods.

### 6. The Archivist's Dual Source
**Image:** `data-merger:2.0` (An application that consolidates data)
**ConfigMap A:** `primary-source` - Has a key `config.xml` with primary settings.
**ConfigMap B:** `secondary-source` - Also has a key `config.xml` with different backup settings.
**Secret:** *None used in this scenario.*
**Scenario:** The application needs to read both `config.xml` files. The Pod spec mounts both ConfigMaps into the same directory, `/config`. However, only one `config.xml` file exists in that directory.
**Question:** What happened to the second file, and what feature must be used to mount both ConfigMaps into the same directory without their files overwriting each other?

### 7. The Chancellor's Dynamic Decree
**Image:** `policy-engine:latest` (An application that reloads its config automatically)
**ConfigMap:** `city-edicts` - Contains a key `policies.json` which is updated frequently by an automated process.
**Secret:** *None used in this scenario.*
**Scenario:** The ConfigMap is updated with new policies. The `policy-engine` application is designed to watch its config file for changes and reload itself. An hour later, it is observed that the running Pods are still using the old policies.
**Question:** What is the default update period for projected ConfigMap changes, and what command can an operator run to explicitly trigger an update check without restarting the Pod?

### 8. The Alchemist's Formula
**Image:** `potion-brewer:alchemy-labs` (A fun experimental app)
**ConfigMap:** *None used in this scenario.*
**Secret:** `secret-formula` - Needs to be created with two literal values: `ingredient1=eye-of-newt` and `ingredient2=wing-of-bat`.
**Scenario:** You must create the Secret without generating any temporary files on disk to avoid leaving traces of the formula.
**Question:** What is the exact `kubectl create secret generic` command that will create this Secret directly from the command line?

### 9. The Sentinel's Fortress
**Image:** `gatekeeper:hardened` (A critical security component)
**ConfigMap:** `security-policy` - Contains a crucial set of firewall rules under the key `iptables.rules`. This configuration must never change accidentally.
**Secret:** `vault-token` - A token for accessing a secure vault.
**Scenario:** An intern accidentally runs a command that attempts to update the `security-policy` ConfigMap, which could have caused a severe outage.
**Question:** What property can be set on the `security-policy` ConfigMap to make it immutable and prevent exactly this type of accidental change?

### 10. The Merger of Two Kingdoms
**Image:** `unification-engine:prod` (A complex business logic app)
**ConfigMap:** `kingdom-a-settings` - Contains a key `API_ENDPOINT` with a URL.
**Secret:** `kingdom-b-credentials` - Contains a key `API_KEY` with a sensitive token.
**Scenario:** The application requires both the `API_ENDPOINT` and the `API_KEY` to be available as environment variables to function correctly.
**Question:** Describe the two different `valueFrom` sources you would use inside the Pod's container specification to populate each environment variable from its respective resource (the ConfigMap and the Secret).


Of course. Here are 5 more CKA-level questions that incorporate commands, arguments, and environment variable interplay with ConfigMaps and Secrets.

***

### 1. The Failing Init Container
**Image:** `busybox:1.35` (Init Container), `main-app:latest` (Main Container)
**ConfigMap:** `db-schema` - Contains a key `schema.sql` with database initialization commands.
**Scenario:** An Init Container is designed to prepopulate a database. It is supposed to execute the command `/bin/sh -c "psql < /config/schema.sql"`. However, the Init Container fails instantly. You discover the main container starts fine if you remove the Init Container.
**Question:** What is the most likely issue with the Init Container's command definition in the Pod spec, and how should the `command` and `args` fields be structured to execute this correctly?

### 2. The Argument That Wasn't There
**Image:** `logger:debug`
**ConfigMap:** `log-config` - Has a key `LOG_LEVEL` with the value `DEBUG`.
**Scenario:** The container is designed to start with the argument `--verbosity=$(LOG_LEVEL)`. The Pod is running, but the application is using its default log level (`INFO`), not `DEBUG`. You exec into the Pod and verify the environment variable `LOG_LEVEL` is correctly set to `DEBUG`.
**Question:** Why didn't the argument `--verbosity=$(LOG_LEVEL)` pick up the value from the environment variable, and what is the correct way to define this argument to ensure it uses the runtime value of the environment variable?

### 3. The Secret Startup Script
**Image:** `nginx:alpine`
**Secret:** `startup-script` - A generic Secret created from a shell script file `init.sh`. The script contains a command to generate a self-signed certificate using values from other Secrets.
**Scenario:** The Pod must execute this script as its main startup process. The Dockerfile's `ENTRYPOINT` is set to `["/bin/sh", "-c"]`.
**Question:** What is the security and operational concern with mounting the `startup-script` Secret as a volume and then pointing the container's `command` to execute the mounted file? What is a safer alternative method to get the script's contents into the container for execution?

### 4. The Conditional Entrypoint
**Image:** `app-server:jre11`
**ConfigMap:** `java-config` - Contains a key `JAVA_OPTS` with the value `-Xmx512m`.
**Scenario:** The application should use the options from `JAVA_OPTS` only if they are present. The container's `ENTRYPOINT` is set to `java`. You want to set the `CMD` to use the value from the environment variable.
**Question:** Write the correct `args` definition for the container that will use the value of the `JAVA_OPTS` environment variable as arguments to the `java` command. What is a key pitfall to avoid if the `JAVA_OPTS` environment variable were ever to be empty or unset?

### 5. The Database Connection String
**Image:** `wordpress:6.4`
**ConfigMap:** `wp-config` - Contains a key `DB_HOST` with the value `wordpress-db`.
**Secret:** `wp-db-creds` - Contains the keys `DB_USER`, `DB_PASSWORD`, and `DB_NAME`.
**Scenario:** The application requires a single environment variable, `DATABASE_URL`, in the format `mysql://USER:PASSWORD@HOST/DATABASE`. All the components are in different resources.
**Question:** How can you use the `env.valueFrom` syntax to populate individual environment variables (e.g., `DB_USER`, `DB_HOST`) and then use a single `command` in the container to assemble them into the required `DATABASE_URL` format *before* launching the main process?