# Sysdig CloudWatch Metrics Stream

Deploy AWS Cloudwatch Metrics Integration with Sysdig Monitor for a single AWS account.<br/>

### Notice
* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-monitor-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore

![diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-monitor-for-cloud/main/examples/cloudwatch-metrics-stream-single-account/diagram.png)

## Prerequisites

### Getting your `sysdig_aws_account_id` and `sysdig_external_id`
In order to establish the cross-account IAM role that Sysdig Monitor uses to connect with your AWS Metric Stream, it is necessary to fetch the `sysdig_external_id` and `sysdig_aws_account_id` associated with your Sysdig instance. This is the Sysdig AWS account ID **NOT** your AWS account ID. An API has been developed to make this process easier. You will need to use the correct API endpoint depending on your [sysdig_monitor_url](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges). For example, the following example uses the **US East** endpoint.


```bash
curl --location 'https://app.sysdigcloud.com/api/v2/providers/info/awsCloudInformation' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $SYSDIG_MONITOR_API_TOKEN"
{"apiToken":"11111111-1111-1111-1111-111111111111",
"externalId":"11111111-2222-3333-4444-555555555555",
"awsSystemAccountId":"123456789123"}
```

The `sysdig_aws_account_id`, and `sysdig_external_id` are all needed to configure the AWS Cloudwatch integration with Sysdig Monitor when using role delegation(`create_new_role = true`).


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 1.37.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | >= 1.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sysdig_cloudwatch_metric_stream_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sysdig_cloudwatch_integration_monitoring_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloud_monitoring_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_cloudwatch_log_group.sysdig_stream_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.http_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.s3_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_s3_bucket.sysdig_stream_backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_kinesis_firehose_delivery_stream.sysdig_metric_kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_cloudwatch_metric_stream.sysdig_metris_stream_all_namespaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [sysdig_monitor_cloud_account.cloud_account](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/resources/monitor_cloud_account) | resource |
| [aws_iam_policy_document.service_role_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_role_task_policy_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_cloudwatch_metric_stream_role_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_role_task_policy_sysdig_cloudwatch_metric_stream_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sysdig_cloudwatch_integration_monitoring_role_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_role_task_policy_cloud_monitoring_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                                       | Description | Type | Default | Required |
|------------------------------------------------------------------------------------------------------------|-------------|------|---------|:--------:|
| <a name="sysdig_monitor_api_token"></a> [sysdig\_monitor\_api\_token](#input\_sysdig\_monitor\_api\_token) | Your Sysdig API Key | `string` | n/a | yes |
| <a name="sysdig_monitor_url"></a> [sysdig\_monitor\_url](#input\_sysdig\_monitor\_url)                     | Sysdig input endpoint | `string` | n/a | yes |
| <a name="sysdig_aws_account_id"> </a> [sysdig\_aws\_account\_id](#input\_sysdig\_aws\_account\_id)         | Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream | `string` | n/a | yes |
| <a name="monitoring_role_name"></a> [monitoring\_role\_name](#input\_monitoring\_role\_name)               | The role name used for delegation over the customer resources towards the Sysdig AWS account. Only for AWS when the authentication mode is role delegation instead of secret key | `string` | `"SysdigCloudwatchIntegrationMonitoringRole"`| no |
| <a name="create_new_role"></a> [create\_new\_role](#input\_create\_new\_role)                              | Whether the role above already exists or should be created from scratch | `bool` | n/a | no |
| <a name="sysdig_external_id"></a> [sysdig\_external\_id](#input\_sysdig\_external\_id)                     | Your Sysdig External ID which will be used when assuming roles in the account | `string` | n/a | no |
| <a name="secret_key"></a> [secret\_key](#input\_secret\_key)                                               | The the secret key for a AWS connection. It must be provided along access_key_id when this auth mode is used | `string` | n/a | no |
| <a name="access_key_id"></a> [access\_key\_id](#input\_access\_key\_id)                                    | The ID for the access key that has the permissions into the Cloud Account. It must be provided along secret_key when this auth mode is used | `string` | n/a | no |
| <a name="include_filters"></a> [include\_filters](#input\_include\_filters)                                | List of inclusive metric filters. If you specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If you don't specify metric names or provide empty metric names whole metric namespace is included. Conflicts with `exclude_filter` | `Object` | n/a | no |
| <a name="exclude_filters"></a> [exclude\_filters](#input\_exclude\_filters)                                | List of exclusive metric filters. If you specify this parameter, the stream sends metrics from all metric namespaces except for the namespaces and the conditional metric names that you specify here. If you don't specify metric names or provide empty metric names whole metric namespace is excluded. Conflicts with `include_filter` | `Object` | n/a | no |
| <a name="tags"></a> [tags](#input\_tags)                                                                   | Map of tags to apply to resources | `map string` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_role_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the role which could be used to monitor cloudwatch metric stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
