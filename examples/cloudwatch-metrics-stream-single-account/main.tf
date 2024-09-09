#-------------------------------------
# cloudwatch metric stream
#-------------------------------------
module "cloudwatch_metric_stream" {
    source = "../../modules/cloud-watch-metrics-stream"

    api_key = var.api_key
    sysdig_site = var.sysdig_site
    sysdig_aws_account_id = var.sysdig_aws_account_id
    monitoring_role_name = var.monitoring_role_name
    create_new_role = var.create_new_role
    sysdig_external_id = var.sysdig_external_id
    secret_key = var.secret_key
    access_key_id = var.access_key_id
}