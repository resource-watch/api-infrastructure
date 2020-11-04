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

        /cronjobs/area-automongobackup.sh | true
        echo "Syncing areas backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/clayers-automongobackup.sh | true
        echo "Syncing clayers backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/control-tower-automongobackup.sh | true
        echo "Syncing control-tower backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/dataset-automongobackup.sh | true
        echo "Syncing dataset backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/doc-orchestrator-automongobackup.sh | true
        echo "Syncing doc-orchestrator backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/forms-automongobackup.sh | true
        echo "Syncing forms backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/geostore-automongobackup.sh | true
        echo "Syncing geostore backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/layer-automongobackup.sh | true
        echo "Syncing layer backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/layerbackup-automongobackup.sh | true
        echo "Syncing layerbackup backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/metadata-automongobackup.sh | true
        echo "Syncing metadata backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/story-automongobackup.sh | true
        echo "Syncing story backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/subscription-automongobackup.sh | true
        echo "Syncing subscription backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/user-automongobackup.sh | true
        echo "Syncing user backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/vocabulary-automongobackup.sh | true
        echo "Syncing vocabulary backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        /cronjobs/widget-automongobackup.sh | true
        echo "Syncing widget backup to $AWS_BACKUPS_BUCKET_URI/mongo"
        aws s3 sync /cronjobs/backups/mongo "$AWS_BACKUPS_BUCKET_URI/mongo"

        rm -rf /cronjobs/backups/mongo/*
        ;;
    *)
        exec "$@"
esac
