resource "helm_release" "mongo_apps" {
  name       = "mongo-apps"
  chart      = "stable/mongodb-replicaset"
  namespace = "core"

  values = [
    file("${path.module}/mongo_apps/mongo-apps-values.yaml")
  ]
}


