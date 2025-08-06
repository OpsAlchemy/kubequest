import ipaddress
from .ca import load_ca
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.x509 import DNSName, IPAddress, SubjectAlternativeName
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
import os
import datetime

def generate_server_cert(name, cn, san_dns=None, san_ips=None):
    san_dns = san_dns or []
    san_ips = san_ips or []

    os.makedirs(name, exist_ok=True)
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

    subject = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, cn),
    ])

    alt_names = [DNSName(d) for d in san_dns] + [IPAddress(ipaddress.IPv4Address(ip)) for ip in san_ips]

    csr = x509.CertificateSigningRequestBuilder().subject_name(subject).add_extension(
        SubjectAlternativeName(alt_names), critical=False).sign(key, hashes.SHA256())

    ca_cert, ca_key = load_ca()

    cert = x509.CertificateBuilder().subject_name(
        csr.subject).issuer_name(
        ca_cert.subject).public_key(
        csr.public_key()).serial_number(
        x509.random_serial_number()).not_valid_before(
        datetime.datetime.utcnow()).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=365)
    ).add_extension(
        SubjectAlternativeName(alt_names), critical=False
    ).sign(ca_key, hashes.SHA256())

    with open(f"{name}/{name}.crt", "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    with open(f"{name}/{name}.key", "wb") as f:
        f.write(key.private_bytes(serialization.Encoding.PEM,
                                  serialization.PrivateFormat.TraditionalOpenSSL,
                                  serialization.NoEncryption()))
    print(f"[✓] Server cert for {name} generated with SANs.")
