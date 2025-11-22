#!/usr/bin/env bash
set -euo pipefail
sudo awk '!/ns\.root(\s|$)|ns\.test(\s|$)|ns\.example\.test(\s|$)/' /etc/hosts > /tmp/hosts.$$ \
  && sudo mv /tmp/hosts.$$ /etc/hosts

