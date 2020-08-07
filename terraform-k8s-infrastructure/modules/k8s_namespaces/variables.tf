variable "namespaces" {
  description = "Namespace list"
  type        = list(string)
  default     = ["gateway", "core", "aqueduct", "rw", "gfw", "fw", "prep", "climate-watch"]
}