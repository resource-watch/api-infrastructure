import asyncio
import json

import boto3

def should_update_scaling_config(client, cluster_name, nodegroup_name, desired_scaling_config):
    response = client.describe_nodegroup(
        clusterName=cluster_name,
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

def scale_nodegroups(cluster_name, scaling_config):
    eks_client = boto3.client('eks')
    for nodegroup_name in scaling_config:
        ng_scaling_config = scaling_config[nodegroup_name]['scaling_config']
        if should_update_scaling_config(eks_client, cluster_name, nodegroup_name, ng_scaling_config):
            # Update the nodegroup with the desired config
            response = eks_client.update_nodegroup_config(
                clusterName=cluster_name,
                nodegroupName=nodegroup_name,
                scalingConfig=ng_scaling_config
            )
            # Yield info about the update for tracking purposes
            yield {
                "cluster": cluster_name,
                "nodegroup": nodegroup_name,
                "update_response": response
            }

def lambda_handler(event, context):
    # event is JSON that looks like this:
    # {
    #   "eks_cluster_name": "cluster-name",
    #   "scaling_config": {
    #     "apps-node-group": {
    #       "minSize": 123,
    #       "maxSize": 123,
    #       "desiredSize": 123
    #     },
    #     "gfw-node-group": {
    #       "minSize": 123,
    #       "maxSize": 123,
    #       "desiredSize": 123
    #     }
    #   }
    # }
    print("Incoming event:", json.dumps(event, default=str))
    cluster_name = event["eks_cluster_name"]
    scaling_config = event["scaling_config"]

    # Return responses from the update requests so we can
    # look up update_ids later if necessary for debugging
    body = [r for r in scale_nodegroups(cluster_name, scaling_config)]
    return {
        "statusCode": 200,
        "body": json.dumps(body, default=str),
    }