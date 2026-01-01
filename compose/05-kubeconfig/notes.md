
~/.kube                                                                                                                      14:23:22
❯ kind get cluster
Gets one of [clusters, nodes, kubeconfig]

Usage:
  kind get [flags]
  kind get [command]

Available Commands:
  clusters    Lists existing kind clusters by their name
  kubeconfig  Prints cluster kubeconfig
  nodes       Lists existing kind nodes by their name

Flags:
  -h, --help   help for get

Global Flags:
  -q, --quiet             silence all stderr output
  -v, --verbosity int32   info log verbosity, higher value produces more output

Use "kind get [command] --help" for more information about a command.
ERROR: Subcommand is required

~/.kube                                                                                                                      14:24:45
❯ kind get clusters
gatewayapi

~/.kube                                                                                                                      14:24:53
❯ # Get kubeconfig for gatewayapi cluster
kind get kubeconfig --name=gatewayapi > /tmp/gatewayapi-kubeconfig.yaml

# Show the structure
cat /tmp/gatewayapi-kubeconfig.yaml
zsh: command not found: #
zsh: command not found: #
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJS0RYandhOW1KNll3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1ERXdOekE0TlRoYUZ3MHpOVEV5TXpBd056RXpOVGhhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUM1OHpsZnJGRUJRZHZuRzJ6MzBvQ09zODJnTldnUlNsWW5ZNGgwUkVtSE5DOVVYWmFNUm1hVHFCQ1kKT2pDbW9nMVhaYlFQcTE5MHFGTkV1ZDk2MDRjS3FhTFhHbGhuR20wZEQ1dWFtN3NsQngrQURmMzErbEhXYTNsSgpGU3A1WFlIMGxpb3dWMHpQVmN5RlpDZjk0UTIxejVMS1lvRmdXWHdTMG5oZUZ5WWZPdjFXWUV3cVExZVFlS0RGCjljbFNiQ0VpbEtUbDgzZng1MXZ1YThLcGExTmt3TG1tdzFBSHZkZXRBUnZBUDk2Zm5zTm94SFY0YVM3YVNTM1kKQkJUeC9SWExPaFVJRXFjbFZSSzNyeEF4T2NUYnVqaCtZRzh3Nmwrc3VBY296QmtNZmNzcGY4UjdxMm4wTkdkcAp4eGYvZG9WeUQxK200N3dKVzIyTDcxalN6OXNUQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTRXByTko1dmVOQU1kb1BWUlJ4cjJvUUpqUytqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmM5RnpOSEhTaAoyZnhJZ0l0azZEUVZRc3BpN0ZZcURKd3pKdFczZmx6ZHBnckF0STM4VTdmc0NhcnpFaFpQVmY3ODR2OTdFWHBDCmZabHRGVXlXL2xvWVlDZ1hnSGo1Sjh6MjNQSGxVVklJOUU0c1BYM1dKWlBjWmtsSWpyNFdDOFY1dzNpSms2aHoKZS9xdDhpb291QkFGNVlHM24ycTlSSUFuN0h3N3M0UCs5ZXJMOGlKbC80T0VOQWpNemRYMzJvZmJUenNzQlcyVwppelU4YWpVVnE0RkVRZW9zT3JmcWQvNURwcEJqb3lpZlJ1SXNLaDJNdG1vcFBtV3VLcTVLemI3M3BNcTJSeE5OClVWRDdXZWFzdTAxWVQrdEZTMlRqTFZyNGZxL1dYRjhDM0JUUHltZ3lUQWVxcXk4SzhVQlVFTnVBMG1FS1VONEcKcnVqbFZ1dEM1M0VXCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://127.0.0.1:39619
  name: kind-gatewayapi
contexts:
- context:
    cluster: kind-gatewayapi
    user: kind-gatewayapi
  name: kind-gatewayapi
