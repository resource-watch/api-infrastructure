#####
#
# NOTE: this is not fully blown, and for now it focuses only on the canary script
# Known limitations/TODO:
# - Most changes in the config are not picked up by TF, and require changes in the resource config to force a redeploy
# - Alarms are not covered, so this can be used to create a new canary, but it will not trigger emails to anyone if it fails.
#
####

module "convert-fs2sql" {
  source               = "./api-endpoint-canary"
  name                 = "convert-fs2sql"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/convert-fs2sql-4f6-24a1ee6237dc"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/convert/fs2SQL?tableName=table&outFields=fields&where=filter=filtered&outStatistics=true&groupByFieldsForStatistics=sortfields&resultRecordCount=10&orderByFields=orderfields"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "vocabulary-get" {
  source               = "./api-endpoint-canary"
  name                 = "vocabulary-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/vocabulary-get-a3f-1681926b8fe0"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/vocabulary"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "india-cwdata-org" {
  source               = "./url-canary"
  name                 = "india-cwdata-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/india-cwdata-org-e1f-5368c9ddee47"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "http://india.climatewatchdata.org"
  schedule_expression  = "rate(5 minutes)"
}

module "post-and-get-geostore" {
  source                 = "./api-endpoint-canary"
  name                   = "post-and-get-geostore"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/post-and-get-geostore-034-578dac4dd238"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/geostore"
  verb                   = "POST"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/post-and-get-geostore.js.tpl"
}

module "subscriptions-get" {
  source               = "./api-endpoint-canary"
  name                 = "subscriptions-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/subscriptions-get-491-639c74015dbd"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/subscriptions"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "fields-get" {
  source               = "./api-endpoint-canary"
  name                 = "fields-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/fields-get-dcf-a0a46ff5bcb6"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/fields/098b33df-6871-4e53-a5ff-b56a7d989f9a"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "get-gee-tile" {
  source                 = "./api-endpoint-canary"
  name                   = "get-gee-tile"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/get-gee-tile-059-3ff0f2b704c3"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/layer/47dc9961-05d6-48f1-93c5-aa633e4a1efa/tile/gee/3/5/5"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/get-gee-tile.js.tpl"
}

module "jiminy-get" {
  source               = "./api-endpoint-canary"
  name                 = "jiminy-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/jiminy-get-9a3-2bd6cee92c69"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/jiminy/?sql=SELECT%20iso%2C%20name_1%2C%20type_1%2C%20shape_area%2C%20area_ha%20FROM%20098b33df-6871-4e53-a5ff-b56a7d989f9a%20%20ORDER%20BY%20area_ha%20desc%20LIMIT%2050"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "climatedata-org" {
  source               = "./url-canary"
  name                 = "climatedata-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/climatedata-org-086-895a7658fd66"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://climatedata.org"
  schedule_expression  = "rate(1 hour)"
}

module "widget-get" {
  source               = "./api-endpoint-canary"
  name                 = "widget-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/widget-get-781-eed6e98e75b3"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/widget"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "indiacexplorer-org" {
  source               = "./url-canary"
  name                 = "indiacexplorer-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/indiacexplorer-org-f58-1d81087f9cb8"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "http://indiaclimateexplorer.org"
  schedule_expression  = "rate(1 hour)"
}

module "metadata-get" {
  source               = "./api-endpoint-canary"
  name                 = "metadata-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/metadata-get-c3b-fed40ded7a59"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/metadata?limit=10"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "layer-get-by-id" {
  source                 = "./api-endpoint-canary"
  name                   = "layer-get-by-id"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/layer-get-by-id-7ab-7323bb0de62e"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/layer"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/layer-get-by-id.js.tpl"
}

module "post-widget-find-ids" {
  source                 = "./api-endpoint-canary"
  name                   = "post-widget-find-ids"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/post-widget-find-ids-bb6-8f37c1ab1104"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/widget"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/post-widget-find-ids.js.tpl"
}

module "similar-dataset-get" {
  source                 = "./api-endpoint-canary"
  name                   = "similar-dataset-get"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/similar-dataset-get-056-e1d66816165a"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/similar-dataset-get.js.tpl"
}

module "prepdata-org" {
  source               = "./url-canary"
  name                 = "prepdata-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/prepdata-org-daf-0304980e70f4"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://prepdata.org"
  schedule_expression  = "rate(1 hour)"
}

module "topic-get" {
  source               = "./api-endpoint-canary"
  name                 = "topic-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/topic-get-37a-981da4182f78"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/topic"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "staging-rw-org" {
  source               = "./url-canary"
  name                 = "staging-rw-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/staging-rw-org-1d1-9ea24cac00f6"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://staging.resourcewatch.org"
  schedule_expression  = "rate(1 hour)"
}

module "convert-sql2fs" {
  source               = "./api-endpoint-canary"
  name                 = "convert-sql2fs"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/convert-sql2fs-aea-4c1fd4ca6836"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/convert/sql2FS?sql=select%20field%20AS%20alias%20from%20table%20where%20filter%3Dfiltered%20limit%2010"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "resourcewatch-org" {
  source               = "./url-canary"
  name                 = "resourcewatch-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/resourcewatch-org-f94-59df572323f8"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://resourcewatch.org"
  schedule_expression  = "rate(1 hour)"
}

module "dashboard-get" {
  source               = "./api-endpoint-canary"
  name                 = "dashboard-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/dashboard-get-cd1-95957cfeb8c9"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/dashboard"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "fw-area-get" {
  source               = "./api-endpoint-canary"
  name                 = "fw-area-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/fw-area-get-3bb-668398f67bc7"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/forest-watcher/area"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

# Redirects to the main CW site
#module "beta-cw-org" {
#  source               = "./url-canary"
#  name                 = "beta-cw-org"
#  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/beta-cw-org-327-b5c21e538f29"
#  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
#  hostname             = "http://beta.climatewatchdata.org"
#  schedule_expression  = "rate(1 hour)"
#}

module "areas-get" {
  source               = "./api-endpoint-canary"
  name                 = "areas-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/areas-get-3e5-49416506469b"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v2/area"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "geostore-find-by-ids" {
  source                 = "./api-endpoint-canary"
  name                   = "geostore-find-by-ids"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/geostore-find-by-ids-3d7-4153814472ef"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v2/geostore/find-by-ids"
  verb                   = "POST"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/geostore-find-by-ids.js.tpl"
}

module "viirrs-fires-get" {
  source               = "./api-endpoint-canary"
  name                 = "viirrs-fires-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/viirrs-fires-get-a20-0439069dbfc5"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v2/viirs-active-fires?geostore=610f5194e26f58c7f3395f70446524fd"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "convert-checksql" {
  source               = "./api-endpoint-canary"
  name                 = "convert-checksql"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/convert-checksql-645-4e77b2b32bf4"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/convert/checkSQL?sql=select%20a%20as%20b%2C%20count%28c%29%2Csum%28d%29%2Cavg%28e%29%2Cmin%28f%29%2Cmax%28g%29%20from%20h%20where%20i%3Dj%20and%20k%3Dl%20group%20by%20m%20order%20by%20n%20desc"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "dataset-get-id-layer" {
  source                 = "./api-endpoint-canary"
  name                   = "dataset-get-id-layer"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/dataset-get-id-layer-668-e867e4158a44"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset?includes=layer"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/dataset-get-id-layer.js.tpl"
}

module "questionnaire-get" {
  source               = "./api-endpoint-canary"
  name                 = "questionnaire-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/questionnaire-get-b15-aeafea16e8fb"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/questionnaire"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "preproduction-rw-org" {
  source               = "./url-canary"
  name                 = "preproduction-rw-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/preproduction-rw-org-61e-e74fe7f821bb"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://preproduction.resourcewatch.org"
  schedule_expression  = "rate(1 hour)"
}

module "ct-check-logged" {
  source               = "./api-endpoint-canary"
  name                 = "ct-check-logged"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/ct-check-logged-4d4-957957a46c83"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/auth/check-logged"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "get-contxt-loss-layer" {
  source               = "./url-canary"
  name                 = "get-contxt-loss-layer"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/get-contxt-loss-layer-afa-d2259df1c5a0"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://api.resourcewatch.org/contextual-layer/loss-layer/2014/2015/2/3/1.png"
  schedule_expression  = "rate(1 hour)"
}

module "story-get" {
  source               = "./api-endpoint-canary"
  name                 = "story-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/story-get-4e9-516d9c0178a3"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/story"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "dataset-widget-by-id" {
  source                 = "./api-endpoint-canary"
  name                   = "dataset-widget-by-id"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/dataset-widget-by-id-2df-1a5e6967a204"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset?includes=widget"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/dataset-widget-by-id.js.tpl"
}

module "prod-api-gfw-org" {
  source               = "./url-canary"
  name                 = "prod-api-gfw-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/prod-api-gfw-org-4a3-14fb981d687a"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://production-api.globalforestwatch.org"
  schedule_expression  = "rate(1 hour)"
}

module "metadata-get-dataset" {
  source                 = "./api-endpoint-canary"
  name                   = "metadata-get-dataset"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/metadata-get-dataset-488-1c9bd0b36790"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/metadata-get-dataset.js.tpl"
}

module "fw-context-layer-get" {
  source               = "./api-endpoint-canary"
  name                 = "fw-context-layer-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/fw-context-layer-get-627-c412a49ac5ce"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/contextual-layer"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "gfw-user-get" {
  source               = "./api-endpoint-canary"
  name                 = "gfw-user-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/gfw-user-get-dea-8c1a29ba5641"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/user"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "dataset-get" {
  source               = "./api-endpoint-canary"
  name                 = "dataset-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/dataset-get-47b-b7c54df5c025"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/dataset"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "dataset-get-widgets" {
  source                 = "./api-endpoint-canary"
  name                   = "dataset-get-widgets"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/dataset-get-widgets-eb4-8b9a312df911"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset?includes=widget"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/dataset-get-widgets.js.tpl"
}

module "dataset-layer-by-id" {
  source                 = "./api-endpoint-canary"
  name                   = "dataset-layer-by-id"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/dataset?includes=layer"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/dataset-layer-by-id.js.tpl"
}

module "layer-get" {
  source               = "./api-endpoint-canary"
  name                 = "layer-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/layer-get-ebb-ffcca0ba602b"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/layer"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "geodescriber-get" {
  source               = "./api-endpoint-canary"
  name                 = "geodescriber-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/geodescriber-get-302-c50d9b6ed22a"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/geodescriber?geostore=610f5194e26f58c7f3395f70446524fd"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "task-get" {
  source               = "./api-endpoint-canary"
  name                 = "task-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/task-get-567-d5947200b020"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/task"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "query-get" {
  source               = "./api-endpoint-canary"
  name                 = "query-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/query-get-fee-52d3757bf048"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/query/?sql=SELECT%20%2A%20FROM%20098b33df-6871-4e53-a5ff-b56a7d989f9a%20LIMIT%2010"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "partner-get" {
  source               = "./api-endpoint-canary"
  name                 = "partner-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/partner-get-c10-a77853693616"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/partner"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 minute)"
}

module "geostore-get-by-id" {
  source               = "./api-endpoint-canary"
  name                 = "geostore-get-by-id"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/geostore-get-by-id-30b-6fd7e1c9ad89"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/geostore/ca38fa80a4ffa9ac6217a7e0bf71e6df"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "story-get-by-user" {
  source               = "./api-endpoint-canary"
  name                 = "story-get-by-user"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/story-get-by-user-793-0acae51fc70b"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/story/user/undefined"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "climatewatchdata-org" {
  source               = "./url-canary"
  name                 = "climatewatchdata-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/climatewatchdata-org-54b-6f30a00a68f2"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://climatewatchdata.org"
  schedule_expression  = "rate(1 hour)"
}

module "emissionspathways-org" {
  source               = "./url-canary"
  name                 = "emissionspathways-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/emissionspathways-org-4dd-af381ba6bd47"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "http://emissionspathways.org"
  schedule_expression  = "rate(1 hour)"
}

# This endpoint a geo intersection query in ElasticSearch/Amazon OpenSearch which relies on a geo_intersects function
# that exists in vanilla ES but not on AWS.
# See https://gfw.atlassian.net/browse/GTC-1234 and https://gfw.atlassian.net/browse/GTC-1086
#module "terrai-alert-get" {
#  source               = "./api-endpoint-canary"
#  name                 = "terrai-alert-get"
#  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/terrai-alert-get-d1a-1ea213039d95"
#  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
#  hostname             = "api.resourcewatch.org"
#  path                 = "/v1/terrai-alerts?geostore=610f5194e26f58c7f3395f70446524fd"
#  verb                 = "GET"
#  hostname_secret_id   = "wri-api/smoke-tests-host"
#  token_secret_id      = "gfw-api/token"
#  schedule_expression  = "rate(1 hour)"
#}

module "story-get-by-id" {
  source                 = "./api-endpoint-canary"
  name                   = "story-get-by-id"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/story-get-by-id-fdd-741e09c901da"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/story"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/story-get-by-id.js.tpl"
}

module "api-resourcewatch-org" {
  source               = "./url-canary"
  name                 = "api-resourcewatch-org"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "https://api.resourcewatch.org"
  schedule_expression  = "rate(1 hour)"
}

module "widget-get-by-id" {
  source                 = "./api-endpoint-canary"
  name                   = "widget-get-by-id"
  s3_artifact_location   = "cw-syn-results-534760749991-us-east-1/canary/widget-get-by-id-044-27646e2c4554"
  execution_role_arn     = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname               = "api.resourcewatch.org"
  path                   = "/v1/widget"
  verb                   = "GET"
  hostname_secret_id     = "wri-api/smoke-tests-host"
  token_secret_id        = "gfw-api/token"
  schedule_expression    = "rate(1 hour)"
  template_relative_path = "../custom-templates/get-widget-by-id.js.tpl"
}

module "dataset-get-by-id" {
  source               = "./api-endpoint-canary"
  name                 = "dataset-get-by-id"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/dataset-get-by-id-64f-370c4648e3fd"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/dataset/098b33df-6871-4e53-a5ff-b56a7d989f9a"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "glad-alerts-admin-get" {
  source               = "./api-endpoint-canary"
  name                 = "glad-alerts-admin-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/glad-alerts-admin-get-f41-fb063cac58e0"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/glad-alerts/admin/BRA"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

module "doc-orch-tasks-get" {
  source               = "./api-endpoint-canary"
  name                 = "doc-orch-tasks-get"
  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/doc-orch-tasks-get-730-f3381a6f7007"
  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
  hostname             = "api.resourcewatch.org"
  path                 = "/v1/doc-importer/task"
  verb                 = "GET"
  hostname_secret_id   = "wri-api/smoke-tests-host"
  token_secret_id      = "gfw-api/token"
  schedule_expression  = "rate(1 hour)"
}

# DNS no longer resolves to AWS
#module "indonesia-cwdata-org" {
#  source               = "./url-canary"
#  name                 = "indonesia-cwdata-org"
#  s3_artifact_location = "cw-syn-results-534760749991-us-east-1/canary/indonesia-cwdata-org-57d-c3e6b0104130"
#  execution_role_arn   = "arn:aws:iam::534760749991:role/CloudWatchSyntheticsRole-CanaryRunWithSecretsAccess"
#  hostname             = "https://indonesia.climatewatchdata.org"
#  schedule_expression  = "rate(1 hour)"
#}
