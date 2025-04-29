terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.3.0"
    }
  }
  backend "consul" {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "container_network" {
  name = "network-${var.env}-container"
  attachable = var.attachable
  driver = var.driver
  ingress = false
  labels { 
     label = "environment"
     value = var.env
  }
  ipam_config {
    gateway = var.gateway
    subnet = var.subnet
  }
}