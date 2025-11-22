sudo nohup ncat -kl 25 > /var/log/ncat-25.log 2>&1 &
# note: -k keeps listening after each connection; remove -k if you want single-shot
# disown optional if you started from interactive shell:
disown


sudo pkill -f "ncat .*:25"    # crude but works
# or find PID and kill
ps aux | grep '[n]cat' 
sudo kill <pid>

apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update
apt-get install -y nginx || \
( cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
  sed -i 's|mirrors.edge.kernel.org|archive.ubuntu.com|g' /etc/apt/sources.list && \
  apt-get update && apt-get install -y nginx )


Setting up nginx (1.18.0-6ubuntu14.7) ...
Processing triggers for ufw (0.36.1-4ubuntu0.1) ...
Processing triggers for man-db (2.10.2-1) ...
Processing triggers for libc-bin (2.35-0ubuntu3.5) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
root@playground:/home/vagrant# iptable -t filter -A INPUT -p tcp --dport 80 -j DROP
Command 'iptable' not found, did you mean:
  command 'ptable' from deb xcrysden (1.6.2-4)
  command 'iptables' from deb iptables (1.8.7-1ubuntu5.2)
Try: apt install <deb name>
root@playground:/home/vagrant# iptables -t filter -A INPUT -p tcp --dport 80 -j DROP
root@playground:/home/vagrant# iptables -vn -L
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    4   176 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:25
    5   268 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
root@playground:/home/vagrant# iptable -I INPUT -p udp --dport 69 -j DROP
Command 'iptable' not found, did you mean:
  command 'iptables' from deb iptables (1.8.7-1ubuntu5.2)
  command 'ptable' from deb xcrysden (1.6.2-4)
Try: apt install <deb name>
root@playground:/home/vagrant# iptables -I INPUT -p udp --dport 69 -j DROP
root@playground:/home/vagrant# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
DROP       udp  --  anywhere             anywhere             udp dpt:tftp
DROP       tcp  --  anywhere             anywhere             tcp dpt:smtp
DROP       tcp  --  anywhere             anywhere             tcp dpt:http

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
root@playground:/home/vagrant# iptables -L -vn
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:69
    6   264 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:25
    7   356 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
root@playground:/home/vagrant# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:69
    6   264 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:25
    7   356 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
root@playground:/home/vagrant#

