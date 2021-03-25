variable "aliases" {
  type        = list(string)
  description = "List of alternative URLs to access this ingress"
}

variable "core_origin" {
  type = string
}

variable "gfw_origin" {
  type = string
}

variable "misc_origin" {
  type = string
}

variable "certificate_arn" {}


variable "log_retention" {
  default = 30
  type = number
}