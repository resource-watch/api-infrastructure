variable "url" {
  type        = string
  description = "Main URL to access this ingress"
}

variable "aliases" {
  type        = list(string)
  description = "List of alternative URLs to access this ingress"
}

variable "core_origin" {
  type = object({
    domain_name = string
    origin_id = string
  })
}

variable "gfw_origin" {
  type = object({
    domain_name = string
    origin_id = string
  })
}

variable "misc_origin" {
  type = object({
    domain_name = string
    origin_id = string
  })
}