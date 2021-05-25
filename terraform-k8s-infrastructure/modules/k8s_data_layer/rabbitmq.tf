data "kubernetes_secret" "rabbitmq_core" {
  metadata {
    name      = "rabbitmq-passwords"
    namespace = "core"
  }
}
resource "helm_release" "rabbitmq" {
  name      = "rabbitmq"
  chart     = "bitnami/rabbitmq"
  namespace = "core"
  version   = "6.18.2"

  values = [
    file("${path.module}/rabbitmq/rabbitmq.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.rabbitmq_core
  ]
}
