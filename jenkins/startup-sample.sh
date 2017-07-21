#!/bin/sh

gcloud auth activate-service-account --key-file=gcloudcredentials.json
gcloud config set project resource-watch
gcloud container clusters get-credentials wri-prod \
    --zone us-east1-c --project resource-watch
