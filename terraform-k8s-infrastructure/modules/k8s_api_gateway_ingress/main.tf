data "http" "k8s_gateway_api_crd_manifest" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml"

  request_headers = {
    Accept = "text/plain"
  }
}

data "kubectl_file_documents" "crd_docs" {
  content = data.http.k8s_gateway_api_crd_manifest.response_body
}

data "http" "k8s_gateway_api_lbc_crd_manifest" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml"

  request_headers = {
    Accept = "text/plain"
  }
}

data "kubectl_file_documents" "lbc_crd_docs" {
  content = data.http.k8s_gateway_api_lbc_crd_manifest.response_body
}

resource "kubectl_manifest" "apply_crds" {
  for_each = data.kubectl_file_documents.crd_docs.manifests
  yaml_body = each.value

  server_side_apply = true
  force_conflicts = true

  lifecycle {
    ignore_changes = [yaml_body]
  }
}

resource "kubectl_manifest" "apply_lbc_crds" {
  for_each = data.kubectl_file_documents.lbc_crd_docs.manifests
  yaml_body = each.value

  server_side_apply = true
  force_conflicts = true

  lifecycle {
    ignore_changes = [yaml_body]
  }
}

resource "kubectl_manifest" "gateway_class" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: alb
spec:
  controllerName: gateway.k8s.aws/alb
YAML
}

resource "kubectl_manifest" "shared_gateway" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: core
  annotations:
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/target-type: ip
spec:
  gatewayClassName: alb
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
YAML
}

# Needs at least one HTTPRoute to create the ALB Listener
# Points to the rw_lp service
resource "kubectl_manifest" "shared_gateway_health" {
  yaml_body = <<YAML
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: shared-gateway-health
  namespace: default
spec:
  parentRefs:
  - kind: Gateway
    name: shared-gateway
    namespace: core
  rules:
  - matches:
    - path:
        type: Exact
        value: /health
    backendRefs:
    - name: rw-lp
      port: 30559
YAML
}