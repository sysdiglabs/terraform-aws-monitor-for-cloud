module "sysdig_cloudwatch_metrics_stream" {
    source = "./cloud-watch-metrics-stream"
    
    api_key = ""
    sysdig_site = "https://app-staging.sysdigcloud.com"
    sysdig_aws_account_id = ""
    monitoring_role_name = "TestTerraformSysdigCloudwatchIntegrationMonitoringRole"
    create_new_role = true
    sysdig_external_id = ""
}