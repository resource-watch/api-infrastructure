resource "helm_release" "mongodb_apps" {
  name       = "mongodb-apps"
  chart      = "stable/mongodb-replicaset"
  namespace = "core"

  values = [
    file("${path.module}/mongodb_apps/mongodb-apps-values.yaml")
  ]
}


