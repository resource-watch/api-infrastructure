resource "helm_release" "redis" {
  name       = "redis"
  chart      = "stable/redis"
  namespace = "core"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]
}


