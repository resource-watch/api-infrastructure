data "kubernetes_secret" "postgresql_core" {
  metadata {
    name      = "postgresql"
    namespace = "core"
  }
}
resource "helm_release" "postgresql" {
  name      = "postgresql"
  chart     = "bitnami/postgresql"
  namespace = "core"

  values = [
    file("${path.module}/postgresql/postgresql.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.postgresql_core
  ]
}