current-context: kind-gatewayapi
kind: Config
users:
- name: kind-gatewayapi
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJTGh0ajRISmR5Nkl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1ERXdOekE0TlRoYUZ3MHlOekF4TURFd056RXpOVGhhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDcWtwcEMKbndWQnNmMjFId2dGQ1Rod0dQR2RpcUtSVk42RVF3Z0Z3WnkzWjlNb0llRWZNa1MvYjlQOGxEY0d2Vk0vR3d3Rwp5RG4rcFJMK3ZYT2JObVNnblMveHNRK3NVamZnTERLb2V3ZHFBYXJCUG0vaHIxTXpPSXErdUdvMWRBeHZpcHNvCjNPQjc0Y0VsQmIxd2pxb3U1akwxRzNjNW9pbnRUSmFjcjJPcjZ3Z2JSaUsxaEF0ZjlPL2tFbndNRkQvdnV2NmMKSXZwVVB0aUtwUUJGZnhLRWdQYjZYOVZhc2J5d1Jab3JsS2pvSWlpVTNZM3ZBQ1FqSlExYVlEUm1JYW12bVNURQoyKzl4RDUweGY5MDNRSnp5UG45Umx0RzhPYnlHRTkvVW5IL1g2VER3UGRydFpwMjlXWHAxZDIrd3VyMld4a01PCnREZDZUbGNuV01kMStKL3JBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRklTbXMwbm05NDBBeDJnOQpWRkhHdmFoQW1OTDZNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJlUXk2N3YvMVdFUVB5bXV6L2V4NHlNdHgwCjY3S3BWQzkxUVZ1aEFjNUpZMWwwSnp3bWxjRzJrUk1lK2VFM3Erd1pEMTRmYVhKcjdrbGFjQkcxMXRsZUZKRXoKelZCVVArU3Jpbk9yN05wS3VlMGdmZ2FzTTJ4UkFRVWkyOXQvem5FTjZ3a1BzRzkvbUFBSGZZWTAzVjlxSmovMwp2N3NFcElrR3lxNzMzek5qRC81bHEvTFgvUWppeHc4MzE1b0h1WHMzekhmM3pONGkrZFhRQnAxTlk0TGVCQzFYCnVUa3lhbXJRR3ZQRTBsT2llTUlLQ3pkQ1k0cXlpb04yL2Jqd21KZStXYTBpNEorQ3VKQ0MyWjVKYVJpVUM1QUQKdW94Z1lYSXFSazlkekZ2SkU2WnRvWG9VMDVlS0oyNHFBaEd4UEViV2ptMDZJVEtwc3J3MCs0aUVLY09mCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBcXBLYVFwOEZRYkg5dFI4SUJRazRjQmp4bllxaWtWVGVoRU1JQmNHY3QyZlRLQ0hoCkh6SkV2Mi9UL0pRM0JyMVRQeHNNQnNnNS9xVVMvcjF6bXpaa29KMHY4YkVQckZJMzRDd3lxSHNIYWdHcXdUNXYKNGE5VE16aUt2cmhxTlhRTWI0cWJLTnpnZStIQkpRVzljSTZxTHVZeTlSdDNPYUlwN1V5V25LOWpxK3NJRzBZaQp0WVFMWC9UdjVCSjhEQlEvNzdyK25DTDZWRDdZaXFVQVJYOFNoSUQyK2wvVldyRzhzRVdhSzVTbzZDSW9sTjJOCjd3QWtJeVVOV21BMFppR3ByNWtreE52dmNRK2RNWC9kTjBDYzhqNS9VWmJSdkRtOGhoUGYxSngvMStrdzhEM2EKN1dhZHZWbDZkWGR2c0xxOWxzWkREclEzZWs1WEoxakhkZmlmNndJREFRQUJBb0lCQUJJcUpPY0ZycFoxbG4rVQpkajJzWXQxcExVaC9nWVY1ajIxd0FxbUk3MHF4Y2Z3Rm5rYm5ZRjZFcHdOd1kwQnRVVndETjRUU0MzOEhPWjUxCmlCdFdMN2JTVm5ubUhHQlhySFNoTUU4MGlZWEJUTEVNbUV5UDU3WitNSG1wV096U3JCcGF4K0E4K1dPbjdISW8KQ2ltemxRTUQ1OEdtSGFHK2JRN3Zjalh0dXU4TlNXWFJRKzhtMHVYN2k1dGRUa3BXUkNKdEVYZzY5bmtLazF4LwpscHVHNS9RT2J3cDdrSVBYS0tuZTdYL1hRTnB6TCtSaHh3UVFxVllDUzhUMzZMVkVnMVZIbGV6OEpSQlVGNENvClRDUUM4SWgvVWY0TTBTWHd2Z1RJRXAyQlNWVThESWQzUHFhdk1RU2E2UmxZcnFmUHNFcXgwZ0tLSFhGM2ZjTDcKSXZadVFNRUNnWUVBM0cvQ21qZlJBY0lCVGJwYklYcXo2MEpjVEpZdDVDaEF3cEtYVjN5T3NmNGxDNG15MG1hcApNT2t5MWxkVXRMWnBaWTN2ejVqSE5rOUYyY3BiRjhRbHNyb3dPUzFjZ05XM1JVVExBaWZHRGpmak9uOTFiNHk2CjZ3T1hZSFlyRWszVXVrcm1tcTlRNlI1ek10bTNlNlNlRmlQSmovTzQzVUx1R2Z3MXNyanVmS3NDZ1lFQXhoZHEKZ0d5Z2wyellOSTc3ZWVmOVJRNTB2UGUwRFBKUGZWLzlXMldZWG1rMVQwNWVscWhEWXowRnhEWGo4aG9pZG5kTQpzZW42UUdueUdaMFQ3S0Uwc1pLWjlmaEZWWlhrYnM5dncxS3BsSlpCaG9uek1nVkVqeEw4ZGlwVVpTQmpuZHRjCmZmS3YvcncxdnpJdzZ0RDJ6Vk4vc21iQTFkT3hWTlFaQTZZZjZjRUNnWUVBZ0tBUi9HenZYMGcxL0lYdUlSWDUKSUNDanZPaXd0SDRzYzV5WUJLdWdsQW5JMGZleVNZVXYybU5vajV0N3lNcmJxeTlzTEVWb2tLOG5BaE5Lbmc2TgpOTUhoMjZzMVc5UFkwZWwzVDdXbm9xcEh3OTJWeDlabFJ6YmNRS1FUTStZSVovL0dtYUlNNDBvcVRCU3dOTXgwCmxsU2hpNGJhYXZsZjkvZXIyYktCTG1zQ2dZRUFsSWJzS1B6SjhLQUJBRytRNlJma0ZBcEJ4NHBtNnlvb0pkWjYKVGpRLzZkSXkwWkx1WTBJb3ZOajlZT0FUV096MW1DUGRVcTBnSVhvT3Q5dktHNnZIcWJsRlRXTnBBVUlSZEhCKwoyVkk2cXBsNjZoaTNTM01kczdWRnJJZ1NuWHlLbE1yc2I5Y3UxTzVqMGtjYzNJUHYrWVk1QWhmL1VKU1lxd1VZCitGNXdJVUVDZ1lCdE9FNGhzQXJteDgrbFRHQUJKMHRSdjZkYzE5WFJlUFFYY2NUV3gyQWt1alM5b1dmSHduUmIKWHVZQkI3Yi9TV05jcVJiNTZjMTZRZWYrZzFPb1RObGpaeHZmblg2WUZoUnNOeXNYeUtxUnRZdHZUcXhUM2VjbQpYdTlKWXVpUmx1enBJSUc5S1QrVS95VU1qcjFVa0x3Nmw5dU9mcGtSVko1elF2VVFSeXdvcXc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=


