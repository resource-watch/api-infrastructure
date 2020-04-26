#!/bin/bash
set -e

case "$1" in
    postgres)
        echo postgresql.core.svc.cluster.local:5432:*:postgres:$POSTGRES_PASSWORD > $HOME/.pgpass
        chmod 0600 /root/.pgpass
        echo "Starting auto postgres backup"
        /cronjobs/autopostgresbackup.sh
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/postgres"
        aws s3 sync /cronjobs/backups/postgres "$AWS_BACKUPS_BUCKET_URI/postgres"
        rm -rf /cronjobs/backups/postgres/*
        ;;
    neo4j)
        echo "Starting auto neo backup"
        /cronjobs/autoneobackup.sh | true
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/neo4j"
        aws s3 sync /cronjobs/backups/neo4j "$AWS_BACKUPS_BUCKET_URI/neo4j"
        rm -rf /cronjobs/backups/neo4j/*
        ;;
    elasticsearch)
        echo "Starting auto elastic backup"
        /cronjobs/autoelasticbackup.sh | true
        ;;
    mongo)
        echo "Starting auto mongo backup"
        /cronjobs/automongobackup.sh | true
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"
        rm -rf /cronjobs/backups/mongo/*
        ;;
    mongo-ct)
        echo "Starting auto mongo-ct backup"
        /cronjobs/automongoctbackup.sh | true
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/mongo-ct"
        aws s3 sync /cronjobs/backups/mongo-ct "$AWS_BACKUPS_BUCKET_URI/mongo-ct"
        rm -rf /cronjobs/backups/mongo-ct/*
        ;;
    *)
        exec "$@"
esac
