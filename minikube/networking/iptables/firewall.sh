#!/bin/bash
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -t raw -F
# dropping outgoing http and https traffic
iptables -A OUTPUT -p tcp --dport 80 -j DROP
iptables -A OUTPUT -p tcp --dport 443 -j DROP
