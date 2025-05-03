variable "env" {
  type = string
  default = "dev"
}

variable "short_env" {
  type = string
  default = "d"
}

variable "image_container_name" {
  type = string
}

variable "image_container_version" {
  type = string
  default = "latest"
}

variable "mock_app_ipv4" {
  type = string
}

variable "container_name" {
  type = string
}