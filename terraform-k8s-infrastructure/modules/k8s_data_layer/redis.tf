resource "helm_release" "redis" {
  name      = "redis"
  chart     = "bitnami/redis"
  namespace = "core"
  version   = "16.13.2"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]
}


