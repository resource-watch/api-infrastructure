resource "helm_release" "redis" {
  name      = "redis"
  chart     = "bitnami/redis"
  namespace = "core"
  version   = "10.5.7"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]
}


