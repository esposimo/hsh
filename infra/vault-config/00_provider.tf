terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.8.0"
    }
  }
  backend "consul" {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "terraform_remote_state" "vault" {
    backend = "consul"

    config = {
        address = "127.0.0.1:18500"
        scheme  = "http"
        path    = "terraform/state/vault/${var.env}"
    }
}

provider "vault" {
    address = data.terraform_remote_state.vault.outputs.core_vault_host_endpoint
    skip_tls_verify = true
}

resource "vault_mount" "sops" {
  path                      = "sops_kv"
  type                      = "transit"
  description               = "Chiavi di crittografia per sops. Ogni chiave serve ad un kv specifico"
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.sops.path
  name    = "my_key"
  deletion_allowed = true
}

# sops ha bisogno di 
# export VAULT_ADDR="https://192.168.1.220:28500"
# export VAULT_SKIP_VERIFY=true
# encrypt => sops encrypt --hc-vault-transit https://192.168.1.220:28200/v1/transit/sops_kv/my_key server.json
# decrypt => sops decrypt simone.json
# io devo creare un file di configurazione json con sops, e in automatico quando lo salvo deve risultare già crittografato
# per farlo, devo usare uno script che si carica in automatico le configurazioni e mi va in modalità editing
# una volta che ho salvato, posso decriptare il file o editarlo in automatico perchè sops all'interno del file ha già le informazioni per decriptare
# 
# lato terraform invece, devo solo prenddere i valori del file decriptato con sops, e metterli in "chiaro" in un kv dedicato
