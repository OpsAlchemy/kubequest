import os
import datetime
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa

CA_DIR = "ca"
CA_KEY_PATH = os.path.join(CA_DIR, "ca.key")
CA_CRT_PATH = os.path.join(CA_DIR, "ca.crt")

def ensure_ca():
    os.makedirs(CA_DIR, exist_ok=True)
    if os.path.exists(CA_KEY_PATH) and os.path.exists(CA_CRT_PATH):
        return

    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, "KUBERNETES-CA")
    ])
    cert = x509.CertificateBuilder().subject_name(subject).issuer_name(issuer).public_key(
        key.public_key()).serial_number(
        x509.random_serial_number()).not_valid_before(
        datetime.datetime.utcnow()).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=3650)
    ).sign(key, hashes.SHA256())

    with open(CA_KEY_PATH, "wb") as f:
        f.write(key.private_bytes(
            serialization.Encoding.PEM,
            serialization.PrivateFormat.TraditionalOpenSSL,
            serialization.NoEncryption()
        ))

    with open(CA_CRT_PATH, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))

def load_ca():
    with open(CA_KEY_PATH, "rb") as f:
        ca_key = serialization.load_pem_private_key(f.read(), password=None)
    with open(CA_CRT_PATH, "rb") as f:
        ca_cert = x509.load_pem_x509_certificate(f.read())
    return ca_cert, ca_key
