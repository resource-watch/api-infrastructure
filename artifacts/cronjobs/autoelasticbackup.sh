#!/bin/bash
DATE=$(date +%Y-%m-%d_%Hh%Mm)
URL_PATH=$'http://elastic.default.svc.cluster.local:9200/_snapshot/wri-api-backups/'
PARAMS=$'?wait_for_completion=true'
URL=$URL_PATH$DATE$PARAMS
echo 'Uploading Elastic Backup to:'
echo $URL
curl -XPUT $URL
