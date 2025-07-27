"""
jit_service.py

This FastAPI-based service provides a secure endpoint for issuing JIT SSH certificates.
It validates username/password/MFA credentials and signs a temporary SSH certificate.

Author: Richard Chamberlain
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from user_auth_manager import UserAuthManager
from ssh_cert_manager import SshCertManager
from ticket_logger import TicketLogger

app = FastAPI()

# Initialize service objects
auth_manager = UserAuthManager("../db/users.yaml")
cert_manager = SshCertManager("../ca/ca_user_key")
ticket_logger = TicketLogger("../db/tickets.sqlite")

class JitAccessRequest(BaseModel):
    username: str
    password: str
    token: str
    reason: str

@app.post("/jit-access")
def request_jit_access(req: JitAccessRequest):
    print(f"🔍 Authenticating user: {req.username}")
    if not auth_manager.authenticate_user(req.username, req.password, req.token):
        raise HTTPException(status_code=403, detail="Access denied")

    print(f"📝 Logging access reason: {req.reason}")
    ticket_logger.log_ticket(req.username, req.reason)

    print("🔐 Generating SSH certificate...")
    try:
        cert_paths = cert_manager.generate_and_sign(req.username)
    except Exception as e:
        print(f"❌ SSH cert generation failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to generate SSH certificate")

    print(f"📄 SSH Certificate Path: {cert_paths['cert_path']}")
    return cert_paths

