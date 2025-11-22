#!/usr/bin/env bash
SERVER=${SERVER:-127.0.0.1}
PORT=${PORT:-1053}
CMD=${1:-all}
DOMAIN=${2:-www.example.test}
IP=${IP:-10.0.0.1}

trace_cmd() { dig @"$SERVER" -p "$PORT" +trace "$DOMAIN"; }
soa_cmd() {
  dig @"$SERVER" -p "$PORT" . SOA +short
  dig @"$SERVER" -p "$PORT" test. SOA +short
  dig @"$SERVER" -p "$PORT" example.test. SOA +short
}
ns_cmd() {
  dig @"$SERVER" -p "$PORT" . NS +short
  dig @"$SERVER" -p "$PORT" test. NS +short
  dig @"$SERVER" -p "$PORT" example.test. NS +short
}
forward_cmd() {
  dig @"$SERVER" -p "$PORT" "$DOMAIN" A
  dig @"$SERVER" -p "$PORT" "$DOMAIN" AAAA
}
reverse_cmd() { dig @"$SERVER" -p "$PORT" -x "$IP"; }
norec_cmd() { dig @"$SERVER" -p "$PORT" +norecurse "$DOMAIN" A; }
dnssec_cmd() { dig @"$SERVER" -p "$PORT" "$DOMAIN" A +dnssec; }

auth_direct_cmd() {
  NS_NAME=$(dig @"$SERVER" -p "$PORT" example.test. NS +short | head -n1)
  if [ -z "$NS_NAME" ]; then
    echo "no NS found for example.test"
    return 1
  fi
  NS_IP=$(dig @"$SERVER" -p "$PORT" "$NS_NAME" A +short | head -n1)
  if [ -z "$NS_IP" ]; then
    echo "no A record found for $NS_NAME (try adding glue A record in parent zone)"
    return 1
  fi
  dig @"$NS_IP" -p "$PORT" example.test. SOA
}

case "$CMD" in
  help)
    echo "usage: $0 <command> [domain]"
    echo "commands: all trace soa ns forward reverse norec dnssec auth"
    echo "env overrides: SERVER PORT IP"
    exit 0
    ;;
  all)
    echo ">>> TRACE"; trace_cmd; echo
    echo ">>> SOA"; soa_cmd; echo
    echo ">>> NS"; ns_cmd; echo
    echo ">>> FORWARD"; forward_cmd; echo
    echo ">>> REVERSE"; reverse_cmd; echo
    echo ">>> NON-RECURSIVE"; norec_cmd; echo
    echo ">>> DNSSEC"; dnssec_cmd; echo
    echo ">>> AUTHORITATIVE DIRECT"; auth_direct_cmd; echo
    ;;
  trace) trace_cmd ;;
  soa) soa_cmd ;;
  ns) ns_cmd ;;
  forward) forward_cmd ;;
  reverse) reverse_cmd ;;
  norec) norec_cmd ;;
  dnssec) dnssec_cmd ;;
  auth) auth_direct_cmd ;;
  *)
    echo "unknown command: $CMD"
    echo "run '$0 help' for usage"
    exit 2
    ;;
esac

