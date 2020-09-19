resource "kubernetes_namespace" "namespace" {

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "ct_secrets" {
  # only  create secrets  if db_secrets set
  count = length(var.ct_secrets) > 0 ? 1 : 0
  metadata {
    annotations = {
      name      = "ctsecrets"
      namespace = var.namespace
    }
  }

  type = "Opaque"
  data = var.db_secrets
}

resource "kubernetes_secret" "db_secrets" {
  # only  create secrets  if db_secrets set
  count = length(var.db_secrets) > 0 ? 1 : 0
  metadata {
    annotations = {
      name      = "dbsecrets"
      namespace = var.namespace
    }
  }

  type = "Opaque"
  data = var.db_secrets
}

resource "kubernetes_secret" "app_secrets" {
  # only  create secrets  if dbsecrets set
  count = length(var.app_secrets) > 0 ? 1 : 0
  metadata {
    annotations = {
      name      = "appsecrets"
      namespace = var.namespace
    }
  }

  type = "Opaque"
  data = var.app_secrets
}

resource "kubernetes_secret" "ms_secrets" {
  # only  create secrets  if ms_secrets set
  count = length(var.ms_secrets) > 0 ? 1 : 0
  metadata {
    annotations = {
      name      = "mssecrets"
      namespace = var.namespace
    }
  }

  type = "Opaque"
  data = var.ms_secrets
}


resource "kubernetes_secret" "container_registry" {
  # only  create secrets  if container_registry_server set
  count = length(var.container_registry_server) > 0 ? 1 : 0
  metadata {
    annotations = {
      name      = "regcred"
      namespace = var.namespace
    }
  }

  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = <<DOCKER
      {
        "auths": {
          "${var.container_registry_server}": {
            "auth": "${base64encode("${var.container_registry_username}:${var.container_registry_password}")}"
          }
        },
        "HttpHeaders": {
          "User-Agent": "Docker-Client/19.03.2-ce (linux)"
          }
      }
      DOCKER
  }
}