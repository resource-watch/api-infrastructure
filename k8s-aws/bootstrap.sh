#!/bin/bash

#
# Create namespaces
#
kubectl create namespace gateway
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
# See nginx/README.md


#
# Kubernetes RBAC role and ALB ingress controller files, so that AWS creates ALB automatically from Ingresses.
#
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
## Next, you MUST configure the ingress controller. See https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html for details

#
# At this stage, you should go into AWS ACM and provision the certificates associated with the domains captured in your ingresses
# The ALB Ingress controller will automagically associate certificates by domain, but only if they already exist.
# Also: be sure to use a cert per ingress.
#


#
# Ingress
#

# API Ingress
kubectl apply -f ingress/<environment>

#
# MongoDB + Replicaset for Control Tower
#

# TODO: Apply `gateway/mongodb-gateway` secrets
helm install mongodb-gateway stable/mongodb-replicaset -f mongodb-gateway/mongo-gateway-values.yaml --namespace gateway
# TODO: Create user in MongoDB for Control Tower
# TODO: Apply `default/secrets-ct` secrets
# TODO: Apply `default/secrets-db` secrets
# TODO: Deploy Control Tower

#
# MongoDB + Replicaset for Microservices
#

helm install mongodb-apps stable/mongodb-replicaset -f mongodb-apps/mongo-apps-values.yaml --namespace core

#
# Elasticsearch
#
# See elasticsearch/README.md



#
# AWS Metrics Server for HPAs
# Read and follow the instructions on ./metrics-server/README.md
#


#
# AWS Cluster Autoscaller
# Read and follow the instructions on ./cluster-autoscaller/README.md
#

#
# Log aggregation on AWS CloudWatch
# See also: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html
#
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/core-k8s-cluster/;s/{{region_name}}/us-east-1/" | kubectl apply -f -
