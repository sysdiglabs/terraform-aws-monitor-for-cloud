terraform {
    required_providers {
        sysdig = {
            source = "sysdiglabs/sysdig"
            version = ">= 1.43.0"
        }
    }
}

provider "aws" {
    region = "<AWS-REGION>"
}

provider "sysdig" {
    sysdig_monitor_url = "https://<sysdig-endpoint>"
    sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "billing_module" {
    source = "sysdiglabs/monitor-for-cloud/aws//modules/private-billing"

    s3_bucket_name = "billing-bucket-test"
    s3_bucket_prefix = "billing-data"
    s3_athena_bucket_prefix = "athena-cur-query-results"
    sysdig_cost_access_role_name = "test-MonitoringRole"
    create_new_role = true
    sysdig_aws_account_id = "xxxx-xxxx-xxxx"
    sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}