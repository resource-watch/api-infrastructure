#!/bin/bash
set -e

case "$1" in
    postgres)
        echo $POSTGRES_URI:5432:*:postgres:$POSTGRES_PASSWORD > $HOME/.pgpass
        chmod 0600 /root/.pgpass
        echo "Starting auto postgres backup"
        /cronjobs/autopostgresbackup.sh
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/postgres"
        aws s3 sync /cronjobs/backups/postgres "$AWS_BACKUPS_BUCKET_URI/postgres"
        rm -rf /cronjobs/backups/postgres/*
        ;;
    neo4j)
        echo "Starting auto neo backup"
        /cronjobs/autoneobackup.sh || true
        echo "Syncing to $AWS_BACKUPS_BUCKET_URI/neo4j"
        aws s3 sync /cronjobs/backups/neo4j "$AWS_BACKUPS_BUCKET_URI/neo4j"
        rm -rf /cronjobs/backups/neo4j/*
        ;;
    elasticsearch)
        echo "Starting auto elastic backup"
        /cronjobs/autoelasticbackup.sh || true
        ;;
    mongo)
        echo "Starting auto mongo backup"

        BACKUP_DIR="/cronjobs/backups/mongo"

        # List of databases with default backup strategy
        default_backups=("area"
                         "contextual-layers"
                         "dataset"
                         "doc-orchestrator"
                         "forms"
                         "geostore"
                         "layer"
                         "layerbackup"
                         "metadata"
                         "story"
                         "subscription"
                         "teams"
                         "user"
                         "vocabulary"
                         "widget")

        for db in "${default_backups[@]}"; do
          /cronjobs/automongobackup.sh --dbhost "$MONGODB_URI" \
                                       --dbname "$db" \
                                       --dbusername "$MONGODB_USER" \
                                       --dbpassword "$MONGODB_PASSWORD" \
                                       --backup_dir "$BACKUP_DIR" || true
          echo "Syncing areas backup to $AWS_BACKUPS_BUCKET_URI/mongo"
          aws s3 sync "$BACKUP_DIR" "$AWS_BACKUPS_BUCKET_URI/mongo"
        done

        # Databases with custom backup strategy
        /cronjobs/automongobackup.sh --dbhost "$MONGODB_URI" \
                                     --dbname control-tower \
                                     --dbusername "$MONGODB_USER" \
                                     --dbpassword "$MONGODB_PASSWORD" \
                                     --exclude_collection statistics \
                                     --backup_dir "$BACKUP_DIR" || true
        echo "Syncing areas backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync "$BACKUP_DIR" "$AWS_BACKUPS_BUCKET_URI/mongo"

        # Clean up
        rm -rf ${BACKUP_DIR:?}/*
        ;;
    *)
        exec "$@"
esac
