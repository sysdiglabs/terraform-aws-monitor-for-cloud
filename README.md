# AWS Cloudwatch Metrics Integration with Sysdig Monitor Terraform Module

This Terraform module integrates AWS Cloudwatch with Sysdig Monitor, enabling users to directly consume AWS Cloudwatch metrics within Sysdig Monitor.

## Usage

There are several ways to integrate AWS Cloudwatch Metrics with Sysdig Monitor.
- **[`/examples`](https://github.com/sysdiglabs/terraform-aws-monitor-for-cloud/tree/master/examples)** for the most common scenarios
  - [Cloudwatch Metrics Stream Single Account](https://github.com/sysdiglabs/terraform-aws-monitor-for-cloud/tree/master/examples/cloudwatch-metrics-stream-single-account/)

<br/>

## IAM Permissions for Sysdig Cross-Account Role
Sysdig requires AWS IAM permissions to display the correct status and metadata for the Cloudwatch Metric Stream integration in the web UI. If `create_new_role` is set to `true`, the following IAM permissions are granted to an IAM Role that Sysdig Monitor will use to display the correct metadata for your Cloudwatch Metric Stream.

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"s3:ListBucket",
				"s3:GetObjectAttributes",
				"s3:GetObject"
			],
			"Effect": "Allow",
			"Resource": "arn:aws:s3:::sysdig-backup-bucket*"
		},
		{
			"Action": [
				"cloudwatch:ListMetricStreams",
				"cloudwatch:GetMetricStream"
			],
			"Effect": "Allow",
			"Resource": "arn:aws:cloudwatch:*:<AWS-accountID>:metric-stream/*"
		},
		{
			"Action": "firehose:DescribeDeliveryStream",
			"Effect": "Allow",
			"Resource": "arn:aws:firehose:*:<AWS-accountID>:deliverystream/*"
		},
		{
			"Action": [
				"cloudwatch:ListMetrics",
				"cloudwatch:GetMetricData"
			],
			"Effect": "Allow",
			"Resource": "*"
		},
		{
			"Action": "ec2:DescribeInstances",
			"Effect": "Allow",
			"Resource": "*"
		},
		{
			"Action": [
				"s3:ListBucket",
				"s3:ListAllMyBuckets"
			],
			"Effect": "Allow",
			"Resource": "*"
		}
	]
}
```

### Administrator Permissions for Sysdig Monitor
A Sysdig Monitor API Token that has Administrator privileges is necessary for configuring an integration between AWS Cloudwatch and Sysdig Monitor.

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

The `sysdig_monitor_url`, `sysdig_aws_account_id`, and `sysdig_external_id` are all needed to configure the AWS Cloudwatch integration with Sysdig Monitor.

### AWS Resources Created for the AWS Cloudwatch Metrics Integration
Precise AWS resources may vary depending on module configuration but in general, the following AWS resources are created as part of the AWS Cloudwatch Metrics Integration.

* aws_cloudwatch_log_group.sysdig_stream_logs
* aws_cloudwatch_log_stream.http_log_stream
* aws_cloudwatch_log_stream.s3_backup
* aws_cloudwatch_metric_stream.sysdig_metris_stream_all_namespaces
* aws_iam_role.service_role
* aws_iam_role.sysdig_cloudwatch_integration_monitoring_role
* aws_iam_role.sysdig_cloudwatch_metric_stream_role
* aws_iam_role_policy.cloud_monitoring_policy
* aws_kinesis_firehose_delivery_stream.sysdig_metric_kinesis_firehose
* aws_s3_bucket.sysdig_stream_backup_bucket

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.

