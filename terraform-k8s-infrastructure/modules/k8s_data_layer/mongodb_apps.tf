resource "helm_release" "mongodb_apps" {
  name      = "mongodb-apps"
  chart     = "stable/mongodb-replicaset"
  namespace = "core"
  version   = "3.15.0"

  values = [
    file("${path.module}/mongodb_apps/mongodb-apps-values.yaml")
  ]
}


