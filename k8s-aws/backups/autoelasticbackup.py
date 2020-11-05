import os
from datetime import datetime

import boto3
import click
import requests
from requests.model import Response
from requests_aws4auth import AWS4Auth
from typing import Any, Dict, Optional


@click.command()
@click.option('--host', type=str, help='Elastic Search Host.')
@click.option('--region', type=str, default="us-east-1", help='AWS region.')
@click.option('--snapshot', type=str, help='Snapshot name.')
@click.option('--role_arn', type=str, help='Snapshot IAM Role.')
@click.option('--bucket', type=str, help='Backup S3 Bucket.')
@click.option('--base_path', type=str, required=False, help='S3 Prefix.')
def cli(host: str, region: str, snapshot: str, role_arn: str, bucket: str, base_path: Optional[str] = None) -> None:
    """Main function to trigger Elastic Search Backup"""
    service: str = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth: AWS4Auth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service,
                                 session_token=credentials.token)

    settings: Dict[str, str] = {
        "bucket": bucket,
        "region": region,
        "role_arn": role_arn
    }
    if base_path:
        settings["base_path"] = base_path

    register_snapshot(host, snapshot, awsauth, settings)
    take_snapshot(host, snapshot, awsauth)


def register_snapshot(host: str, snapshot: str, awsauth: str, settings: Dict[str, str]) -> None:
    url: str = os.path.join(host, "_snapshot", snapshot)

    payload: Dict[str, Any] = {
        "type": "s3",
        "settings": settings
    }

    headers = {"Content-Type": "application/json"}

    r = requests.put(url, auth=awsauth, json=payload, headers=headers)

    if r.status_code != 200:
        click.echo("WARNING: Cannot register snapshot.")
        click.echo(r.text)

    else:
        click.echo("Successfully registered snapshot.")


def take_snapshot(host: str, snapshot: str, awsauth: str) -> None:
    name: str = f"{datetime.utcnow()}".replace(" ", "_")
    url: str = os.path.join(host, "_snapshot", snapshot, name)

    r: Response = requests.put(url, auth=awsauth)

    if r.status_code != 200:
        raise RuntimeError(r.text)
    else:
        click.echo("Successfully started taking snapshot.")


if __name__ == "__main__":
    cli()