~/.kube                                                                                                                      14:25:21
❯ sed -n '/certificate-authority-data:/,/^[[:space:]]*server:/p' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'certificate-authority-data:' | \
  cut -d':' -f2- | \
  tr -d ' ' | \
  base64 -d > /tmp/decoded-ca.crt

~/.kube                                                                                                                      14:28:18
❯ cat /tmp/decoded-ca.crt
-----BEGIN CERTIFICATE-----
MIIDBTCCAe2gAwIBAgIIKDXjwa9mJ6YwDQYJKoZIhvcNAQELBQAwFTETMBEGA1UE
AxMKa3ViZXJuZXRlczAeFw0yNjAxMDEwNzA4NThaFw0zNTEyMzAwNzEzNThaMBUx
EzARBgNVBAMTCmt1YmVybmV0ZXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC58zlfrFEBQdvnG2z30oCOs82gNWgRSlYnY4h0REmHNC9UXZaMRmaTqBCY
OjCmog1XZbQPq190qFNEud9604cKqaLXGlhnGm0dD5uam7slBx+ADf31+lHWa3lJ
FSp5XYH0liowV0zPVcyFZCf94Q21z5LKYoFgWXwS0nheFyYfOv1WYEwqQ1eQeKDF
9clSbCEilKTl83fx51vua8Kpa1NkwLmmw1AHvdetARvAP96fnsNoxHV4aS7aSS3Y
BBTx/RXLOhUIEqclVRK3rxAxOcTbujh+YG8w6l+suAcozBkMfcspf8R7q2n0NGdp
xxf/doVyD1+m47wJW22L71jSz9sTAgMBAAGjWTBXMA4GA1UdDwEB/wQEAwICpDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSEprNJ5veNAMdoPVRRxr2oQJjS+jAV
BgNVHREEDjAMggprdWJlcm5ldGVzMA0GCSqGSIb3DQEBCwUAA4IBAQBc9FzNHHSh
2fxIgItk6DQVQspi7FYqDJwzJtW3flzdpgrAtI38U7fsCarzEhZPVf784v97EXpC
fZltFUyW/loYYCgXgHj5J8z23PHlUVII9E4sPX3WJZPcZklIjr4WC8V5w3iJk6hz
e/qt8ioouBAF5YG3n2q9RIAn7Hw7s4P+9erL8iJl/4OENAjMzdX32ofbTzssBW2W
izU8ajUVq4FEQeosOrfqd/5DppBjoyifRuIsKh2MtmopPmWuKq5Kzb73pMq2RxNN
UVD7Weasu01YT+tFS2TjLVr4fq/WXF8C3BTPymgyTAeqqy8K8UBUENuA0mEKUN4G
rujlVutC53EW
-----END CERTIFICATE-----

