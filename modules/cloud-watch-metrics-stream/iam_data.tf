data "aws_iam_policy_document" "service_role_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["firehose.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "iam_role_task_policy_service_role" {
    statement {
        effect = "Allow"
        actions = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject",
            "s3:PutBucketTagging"
        ]
        resources = [
            "arn:${data.aws_partition.current.partition}:s3:::sysdig-backup-bucket*",
            "arn:${data.aws_partition.current.partition}:s3:::sysdig-backup-bucket*/*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "logs:PutLogEvents"
        ]
        resources = [
            "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:log-group:sysdig-cloudwatch-metric-stream*"
        ]
    }
}

data "aws_iam_policy_document" "sysdig_cloudwatch_metric_stream_role_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "iam_role_task_policy_sysdig_cloudwatch_metric_stream_role" {
    statement {
        effect = "Allow"
        actions = [
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
        ]
        resources = [
            "arn:${data.aws_partition.current.partition}:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:deliverystream/sysdig-cloudwatch-metrics-stream*"
        ]
    }
}

data "aws_iam_policy_document" "sysdig_cloudwatch_integration_monitoring_role_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["arn:${data.aws_partition.current.partition}:iam::${var.sysdig_aws_account_id}:root"]
            type        = "AWS"
        }
        actions = ["sts:AssumeRole"]
        condition {
            test     = "ForAnyValue:StringEquals"
            variable = "sts:ExternalId"
            values   = [var.sysdig_external_id]
        }
    }
}

data "aws_iam_policy_document" "iam_role_task_policy_cloud_monitoring_policy" {

    statement {
        effect = "Allow"
        actions = [
            "cloudwatch:GetMetricData",
            "cloudwatch:ListMetrics"
        ]
        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "ec2:DescribeInstances"
        ]
        resources = [
            "*"
        ]
    }

}