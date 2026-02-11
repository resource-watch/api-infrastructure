resource "helm_release" "redis" {
  name      = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "redis"
  namespace = "core"
  version   = "16.13.2"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]
}