~/.kube                                                                                                                      14:28:22
❯ openssl x509 -in /tmp/decoded-ca.crt -text -noout | head -30
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 2897472356293683110 (0x2835e3c1af6627a6)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: Jan  1 07:08:58 2026 GMT
            Not After : Dec 30 07:13:58 2035 GMT
        Subject: CN = kubernetes
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b9:f3:39:5f:ac:51:01:41:db:e7:1b:6c:f7:d2:
                    80:8e:b3:cd:a0:35:68:11:4a:56:27:63:88:74:44:
                    49:87:34:2f:54:5d:96:8c:46:66:93:a8:10:98:3a:
                    30:a6:a2:0d:57:65:b4:0f:ab:5f:74:a8:53:44:b9:
                    df:7a:d3:87:0a:a9:a2:d7:1a:58:67:1a:6d:1d:0f:
                    9b:9a:9b:bb:25:07:1f:80:0d:fd:f5:fa:51:d6:6b:
                    79:49:15:2a:79:5d:81:f4:96:2a:30:57:4c:cf:55:
                    cc:85:64:27:fd:e1:0d:b5:cf:92:ca:62:81:60:59:
                    7c:12:d2:78:5e:17:26:1f:3a:fd:56:60:4c:2a:43:
                    57:90:78:a0:c5:f5:c9:52:6c:21:22:94:a4:e5:f3:
                    77:f1:e7:5b:ee:6b:c2:a9:6b:53:64:c0:b9:a6:c3:
                    50:07:bd:d7:ad:01:1b:c0:3f:de:9f:9e:c3:68:c4:
                    75:78:69:2e:da:49:2d:d8:04:14:f1:fd:15:cb:3a:
                    15:08:12:a7:25:55:12:b7:af:10:31:39:c4:db:ba:
                    38:7e:60:6f:30:ea:5f:ac:b8:07:28:cc:19:0c:7d:
                    cb:29:7f:c4:7b:ab:69:f4:34:67:69:c7:17:ff:76:

