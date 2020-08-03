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