variable "retention_period" {
  type    = number
  default = 1
}

variable "environment" {
  type = string
}

variable "cors_allowed_origin" {
  type = string
}

variable "tags" {
  default = {}
}