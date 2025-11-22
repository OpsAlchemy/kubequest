#!/usr/bin/env bash
set -euo pipefail

echo "Enabling & starting systemd-resolved..."
if sudo systemctl enable --now systemd-resolved; then
  echo "systemd-resolved enabled."
else
  echo "Warning: failed to enable systemd-resolved (service may not exist)." >&2
fi

echo "Restoring /etc/resolv.conf symlink to systemd-resolved stub..."
sudo rm -f /etc/resolv.conf

if [ -e /run/systemd/resolve/stub-resolv.conf ]; then
  sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  echo "Linked to /run/systemd/resolve/stub-resolv.conf"
elif [ -e /run/systemd/resolve/resolv.conf ]; then
  sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
  echo "Linked to /run/systemd/resolve/resolv.conf"
else
  echo "No systemd-resolve resolv.conf file found. Leaving /etc/resolv.conf removed." >&2
  echo "You can create a temporary /etc/resolv.conf with e.g. 'nameserver 8.8.8.8' if necessary."
  exit 1
fi

echo "Status:"
systemctl status systemd-resolved --no-pager || true
resolvectl status || true

echo "Test DNS (nslookup google.com):"
nslookup google.com || echo "nslookup failed"

