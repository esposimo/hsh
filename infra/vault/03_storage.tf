resource "docker_image" "image_container_storage_vault" {
  name         = "${var.image_storage_vault_name}:${var.image_storage_vault_tag}"
  force_remove = false
  keep_locally = true
}

resource "docker_volume" "storage_engine_vault_volume" {
    name   = "data-storage_engine_vault_volume"
    driver = "local"
}

resource "docker_container" "storage_engine_vault" {
  depends_on    = [ docker_image.image_container_storage_vault , docker_volume.storage_engine_vault_volume ]
  rm            = false

  name          = "${var.storage_engine_container_name}"
  image         = docker_image.image_container_storage_vault.image_id

  networks_advanced {
    name            = docker_network.infra_network.id
    ipv4_address    = var.storage_engine_ipv4
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  volumes {
      container_path = "/consul/data"
      volume_name    = docker_volume.storage_engine_vault_volume.name
  }
  volumes {
      container_path = "/etc/timezone"
      volume_name    = "/etc/timezone"
  }
  volumes {
      container_path = "/etc/localtime"
      volume_name    = "/etc/localtime"
  }

  dynamic "ports" {
    for_each = var.storage_engine_ports
    content {
        internal = ports.value.container
        external = ports.value.host
        protocol = ports.value.protocol
    }
  }
  #env = local.environment_variables
}