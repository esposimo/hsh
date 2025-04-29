variable "env" {
  type = string
  default = "dev"
}

variable "short_env" {
  type = string
  default = "d"
}

variable "attachable" {
  type = bool
  default = false
}

variable "driver" {
  type = string
  default = "bridge"

  validation {
    condition = contains(["bridge", "host", "overlay", "macvlan"], var.driver)
    error_message = "Valore non permesso: permessi solo i seguenti valori: bridge, host, overlay, macvlan"
  }
}

variable "subnet" {
  type = string
  description = "CIDR della subnet, es. 10.0.0.0/24"

  validation {
    condition     = can(cidrhost(var.subnet, 0))
    error_message = "Devi inserire un CIDR valido, es. 192.168.1.0/24."
  }
}

variable "gateway" {
  type = string
  description = "Indirizzo gateway della network"
  
  validation {
   condition = can(cidrhost("${var.gateway}/32", 0))
   error_message = "L'indirizzo IP deve essere valido (es: 192.168.1.1)"
  }
}

