resource "helm_release" "redis" {
  name      = "redis"
  chart     = "bitnami/redis"
  namespace = "core"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]
}


