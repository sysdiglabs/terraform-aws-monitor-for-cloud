# Sysdig Monitor for Cloud in AWS<br/>[ Example :: CloudWatch Metrics Stream Single Account ]

Deploy CloudWatch Metrics Stream feature in a single AWS account.<br/>
All the required resources and workloads will be run under the same account.


### Notice
* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-monitor-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore


## Prerequisites

Minimum requirements:

1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Monitor requirements, as input variable value
    ```
    api_key=<Sysdig API Key>
    sysdig_aws_account_id=<Sysdig AWS accountId>
    sysdig_external_id=<Sysdig external ID>
    ```


## Usage

For quick testing, use this snippet on your terraform files

### One region

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
      }
   }
}

provider "aws" {
   region = "<AWS-REGION>; ex. us-east-1"
}

module "cloudwatch_metrics_stream_single_account" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx" # this is draios-dev
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Multiple regions

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

module "cloudwatch_metrics_stream_single_account_eu_west_1" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx" # this is draios-dev
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

   providers = {
      aws = aws.eu-west-1
   }
}

provider "aws" {
   alias  = "eu-central-1"
   region = "eu-central-1"
}

module "cloudwatch_metrics_stream_single_account_eu_central_1" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx" # this is draios-dev
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_metrics_stream"></a> [cloud\_watch\_metrics\_stream](#module\_cloud\_watch\_metrics\_stream) | ../../modules/cloud-watch-metrics-stream | n/a |

## Resources

| Name | Type |
|------|------|
| [sysdig_secure_connection.current](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|<a name="api_key"></a> [api\_key](#input\_api\_key) | Your Sysdig API Key | `string` | n/a | yes |
|<a name="sysdig_site"></a> [sysdig\_site](#input\_sysdig\_site) | Sysdig input endpoint | `string` | n/a | yes |
|<a name="sysdig_aws_account_id"> </a> [sysdig\_aws\_account\_id](#input\_sysdig\_aws\_account\_id) | Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream | `string` | n/a | yes |
|<a name="monitoring_role_name"></a> [monitoring\_role\_name](#input\_monitoring\_role\_name) | Name for a role which will be used by Sysdig to monitor status of the stream | `string` | `"SysdigCloudwatchIntegrationMonitoringRole"`| yes |
|<a name="create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether the role above already exists or should be created from scratch | `bool` | n/a | no |
|<a name="sysdig_external_id"></a> [sysdig\_external\_id](#input\_sysdig\_external\_id) | Your Sysdig External ID which will be used when assuming roles in the account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_role_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the role which could be used to monitor cloudwatch metric stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.