#!/bin/sh

gcloud auth activate-service-account --key-file=gcloudcredentials.json
gcloud config set project resource-watch