~/.kube                                                                                                                      14:28:36
❯ awk '/client-certificate-data:/{flag=1} flag && /^[[:space:]]*client-key-data:/{flag=0} flag' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'client-certificate-data:' | \
  cut -d':' -f2- | \
  sed 's/^[[:space:]]*//' | \
  base64 -d > /tmp/decoded-client.crt

~/.kube                                                                                                                      14:28:57
❯ openssl x509 -in /tmp/decoded-client.crt -text -noout | head -30
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 3322358965758446498 (0x2e1b63e0725dcba2)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: Jan  1 07:08:58 2026 GMT
            Not After : Jan  1 07:13:58 2027 GMT
        Subject: O = kubeadm:cluster-admins, CN = kubernetes-admin
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:aa:92:9a:42:9f:05:41:b1:fd:b5:1f:08:05:09:
                    38:70:18:f1:9d:8a:a2:91:54:de:84:43:08:05:c1:
                    9c:b7:67:d3:28:21:e1:1f:32:44:bf:6f:d3:fc:94:
                    37:06:bd:53:3f:1b:0c:06:c8:39:fe:a5:12:fe:bd:
                    73:9b:36:64:a0:9d:2f:f1:b1:0f:ac:52:37:e0:2c:
                    32:a8:7b:07:6a:01:aa:c1:3e:6f:e1:af:53:33:38:
                    8a:be:b8:6a:35:74:0c:6f:8a:9b:28:dc:e0:7b:e1:
                    c1:25:05:bd:70:8e:aa:2e:e6:32:f5:1b:77:39:a2:
                    29:ed:4c:96:9c:af:63:ab:eb:08:1b:46:22:b5:84:
                    0b:5f:f4:ef:e4:12:7c:0c:14:3f:ef:ba:fe:9c:22:
                    fa:54:3e:d8:8a:a5:00:45:7f:12:84:80:f6:fa:5f:
                    d5:5a:b1:bc:b0:45:9a:2b:94:a8:e8:22:28:94:dd:
                    8d:ef:00:24:23:25:0d:5a:60:34:66:21:a9:af:99:
                    24:c4:db:ef:71:0f:9d:31:7f:dd:37:40:9c:f2:3e:
                    7f:51:96:d1:bc:39:bc:86:13:df:d4:9c:7f:d7:e9:
                    30:f0:3d:da:ed:66:9d:bd:59:7a:75:77:6f:b0:ba:

~/.kube                                                                                                                      14:29:02
❯ awk '/client-key-data:/{flag=1} flag && /^[[:space:]]*token:/{flag=0} flag' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'client-key-data:' | \
  cut -d':' -f2- | \
  sed 's/^[[:space:]]*//' | \
  base64 -d > /tmp/decoded-client.key

~/.kube                                                                                                                      14:29:18
❯ file /tmp/decoded-client.key
/tmp/decoded-client.key: PEM RSA private key

~/.kube                                                                                                                      14:29:22
❯ # Using yq (if installed)
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.clusters[0].cluster.certificate-authority-data' | base64 -d > /tmp/ca.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-certificate-data' | base64 -d > /tmp/client.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-key-data' | base64 -d > /tmp/client.key

# Using grep/sed only
cat /tmp/gatewayapi-kubeconfig.yaml | grep -A1 -B1 'certificate-authority-data:' | tail -1 | base64 -d > /tmp/ca2.crt
zsh: unknown file attribute: i
jq: error: authority/0 is not defined at <top-level>, line 1:
.clusters[0].cluster.certificate-authority-data
jq: error: data/0 is not defined at <top-level>, line 1:
.clusters[0].cluster.certificate-authority-data
jq: 2 compile errors
jq: error: certificate/0 is not defined at <top-level>, line 1:
.users[0].user.client-certificate-data
jq: error: data/0 is not defined at <top-level>, line 1:
.users[0].user.client-certificate-data
jq: 2 compile errors
jq: error: key/0 is not defined at <top-level>, line 1:
.users[0].user.client-key-data
jq: error: data/0 is not defined at <top-level>, line 1:
.users[0].user.client-key-data
jq: 2 compile errors
zsh: command not found: #
base64: invalid input

~/.kube                                                                                                                      14:29:36
❯