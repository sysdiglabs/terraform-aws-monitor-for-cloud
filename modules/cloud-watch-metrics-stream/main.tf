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
        url               = "${var.sysdig_site}/api/awsmetrics/v1/input"
        name              = "Event intake"
        access_key        = var.api_key
        role_arn          = aws_iam_role.service_role.arn
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
            role_arn            = aws_iam_role.service_role.arn
            bucket_arn          = aws_s3_bucket.sysdig_stream_backup_bucket.arn
            error_output_prefix = "sysdig_stream"
            buffering_size      = 4
            buffering_interval  = 60
            compression_format  = "GZIP"
        }
    }
}

resource "aws_cloudwatch_metric_stream" "sysdig_metris_stream_all_namespaces" {
    name          = "sysdig-cloudwatch-metrics-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    role_arn      = aws_iam_role.sysdig_cloudwatch_metric_stream_role.arn
    firehose_arn  = aws_kinesis_firehose_delivery_stream.sysdig_metric_kinesis_firehose.arn
    output_format = "opentelemetry0.7"
    ## add tags?
}

resource "sysdig_monitor_cloud_account" "cloud_account" {
    cloud_provider = "AWS"
    integration_type = "Metrics Streams"
    account_id = var.sysdig_aws_account_id
}