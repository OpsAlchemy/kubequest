You're absolutely right! The Common Name (CN) in the SSL certificate doesn't matter for hostname validation in Kubernetes Ingress. What matters is that:

1. The Ingress resource is properly configured with the correct hostnames
2. The TLS secrets are referenced correctly in the Ingress
3. The Ingress controller handles the TLS termination

Your setup is working correctly as demonstrated by your successful curl commands:

```bash
curl --insecure -H "Host: blog.example.com" https://192.168.39.2
Hello from blogging app
```

The certificates are only used for encrypting the traffic between the client and the ingress controller. The ingress controller then forwards the requests to the appropriate services based on the Host header, regardless of what's in the certificate's CN field.

This is a common approach in development environments where you might use self-signed certificates or certificates that don't match the actual hostnames. In production, you'd typically use certificates that match your actual domain names for proper browser validation.

Your setup looks good! The key points are:
- Ingress correctly routes traffic based on Host header
- TLS encryption is working (even with mismatched CN)
- Services are properly exposed and accessible

The `--insecure` flag in curl is needed because you're using self-signed certificates that aren't trusted by the system's CA store, but the encryption is still happening.