# Backups

In this directory, you'll find all the artifacts needed to setup regular backups for the different data layers.

## Where are the backups stored?

[AWS cluster PRODUCTION backups are stored here](https://s3.console.aws.amazon.com/s3/buckets/wri-api-production-backups/?region=us-east-1)

[AWS cluster STAGING backups are stored here](https://s3.console.aws.amazon.com/s3/buckets/wri-api-staging-backups/?region=us-east-1)

## Activating the backups

In order to activate the backups, you'll need to apply the different Kubernetes cronjobs to the cluster:

```bash
# Apply Elasticsearch backups
docker apply -f elasticsearch-backup.yaml

# Apply Mongo backups
docker apply -f mongo-backup.yaml

# Apply Mongo CT backups
docker apply -f mongo-ct-backup.yaml

# Apply Neo4j backups
docker apply -f neo4j-backup.yaml

# Apply Postgres backups
docker apply -f postgres-backup.yaml
```

By default, backups will run at 01:35 AM every day. If you need to change this periodicity, you can do so in each of the backup scripts by changing the line that defines the schedule, following the syntax for defining cronjobs: `schedule: "35 01 * * *"`

## Changing the backup scripts

If you need to change the scripts that perform the backups (either `entrypoint.sh` or any of the specific `auto*backup.sh` scripts), you'll need to generate a new version for the `vizzuality/kubecron` Docker image, and set the Kubernetes cronjobs to use that new version. Assuming that the current version is `1.0.0`, to generate a new `1.0.1` version of the Docker image, use the following command:

```bash
docker build -t vizzuality/kubecron:1.0.1 .
```

To push this new version of the Docker image to Docker Hub, use the following command (you'll need to be authenticated in Docker and have access to the Vizzuality organization):

```bash
docker push vizzuality/kubecron:1.0.1
```

After this, you'll need to update the different YAML scripts to use this new version:

* `elasticsearch-backup.yaml`
* `mongo-backup.yaml`
* `mongo-ct-backup.yaml`
* `neo4j-backup.yaml`
* `postgres-backup.yaml`
