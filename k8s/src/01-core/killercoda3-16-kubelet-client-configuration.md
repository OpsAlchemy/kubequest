controlplane:~$ # view the config that kubelet uses to authenticate to the Kubernetes API
controlplane:~$ cat /etc/kubernetes/kubelet.conf > kubelet-config.txt
controlplane:~$ 
controlplane:~$ # view the certificate using openssl. Get the certificate file location from the 'kubelet.conf' file above. 
controlplane:~$ openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 974831920606495773 (0xd874c778776441d)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: Aug 19 08:58:32 2025 GMT
            Not After : Aug 19 09:03:32 2026 GMT
        Subject: O = system:nodes, CN = system:node:controlplane
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:dc:13:14:1f:d9:96:70:c1:eb:36:70:e3:56:0d:
                    ab:87:ba:67:87:4e:c3:f5:74:c1:72:1b:87:0f:e0:
                    11:bd:df:f6:91:08:cf:66:76:2b:c0:27:18:9f:6c:
                    3e:1c:c1:6b:cf:7c:50:0f:dd:30:7e:49:b8:30:d5:
                    5b:b1:dd:ee:cb:a2:ab:45:fb:56:bd:bf:94:ce:4a:
                    ff:f2:ec:96:19:07:23:ad:cf:6c:f0:21:60:07:a0:
                    3c:54:57:4e:a6:60:49:c6:98:14:89:b4:36:e6:2b:
                    3c:58:6a:c3:44:94:e2:92:d0:85:b6:7b:8d:a6:4a:
                    4f:64:68:c9:d6:59:e0:89:f4:ff:98:ad:b3:ed:04:
                    2d:bc:f5:7f:db:14:e5:f7:f8:ff:31:1d:ff:0c:86:
                    0d:91:5b:35:81:07:41:4f:43:6b:0f:61:6e:63:c4:
                    85:49:28:a2:40:b2:84:15:5d:bd:c6:3f:b1:62:06:
                    91:3a:a9:3b:ef:07:1a:29:ab:7e:df:67:8b:cf:e2:
                    08:bb:6b:c0:dc:01:9f:b8:04:8d:3b:69:36:28:d0:
                    d8:b3:68:f5:23:a2:73:c8:ef:3b:1a:c8:ab:20:03:
                    37:67:7f:16:b4:f6:25:bf:92:43:ae:0c:8f:89:c3:
                    4e:15:b2:a3:76:4e:80:8a:d3:03:79:ae:14:21:7c:
                    c0:07
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Authority Key Identifier: 
                A2:A0:23:2E:6A:36:52:9C:07:4B:59:91:30:95:6C:97:3F:B2:0C:FD
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        a8:98:c5:e3:1f:00:bc:2e:98:0e:04:01:c5:e0:f1:a5:0c:19:
        47:04:a1:74:64:77:38:0e:58:7c:42:68:d0:82:75:a4:ce:05:
        71:86:fe:3d:a5:ac:65:0c:82:f0:90:48:c3:78:30:df:3d:cc:
        ff:c2:a8:f9:bd:50:02:0f:26:11:dd:ca:0e:eb:cf:8d:05:75:
        f9:09:fb:a3:70:66:03:d4:22:a8:7b:07:c4:fd:07:ad:ee:87:
        5b:47:d4:5a:c1:98:f7:ad:e5:b4:31:9b:1c:2b:d7:ef:fc:9b:
        42:f4:1c:c4:0e:3c:30:2e:fd:68:1b:22:90:56:db:be:1d:88:
        9e:e8:1c:3a:25:29:ab:75:6e:b9:17:b1:77:20:52:50:ab:be:
        6b:df:2f:86:1d:63:17:90:26:6f:81:80:cb:c6:68:df:60:03:
        fc:1e:5c:cb:41:cc:aa:4b:05:98:6c:9a:b3:9d:eb:03:ef:17:
        48:77:1b:c1:73:3a:89:6c:ec:ba:d7:d9:82:1e:44:65:ec:1d:
        da:48:d2:8e:15:d9:08:6e:d2:fe:35:19:31:c2:40:22:22:4e:
        a3:56:4d:05:2b:9a:04:a5:a1:00:95:a8:8c:30:44:4d:1b:99:
        8f:eb:e0:d6:d7:ab:82:40:7f:fb:e0:0e:e0:e9:36:b7:d4:e5:
        ea:e6:a1:7e
controlplane:~$ 
controlplane:~$ 