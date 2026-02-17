🛡️ Vault Project Documentation & Survival Guide
Este documento é a fonte oficial para a implantação, manutenção e resolução de problemas do HashiCorp Vault no projeto personalAgent.

🏗️ 1. Arquitetura e Capacidades
O Vault centraliza o armazenamento de informações sensíveis, removendo a necessidade de arquivos .env inseguros.

KV Store (v2): Armazenamento de chave-valor com versionamento e rollback.

Dynamic Secrets: Geração de credenciais temporárias para bancos de dados.

Transit Encryption: Criptografia de dados sem gerenciar chaves na aplicação (ideal para PII).

Lease & Revocation: Todo segredo tem um tempo de vida (TTL) definido.

📥 2. Instruções de Instalação e Setup
Pré-requisitos
Docker e Docker Compose instalados.

Permissões de usuário para gerenciar containers.

Passo 1: Estrutura de Pastas
No diretório do seu projeto, crie a seguinte estrutura:

Bash
mkdir -p vault/config vault/data
Passo 2: Arquivos de Configuração
Crie o arquivo vault/config/vault.hcl:

Terraform
storage "raft" {
  path    = "/vault/file"
  node_id = "node1"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = "true"
}

disable_mlock = true
api_addr      = "http://127.0.0.1:8200"
cluster_addr  = "http://127.0.0.1:8201"
ui            = true
Crie o arquivo docker-compose.yaml:

YAML
services:
  vault:
    image: hashicorp/vault:latest
    container_name: vault
    ports:
      - "8201:8200" # Acesso via localhost:8201
    volumes:
      - ./vault/config:/vault/config
      - ./vault/data:/vault/file
    cap_add:
      - IPC_LOCK
    entrypoint: vault server -config=/vault/config/vault.hcl
    restart: always
Passo 3: Subindo o Serviço
Bash
docker compose up -d
🔐 3. Inicialização e Unseal (Primeiro Acesso)
O Vault inicia no estado Sealed (lacrado). Siga estes comandos para liberar o acesso:

Inicializar o sistema:

Bash
docker exec -it -e VAULT_ADDR="http://127.0.0.1:8200" vault vault operator init
Guarde as 5 chaves e o Root Token gerados.

Realizar o Unseal (Repetir 3 vezes):

Bash
docker exec -it -e VAULT_ADDR="http://127.0.0.1:8200" vault vault operator unseal
Insira uma chave diferente a cada execução.

🛠️ 4. Guia de Troubleshooting (Resolução de Erros)
🔴 Conflito de Porta (bind: address already in use)
Sintoma: Log mostra listen tcp4 0.0.0.0:8200: bind: address already in use.

Causa: Um processo no Host ou container órfão está usando a porta.

Solução:

Bash
sudo lsof -i :8200
sudo kill -9 <PID>
docker compose down --remove-orphans
sudo killall docker-proxy
🔴 Erro de Protocolo (HTTP response to HTTPS client)
Sintoma: Erro ao rodar comandos vault operator.

Causa: O CLI tenta usar HTTPS (padrão) em um servidor configurado como HTTP.

Solução: Sempre declare a variável de ambiente:

Bash
docker exec -it -e VAULT_ADDR="http://127.0.0.1:8200" vault vault <COMANDO>
🔴 Vault "Sealed" (Status 503)
Sintoma: API retorna erro ou navegador mostra "Vault is Sealed".

Causa: O container foi reiniciado ou o serviço acabou de subir.

Solução: Execute novamente o processo de Unseal (Passo 3).

📚 5. Documentação Adicional
Navegador: http://localhost:8201/ui

SDK Python: hvac Documentation

Oficial: Vault Documentation