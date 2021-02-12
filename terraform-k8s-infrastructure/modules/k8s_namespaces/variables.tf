variable "cluster_endpoint" {
  type        = string
  description = "The k8s cluster endpoint. Must be accessible from localhost"
}

variable "cluster_ca" {
  type        = string
  description = "The k8s CA string"
}

variable "cluster_name" {
  type        = string
  description = "The k8s cluster name"
}

variable "namespaces" {
  description = "Namespace list"
  type        = list(string)
  default     = ["gateway", "core", "aqueduct", "rw", "gfw", "fw", "prep", "climate-watch"]
}