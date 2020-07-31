#!/bin/bash
set -e

case "$1" in
    start)
        echo "Start cron"
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        echo postgres-postgresql.default.svc.cluster.local:5432:*:postgres:$POSTGRES_PASSWORD > $HOME/.pgpass
        chmod 0600 /root/.pgpass
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        crontab /etc/cron.d/cron
        cron && tail -f /var/log/cron.log
        ;;
    postgres)
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        echo postgres-postgresql.default.svc.cluster.local:5432:*:postgres:$POSTGRES_PASSWORD > $HOME/.pgpass
        chmod 0600 /root/.pgpass
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        echo "Starting auto postgres backup"
        /cronjobs/autopostgresbackup.sh | true
        echo "Syncing to $GCLOUD_BACKUPS_BUCKET/postgres"
        gsutil rsync -r /cronjobs/backups/postgres "$GCLOUD_BACKUPS_BUCKET/postgres"
        rm -rf /cronjobs/backups/postgres/*
        ;;
    neo4j)
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        echo "Starting auto neo backup"
        /cronjobs/autoneobackup.sh | true
        echo "Syncing to $GCLOUD_BACKUPS_BUCKET/neo4j"
        gsutil rsync -r /cronjobs/backups/neo4j "$GCLOUD_BACKUPS_BUCKET/neo4j"
        rm -rf /cronjobs/backups/neo4j/*
        ;;
    elasticsearch)
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        echo "Starting auto elastic backup"
        /cronjobs/autoelasticbackup.sh | true
        ;;
    mongo)
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        echo "Starting auto mongo backup"
        /cronjobs/automongobackup.sh | true
        echo "Syncing to $GCLOUD_BACKUPS_BUCKET/mongo"
        gsutil rsync -r /cronjobs/backups/mongo "$GCLOUD_BACKUPS_BUCKET/mongo"
        rm -rf /cronjobs/backups/mongo/*
        ;;
    mongo-ct)
        echo -e "$GCLOUD_BACKUPS_CREDENTIALS" | base64 -d > /cronjobs/gcloudcredentials.json
        gcloud auth activate-service-account --key-file=/cronjobs/gcloudcredentials.json
        gcloud config set project resource-watch
        echo "Starting auto mongo-ct backup"
        /cronjobs/automongoctbackup.sh | true
        echo "Syncing to $GCLOUD_BACKUPS_BUCKET/mongo-ct"
        gsutil rsync -r /cronjobs/backups/mongo-ct "$GCLOUD_BACKUPS_BUCKET/mongo-ct"
        rm -rf /cronjobs/backups/mongo-ct/*
        ;;
    *)
        exec "$@"
esac
