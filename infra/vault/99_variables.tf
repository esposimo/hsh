variable "network_infra_name" {
  type    = string
  default = "infra_network"
}

variable "network_infra_gateway" {
  type    = string
  default = "10.100.100.1"
}

variable "network_infra_subnet" {
  type    = string
  default = "10.100.100.1/24"
}

## images 
variable "image_storage_vault_name" {
  type = string
}

variable "image_storage_vault_tag" {
  type    = string
  default = "latest"
}

variable "image_core_vault_name" {
  type = string
}

variable "image_core_vault_tag" {
  type    = string
  default = "latest"
}

# containers
variable "storage_engine_container_name" {
  type = string
}

variable "storage_engine_ipv4" {
  type = string
}

variable "core_vault_container_name" {
  type = string
}

variable "core_vault_ipv4" {
  type = string
}

# ports
variable "storage_engine_ports" {
  type = list(object({
    container = number
    host      = number
    protocol  = string
  }))
}

variable "core_vault_ports" {
  type = list(object({
    container = number
    host      = number
    protocol  = string
  }))
}