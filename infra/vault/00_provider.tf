terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.6"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
  backend "consul" { }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}