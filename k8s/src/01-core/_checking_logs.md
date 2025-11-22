### Checking Logs for Containers

* **Pod logs**: `/var/log/pods/`
* **Container logs**: `/var/log/containers/`
* **Using `crictl` to view logs**:

  * `crictl ps` — Lists containers.
  * `crictl logs <container-id>` — Displays logs for a specific container.
* **Kubelet logs**:

  * Located in `/var/log/syslog` or via `journalctl`.

### Checking Logs for System Daemons (e.g., kubelet, containerd)

System logs are managed via **systemd** on most modern Linux distributions. `journalctl` is the utility for viewing logs.

#### `journalctl` Overview

* **Basic Usage**:

  * `journalctl` — View system logs.
  * `journalctl -f` — Follow the logs in real-time.
  * `journalctl -u kubelet` — View logs for the `kubelet` service.
  * `journalctl -f apache2 --no-pager` — Follow logs for `apache2`.
  * `journalctl --since "2025-03-25 12:00:00"` — Show logs from a specific timestamp.
  * `journalctl --since "yesterday"` — Show logs since yesterday.
  * `journalctl --since "1 hour ago"` — Show logs from the last hour.
  * `journalctl _UID=1000` — View logs for a specific user (UID 1000 in this case).
  * `sudo journalctl --vacuum-size=500M` — Clean up older logs, limiting the total log size.

#### Installing Apache2 and Viewing Logs:

```bash
sudo apt install apache2
journalctl -f apache2 --no-pager
```

### Configuration for `crictl`

The best way to configure `crictl` is to define the configuration in the `/etc/crictl.yaml` file on the node.

* Example `crictl.yaml` is usually provided in Kubernetes documentation or course repositories.

To check `crictl` help:

```bash
crictl --help
```

### Viewing Logs in `/var/log/`

If you're troubleshooting or auditing logs, these are the key log files and directories to check:

* **Logs Directory**: `/var/log/`

  * Contains system logs such as `auth.log`, `syslog`, `kern.log`, etc.
* **List Logs**:

```bash
ls /var/log
```

* Example output (abbreviated):

```bash
/var/log$ ls
README            apt         apache2     auth.log    cloud-init-output.log   syslog
alternatives.log  dpkg.log    kern.log    lastlog     sysstat
```

#### Detailed Logs:

* **Authentication Logs**: `/var/log/auth.log`
* **System Logs**: `/var/log/syslog`
* **Kernel Logs**: `/var/log/kern.log`
* **Apache2 Logs**: `/var/log/apache2/`

#### Checking specific logs for system components:

```bash
sudo journalctl -u kubelet
```

#### Handling Binary Logs (e.g., systemd journal logs):

Use `journalctl` to view logs that are stored in binary format within `/var/log/journal/`.

### Additional Notes:

* **If using a service like Apache2**: Logs are generally stored in `/var/log/apache2/`.
* **Binary logs**: Some logs, like system logs, are stored in binary format under `/var/log/journal/`. They can be accessed with `journalctl`.
* **Logs Rotation and Vacuuming**:

  * Use `sudo journalctl --vacuum-size=500M` to limit the size of the log files.

This should make it easier to locate and analyze logs on your system, ensuring proper troubleshooting for both containers and system services like `kubelet` or `containerd`.
