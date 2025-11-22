#!/bin/sh

PORT=${PORT:-8080}
TEXT=${TEXT:-netkit}

echo "Starting: $TEXT on port $PORT"
echo "Tools available: curl, ping, dig, nslookup, nc, tcpdump, iperf3, nmap, redis, psql, mysql"

python3 /app/api.py &
redis-server --daemonize yes

tail -f /dev/null
