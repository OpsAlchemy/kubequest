controlplane:/usr/lib/systemd/system$ cat kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
controlplane:/usr/lib/systemd/system$ journalctl -u kubelet -f --no-pager
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084208    1530 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"7ac5e0c1-e88f-4814-aeaa-db71d4a41248\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"40f223ecc53f4edcccf08bc84dcf46a61d47f3f9d2864acb5ee42a8cd29a530b\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="kube-system/calico-kube-controllers-fdf5f5495-8jbqm" podUID="7ac5e0c1-e88f-4814-aeaa-db71d4a41248"
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084356    1530 kuberuntime_manager.go:1161] "killPodWithSyncResult failed" err="failed to \"KillPodSandbox\" for \"90bd1749-4aa8-4158-bc70-7f85e1b31626\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"2a72073636b03267b015126eb8620d48006dca03c1df840c91513a4b72cf7852\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\""
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084839    1530 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"90bd1749-4aa8-4158-bc70-7f85e1b31626\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"2a72073636b03267b015126eb8620d48006dca03c1df840c91513a4b72cf7852\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="local-path-storage/local-path-provisioner-5c94487ccb-gmwjg" podUID="90bd1749-4aa8-4158-bc70-7f85e1b31626"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453797    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"config-volume\" (UniqueName: \"kubernetes.io/configmap/e81873fb-1ea3-40d4-a6fb-bb68fd1b2395-config-volume\") pod \"coredns-6ff97d97f9-q4qw6\" (UID: \"e81873fb-1ea3-40d4-a6fb-bb68fd1b2395\") " pod="kube-system/coredns-6ff97d97f9-q4qw6"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453888    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-6nhgd\" (UniqueName: \"kubernetes.io/projected/e81873fb-1ea3-40d4-a6fb-bb68fd1b2395-kube-api-access-6nhgd\") pod \"coredns-6ff97d97f9-q4qw6\" (UID: \"e81873fb-1ea3-40d4-a6fb-bb68fd1b2395\") " pod="kube-system/coredns-6ff97d97f9-q4qw6"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453911    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-lm9mc\" (UniqueName: \"kubernetes.io/projected/834daaad-294f-4833-ab02-a58dd6a578a3-kube-api-access-lm9mc\") pod \"coredns-6ff97d97f9-x9cwn\" (UID: \"834daaad-294f-4833-ab02-a58dd6a578a3\") " pod="kube-system/coredns-6ff97d97f9-x9cwn"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453943    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"config-volume\" (UniqueName: \"kubernetes.io/configmap/834daaad-294f-4833-ab02-a58dd6a578a3-config-volume\") pod \"coredns-6ff97d97f9-x9cwn\" (UID: \"834daaad-294f-4833-ab02-a58dd6a578a3\") " pod="kube-system/coredns-6ff97d97f9-x9cwn"
Aug 23 04:21:12 controlplane kubelet[1530]: I0823 04:21:12.039751    1530 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="kube-system/coredns-6ff97d97f9-x9cwn" podStartSLOduration=2.038986014 podStartE2EDuration="2.038986014s" podCreationTimestamp="2025-08-23 04:21:10 +0000 UTC" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2025-08-23 04:21:11.974209004 +0000 UTC m=+1450.781708380" watchObservedRunningTime="2025-08-23 04:21:12.038986014 +0000 UTC m=+1450.846485388"
Aug 23 04:21:12 controlplane kubelet[1530]: I0823 04:21:12.103956    1530 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="kube-system/coredns-6ff97d97f9-q4qw6" podStartSLOduration=2.103944283 podStartE2EDuration="2.103944283s" podCreationTimestamp="2025-08-23 04:21:10 +0000 UTC" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2025-08-23 04:21:12.040708989 +0000 UTC m=+1450.848208366" watchObservedRunningTime="2025-08-23 04:21:12.103944283 +0000 UTC m=+1450.911443657"
Aug 23 04:30:01 controlplane kubelet[1530]: W0823 04:30:01.504469    1530 watcher.go:93] Error while processing event ("/sys/fs/cgroup/system.slice/sysstat-collect.service": 0x40000100 == IN_CREATE|IN_ISDIR): inotify_add_watch /sys/fs/cgroup/system.slice/sysstat-collect.service: no such file or directory





