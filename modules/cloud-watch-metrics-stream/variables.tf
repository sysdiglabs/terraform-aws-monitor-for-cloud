variable "sysdig_monitor_api_token" {
    description = "Your Sysdig API Key"
    type        = string
    sensitive   = true
    validation {
        condition     = length(var.sysdig_monitor_api_token) > 1
        error_message = "The sysdig_monitor_api_token is required."
    }
}

variable "sysdig_monitor_url" {
    description = "Sysdig input endpoint"
    type        = string
    validation {
        condition     = length(var.sysdig_monitor_url) > 1
        error_message = "Sysdig input endpoint is required."
    }
}

variable "sysdig_aws_account_id" {
    description = "Sysdig AWS accountId that will assume MonitoringRole to check status of CloudWatch metric stream"
    type        = string
    default     = "default"
    validation {
        condition     = length(var.sysdig_aws_account_id) > 1
        error_message = "Sysdig AWS Account ID is required."
    }
}

variable "monitoring_role_name" {
    description = "Name for a role which will be used by Sysdig to monitor status of the stream"
    type        = string
    default     = "SysdigCloudwatchIntegrationMonitoringRole"
    validation {
        condition     = length(var.monitoring_role_name) > 1
        error_message = "Monitoring Role Name is required."
    }
}

variable "create_new_role" {
    description = "Whether the role above already exists or should be created from scratch"
    type        = bool
    default     = false
}

variable "sysdig_external_id" {
    description = "Your Sysdig External ID which will be used when assuming roles in the account"
    type        = string
    default     = "default"
    validation {
        condition     = length(var.sysdig_external_id) > 1
        error_message = "Sysdig external ID is required."
    }
}

variable "secret_key" {
    description = "value of the secret key"
    type        = string
    sensitive   = true
    default = ""
}

variable "access_key_id" {
    description = "value of the access key id"
    type        = string
    default = ""
}

variable "include_filters" {
    type = list(object({
        namespace    = string
        metric_names = list(string)
    }))
    default = []
}

variable "exclude_filters" {
    type = list(object({
        namespace    = string
        metric_names = list(string)
    }))
    default = []
}

variable "tags" {
    description = "Map of tags to apply to resources"
    type        = map(string)
    default     = {}
}