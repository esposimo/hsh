output "storage_engine_vault_internal_ip" {
  value       = local.output_storage_engine_vault_internal_ip
  description = "Contiene l'ip del container attestato sulla network di docker"
}

output "storage_engine_vault_internal_port" {
  value       = local.output_storage_engine_vault_internal_port
  description = "Contiene la porta interna esposta da consul"
}

output "storage_engine_vault_external_port" {
  value       = local.output_storage_engine_vault_external_port
  description = "Contiene la porta interna esposta da consul"
}

output "storage_engine_vault_scheme" {
  value       = local.output_storage_engine_vault_scheme
  description = "Contiene lo schema utilizzato http/https"
}

output "storage_engine_vault_internal_endpoint" {
  value       = local.output_storage_engine_vault_internal_endpoint
  description = "Contiene l'endpoint interno da chiamare per interagire con consul (da usare nelle configurazioni di vault)"
}

output "storage_engine_vault_host_endpoint" {
  value       = local.output_storage_engine_vault_external_endpoint
  description = "Contiene l'endpoint del docker host per raggiungere lo storage engine"
}

output "storage_engine_vault_container_name" {
  value       = local.output_storage_engine_vault_container_name
  description = "Contiene il nome del container che esegue lo storage engine di vault"
}

output "core_vault_internal_ip" {
  value       = local.output_vault_internal_ip
  description = "Contiene l'ip del container assegnato a vault"
}

output "core_vault_internal_port" {
  value       = local.output_vault_internal_port
  description = "Contiene la porta interna del container di vault"
}

output "core_vault_internal_scheme" {
  value       = local.output_vault_internal_scheme
  description = "Contiene lo schema usato da vault"
}

output "core_vault_internal_endpoint" {
  value       = local.output_vault_internal_internal_endpoint
  description = "Contiene l'endpoint al container di vault"
}

output "core_vault_host_endpoint" {
  value       = local.output_vault_external_endpoint
  description = "Contiene l'endpoint del docker host per raggiungere il vault"
}

output "core_vault_container_name" {
  value       = local.output_vault_container_name
  description = "Contiene il nome del container che esegue il vault"
}