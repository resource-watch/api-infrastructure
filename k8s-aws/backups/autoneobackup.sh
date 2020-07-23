DATE=$(date +%Y-%m-%d_%Hh%Mm)
neo4j-admin backup --from=neo4j-neo4j.core.svc.cluster.local --backup-dir=/cronjobs/backups/neo4j --name=graph.db-backup-$DATE
