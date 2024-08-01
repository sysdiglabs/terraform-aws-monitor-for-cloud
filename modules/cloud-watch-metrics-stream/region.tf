variable "api_key" {
    description = "Your Sysdig API Key"
    type        = string
    sensitive   = true
    validation {
        condition     = length(var.api_key) > 1
        error_message = "The api_key is required."
    }
}

variable "service_role_arn" {
    description = "The arn for the service role used by kinesis firehose"
    type        = string
    validation {
        condition     = length(var.service_role_arn) > 1
        error_message = "The service_role_arn is required."
    }
}

variable "stream_role_arn" {
    description = "The arn for the stream used by the cloudwatch stream"
    type        = string
    validation {
        condition     = length(var.stream_role_arn) > 1
        error_message = "The stream_role_arn is required."
    }
}

variable "sysdig_url" {
    description = "Define your Sysdig Site to send data to"
    type        = string
    validation {
        condition     = length(var.sysdig_url) > 1
        error_message = "The sysdig_url is required."
    }
}

resource "aws_cloudwatch_log_group" "sysdig_stream_logs" {
    name = "sysdig-cloudwatch-metric-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    retention_in_days = 14
}

resource "aws_cloudwatch_log_stream" "http_log_stream" {
    name           = "http_endpoint_delivery_${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    log_group_name = aws_cloudwatch_log_group.sysdig_stream_logs.name
}

resource "aws_cloudwatch_log_stream" "s3_backup" {
    name           = "s3_backup_${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    log_group_name = aws_cloudwatch_log_group.sysdig_stream_logs.name
}

resource "aws_s3_bucket" "sysdig_stream_backup_bucket" {
    bucket = "sysdig-backup-bucket-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    ## add tags?
}

resource "aws_kinesis_firehose_delivery_stream" "sysdig_metric_kinesis_firehose" {
    name        = "sysdig-cloudwatch-metrics-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    destination = "http_endpoint"

    http_endpoint_configuration {
        url               = "${var.sysdig_url}/api/awsmetrics/v1/input"
        name              = "Event intake"
        access_key        = var.api_key
        role_arn          = var.service_role_arn
        buffering_size    = 4
        buffering_interval = 60

        cloudwatch_logging_options {
            enabled = true
            log_group_name = aws_cloudwatch_log_group.sysdig_stream_logs.name
            log_stream_name = "http_endpoint_delivery_${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
        }

        retry_duration = 60
        s3_backup_mode = "FailedDataOnly"

        s3_configuration {
            role_arn            = var.service_role_arn
            bucket_arn          = sysdig_stream_backup_bucket.arn ## IS this correct?
            error_output_prefix = "sysdig_stream"
            buffering_size      = 4
            buffering_interval  = 60
            compression_format  = "GZIP"
        }
    }
}

resource "aws_cloudwatch_metric_stream" "sysdig_metris_stream_all_namespaces" {
    name          = "sysdig-cloudwatch-metrics-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    role_arn      = var.stream_role_arn
    firehose_arn  = sysdig_metric_kinesis_firehose.arn ## IS this correct?
    output_format = "opentelemetry0.7"
    ## add tags?
}