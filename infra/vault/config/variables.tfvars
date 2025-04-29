network_infra_name = "infra_network"
network_infra_gateway = "10.100.100.1"
network_infra_subnet = "10.100.100.1/24"

image_storage_vault_name = "hashicorp/consul"
image_storage_vault_tag = "1.20"
storage_engine_container_name = "storage_engine_vault"
storage_engine_ipv4 = "10.100.100.10"

image_core_vault_name = "hashicorp/vault"
image_core_vault_tag = "1.19"
core_vault_container_name = "core_vault"
core_vault_ipv4 = "10.100.100.11"

storage_engine_ports = [
    { container = 8300, host = 28300, protocol = "tcp" },
    { container = 8301, host = 28301, protocol = "tcp" },
    { container = 8301, host = 28301, protocol = "udp" },
    { container = 8302, host = 28302, protocol = "tcp" },
    { container = 8302, host = 28302, protocol = "udp" },
    { container = 8500, host = 28500, protocol = "tcp" },
    { container = 8600, host = 28600, protocol = "tcp" },
    { container = 8600, host = 28600, protocol = "udp" }
]


core_vault_ports = [
    { container = 8200, host = 28200, protocol = "tcp" }
]

