variable "s3_bucket_name" {
    description = "Name of S3 bucket where Cost and Usage data will be generated"
    type        = string
    default     = ""
    validation {
        condition     = length(var.s3_bucket_name) > 0
        error_message = "The s3-bucket-name is required."
    }
}

variable "s3_bucket_prefix" {
    description = "Prefix of CUR files inside S3 bucket"
    type        = string
    default     = "billing-data"
    validation {
        condition     = length(var.s3_bucket_prefix) > 0
        error_message = "The s3_bucket_prefix is required."
    }
}

variable "s3_athena_bucket_prefix" {
    description = "Prefix of Athena results inside S3 bucket"
    type        = string
    default     = "athena-cur-query-results"
    validation {
        condition     = length(var.s3_athena_bucket_prefix) > 0
        error_message = "The s3_athena_bucket_prefix is required."
    }
}

variable "sysdig_cost_access_role_name" {
    description = "Name of role which will be granted permissions to access cost and billing data"
    type        = string
    default     = "SysdigCloudwatchIntegrationMonitoringRole"
}

variable "create_new_role" {
    description = "Whether the role above already exists or should be created from scratch"
    type        = bool
    default     = false
}

variable "sysdig_aws_account_id" {
    description = "AWS account used by Sysdig"
    type        = string
    default     = ""
}

variable "sysdig_external_id" {
    description = "ExternalID used by Sysdig when assuming role"
    type        = string
    default     = ""
}