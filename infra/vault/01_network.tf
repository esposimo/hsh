resource "docker_network" "infra_network" {
  name       = var.network_infra_name
  attachable = true
  driver     = "bridge"
  ingress    = false
  ipam_config {
    subnet  = "10.100.100.1/24"
    gateway = "10.100.100.1"
  }
}