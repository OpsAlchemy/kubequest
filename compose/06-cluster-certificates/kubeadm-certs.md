# kubeadm Certificate Checks & Renewal

## Check Certificate Expiration

```bash
kubeadm certs check-expiration
kubeadm certs check-expiration -v=5
```

## Renew Certificates

```bash
kubeadm certs renew all
kubeadm certs renew all --dry-run
```

## Renew Specific Certificate

```bash
kubeadm certs renew apiserver
```
