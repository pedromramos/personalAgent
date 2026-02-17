#!/bin/sh
set -ex  # O -x faz o log de cada comando executado

export VAULT_ADDR='http://vault:8200'

echo "--- INICIANDO SETUP ---"

# Loop de espera
until wget -qO- "$VAULT_ADDR/v1/sys/health" > /dev/null 2>&1 || [ $? -eq 8 ]; do
  echo "Aguardando Vault em $VAULT_ADDR..."
  sleep 2
done

# Verifica se precisa inicializar
# ... (início do script)
echo "--- INICIANDO SETUP ---"

# Loop que aceita QUALQUER resposta do servidor (200, 503, 400)
# Ele só continua no loop se o comando falhar completamente (rede/porta fechada)
while true; do
  # Tenta bater na API. Se retornar algo (mesmo erro HTTP), o grep pega
  if wget -S --spider "$VAULT_ADDR/v1/sys/health" 2>&1 | grep -q "HTTP/"; then
    echo "✅ Vault respondeu!"
    break
  fi
  echo "Aguardando porta do Vault abrir em $VAULT_ADDR..."
  sleep 2
done

# Segue para o Init...

# Unseal
echo "🔓 Tentando Unseal..."
UNSEAL_KEY=$(grep "Unseal Key 1:" /vault/file/keys.txt | awk '{print $NF}')
vault operator unseal -address="$VAULT_ADDR" "$UNSEAL_KEY"

# Login e Configuração
echo "🔑 Configurando Usuários..."
ROOT_TOKEN=$(grep "Initial Root Token:" /vault/file/keys.txt | awk '{print $NF}')
vault login -address="$VAULT_ADDR" "$ROOT_TOKEN"

vault auth enable -address="$VAULT_ADDR" userpass || true
vault write -address="$VAULT_ADDR" auth/userpass/users/pedrin password="123" policies="default"

echo "--- SETUP CONCLUÍDO ---"