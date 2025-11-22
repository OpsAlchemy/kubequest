ss -lntu | grep 1053 || true
dig @127.0.0.1 -p 1053 . NS +short
dig @127.0.0.2 -p 1053 test. NS +short
dig @127.0.0.3 -p 1053 example.test. NS +short
dig @127.0.0.4 -p 1053 www.example.test A +short

