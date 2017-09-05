# MONGO BACKUPS
echo "start automongobackup"
/cronjobs/automongobackup.sh | true
# GCLOUD STORAGE BUCKET rsync
gsutil rsync -r /cronjobs/backups/mongo gs://api-backups/mongo
rm -rf /cronjobs/backups/mongo/*
echo "start autoelasticbackup"
/cronjobs/autoelasticbackup.sh | true
