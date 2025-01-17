# Private Billing

Deploy Private Billing feature in a single AWS account.<br/>
All the required resources and workloads will be run under the same account.

### Notice
* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-monitor-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore

![diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-monitor-for-cloud/main/examples/private-billing-single-account/diagram.png)

## Prerequisites

Minimum requirements:

1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Monitor requirements, as input variable value
    ```
    sysdig_monitor_api_token=<Sysdig API Key>
    sysdig_aws_account_id=<Sysdig AWS accountId>
    sysdig_external_id=<Sysdig external ID>
    ```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 1.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | >= 1.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.sysdig_curs3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.sysdig_curs3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_policy.sysdig_cur_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_cur_report_definition.sysdig_created_cur](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cur_report_definition) | resource |
| [aws_glue_catalog_database.aws_cur_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_athena_workgroup.athena_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_glue_crawler.cur_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_lambda_function.cur_initializer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [null_resource.run_cur_initializer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_lambda_permission.s3_cur_event_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_function.s3_cur_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [null_resource.put_s3_cur_notification](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_glue_catalog_table.cur_report_status_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [sysdig_monitor_cloud_account.assume_role_cloud_account](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/monitor_cloud_account) | resource |
| [archive_file.lambda_crawler_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_notification_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_role.cur_crawler_component_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cur_crawler_lambda_executor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.s3_cur_lambda_executor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.private_billing_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_cur_lambda_executor_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.spot_feed_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.cur_crawler_component_function_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cur_crawler_component_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cur_kms_decryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cur_crawler_lambda_executor_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cur_crawler_lambda_executor_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_cur_lambda_executor_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_cur_lambda_executor_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.private_billing_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.spot_feed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|<a name="s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of S3 bucket where Cost and Usage data will be generated | `string` | ` ` | yes |
|<a name="s3_bucket_prefix"></a> [s3\_bucket\_prefix](#input\_s3\_bucket\_prefix) | Prefix of CUR files inside S3 bucket | `string` | `billing-data` | yes |
|<a name="s3_athena_bucket_prefix"></a> [s3\_athena\_bucket\_prefix](#input\_s3\_athena\_bucket\_prefix) | Prefix of Athena results inside S3 bucket | `string` | `athena-cur-query-results` | yes |
|<a name="sysdig_cost_access_role_name"></a> [sysdig\_cost\_access\_role\_name](#input\_sysdig\_cost\_access\_role_name) | Name of role which will be granted permissions to access cost and billing data | `string` | `SysdigBillingIntegrationMonitoringRole` | yes |
|<a name="create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether the role above already exists or should be created from scratch | `boolean` | false | yes |
|<a name="sysdig_aws_account_id"></a> [sysdig\_aws\_account\_id](#input\_sysdig\_aws\_account\_id) | AWS account used by Sysdig | `string` | ` ` | yes |
|<a name="sysdig_external_id"></a> [sysdig\_external\_id](#input\_sysdig\_external\_id) | ExternalID used by Sysdig when assuming role | `string` | ` ` | yes |
|<a name="spot_data_feed_bucket_name"></a> [spot\_data\_feed\_bucket\_name](#input\_spot\_data\_feed\_bucket\_name) | The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step | `string` | ` ` | no |
|<a name="sysdig_cost_report_file_name"></a> [sysdig\_cost\_report\_file\_name](#input\_sysdig\_cost\_report\_file\_name) | Name of the report file that will be generated by the AWS billing service | `string` | `sysdig_aws_private_billing` | no |
|<a name="sysdig_cost_crawler_name_suffix"></a> [sysdig\_cost\_crawler\_name\_suffix](#input\_sysdig\_cost\_crawler\_name\_suffix) | Name Suffix of the AWS Glue Crawler that will be created to crawl the CUR data | `string` | `sysdig_aws_private_billing` | no |
|<a name="tags"></a> [tags](#input\_tags) | Map of tags to apply to resources | `string map` | ` ` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_role_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the role which could be used to monitor cloudwatch metric stream |
| <a name="athena_bucket_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the S3 bucket where the Athena query results are stored |
| <a name="athena_database_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Prefix of the S3 bucket where the Athena query results are stored |
| <a name="athena_region"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Region where the Athena query results are stored |
| <a name="athena_table_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the Athena table |
| <a name="athena_workgroup_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the Athena workgroup |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
