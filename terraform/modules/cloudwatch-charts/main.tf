resource "aws_cloudwatch_dashboard" "rw_api_keys_usage" {
  dashboard_name = "RW_API_Key_usage"

  dashboard_body = jsonencode({
    "widgets": [
      {
        "type": "log",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "query": "SOURCE 'api-keys-usage' | fields @message\n| filter ispresent(request.method)\n| stats count(*) as requests by request.method, request.path as request_count\n| sort by request_count",
          "region": "us-east-1",
          "stacked": false,
          "title": "Requests per endpoint",
          "view": "pie"
        }
      },
      {
        "type": "log",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "query": "SOURCE 'api-keys-usage' | fields @message\n| filter ispresent(request.method)\n| stats count(*) as requests by @logStream as requests_count\n| sort by requests_count\n",
          "region": "us-east-1",
          "stacked": false,
          "title": "Requests per microservice",
          "view": "pie"
        }
      },
      {
        "type": "log",
        "x": 0,
        "y": 6,
        "width": 12,
        "height": 6,
        "properties": {
          "query": "SOURCE 'api-keys-usage' | fields @message\n| stats count(*) as requests by coalesce(requestApplication.name, \"<no application>\") as requests_count\n| sort by requests_count\n",
          "region": "us-east-1",
          "stacked": false,
          "title": "Requests per application",
          "view": "pie"
        }
      },
      {
        "type": "log",
        "x": 12,
        "y": 6,
        "width": 12,
        "height": 6,
        "properties": {
          "query": "SOURCE 'api-keys-usage' | fields @message\n| stats count(*) as requests by coalesce(requestApplication.organization.name, \"<no organization>\") as requests_count\n| sort by requests_count\n",
          "region": "us-east-1",
          "stacked": false,
          "title": "Requests per organization",
          "view": "pie"
        }
      }
    ]
  })
}
