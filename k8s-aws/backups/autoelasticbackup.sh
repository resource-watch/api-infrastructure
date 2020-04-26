#!/bin/bash
DATE=$(date +%Y-%m-%d_%Hh%Mm)
URL_PATH='http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/'
PARAMS='?wait_for_completion=true'
URL=$URL_PATH$DATE$PARAMS

echo 'Creating snapshot repository'
curl -X PUT \
  http://elasticsearch.core.svc.cluster.local:9200/_snapshot/wri-api-backups/ \
  --header 'Content-Type: application/json' \
  -d '{
  "type": "s3",
  "settings": {
    "bucket": "'$AWS_BACKUPS_BUCKET_NAME'",
    "base_path": "elasticsearch"
  }
}'
echo ''
echo 'Uploading Elastic Backup to:'
echo $URL
curl -XPUT $URL \
  --header 'Content-Type: application/json'
