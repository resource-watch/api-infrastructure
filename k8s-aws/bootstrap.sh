#!/bin/bash

#
# Create namespaces
#
kubectl create namespace core
kubectl create namespace aqueduct
kubectl create namespace rw
kubectl create namespace gfw
kubectl create namespace fw
kubectl create namespace prep
kubectl create namespace climate-watch

#
# Nginx reverse proxy
#

# Deploy nginx config + vhosts as ConfigMaps
kubectl create configmap nginx-hosts --from-file=nginx/nginx-hosts.configmap.conf
kubectl create configmap nginx-conf --from-file=nginx/nginx-config.configmap.conf

# Deploy nginx service and deployment
kubectl apply -f nginx/nginx.deployment.yaml
kubectl apply -f nginx/nginx.service.yaml

#
# Kubernetes RBAC role and ALB ingress controller files, so that AWS creates ALB automatically from Ingresses.
#
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml

#
# Ingress
#



# API Ingress
kubectl apply -f ingress/api-ingress.ingress.yaml

#
# MongoDB + Replicaset for Control Tower
#

# TODO: Apply `core/mongodb-gateway` secrets
helm install mongodb-gateway stable/mongodb-replicaset -f mongo-gateway/mongo-gateway-values.yaml --namespace core
# TODO: Create user in MongoDB for Control Tower
# TODO: Apply `default/secrets-ct` secrets
# TODO: Apply `default/secrets-db` secrets
# TODO: Deploy Control Tower


