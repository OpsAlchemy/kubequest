import os
from .ca import load_ca
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
import datetime

def generate_client_cert(name, cn, org):
    os.makedirs(name, exist_ok=True)
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

    subject = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, cn),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, org)
    ])

    csr = x509.CertificateSigningRequestBuilder().subject_name(subject).sign(key, hashes.SHA256())
    ca_cert, ca_key = load_ca()

    cert = x509.CertificateBuilder().subject_name(csr.subject).issuer_name(
        ca_cert.subject).public_key(
        csr.public_key()).serial_number(
        x509.random_serial_number()).not_valid_before(
        datetime.datetime.utcnow()).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=365)
    ).sign(ca_key, hashes.SHA256())

    with open(f"{name}/{name}.crt", "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    with open(f"{name}/{name}.key", "wb") as f:
        f.write(key.private_bytes(serialization.Encoding.PEM,
                                  serialization.PrivateFormat.TraditionalOpenSSL,
                                  serialization.NoEncryption()))
    print(f"[✓] Client cert for {name} generated.")
