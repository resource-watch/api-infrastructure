resource "helm_release" "redis" {
  name      = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "redis"
  namespace = "core"
  version   = "16.13.2"

  values = [
    file("${path.module}/redis/redis.yaml")
  ]

  // Enable force update and pod recreation
  force_update  = true
  recreate_pods = true
}


