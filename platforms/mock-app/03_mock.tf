data "external" "decrypt_file" {
  program = ["${path.cwd}/sops.sh", "${var.env}", "decrypt" , "env/${var.env}/kv.json"]
}


# C'è ancora molto da fare qui, è molto abozzato
# 


resource "docker_image" "image_container_build_name" {
  name         = "${var.image_container_name}:${var.image_container_version}"
  force_remove = true
  keep_locally = false

  build {
    context = "./build"
  }
}

locals {
    cname = var.container_name
    decrypter_var = jsonencode(data.external.decrypt_file.result)
}


resource "vault_kv_secret" "secret" {
  path = "kv-mock-app/secret"
  data_json = local.decrypter_var
}


resource "docker_container" "container_mock" {
  depends_on    = [ docker_image.image_container_build_name ]
  rm            = true

  name          = "${var.container_name}"
  image         = docker_image.image_container_build_name.image_id

  networks_advanced {
    name                = data.docker_network.container_network.name
    ipv4_address        = var.mock_app_ipv4
  }

  volumes {
      container_path = "/etc/timezone"
      volume_name    = "/etc/timezone"
  }
  volumes {
      container_path = "/etc/localtime"
      volume_name    = "/etc/localtime"
  }

  lifecycle {
    ignore_changes = [ 
      log_opts, log_driver
     ]
  }
}
