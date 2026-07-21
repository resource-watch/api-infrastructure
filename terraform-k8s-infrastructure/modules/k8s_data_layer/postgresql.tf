data "kubernetes_secret" "postgresql_core" {
  metadata {
    name      = "postgresql"
    namespace = "core"
  }
}

resource "helm_release" "postgresql" {
  name      = "postgresql"
  #repository = "oci://registry-1.docker.io/bitnamicharts"
  chart     = "${path.module}/charts/postgresql"
  namespace = "core"
  #version   = "18.3.0"
  #verify    = false # Temporarily necessery

  # In a degraded state, so don't wait for it to be ready.
  wait = false

  values = [
    file("${path.module}/postgresql_values/postgresql.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.postgresql_core
  ]
}


