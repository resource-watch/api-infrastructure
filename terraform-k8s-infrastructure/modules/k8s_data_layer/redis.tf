resource "helm_release" "redis" {
  name      = "redis"
  // For some reason the OCI: registry doesn't work here, even though
  // it is required for the others?
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "redis"
  namespace = "core"
  version   = "16.13.2"
  timeout   = 1200

  values = [
    file("${path.module}/redis_values/redis.yaml")
  ]

  // Enable force update and pod recreation
  force_update  = true
  recreate_pods = true
}


