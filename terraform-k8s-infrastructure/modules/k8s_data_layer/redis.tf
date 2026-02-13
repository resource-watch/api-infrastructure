resource "helm_release" "redis" {
  name      = "redis"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart     = "redis"
  namespace = "core"
  version   = "16.13.2"

  values = [
    file("${path.module}/redis_values/redis.yaml")
  ]

  // Enable force update and pod recreation
  force_update  = true
  recreate_pods = true
}


