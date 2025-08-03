"""
ssh_cert_manager.py

This module handles the generation and signing of temporary SSH certificates
for JIT (Just-in-Time) access. It uses `ssh-keygen` to sign a temporary key
with a CA private key.

Author: Richard Chamberlain
"""

import os
import subprocess
from pathlib import Path
import getpass

class SshCertManager:
    def __init__(self, ca_key_path, output_root="/usr/local/jit-ssh/keys", validity="15m"):
        self.ca_key_path = ca_key_path
        self.output_root = output_root
        self.validity = validity
        os.makedirs(self.output_root, exist_ok=True)

    def generate_and_sign(self, ssh_user, local_user=None):
        if not local_user:
            local_user = getpass.getuser()

        user_dir = Path(self.output_root) / ssh_user / local_user
        user_dir.mkdir(parents=True, exist_ok=True)

        key_path = user_dir / "id_ed25519"
        pub_path = user_dir / "id_ed25519.pub"
        cert_path = user_dir / "id_ed25519-cert.pub"

        # Remove any existing key/cert files
        for file in [key_path, pub_path, cert_path]:
            if file.exists():
                file.unlink()

        # Generate key pair
        subprocess.run([
            "ssh-keygen", "-t", "ed25519",
            "-f", str(key_path),
            "-N", "",
            "-C", f"{ssh_user}@jit"
        ], check=True)

        # Sign with CA key
        subprocess.run([
            "ssh-keygen", "-s", self.ca_key_path,
            "-I", f"{ssh_user}-jit",
            "-n", ssh_user,
            "-V", f"+{self.validity}",
            str(pub_path)
        ], check=True)

        # Permissions
        os.chmod(key_path, 0o640)
        os.chmod(pub_path, 0o644)
        os.chmod(cert_path, 0o644)

        return {
            "private_key": str(key_path),
            "public_key": str(pub_path),
            "cert_path": str(cert_path)
        }

