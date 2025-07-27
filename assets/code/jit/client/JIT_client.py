import requests
import getpass
import yaml
from pathlib import Path
import subprocess
import os

CONFIG_FILE = Path.home() / ".config" / "jit-ssh-client.yaml"

with open(CONFIG_FILE) as f:
    CONFIG = yaml.safe_load(f)

def request_jit_cert(username, password, token, reason):
    payload = {
        "username": username,
        "password": password,
        "token": token,
        "reason": reason
    }

    response = requests.post(CONFIG["service_url"], json=payload, verify=CONFIG.get("verify_ssl", True))
    response.raise_for_status()
    data = response.json()

    private_key = data["private_key"]
    cert_path = data["cert_path"]
    remote_user = CONFIG["remote_user"]
    remote_host = CONFIG["remote_host"]

    print("✅ JIT SSH Certificate issued. Connecting...")

    # Launch SSH directly
    subprocess.run([
        "ssh",
        "-i", private_key,
        "-o", f"CertificateFile={cert_path}",
        f"{remote_user}@{remote_host}"
    ])

if __name__ == "__main__":
    user = input("Service Username: ")
    pw = getpass.getpass("Password: ")
    reason = input("Reason for access: ")
    mfa = input("MFA Token: ")
    request_jit_cert(user, pw, mfa, reason)

