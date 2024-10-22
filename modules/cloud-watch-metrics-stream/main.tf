resource "aws_cloudwatch_log_group" "sysdig_stream_logs" {
    name = "sysdig-cloudwatch-metric-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    retention_in_days = 14
    tags = var.tags
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
    tags = var.tags
}

resource "aws_kinesis_firehose_delivery_stream" "sysdig_metric_kinesis_firehose" {
    name        = "sysdig-cloudwatch-metrics-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    destination = "http_endpoint"

    http_endpoint_configuration {
        url               = "${var.sysdig_monitor_url}/api/awsmetrics/v1/input"
        name              = "Event intake"
        access_key        = var.sysdig_monitor_api_token
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

    tags = var.tags
}

resource "aws_cloudwatch_metric_stream" "sysdig_metris_stream_all_namespaces" {
    name          = "sysdig-cloudwatch-metrics-stream-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    role_arn      = aws_iam_role.sysdig_cloudwatch_metric_stream_role.arn
    firehose_arn  = aws_kinesis_firehose_delivery_stream.sysdig_metric_kinesis_firehose.arn
    output_format = "opentelemetry0.7"


    dynamic "include_filter" {
        for_each = var.include_filters
        content {
            namespace = include_filter.value.namespace
            metric_names = length(include_filter.value.metric_names) > 0 ? include_filter.value.metric_names : null
        }
    }

    dynamic "exclude_filter" {
        for_each = var.exclude_filters
        content {
            namespace = exclude_filter.value.namespace
            metric_names = length(exclude_filter.value.metric_names) > 0 ? exclude_filter.value.metric_names : null
        }
    }

    tags = var.tags
}

resource "time_sleep" "wait_60_seconds" {
    count = var.create_new_role ? 1 : 0
    create_duration = "60s"

    depends_on = [ aws_iam_role.sysdig_cloudwatch_integration_monitoring_role[0] ]
}

resource "sysdig_monitor_cloud_account" "assume_role_cloud_account" {
    count = var.create_new_role ? 1 : 0
    cloud_provider = "AWS"
    integration_type = "Metrics Streams"
    account_id = "${data.aws_caller_identity.me.account_id}"
    role_name = "${var.monitoring_role_name}-${data.aws_caller_identity.me.account_id}"

    depends_on = [ time_sleep.wait_60_seconds[0] ]
}

resource "sysdig_monitor_cloud_account" "secret_key_cloud_account" {
    count = var.create_new_role || var.secret_key == "" || var.access_key_id == "" ? 0 : 1
    cloud_provider = "AWS"
    integration_type = "Metrics Streams"
    secret_key = var.secret_key
    access_key_id = var.access_key_id
    account_id = data.aws_caller_identity.me.account_id
}