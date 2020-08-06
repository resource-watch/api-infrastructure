data "kubernetes_secret" "rabbitmq_core" {
  metadata {
    name      = "rabbitmq-passwords"
    namespace = "core"
  }
}
resource "helm_release" "rabbitmq" {
  name      = "rabbitmq"
  chart     = "stable/rabbitmq"
  namespace = "core"

  values = [
    file("${path.module}/rabbitmq/rabbitmq.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.rabbitmq_core
  ]
}


