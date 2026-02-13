data "kubernetes_secret" "postgresql_core" {
  metadata {
    name      = "postgresql"
    namespace = "core"
  }
}
resource "helm_release" "postgresql" {
  name      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "postgresql"
  namespace = "core"
  version   = "18.3.0"
  verify    = false # Temporarily necessery

  values = [
    file("${path.module}/postgresql/postgresql.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.postgresql_core
  ]
}


