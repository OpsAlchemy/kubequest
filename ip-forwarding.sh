udo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/^#net\.ipv4\.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

