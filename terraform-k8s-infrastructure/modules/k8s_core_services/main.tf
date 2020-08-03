resource "kubernetes_service" "dataset_service" {
  metadata {
    name = "dataset"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=dataset"
    }
  }
  spec {
    selector = {
      name = "dataset"
    }
    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}