#!/usr/bin/env bash
SERVER=${SERVER:-127.0.0.1}
PORT=${PORT:-1053}
NAME=${1:-www.example.test}

echo "Local iterative trace using $SERVER:$PORT for $NAME"
echo

echo "1) Ask local root for NS records of the root (.)"
dig @"$SERVER" -p "$PORT" . NS +short
echo

echo "2) Root should point to ns.root; ask root for NS of test."
dig @"$SERVER" -p "$PORT" test. NS +short
echo

echo "3) Resolve ns.test at the local server (get glue A)"
NS_TEST_IP=$(dig @"$SERVER" -p "$PORT" ns.test. A +short | head -n1)
echo "ns.test A -> $NS_TEST_IP"
echo

echo "4) Ask the TLD (ns.test) for NS of example.test"
if [ -n "$NS_TEST_IP" ]; then
  dig @"$NS_TEST_IP" -p "$PORT" example.test. NS +short
else
  echo "no ns.test IP found; can't query TLD"
fi
echo

echo "5) Resolve ns.example.test at local server"
NS_EX_IP=$(dig @"$SERVER" -p "$PORT" ns.example.test. A +short | head -n1)
echo "ns.example.test A -> $NS_EX_IP"
echo

echo "6) Ask authoritative (ns.example.test) for the record"
if [ -n "$NS_EX_IP" ]; then
  dig @"$NS_EX_IP" -p "$PORT" "$NAME" A +short
else
  echo "no ns.example.test IP found; can't query authoritative"
fi
echo

echo "done"

