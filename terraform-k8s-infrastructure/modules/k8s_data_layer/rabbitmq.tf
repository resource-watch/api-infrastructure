data "kubernetes_secret" "rabbitmq_core" {
  metadata {
    name      = "rabbitmq-passwords"
    namespace = "core"
  }
}
resource "helm_release" "rabbitmq" {
  name      = "rabbitmq"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart     = "rabbitmq"
  namespace = "core"
  version   = "16.0.14"

  values = [
    file("${path.module}/rabbitmq_values/rabbitmq.yaml")
  ]

  depends_on = [
    data.kubernetes_secret.rabbitmq_core
  ]
}
