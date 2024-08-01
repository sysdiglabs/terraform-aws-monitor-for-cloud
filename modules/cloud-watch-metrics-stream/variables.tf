variable "api_key" {
    description = "Your Sysdig API Key"
    type        = string
    sensitive   = true
    validation {
        condition     = length(var.api_key) > 1
        error_message = "The api_key is required."
    }
}

variable "regions" {
    description = "Comma separated list of regions to enable metric streaming"
    type        = list(string)
    default     = [""]
    validation {
        condition     = length(var.regions) > 0
        error_message = "At least one region is required."
    }
}

variable "sysdig_site" {
    description = "Sysdig input endpoint"
    type        = string
    validation {
        condition     = length(var.sysdig_site) > 1
        error_message = "Sysdig input endpoint is required"
    }
}

variable "sysdig_aws_account_id" {
    description = "Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream"
    type        = string
    validation {
        condition     = length(var.sysdig_aws_account_id) > 1
        error_message = "Sysdig AWS Account ID is required"
    }
}

variable "monitoring_role_name" {
    description = "Name for a role which will be used by Sysdig to monitor status of the stream"
    type        = string
    default     = "SysdigCloudwatchIntegrationMonitoringRole"
    validation {
        condition     = length(var.monitoring_role_name) > 1
        error_message = "Monitoring Role Name is required"
    }
}

variable "create_new_role" {
    description = "Whether the role above already exists or should be created from scratch"
    type        = bool
}

variable "sysdig_external_id" {
    description = "Your Sysdig External ID which will be used when assuming roles in the account"
    type        = string
    validation {
        condition     = length(var.sysdig_external_id) > 1
        error_message = "Sysdig external ID is required"
    }
}