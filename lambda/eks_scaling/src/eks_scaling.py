import asyncio
import json

import boto3

CLUSTER_NAME = 'core-k8s-cluster-dev'
NODEGROUPS_TO_SCALE = {
    'apps-node-group': {
        'scaling_config': {
            'minSize': 1,
            'maxSize': 16,
            'desiredSize': 3
        }
    },
    'gfw-node-group': {
        'scaling_config': {
            'minSize': 1,
            'maxSize': 4,
            'desiredSize': 1
        }
    }
}

def should_update_scaling_config(client, nodegroup_name, desired_scaling_config):
    response = client.describe_nodegroup(
        clusterName=CLUSTER_NAME,
        nodegroupName=nodegroup_name
    )
    nodegroup = response['nodegroup']

    # TODO: how to handle this on the backend? At scaledown, need to force the update regardless of current status
    # Don't update if node group is already updating (or down) or if the config is already correct
    if nodegroup['status'] != "ACTIVE":
        print("Nodegroup {} has status {}. Skipping update.".format(nodegroup_name, nodegroup['status']))
        return False
    elif nodegroup['scalingConfig'] == desired_scaling_config:
        print("Nodegroup {} already has desired scaling config {}. Skipping update.".format(
            nodegroup_name, json.dumps(nodegroup['scalingConfig'])
        ))
        return False
    print("Proceeding with update for nodegroup {}.".format(nodegroup_name))
    return True

def scale_nodegroups():
    eks_client = boto3.client('eks')
    for nodegroup_name in NODEGROUPS_TO_SCALE:
        scaling_config = NODEGROUPS_TO_SCALE[nodegroup_name]['scaling_config']
        if should_update_scaling_config(eks_client, nodegroup_name, scaling_config):
            # Update the nodegroup with the desired config
            response = eks_client.update_nodegroup_config(
                clusterName=CLUSTER_NAME,
                nodegroupName=nodegroup_name,
                scalingConfig=scaling_config
            )
            # Yield info about the update for tracking purposes
            yield {
                "cluster": CLUSTER_NAME,
                "nodegroup": nodegroup_name,
                "update_response": response
            }

def lambda_handler(event, context):
    # Return responses from the update requests so we can
    # look up update_ids later if necessary for debugging
    body = [r for r in scale_nodegroups()]
    return {
        "statusCode": 200,
        "body": json.dumps(body, default=str),
    }