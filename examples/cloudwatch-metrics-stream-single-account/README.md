# AWS Cloudwatch Metrics Integration with Sysdig Monitor<br/>[ Example :: CloudWatch Metrics Stream Single Account ]

Deploy AWS Cloudwatch Metrics Integration with Sysdig Monitor for a single AWS account.<br/>

### Notice
The following examples create AWS resources that incur charges which are not part of your Sysdig subscription.

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

The `sysdig_monitor_url`, `sysdig_aws_account_id`, and `sysdig_external_id` are all needed to configure the AWS Cloudwatch integration with Sysdig Monitor.

## Usage

### One region with role delegation authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
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

module "cloudwatch_metrics_stream_single_account" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx"
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   exclude_filters = [ 
      {
         namespace    = "AWS/Firehose"
         metric_names = ["BytesPerSecondLimit"]
      }
   ]
}
```

### One region with secret key authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
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

module "cloudwatch_metrics_stream_single_account" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"
   secret_key = "Xxx5XX2xXx/Xxxx+xxXxXXxXxXxxXXxxxXXxXxXx"
   access_key_id = "XXXXX33XXXX3XX3XXX7X"
   exclude_filters = [ 
      {
         namespace    = "AWS/Firehose"
         metric_names = ["BytesPerSecondLimit"]
      }
   ]
}
```

### Multiple regions with role delegation authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
      }
   }
}

provider "aws" {
   alias  = "eu-west-1"
   region = "eu-west-1"
}

provider "sysdig" {
   sysdig_monitor_url = "https://<sysdig-endpoint>"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account_eu_west_1" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx"
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   exclude_filters = [ 
      {
         namespace    = "AWS/Firehose"
         metric_names = ["BytesPerSecondLimit"]
      }
   ]

   providers = {
      aws = aws.eu-west-1
   }
}

provider "aws" {
   alias  = "eu-central-1"
   region = "eu-central-1"
}

module "cloudwatch_metrics_stream_single_account_eu_central_1" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"

   providers = {
      aws = aws.eu-central-1
   }
}
```

### Multiple regions with secret key authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
      }
   }
}

provider "aws" {
   alias  = "eu-west-1"
   region = "eu-west-1"
}

provider "sysdig" {
   sysdig_monitor_url = "https://<sysdig-endpoint>"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account_eu_west_1" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"
   secret_key = "Xxx5XX2xXx/Xxxx+xxXxXXxXxXxxXXxxxXXxXxXx"
   access_key_id = "XXXXX33XXXX3XX3XXX7X"
   exclude_filters = [ 
      {
         namespace    = "AWS/Firehose"
         metric_names = ["BytesPerSecondLimit"]
      }
   ]

   providers = {
      aws = aws.eu-west-1
   }
}

provider "aws" {
   alias  = "eu-central-1"
   region = "eu-central-1"
}

module "cloudwatch_metrics_stream_single_account_eu_central_1" {
   source = "sysdiglabs/monitor-for-cloud/aws//modules/cloud-watch-metrics-stream"

   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://<sysdig-endpoint>"

   providers = {
      aws = aws.eu-central-1
   }
}
```

See [inputs summary](#inputs) or module module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/variables.tf) file for more optional configuration.

To run this example you need have your [aws account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 1.36.0 |


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_metrics_stream"></a> [cloud\_watch\_metrics\_stream](#module\_cloud\_watch\_metrics\_stream) | ../../modules/cloud-watch-metrics-stream | n/a |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|<a name="sysdig_monitor_api_token"></a> [sysdig\_monitor\_api\_token](#input\_sysdig\_monitor\_api\_token) | Your Sysdig API Key | `string` | n/a | yes |
|<a name="sysdig_site"></a> [sysdig\_site](#input\_sysdig\_site) | Sysdig input endpoint | `string` | n/a | yes |
|<a name="sysdig_aws_account_id"> </a> [sysdig\_aws\_account\_id](#input\_sysdig\_aws\_account\_id) | Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream | `string` | `""` | no |
|<a name="monitoring_role_name"></a> [monitoring\_role\_name](#input\_monitoring\_role\_name) | The role name used for delegation over the customer resources towards the Sysdig AWS account. Only for AWS when the authentication mode is role delegation instead of secret key | `string` | `"SysdigCloudwatchIntegrationMonitoringRole"`| no |
|<a name="create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether the role above already exists or should be created from scratch | `bool` | false | no |
|<a name="sysdig_external_id"></a> [sysdig\_external\_id](#input\_sysdig\_external\_id) | Your Sysdig External ID which will be used when assuming roles in the account | `string` | `""` | no |
|<a name="secret_key"></a> [secret\_key](#input\_secret\_key) | The the secret key for a AWS connection. It must be provided along access_key_id when this auth mode is used | `string` | n/a | no |
|<a name="access_key_id"></a> [access\_key\_id](#input\_access\_key\_id) | The ID for the access key that has the permissions into the Cloud Account. It must be provided along secret_key when this auth mode is used | `string` | n/a | no |
|<a name="include_filters"></a> [include\_filters](#input\_include\_filters) | List of inclusive metric filters. If you specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If you don't specify metric names or provide empty metric names whole metric namespace is included. Conflicts with `exclude_filter` | `Object` | n/a | no |
|<a name="exclude_filters"></a> [exclude\_filters](#input\_exclude\_filters) | List of exclusive metric filters. If you specify this parameter, the stream sends metrics from all metric namespaces except for the namespaces and the conditional metric names that you specify here. If you don't specify metric names or provide empty metric names whole metric namespace is excluded. Conflicts with `include_filter` | `Object` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_role_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the role which could be used to monitor cloudwatch metric stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
