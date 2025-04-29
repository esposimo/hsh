locals {

  output_storage_engine_vault_container_name      = var.storage_engine_container_name
  output_storage_engine_vault_scheme              = "http"
  output_storage_engine_vault_internal_ip         = var.storage_engine_ipv4
  output_storage_engine_vault_internal_port       = 8500
  output_storage_engine_vault_internal_endpoint   = "${local.output_storage_engine_vault_scheme}://${local.output_storage_engine_vault_internal_ip}:${local.output_storage_engine_vault_internal_port}"
  output_storage_engine_vault_external_port       = flatten([ for p in var.storage_engine_ports : p.host if p.container == local.output_storage_engine_vault_internal_port && p.protocol == "tcp" ])[0]
  output_storage_engine_vault_external_endpoint   = "${local.output_storage_engine_vault_scheme}://${data.external.docker_host_ip.result["docker_host_ip"]}:${local.output_storage_engine_vault_external_port}"


  certs = {
    cert_file         = "/vault/certs/vault.crt"
    key_file          = "/vault/certs/vault.key"
    common_name       = "vault.local"
    country           = "IT"
    province          = "Italy"
    locality          = "Naples"
    organization      = "Vault Inc"
    dns_names         = [
      var.core_vault_ipv4,
      data.external.docker_host_ip.result["docker_host_ip"]
    ]
  }

  output_vault_container_name                   = var.core_vault_container_name
  output_vault_internal_scheme                  = "https"
  output_vault_internal_ip                      = var.core_vault_ipv4
  output_vault_internal_port                    = 8200
  output_vault_internal_internal_endpoint       = "${local.output_vault_internal_scheme}://${local.output_vault_internal_ip}:${local.output_vault_internal_port}"
  output_vault_external_port                    = flatten([ for p in var.core_vault_ports : p.host if p.container == local.output_vault_internal_port && p.protocol == "tcp" ])[0]
  output_vault_external_endpoint                = "${local.output_vault_internal_scheme}://${data.external.docker_host_ip.result["docker_host_ip"]}:${local.output_vault_external_port}"

}