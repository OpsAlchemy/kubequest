ip addr show lo | grep 127.0.0.
sudo ip addr add 127.0.0.2/8 dev lo || true
sudo ip addr add 127.0.0.3/8 dev lo || true
sudo ip addr add 127.0.0.4/8 dev lo || true

