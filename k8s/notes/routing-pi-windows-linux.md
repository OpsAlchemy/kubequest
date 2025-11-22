Absolutely. Here is a clean end-to-end guide that matches what you just built and verified.

# Goal

From Raspberry Pi `192.168.1.14` reach VMs on the libvirt network `192.168.121.0/24` that live behind your host `192.168.1.15`, and curl a service on the K8s master `192.168.121.187:30080`.

# Topology

* LAN 192.168.1.0/24

  * Raspberry Pi Wi-Fi: `wlan0 = 192.168.1.14`
  * Host laptop or PC: `wlp4s0 = 192.168.1.15`
* Libvirt NAT network on host

  * `virbr0 = 192.168.121.1/24`
  * K8s master VM: `192.168.121.187`
* We will route Pi → host → virbr0 → VM.
* We will use NAT on the host so VMs reply without extra routes.

# Step 1. Route on the Raspberry Pi

Tell the Pi to send `192.168.121.0/24` via the host.

```bash
# one-time route
sudo ip route add 192.168.121.0/24 via 192.168.1.15 dev wlan0

# verify the kernel decision
ip route get 192.168.121.187
```

Make it persistent (pick one):

**A) systemd**

```bash
sudo tee /etc/systemd/system/static-route-192_168_121.service >/dev/null <<'EOF'
[Unit]
Description=Static route to 192.168.121.0/24 via 192.168.1.15 on wlan0
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ip route replace 192.168.121.0/24 via 192.168.1.15 dev wlan0

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now static-route-192_168_121.service
```

**B) NetworkManager**

```bash
nmcli con show
sudo nmcli con modify "<your Wi-Fi profile>" +ipv4.routes "192.168.121.0/24 192.168.1.15"
sudo nmcli con up "<your Wi-Fi profile>"
```

# Step 2. Enable routing and NAT on the host 192.168.1.15

Enable IPv4 forwarding:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-forward.conf
sudo sysctl --system
```

Insert forwarding and NAT rules **at the top** so they run before libvirt’s default filters:

```bash
# allow new flows from LAN to virbr0
sudo iptables -I FORWARD 1 -i wlp4s0 -o virbr0 -s 192.168.1.0/24 -d 192.168.121.0/24 -j ACCEPT
# allow return traffic from virbr0 back to LAN
sudo iptables -I FORWARD 1 -i virbr0 -o wlp4s0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# masquerade LAN addresses when they exit to virbr0
sudo iptables -t nat -I POSTROUTING 1 -s 192.168.1.0/24 -o virbr0 -j MASQUERADE
```

Persist the rules:

```bash
sudo apt-get install -y iptables-persistent netfilter-persistent
sudo netfilter-persistent save
```

Quick checks on the host:

```bash
# virbr0 must exist and be 192.168.121.1/24
ip -4 addr show virbr0
ip route | grep 192.168.121.0/24

# make sure our rules are at the top and counting packets
sudo iptables -vnL FORWARD --line-numbers
sudo iptables -t nat -vnL POSTROUTING --line-numbers
```

# Step 3. Optional Windows client route

On any Windows box on 192.168.1.0/24, add a persistent route so it also uses `192.168.1.15` as the next hop.

**CMD (Run as Administrator)**

```cmd
route -p add 192.168.121.0 mask 255.255.255.0 192.168.1.15 metric 5
route print -4
```

**PowerShell (Run as Administrator)**

```powershell
$idx = (Get-NetIPConfiguration | Where-Object {$_.IPv4Address.IPAddress -like '192.168.1.*'}).InterfaceIndex
New-NetRoute -DestinationPrefix 192.168.121.0/24 -NextHop 192.168.1.15 -InterfaceIndex $idx -RouteMetric 5 -AddressFamily IPv4
netsh interface ipv4 add route prefix=192.168.121.0/24 interface=$idx nexthop=192.168.1.15 store=persistent
```

# Step 4. Verify end to end

From the Pi:

```bash
ping -c1 192.168.121.187
curl http://192.168.121.187:30080
```

From the host, you can observe forwarding actually happening:

```bash
sudo tcpdump -ni wlp4s0 icmp or tcp port 30080
sudo tcpdump -ni virbr0  icmp or tcp port 30080
```

# Why this was failing before

* Libvirt default NAT network allows VMs to go out, but blocks unsolicited forwarding from LAN to virbr0.
* When the Pi sent traffic to 192.168.121.0/24 via 192.168.1.15, the host replied “Destination Port Unreachable” because forwarding was blocked by iptables chains.
* Inserting ACCEPT and MASQUERADE rules at the top allowed the host to act as a router and NAT for LAN to virbr0.

# Troubleshooting checklist

1. On host, virbr0 exists and is 192.168.121.1/24:

   ```bash
   ip -4 addr show virbr0
   ip route | grep 192.168.121.0/24
   ```
2. IP forwarding is on:

   ```bash
   sysctl net.ipv4.ip_forward
   ```
3. Our iptables rules are at the top and counters increase:

   ```bash
   sudo iptables -vnL FORWARD --line-numbers
   sudo iptables -t nat -vnL POSTROUTING --line-numbers
   ```
4. Watch packets:

   ```bash
   sudo tcpdump -ni wlp4s0 icmp
   sudo tcpdump -ni virbr0 icmp
   ```
5. Pi has the route and uses `wlan0`:

   ```bash
   ip route get 192.168.121.187
   ```
6. If you still see unreachable from 192.168.1.15, your ACCEPT rules may be below libvirt’s chains. Use `-I 1` again to push them to the top.

# Alternative without NAT (pure routing)

Use this if you want VMs to see the real Pi source IP.

* Remove MASQUERADE line from the host.
* Keep the two FORWARD ACCEPT rules.
* On each VM (or on the libvirt network router) add a return route:

  ```bash
  sudo ip route add 192.168.1.0/24 via 192.168.121.1
  ```
* Pi route from Step 1 stays the same.

# Revert changes

Pi:

```bash
sudo ip route del 192.168.121.0/24 via 192.168.1.15 dev wlan0
```

Host:

```bash
sudo iptables -D FORWARD 1   # run repeatedly until the two inserted rules are gone
sudo iptables -t nat -D POSTROUTING 1
sudo netfilter-persistent save
# If you wish, disable forwarding again:
sudo sysctl -w net.ipv4.ip_forward=0
sudo rm /etc/sysctl.d/99-forward.conf
```

Windows:

```cmd
route delete 192.168.121.0
```

# Quick reference summary

* Pi static route: `ip route add 192.168.121.0/24 via 192.168.1.15 dev wlan0`
* Host forwarding on: `net.ipv4.ip_forward=1`
* Host iptables inserts:

  ```
  iptables -I FORWARD 1 -i wlp4s0 -o virbr0 -s 192.168.1.0/24 -d 192.168.121.0/24 -j ACCEPT
  iptables -I FORWARD 1 -i virbr0 -o wlp4s0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  iptables -t nat -I POSTROUTING 1 -s 192.168.1.0/24 -o virbr0 -j MASQUERADE
  ```
* Windows persistent route: `route -p add 192.168.121.0 mask 255.255.255.0 192.168.1.15`

This is exactly the setup you validated when `Invoke-WebRequest` returned HTTP 200 with the JSON from your K8s service.