^C
controlplane:/usr/lib/systemd/system$ ^C
controlplane:/usr/lib/systemd/system$ journalctl -u kubelet -f --no-pager^C
controlplane:/usr/lib/systemd/system$ ^C
controlplane:/usr/lib/systemd/system$ kubectl get pods
No resources found in default namespace.
controlplane:/usr/lib/systemd/system$ k create deploy nginx --image nginx
deployment.apps/nginx created
controlplane:/usr/lib/systemd/system$ k get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5869d7778c-9zhmq   0/1     Pending   0          3s
controlplane:/usr/lib/systemd/system$ k get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5869d7778c-9zhmq   0/1     Pending   0          7s
controlplane:/usr/lib/systemd/system$ journalctl -u kubelet -f --no-pager
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084208    1530 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"7ac5e0c1-e88f-4814-aeaa-db71d4a41248\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"40f223ecc53f4edcccf08bc84dcf46a61d47f3f9d2864acb5ee42a8cd29a530b\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="kube-system/calico-kube-controllers-fdf5f5495-8jbqm" podUID="7ac5e0c1-e88f-4814-aeaa-db71d4a41248"
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084356    1530 kuberuntime_manager.go:1161] "killPodWithSyncResult failed" err="failed to \"KillPodSandbox\" for \"90bd1749-4aa8-4158-bc70-7f85e1b31626\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"2a72073636b03267b015126eb8620d48006dca03c1df840c91513a4b72cf7852\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\""
Aug 23 03:57:38 controlplane kubelet[1530]: E0823 03:57:38.084839    1530 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"KillPodSandbox\" for \"90bd1749-4aa8-4158-bc70-7f85e1b31626\" with KillPodSandboxError: \"rpc error: code = Unknown desc = failed to destroy network for sandbox \\\"2a72073636b03267b015126eb8620d48006dca03c1df840c91513a4b72cf7852\\\": plugin type=\\\"calico\\\" failed (delete): error getting ClusterInformation: Get \\\"https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default\\\": dial tcp 10.96.0.1:443: i/o timeout\"" pod="local-path-storage/local-path-provisioner-5c94487ccb-gmwjg" podUID="90bd1749-4aa8-4158-bc70-7f85e1b31626"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453797    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"config-volume\" (UniqueName: \"kubernetes.io/configmap/e81873fb-1ea3-40d4-a6fb-bb68fd1b2395-config-volume\") pod \"coredns-6ff97d97f9-q4qw6\" (UID: \"e81873fb-1ea3-40d4-a6fb-bb68fd1b2395\") " pod="kube-system/coredns-6ff97d97f9-q4qw6"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453888    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-6nhgd\" (UniqueName: \"kubernetes.io/projected/e81873fb-1ea3-40d4-a6fb-bb68fd1b2395-kube-api-access-6nhgd\") pod \"coredns-6ff97d97f9-q4qw6\" (UID: \"e81873fb-1ea3-40d4-a6fb-bb68fd1b2395\") " pod="kube-system/coredns-6ff97d97f9-q4qw6"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453911    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"kube-api-access-lm9mc\" (UniqueName: \"kubernetes.io/projected/834daaad-294f-4833-ab02-a58dd6a578a3-kube-api-access-lm9mc\") pod \"coredns-6ff97d97f9-x9cwn\" (UID: \"834daaad-294f-4833-ab02-a58dd6a578a3\") " pod="kube-system/coredns-6ff97d97f9-x9cwn"
Aug 23 04:21:10 controlplane kubelet[1530]: I0823 04:21:10.453943    1530 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"config-volume\" (UniqueName: \"kubernetes.io/configmap/834daaad-294f-4833-ab02-a58dd6a578a3-config-volume\") pod \"coredns-6ff97d97f9-x9cwn\" (UID: \"834daaad-294f-4833-ab02-a58dd6a578a3\") " pod="kube-system/coredns-6ff97d97f9-x9cwn"
Aug 23 04:21:12 controlplane kubelet[1530]: I0823 04:21:12.039751    1530 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="kube-system/coredns-6ff97d97f9-x9cwn" podStartSLOduration=2.038986014 podStartE2EDuration="2.038986014s" podCreationTimestamp="2025-08-23 04:21:10 +0000 UTC" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2025-08-23 04:21:11.974209004 +0000 UTC m=+1450.781708380" watchObservedRunningTime="2025-08-23 04:21:12.038986014 +0000 UTC m=+1450.846485388"
Aug 23 04:21:12 controlplane kubelet[1530]: I0823 04:21:12.103956    1530 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="kube-system/coredns-6ff97d97f9-q4qw6" podStartSLOduration=2.103944283 podStartE2EDuration="2.103944283s" podCreationTimestamp="2025-08-23 04:21:10 +0000 UTC" firstStartedPulling="0001-01-01 00:00:00 +0000 UTC" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2025-08-23 04:21:12.040708989 +0000 UTC m=+1450.848208366" watchObservedRunningTime="2025-08-23 04:21:12.103944283 +0000 UTC m=+1450.911443657"
Aug 23 04:30:01 controlplane kubelet[1530]: W0823 04:30:01.504469    1530 watcher.go:93] Error while processing event ("/sys/fs/cgroup/system.slice/sysstat-collect.service": 0x40000100 == IN_CREATE|IN_ISDIR): inotify_add_watch /sys/fs/cgroup/system.slice/sysstat-collect.service: no such file or directory
^C
controlplane:/usr/lib/systemd/system$ sudo cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
controlplane:/usr/lib/systemd/system$ ls
 ModemManager.service                     remote-fs.target
 NetworkManager-dispatcher.service        remote-veritysetup.target
 NetworkManager-wait-online.service       rescue-ssh.target
 NetworkManager.service                   rescue.service
 accounts-daemon.service                  rescue.target
 apparmor.service                         rescue.target.wants
 apport-autoreport.path                   rpcbind.target
 apport-autoreport.service                rsync.service
 apport-autoreport.timer                  rsyslog.service
 apport-coredump-hook@.service            rtkit-daemon.service
 apport-forward.socket                    runlevel0.target
 apport-forward@.service                  runlevel1.target
 apport.service                           runlevel2.target
 apt-daily-upgrade.service                runlevel3.target
 apt-daily-upgrade.timer                  runlevel4.target
 apt-daily.service                        runlevel5.target
 apt-daily.timer                          runlevel6.target
 apt-news.service                         saned.service
 autovt@.service                          saned.socket
 avahi-daemon.service                     saned@.service
 avahi-daemon.socket                      screen-cleanup.service
 basic.target                             secureboot-db.service
 blk-availability.service                 serial-getty@.service
 blockdev@.target                         setvtrgb.service
 bluetooth.service                        shutdown.target
 bluetooth.target                         sigpwr.target
 bolt.service                             sleep.target
 boot-complete.target                     slices.target
 cloud-config.service                     smartcard.target
 cloud-config.target                      sockets.target
 cloud-final.service                      sockets.target.wants
 cloud-init-hotplugd.service              soft-reboot.target
 cloud-init-hotplugd.socket               sound.target
 cloud-init-local.service                 ssh.service
 cloud-init.service                       ssh.socket
 cloud-init.target                        sshd-keygen@.service.d
 cni-dhcp.service                         ssl-cert.service
 cni-dhcp.socket                          storage-target-mode.target
 colord.service                           sudo.service
 configure-printer@.service               suspend-then-hibernate.target
 console-getty.service                    suspend.target
 console-setup.service                    swap.target
 container-getty@.service                 sys-fs-fuse-connections.mount
 containerd.service                       sys-kernel-config.mount
 cron.service                             sys-kernel-debug.mount
 cryptdisks-early.service                 sys-kernel-tracing.mount
 cryptdisks.service                       sysinit.target
 cryptsetup-pre.target                    sysinit.target.wants
 cryptsetup.target                        syslog.socket
 ctrl-alt-del.target                      sysstat-collect.service
 cups-browsed.service                     sysstat-collect.timer
 cups.path                                sysstat-summary.service
 cups.service                             sysstat-summary.timer
 cups.socket                              sysstat.service
 dbus-org.freedesktop.hostname1.service  'system-systemd\x2dcryptsetup.slice'
 dbus-org.freedesktop.locale1.service    'system-systemd\x2dveritysetup.slice'
 dbus-org.freedesktop.login1.service      system-update-cleanup.service
 dbus-org.freedesktop.timedate1.service   system-update-pre.target
 dbus.service                             system-update.target
 dbus.socket                              system-update.target.wants
 debug-shell.service                      systemd-ask-password-console.path
 default.target                           systemd-ask-password-console.service
 dev-hugepages.mount                      systemd-ask-password-plymouth.path
 dev-mqueue.mount                         systemd-ask-password-plymouth.service
 dm-event.service                         systemd-ask-password-wall.path
 dm-event.socket                          systemd-ask-password-wall.service
 dmesg.service                            systemd-backlight@.service
 docker.service                           systemd-battery-check.service
 docker.socket                            systemd-binfmt.service
 dpkg-db-backup.service                   systemd-boot-check-no-failures.service
 dpkg-db-backup.timer                     systemd-bsod.service
 e2scrub@.service                         systemd-confext.service
 e2scrub_all.service                      systemd-coredump@.service.d
 e2scrub_all.timer                        systemd-exit.service
 e2scrub_fail@.service                    systemd-firstboot.service
 e2scrub_reap.service                     systemd-fsck-root.service
 emergency.service                        systemd-fsck@.service
 emergency.target                         systemd-fsckd.service
 esm-cache.service                        systemd-fsckd.socket
 exit.target                              systemd-growfs-root.service
 factory-reset.target                     systemd-growfs@.service
 final.target                             systemd-halt.service
 finalrd.service                          systemd-hibernate-resume.service
 first-boot-complete.target               systemd-hibernate.service
 friendly-recovery.service                systemd-hostnamed.service
 friendly-recovery.target                 systemd-hwdb-update.service
 fstrim.service                           systemd-hybrid-sleep.service
 fstrim.timer                             systemd-initctl.service
 fwupd-offline-update.service             systemd-initctl.socket
 fwupd-refresh.service                    systemd-journal-catalog-update.service
 fwupd-refresh.timer                      systemd-journal-flush.service
 fwupd.service                            systemd-journald-audit.socket
 getty-pre.target                         systemd-journald-dev-log.socket
 getty-static.service                     systemd-journald-varlink@.socket
 getty.target                             systemd-journald.service
 getty.target.wants                       systemd-journald.service.d
 getty@.service                           systemd-journald.socket
 graphical.target                         systemd-journald@.service
 graphical.target.wants                   systemd-journald@.socket
 grub-common.service                      systemd-kexec.service
 grub-initrd-fallback.service             systemd-localed.service
 halt.target                              systemd-localed.service.d
 halt.target.wants                        systemd-logind.service
 hibernate.target                         systemd-logind.service.d
 hwclock.service                          systemd-machine-id-commit.service
 hybrid-sleep.target                      systemd-modules-load.service
 initrd-cleanup.service                   systemd-network-generator.service
 initrd-fs.target                         systemd-networkd-wait-online.service
 initrd-parse-etc.service                 systemd-networkd-wait-online@.service
 initrd-root-device.target                systemd-networkd.service
 initrd-root-device.target.wants          systemd-networkd.socket
 initrd-root-fs.target                    systemd-pcrextend.socket
 initrd-root-fs.target.wants              systemd-pcrextend@.service
 initrd-switch-root.service               systemd-pcrfs-root.service
 initrd-switch-root.target                systemd-pcrfs@.service
 initrd-switch-root.target.wants          systemd-pcrlock-file-system.service
 initrd-udevadm-cleanup-db.service        systemd-pcrlock-firmware-code.service
 initrd-usr-fs.target                     systemd-pcrlock-firmware-config.service
 initrd.target                            systemd-pcrlock-machine-id.service
 initrd.target.wants                      systemd-pcrlock-make-policy.service
 integritysetup-pre.target                systemd-pcrlock-secureboot-authority.service
 integritysetup.target                    systemd-pcrlock-secureboot-policy.service
 ipp-usb.service                          systemd-pcrmachine.service
 iscsid.service                           systemd-pcrphase-initrd.service
 iscsid.socket                            systemd-pcrphase-sysinit.service
 kexec.target                             systemd-pcrphase.service
 kexec.target.wants                       systemd-poweroff.service
 keyboard-setup.service                   systemd-pstore.service
 kmod-static-nodes.service                systemd-quotacheck.service
 kmod.service                             systemd-random-seed.service
 kubelet.service                          systemd-reboot.service
 kubelet.service.d                        systemd-remount-fs.service
 ldconfig.service                         systemd-repart.service
 lightdm.service                          systemd-resolved.service
 lm-sensors.service                       systemd-rfkill.service
 local-fs-pre.target                      systemd-rfkill.socket
 local-fs.target                          systemd-soft-reboot.service
 logrotate.service                        systemd-storagetm.service
 logrotate.timer                          systemd-suspend-then-hibernate.service
 lvm2-lvmpolld.service                    systemd-suspend.service
 lvm2-lvmpolld.socket                     systemd-sysctl.service
 lvm2-monitor.service                     systemd-sysext.service
 lxd-agent.service                        systemd-sysext.socket
 lxd-installer.socket                     systemd-sysext@.service
 lxd-installer@.service                   systemd-sysupdate-reboot.service
 machine.slice                            systemd-sysupdate-reboot.timer
 man-db.service                           systemd-sysupdate.service
 man-db.timer                             systemd-sysupdate.timer
 mdadm-grow-continue@.service             systemd-sysusers.service
 mdadm-last-resort@.service               systemd-time-wait-sync.service
 mdadm-last-resort@.timer                 systemd-timedated.service
 mdcheck_continue.service                 systemd-timesyncd.service
 mdcheck_continue.timer                   systemd-tmpfiles-clean.service
 mdcheck_start.service                    systemd-tmpfiles-clean.timer
 mdcheck_start.timer                      systemd-tmpfiles-setup-dev-early.service
 mdmon@.service                           systemd-tmpfiles-setup-dev.service
 mdmonitor-oneshot.service                systemd-tmpfiles-setup.service
 mdmonitor-oneshot.timer                  systemd-tpm2-setup-early.service
 mdmonitor.service                        systemd-tpm2-setup.service
 modprobe@.service                        systemd-udev-settle.service
 motd-news.service                        systemd-udev-trigger.service
 motd-news.timer                          systemd-udevd-control.socket
 multi-user.target                        systemd-udevd-kernel.socket
 multi-user.target.wants                  systemd-udevd.service
 multipath-tools-boot.service             systemd-udevd.service.d
 multipath-tools.service                  systemd-update-done.service
 multipathd.service                       systemd-update-utmp-runlevel.service
 multipathd.socket                        systemd-update-utmp.service
 network-online.target                    systemd-user-sessions.service
 network-pre.target                       systemd-volatile-root.service
 network.target                           tigervncserver@.service
 networkd-dispatcher.service              time-set.target
 nftables.service                         time-sync.target
 nm-priv-helper.service                   timers.target
 nss-lookup.target                        timers.target.wants
 nss-user-lookup.target                   tpm-udev.path
 open-iscsi.service                       tpm-udev.service
 open-vm-tools.service                    ua-reboot-cmds.service
 packagekit-offline-update.service        ua-timer.service
 packagekit.service                       ua-timer.timer
 pam_namespace.service                    ubuntu-advantage.service
 paths.target                             ubuntu-fan.service
 phpsessionclean.service                  udev.service
 phpsessionclean.timer                    udisks2.service
 plymouth-halt.service                    ufw.service
 plymouth-kexec.service                   umount.target
 plymouth-log.service                     unattended-upgrades.service
 plymouth-poweroff.service                update-notifier-download.service
 plymouth-quit-wait.service               update-notifier-download.timer
 plymouth-quit.service                    update-notifier-motd.service
 plymouth-read-write.service              update-notifier-motd.timer
 plymouth-reboot.service                  upower.service
 plymouth-start.service                   usb-gadget.target
 plymouth-switch-root-initramfs.service   usb_modeswitch@.service
 plymouth-switch-root.service             usbmuxd.service
 plymouth.service                         user-.slice.d
 podman-auto-update.service               user-runtime-dir@.service
 podman-auto-update.timer                 user.slice
 podman-clean-transient.service           user@.service
 podman-kube@.service                     user@.service.d
 podman-restart.service                   user@0.service.d
 podman.service                           uuidd.service
 podman.socket                            uuidd.socket
 polkit.service                           veritysetup-pre.target
 pollinate.service                        veritysetup.target
 poweroff.target                          vgauth.service
 poweroff.target.wants                    wacom-inputattach@.service
 printer.target                           whoopsie.path
 proc-sys-fs-binfmt_misc.automount        whoopsie.service
 proc-sys-fs-binfmt_misc.mount            wpa_supplicant-nl80211@.service
 procps.service                           wpa_supplicant-wired@.service
 pulseaudio-enable-autospawn.service      wpa_supplicant.service
 quotaon.service                          wpa_supplicant@.service
 rc-local.service                         x11-common.service
 rc-local.service.d                       xfs_scrub@.service
 reboot.target                            xfs_scrub_all.service
 reboot.target.wants                      xfs_scrub_all.timer
 remote-cryptsetup.target                 xfs_scrub_fail@.service
 remote-fs-pre.target
