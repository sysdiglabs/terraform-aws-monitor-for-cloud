#-------------------------------------
# private billing
#-------------------------------------

module "private_billing" {
    source = "../../modules/private-billing"
    s3_bucket_name = var.s3_bucket_name
    s3_bucket_prefix = var.s3_bucket_prefix
    s3_athena_bucket_prefix = var.s3_athena_bucket_prefix
    sysdig_cost_access_role_name = var.sysdig_cost_access_role_name
    create_new_role = var.create_new_role
    sysdig_aws_account_id = var.sysdig_aws_account_id
    sysdig_external_id = var.sysdig_external_id
    spot_data_feed_bucket_name = var.spot_data_feed_bucket_name
    sysdig_cost_report_file_name = var.sysdig_cost_report_file_name
    sysdig_cost_crawler_name_suffix = var.sysdig_cost_crawler_name_suffix
    tags = var.tags
}