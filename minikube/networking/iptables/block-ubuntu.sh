iptables -t filter -A OUTPUT -p tcp --dport 443 -d www.ubuntu.com -j REJECT
iptables -t filter -A OUTPUT -p tcp --dport 80 -d www.ubuntu.com -j REJECT
iptables -L -vn

