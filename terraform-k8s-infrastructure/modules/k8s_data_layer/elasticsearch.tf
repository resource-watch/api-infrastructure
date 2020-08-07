data "kubernetes_secret" "elasticsearch_core" {
  metadata {
    name = "elasticsearch"
    namespace = "core"
  }
}

resource "kubectl_manifest" "es_data_service" {
  yaml_body = file("${path.module}/elasticsearch/data/es-data.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_data_statefulset" {
  yaml_body = templatefile("${path.module}/elasticsearch/data/es-data.statefulset.yaml.tmpl", {
    size: var.elasticsearch_disk_size
  })

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_ingest_deployment" {
  yaml_body = file("${path.module}/elasticsearch/ingest/es-ingest.deployment.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_ingest_service" {
  yaml_body = file("${path.module}/elasticsearch/ingest/es-ingest.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_master_deployment" {
  yaml_body = file("${path.module}/elasticsearch/master/es-master.deployment.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}

resource "kubectl_manifest" "es_master_service" {
  yaml_body = file("${path.module}/elasticsearch/master/es-master.service.yaml")

  depends_on = [
    data.kubernetes_secret.elasticsearch_core
  ]
}


//
//resource "kubectl_manifest" "alb_ingress_controller_main" {
//  yaml_body = templatefile("${path.module}/alb_ingress/alb-ingress-controller.yaml.tmpl", {
//    vpc_id: var.vpc_id,
//    aws_region: var.aws_region,
//    cluster_name: var.cluster_name
//  })
//}

