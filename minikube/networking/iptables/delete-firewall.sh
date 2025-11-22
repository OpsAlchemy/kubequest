#!/bin/bash

# 1. Set the ACCEPT Policy
iptables -P INPUT    ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# 2. Flush all the rules
iptables -t filter -F
iptables -t nat    -F
iptables -t mangle -F
iptables  -t raw    -F

# 3. Delete user defined chain if any
iptables -X
