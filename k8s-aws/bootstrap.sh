#!/bin/bash

#Nginx reverse proxy configuration
kubectl create configmap nginx-hosts --from-file=nginx/nginx-hosts.configmap.conf
kubectl create configmap nginx-conf --from-file=nginx/nginx-config.configmap.conf

#Nginx reverse proxy service and deployment
kubectl apply -f nginx/nginx.deployment.yaml
kubectl apply -f nginx/nginx.service.yaml

#Kubernetes RBAC role and ALB ingress controller files, so that AWS creates ALB automatically from Ingresses.
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml

#Ingress
kubectl apply -f ingress/api-ingress.ingress.yaml