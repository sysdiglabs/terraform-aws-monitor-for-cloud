# Sysdig Monitor for Cloud in AWS 
Monitor repo for Terraform AWS modules in sysdiglabs

For now this repository provides the CloudWatch Metrics Stream functionality

* **[CloudWatch Metrics Stream](https://docs.sysdig.com/en/docs/sysdig-monitor/integrations/cloud-accounts/connect-aws-account/cloudwatch-monitoring/)**:  You can collect both general metadata and various types of CloudWatch metrics from your AWS environment for this purpose <br/>

## Usage

There are several ways to deploy Secure for Cloud in you AWS infrastructure,
- **[`/examples`](https://github.com/sysdiglabs/terraform-aws-monitor-for-cloud/tree/master/examples)** for the most common scenarios
  - [CloudWatch Metrics Stream Single Account](https://github.com/sysdiglabs/terraform-aws-monitor-for-cloud/tree/master/examples/cloudwatch-metrics-stream-single-account/)

<br/>

In the long-term our purpose is to evaluate those use-cases and if they're common enough, convert them into examples to make their usage easier.

## Required Permissions

Sysdig needs some additional permissions in order to show correct status and additional metadata for the CloudWatch Metric Stream integration on the web UI. The following policy should be used when you set up CloudWatch Metric Streams manually and you prefer authenticating using the Access Keys.

```
s3:ListBucket
s3:GetBucketTagging
s3:GetObject
s3:GetObjectAttributes

cloudwatch:GetMetricStream
cloudwatch:ListMetricStreams
cloudwatch:ListTagsForResource

firehose:DescribeDeliveryStream
```

### Provisioning Permissions

Terraform provider credentials/token, requires `Administrative` permissions in order to be able to create the
resources specified in the per-example diagram.

Some components may vary, or may be deployed on different accounts (depending on the example). You can check full resources on each module "Resources" section in their README's. You can also check our source code and suggest changes.

This would be an overall schema of the **created resources**, for the default setup.

- CloudWatch / S3 / Kinesis Firehose
- SSM Parameter for Sysdig API Token Storage
- Sysdig role for Compliance

## Upgrading

1. Uninstall previous deployment resources before upgrading
  ```
  $ terraform destroy
  ```

2. Upgrade the full terraform example with
  ```
  $ terraform init -upgrade
  $ terraform plan
  $ terraform apply
  ```

<br/>

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.