controlplane:/usr/lib/systemd/system$ cat kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
controlplane:/usr/lib/systemd/system$ /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
bash: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf: Permission denied
controlplane:/usr/lib/systemd/system$ cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
controlplane:/usr/lib/systemd/system$ ^C
controlplane:/usr/lib/systemd/system$ cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.10"
controlplane:/usr/lib/systemd/system$ [ -f /etc/default/kubelet ] && sudo cat /etc/default/kubelet
KUBELET_EXTRA_ARGS="--container-runtime-endpoint unix:///run/containerd/containerd.sock --cgroup-driver=systemd --eviction-hard imagefs.available<5%,memory.available<100Mi,nodefs.available<5% --fail-swap-on=false"
controlplane:/usr/lib/systemd/system$ sudo sed -n '1,200p' /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerRuntimeEndpoint: ""
cpuManagerReconcilePeriod: 0s
crashLoopBackOff: {}
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMaximumGCAge: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
    text:
      infoBufferSize: "0"
  verbosity: 0
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
controlplane:/usr/lib/systemd/system$ kubectl get nodes
NAME           STATUS     ROLES           AGE     VERSION
controlplane   Ready      control-plane   3d19h   v1.33.2
node01         NotReady   <none>          3d19h   v1.33.2
controlplane:/usr/lib/systemd/system$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5869d7778c-9zhmq   0/1     Pending   0          3m59s
controlplane:/usr/lib/systemd/system$ kubectl describe pod nginx-5869d7778c-9zhmq
Name:             nginx-5869d7778c-9zhmq
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           app=nginx
                  pod-template-hash=5869d7778c
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Controlled By:    ReplicaSet/nginx-5869d7778c
Containers:
  nginx:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5rm47 (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  kube-api-access-5rm47:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  4m19s  default-scheduler  0/2 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 1 node(s) had untolerated taint {node.kubernetes.io/unreachable: }. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
controlplane:/usr/lib/systemd/system$ 