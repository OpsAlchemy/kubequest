#!/usr/bin/env bash
set -euo pipefail

entries=(
"127.0.0.2 ns.root ns.root."
"127.0.0.3 ns.test ns.test."
"127.0.0.4 ns.example.test ns.example.test."
)

for e in "${entries[@]}"; do
  if ! grep -Fxq "$e" /etc/hosts; then
    echo "$e" | sudo tee -a /etc/hosts >/dev/null
  fi
done

