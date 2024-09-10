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

### One region with role delegation authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
         version = ">= 1.36.0"
      }
   }
}

provider "aws" {
   region = "<AWS-REGION>"
}

provider "sysdig" {
   sysdig_monitor_url = "https://app-staging.sysdigcloud.com"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx"
   monitoring_role_name = "TerraformSysdigMonitoringRole"
   create_new_role = true
   sysdig_external_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### One region with secret key authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
         version = ">= 1.36.0"
      }
   }
}

provider "aws" {
   region = "<AWS-REGION>"
}

provider "sysdig" {
   sysdig_monitor_url = "https://app-staging.sysdigcloud.com"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   secret_key = "Xxx5XX2xXx/Xxxx+xxXxXXxXxXxxXXxxxXXxXxXx"
   access_key_id = "XXXXX33XXXX3XX3XXX7X"
}
```

### Multiple regions with role delegation authentication

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
         version = ">= 1.36.0"
      }
   }
}

provider "aws" {
   alias  = "eu-west-1"
   region = "eu-west-1"
}

provider "sysdig" {
   sysdig_monitor_url = "https://app-staging.sysdigcloud.com"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account_eu_west_1" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   sysdig_aws_account_id = "xxxx-xxxx-xxxx"
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
         version = ">= 1.36.0"
      }
   }
}

provider "aws" {
   alias  = "eu-west-1"
   region = "eu-west-1"
}

provider "sysdig" {
   sysdig_monitor_url = "https://app-staging.sysdigcloud.com"
   sysdig_monitor_api_token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cloudwatch_metrics_stream_single_account_eu_west_1" {
   source = "sysdiglabs/terraform-aws-monitor-for-cloud/examples/cloudwatch-metrics-stream-single-account"

   api_key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   sysdig_site = "https://app-staging.sysdigcloud.com"
   secret_key = "Xxx5XX2xXx/Xxxx+xxXxXXxXxXxxXXxxxXXxXxXx"
   access_key_id = "XXXXX33XXXX3XX3XXX7X"

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 1.36.0 |


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
|<a name="sysdig_aws_account_id"> </a> [sysdig\_aws\_account\_id](#input\_sysdig\_aws\_account\_id) | Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream | `string` | `""` | no |
|<a name="monitoring_role_name"></a> [monitoring\_role\_name](#input\_monitoring\_role\_name) | The role name used for delegation over the customer resources towards the Sysdig AWS account. Only for AWS when the authentication mode is role delegation instead of secret key | `string` | `"SysdigCloudwatchIntegrationMonitoringRole"`| no |
|<a name="create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether the role above already exists or should be created from scratch | `bool` | false | no |
|<a name="sysdig_external_id"></a> [sysdig\_external\_id](#input\_sysdig\_external\_id) | Your Sysdig External ID which will be used when assuming roles in the account | `string` | `""` | no |
|<a name="secret_key"></a> [secret\_key](#input\_secret\_key) | The the secret key for a AWS connection. It must be provided along access_key_id when this auth mode is used | `string` | n/a | no |
|<a name="access_key_id"></a> [access\_key\_id](#input\_access\_key\_id) | The ID for the access key that has the permissions into the Cloud Account. It must be provided along secret_key when this auth mode is used | `string` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitoring_role_name"></a> [monitoring\_role\_name](#output\_monitoring\_role\_name) | Name of the role which could be used to monitor cloudwatch metric stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.