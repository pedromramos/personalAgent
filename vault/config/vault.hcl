storage "raft" {
  path    = "/vault/file"
  node_id = "node1"
}

listener "tcp" {
  # 0.0.0.0 permite conexões de qualquer interface (inclusive externa)
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

# O Vault precisa saber que o nome dele na rede é 'vault'
api_addr = "http://vault:8200"
cluster_addr = "http://vault:8201"
ui = true
disable_mlock = true