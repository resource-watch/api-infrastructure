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
    *)
        exec "$@"
esac
