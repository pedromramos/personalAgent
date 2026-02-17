# 🔐 personalAgent - Vault Infrastructure (V1.0)

Este repositório contém a camada de gestão de segredos e identidade para o ecossistema **personalAgent**. Esta versão foca na automação completa do ciclo de vida do cofre (Bootstrap) em ambiente de desenvolvimento.

## 🎯 Por que HashiCorp Vault?

A escolha pelo **HashiCorp Vault** em detrimento de arquivos `.env` ou soluções de gerenciamento de chaves simples baseia-se em quatro pilares fundamentais para sistemas de agentes de IA:

1.  **Centralização de Segredos:** Consolida todas as chaves de API (OpenAI, Anthropic, Bancos de Dados) em um único ponto com criptografia de ponta a ponta.
2.  **Identidade de Máquina:** Diferente de senhas compartilhadas, o Vault permite que cada agente tenha sua própria identidade e permissões granulares.
3.  **Criptografia como Serviço:** O Vault protege os dados em repouso utilizando AES-GCM de 256 bits, garantindo que, mesmo que o disco seja comprometido, os segredos permaneçam ilegíveis.
4.  **Escalabilidade e Auditoria:** Oferece logs detalhados de cada acesso (quem, quando e o quê), essencial para a resiliência e conformidade de sistemas autônomos.

---

## ✨ Funcionalidades Implementadas (V1.0)

* **Secret Storage (KV Engine):** Armazenamento de pares chave-valor para configurações sensíveis.
* **Raft Integrated Storage:** Persistência de dados de alta performance sem dependência de bancos de dados externos.
* **Automated Unseal:** Script de bootstrap para abertura automática do cofre em ambiente de PoC.
* **Identity Management:** Provisionamento inicial de identidades para desenvolvedores e agentes.

---

## 🏗️ Arquitetura da Solução

A stack utiliza orquestração via Docker Compose com dependências de estado:

* **Vault Server**: Motor de segredos operando em HTTP (PoC Mode).
* **Vault-Init**: Automação *stateless* que gerencia o fluxo `Init -> Unseal -> Provisioning`.
* **Storage**: Persistência baseada em Raft no diretório `./vault/data`.

---

## 🚀 Quick Start

### 1. Preparação de Permissões
Como o Vault roda com o usuário interno `vault` (UID 100), garanta que o host permita a escrita:
```bash
sudo chown -R 100:100 ./vault/data
sudo chmod -R 700 ./vault/data
```

### 2. Boot da Stack
```bash
docker compose up -d
docker logs -f vault-init
```
*O container `vault-init` encerrará automaticamente após exibir a mensagem `🏁 SETUP CONCLUÍDO!`.*

---

## 📓 Diário de Batalha (Troubleshooting Mapeado)

| Erro / Log | Causa Raiz | Solução Implementada |
| :--- | :--- | :--- |
| **"Vault is already initialized" (400)** | Dados no Raft sem o arquivo `keys.txt` correspondente. | Lógica de consistência que valida storage vs. arquivos físicos. |
| **"File descriptor 0 is not a terminal"** | O comando `unseal` tentou ser interativo no Docker. | Automatizado via passagem de argumento: `vault operator unseal "$KEY"`. |
| **"Permission Denied"** | Pasta de dados criada pelo root do host. | Ajuste mandatório de `chown` para UID 100 antes do boot. |
| **"Connection Refused"** | Mapeamento de portas ou protocolo (HTTPS vs HTTP). | Padronização de portas (8200) e desativação de TLS para PoC. |

---

## 🛣️ Roadmap: Rumo ao Production-Ready (V1.1)

1.  **Segurança em Trânsito**: Implementação de **TLS/HTTPS**.
2.  **Identidade de Máquina**: Migrar de `userpass` para **AppRole**.
3.  **Root of Trust**: Implementar **Auto-Unseal via KMS/Cloud**.
4.  **Alta Disponibilidade**: Evoluir para um cluster Raft de 3 nós.

---

## 📚 Documentação e Referências

* [Site Oficial HashiCorp Vault](https://www.vaultproject.io/)
* [Documentação: Raft Integrated Storage](https://www.vaultproject.io/docs/configuration/storage/raft)
* [Documentação: AppRole Auth Method](https://www.vaultproject.io/docs/auth/approle)
* [Best Practices: Secret Management](https://learn.hashicorp.com/collections/vault/security)

---

### 💡 Nota de Encerramento
Este commit fecha a base de segurança do **personalAgent**. A infraestrutura agora é **programável e resiliente**.
