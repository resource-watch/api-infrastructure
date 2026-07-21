resource "helm_release" "mongodb_apps" {
  name      = "mongodb-apps"
  #chart     = "stable/mongodb-replicaset"
  chart     = "${path.module}/charts/mongodb-replicaset"
  namespace = "core"
  #version   = "3.15.0"

  # In a degraded state, so don't wait for it to be ready.
  wait = false

  values = [
    file("${path.module}/mongodb_apps_values/mongodb-apps-values.yaml")
  ]
}