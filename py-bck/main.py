from fastapi import FastAPI, HTTPException, Depends
import hvac
import os

app = FastAPI(title="Personal Agent API")

# Configuração via rede interna do Docker
VAULT_URL = os.getenv("VAULT_ADDR", "http://vault:8200")

def get_vault_client():
    # O cliente hvac para falar com o Vault
    return hvac.Client(url=VAULT_URL)

@app.post("/login")
def login(username: str, password: str, client: hvac.Client = Depends(get_vault_client)):
    """
    O Agente recebe o login e delega a autenticação para o Vault.
    Se o 'vault-init' rodou, o usuário 'pedrin' já existe lá.
    """
    try:
        # 1. Autentica o usuário no Vault
        login_res = client.auth.userpass.login(
            username=username,
            password=password,
        )
        
        # 2. Solicita o Identity Token (JWT) que configuramos no setup.sh
        # O token de login do usuário permite que ele peça sua própria identidade
        identity_token_res = client.read('identity/oidc/token/agent-role')
        
        return {
            "status": "Authenticated by Vault",
            "jwt_token": identity_token_res['data']['token']
        }
    except Exception:
        raise HTTPException(status_code=401, detail="Credenciais inválidas no Vault")

@app.get("/agent/status")
def status():
    return {"agent": "online", "security": "Vault-backed"}