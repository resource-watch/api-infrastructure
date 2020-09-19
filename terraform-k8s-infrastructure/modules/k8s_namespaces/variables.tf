variable "namespaces" {
  description = "Namespace list"
  type        = list(string)
  default     = ["gateway", "core", "aqueduct", "rw", "gfw", "fw", "prep", "climate-watch"]
}

variable "namespace" {
  type = string
}

variable "ct_secrets" {
  type    = map(string)
  default = {}
}

variable "db_secrets" {
  type    = map(string)
  default = {}
}

variable "app_secrets" {
  type    = map(string)
  default = {}
}


variable "ms_secrets" {
  type    = map(string)
  default = {}
}

variable "container_registry_server" {
  type    = string
  default = ""

}

variable "container_registry_username" {
  type    = string
  default = ""

}

variable "container_registry_password" {
  type    = string
  default = ""

}