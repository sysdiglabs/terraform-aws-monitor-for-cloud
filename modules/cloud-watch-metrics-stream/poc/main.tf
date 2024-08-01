data "http" "sysdig_cloud_info" {
    url = "${var.sysdig_monitor_url}/api/v2/providers/info/awsCloudInformation"

    request_headers = {
        Accept        = "application/json"
        Authorization = "Bearer ${var.sysdig_monitor_api_token}"
    }

    lifecycle {
        postcondition {
            condition     = self.status_code == 200
            error_message = "Status code invalid"
        }
    }
}

locals {
    sysdig_cloud_info_resp = jsondecode(data.http.sysdig_cloud_info.response_body)
    stream_external_id     = local.sysdig_cloud_info_resp.externalId
    sysdig_aws_account     = local.sysdig_cloud_info_resp.awsSystemAccountId
}

resource "aws_s3_bucket" "stream_fallback" {
    bucket = "sysdig-metric-stream-fallback" ## Unique name for buckets ???
}

resource "aws_kinesis_firehose_delivery_stream" "stream" {
    name        = "sysdig-monitor-cloudwatch"
    destination = "http_endpoint"

    http_endpoint_configuration {
        url                = "${var.sysdig_monitor_url}/api/awsmetrics/v1/input"
        name               = "Sysdig"
        access_key         = var.sysdig_monitor_api_token
        role_arn           = aws_iam_role.firehose_to_s3.arn
        buffering_size     = 5
        buffering_interval = 60
        retry_duration     = 60
        s3_backup_mode     = "FailedDataOnly"

        s3_configuration {
            role_arn           = aws_iam_role.firehose_to_s3.arn
            bucket_arn         = aws_s3_bucket.stream_fallback.arn
            buffering_size     = 5
            buffering_interval = 60
            compression_format = "GZIP"
        }

        request_configuration {
            content_encoding = "GZIP"
        }
    }
}

resource "aws_cloudwatch_metric_stream" "stream" {
    name          = "sysdig-monitor"
    role_arn      = aws_iam_role.cloudwatch_to_firehose.arn
    firehose_arn  = aws_kinesis_firehose_delivery_stream.stream.arn
    output_format = "opentelemetry0.7"
}