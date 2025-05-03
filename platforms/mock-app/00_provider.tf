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
    consul = {
      source = "hashicorp/consul"
      version = "2.21.0"
    }
  }
  backend "consul" {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
data "external" "secrets" {
  program = ["bash", "${path.cwd}/../../scripts/get_env.sh"]
}

output "secret_from_env" {
  value = data.external.secrets.result["CONSUL_ENDPOINT"]
}

provider "consul" {
  address = data.external.secrets.result["CONSUL_ENDPOINT"]
}

data "consul_keys" "vault_endpoint" {
  key {
    name = "endpoint"
    path = "infrastructure/vault/endpoint"
  }
}

data "consul_keys" "vault_token" {
  key {
    name = "root-key"
    path = "infrastructure/vault/security/root-key"
  }
}

provider "vault" {
   address = data.consul_keys.vault_endpoint.var.endpoint
   token = data.consul_keys.vault_token.var.root-key
   skip_tls_verify = true
}
