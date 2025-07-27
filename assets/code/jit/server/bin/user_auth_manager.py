"""
user_auth_manager.py

This module defines the UserAuthManager class, which handles user registration
and authentication using secure password hashing (bcrypt) and TOTP-based MFA (pyotp).
It is designed to support a zero-trust model by requiring short-lived, validated credentials.

Dependencies:
- PasswordManager: Handles password hashing and generation
- UserStore: Handles persistent user storage in YAML format
- pyotp: Verifies TOTP-based tokens

Author: Richard Chamberlain
"""
# user_auth_manager.py

import base64
import pyotp
from password_manager import PasswordManager
from user_store import UserStore

class UserAuthManager:
    def __init__(self, user_file="./db/users.yaml"):
        self.store = UserStore(user_file)
        self.password_manager = PasswordManager()

    def _is_valid_base32(self, secret):
        try:
            base64.b32decode(secret, casefold=True)
            return True
        except Exception:
            return False

    def register_user(self, username, mfa_secret, show_password=False):
        if self.store.exists(username):
            print(f"❌ User '{username}' already exists.")
            return

        if not self._is_valid_base32(mfa_secret):
            print("❌ Invalid TOTP secret. Must be base32.")
            return

        password = self.password_manager.generate_strong_password()
        password_hash = self.password_manager.hash_password(password)

        self.store.add(username, {
            "password_hash": password_hash,
            "mfa_secret": mfa_secret
        })

        print(f"✅ User '{username}' registered.")
        if show_password:
            print(f"🔐 Temporary password: {password}")
        else:
            print("🔐 Password stored securely. Use '--show-password' to display it.")

    def authenticate_user(self, username, password, token):
        print(f"🔍 Authenticating user: {username}")
        user = self.store.get(username)

        if not user:
            print(f"❌ User '{username}' not found in store.")
            print(f"🧪 All users available: {self.store.all_usernames()}")
            return False

        print("🔐 Verifying password...")
        if not self.password_manager.verify_password(password, user["password_hash"]):
            print("❌ Password verification failed.")
            return False

        print("🔐 Verifying MFA token...")
        if not pyotp.TOTP(user["mfa_secret"]).verify(token):
            print("❌ MFA token verification failed.")
            return False

        print(f"✅ User '{username}' authenticated successfully.")
        return True

    def list_users(self):
        return self.store.all_usernames()

