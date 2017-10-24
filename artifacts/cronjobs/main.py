"""main"""

import os
import json
import requests


def update_dataset(dataset_id):
    print('failed -> updating dataset: '+dataset_id)
    session = requests.Session()
    request = requests.Request(
        method='PATCH',
        url='https://api.resourcewatch.org/v1/dataset/'+dataset_id,
        data=json.dumps({
            'status': 2,
            'errorMessage': '[Automatic Validation] ConnectorFailed -> Invalid Dataset'
        }),
        headers={
            'Authorization': 'Bearer '+os.getenv('CT_TOKEN'),
            'Content-Type': 'application/json'
        })
    prepped = session.prepare_request(request)
    response = session.send(prepped)
    print(response.status_code)


def check_dataset(dataset):
    dataset_id = dataset.get('id')
    print('checking dataset '+dataset_id)
    dataset_connector_type = dataset.get('attributes').get('connectorType')
    dataset_provider = dataset.get('attributes').get('provider')
    dataset_table_name = dataset.get('attributes').get('tableName')
    if dataset_connector_type == 'rest':
        if dataset_provider in ['cartodb', 'featureservice', 'bigquery']:
            url = 'https://api.resourcewatch.org/v1/query/'+dataset_id+'?sql=select * from '+dataset_table_name+' limit 1'
        if dataset_provider in ['nexgddp', 'rasdaman']:
            # @TODO
            url = 'https://api.resourcewatch.org/v1/dataset/'+dataset_id
        if dataset_provider == 'gee' and dataset_table_name[:3] != 'ft:':
            url = 'https://api.resourcewatch.org/v1/query/'+dataset_id+'?sql=select st_metadata(the_raster_webmercator) from '+dataset_table_name+' limit 1'
    elif dataset_connector_type == 'document':
        url = 'https://api.resourcewatch.org/v1/query/'+dataset_id+'?sql=select * from '+dataset_table_name+' limit 1'
    elif dataset_connector_type == 'wms':
        # @TODO
        url = 'https://api.resourcewatch.org/v1/dataset/'+dataset_id
    else:
        url = 'https://api.resourcewatch.org/v1/dataset/'+dataset_id

    query = requests.get(url)
    print(query.status_code)
    if query.status_code != 200:
        update_dataset(dataset_id)


def main():
    try:
        req = requests.get("https://api.resourcewatch.org/v1/dataset?status=saved&includes=layer&page[size]=99999999")
    except Exception:
        raise
    datasets = req.json().get('data')
    for dataset in datasets:
        check_dataset(dataset)


if __name__ == '__main__':
    main()
