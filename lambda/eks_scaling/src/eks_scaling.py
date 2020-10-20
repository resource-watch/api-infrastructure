import asyncio
import json

import boto3

CLUSTER_NAME = 'core-k8s-cluster-dev'
NODE_GROUPS_TO_SCALE = [
    {
        'nodegroup_name': 'apps-node-group',
        'scaling_config': {
            'minSize': 1,
            'maxSize': 16,
            'desiredSize': 3
        }
    },
    {
        'nodegroup_name': 'gfw-node-group',
        'scaling_config': {
            'minSize': 1,
            'maxSize': 4,
            'desiredSize': 1
        }
    }
]

async def wait_for_update(client, nodegroup_name, initial_progress, update_id):
    progress = initial_progress
    response = None
    while (progress == 'InProgress'):
        await asyncio.sleep(5)
        response = client.describe_update(
            name=CLUSTER_NAME,
            nodegroupName=nodegroup_name,
            updateId=update_id
        )
        progress = response['update']['status']
        print('Progress:', nodegroup_name, progress)
    return response, progress


async def update_nodegroup_config(eks_client, nodegroup_name, scaling_config):

    # Update the nodegroup with the desired config
    response = eks_client.update_nodegroup_config(
        clusterName=CLUSTER_NAME,
        nodegroupName=nodegroup_name,
        scalingConfig=scaling_config
    )
    
    # Wait for the update to report success or failure
    initial_progress = response['update']['status']
    update_id = response['update']['id']
    final_response, final_progress = await wait_for_update(eks_client, nodegroup_name, initial_progress, update_id)

    if final_progress != 'Successful':
        if (final_response is not None):
            errors = final_response['errors']
            raise Exception('Update failed with errors: {}'.format(json.dumps(errors, indent=2, default=str)))
        else:
            raise Exception('Update failed for unknown reasons. Response was empty.')

    return final_response

async def scale_nodegroups():
    eks_client = boto3.client('eks')
    responses = []
    for node_group in NODE_GROUPS_TO_SCALE:
        # TODO: Make these run in parallel
        responses.append(
            await update_nodegroup_config(eks_client, node_group['nodegroup_name'], node_group['scaling_config'])
        )
    return responses

def main():
    # https://stackoverflow.com/questions/60455830/can-you-have-an-async-handler-in-lambda-python-3-6
    body = asyncio.get_event_loop().run_until_complete(scale_nodegroups())
    print(json.dumps(body, indent=2, default=str))
    return {
        "statusCode": 200,
        "body": json.dumps(body, default=str),
    }
    
main()