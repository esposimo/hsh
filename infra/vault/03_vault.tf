resource "docker_image" "image_container_core_vault" {
  name         = "${var.image_core_vault_name}:${var.image_core_vault_tag}"
  force_remove = false
  keep_locally = true
}

resource "docker_volume" "core_vault_data" {
    name      = "data-vault"
    driver    = "local"
}

resource "tls_private_key" "vault_certificate_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_self_signed_cert" "vault_certificate" {
  private_key_pem = tls_private_key.vault_certificate_key.private_key_pem

  subject {
    common_name   = local.certs.common_name
    country       = local.certs.country
    province      = local.certs.province
    locality      = local.certs.locality
    organization  = local.certs.organization
  }

  dns_names       = local.certs.dns_names

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "docker_container" "vault" {
  depends_on    = [ docker_container.storage_engine_vault , docker_image.image_container_core_vault , docker_volume.core_vault_data ]
  rm            = false

  name          = "${var.core_vault_container_name}"
  image         = docker_image.image_container_core_vault.image_id

  networks_advanced {
    name                = docker_network.infra_network.name
    ipv4_address        = var.core_vault_ipv4
  }

  command = ["server"]

  volumes {
      container_path = "/consul/data"
      volume_name    = docker_volume.core_vault_data.name
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
    for_each = var.core_vault_ports
    content {
        internal = ports.value.container
        external = ports.value.host
        protocol = ports.value.protocol
    }
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }

  capabilities {
    add = ["CAP_IPC_LOCK"]
  }


  upload {
    file          = local.certs.cert_file
    content       = tls_self_signed_cert.vault_certificate.cert_pem
    permissions   = "0644"
  }

  upload {
    file          = local.certs.key_file
    content       = tls_private_key.vault_certificate_key.private_key_pem
    permissions   = "0644"
  }

  upload {
    content    = templatefile("./config/vault.hcl", { 
      cert_file               = local.certs.cert_file , 
      key_file                = local.certs.key_file , 
      storage_engine_endpoint = local.output_storage_engine_vault_external_endpoint
    })
    file = "/vault/config/vault.hcl"
  }

  upload {
    source      = "./config/init-vault.sh"
    file        = "/tmp/init-vault.sh"
    executable  = true
    permissions = "0755"
  }
}
