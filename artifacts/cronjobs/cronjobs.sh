#!/usr/bin/env bash

echo "Starting auto mongo backup"
/cronjobs/automongobackup.sh | true
gsutil rsync -r /cronjobs/backups/mongo gs://api-backups/mongo
rm -rf /cronjobs/backups/mongo/*

echo "Starting auto mongo-ct backup"
/cronjobs/automongoctbackup.sh | true
gsutil rsync -r /cronjobs/backups/mongo-ct gs://api-backups/mongo-ct
rm -rf /cronjobs/backups/mongo-ct/*

echo "Starting auto postgres backup"
/cronjobs/autopostgresbackup.sh | true
gsutil rsync -r /cronjobs/backups/postgres gs://api-backups/postgres
rm -rf /cronjobs/backups/postgres/*

echo "Starting auto neo backup"
/cronjobs/autoneobackup.sh | true
gsutil rsync -r /cronjobs/backups/neo4j gs://api-backups/neo4j
rm -rf /cronjobs/backups/neo4j/*

echo "Starting auto elastic backup"
/cronjobs/autoelasticbackup.sh | true
