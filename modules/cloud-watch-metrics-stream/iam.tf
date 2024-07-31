# Sysdig <-> Stream Ingestion

resource "aws_iam_role" "sysdig_to_cloudwatch" {
    name               = "sysdig_metrics_stream_ingest"
    assume_role_policy = data.aws_iam_policy_document.sysdig_to_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "sysdig_to_cloudwatch_assume_role" {
    statement [
        {
            effect = "Allow"
            principals {
                identifiers = ["arn:aws:iam::${local.sysdig_aws_account}:root"]
                type        = "AWS"
            }
            actions = ["sts:AssumeRole"]
            condition {
                test     = "StringEquals"
                variable = "sts:ExternalId"
                values   = ["${local.stream_external_id}"]
            }
        }
    ]
}

resource "aws_iam_role_policy" "cloudwatch_read" {
    name   = "cloudwatch_read"
    role   = aws_iam_role.sysdig_to_cloudwatch.id
    policy = data.aws_iam_policy_document.iam_role_task_policy_cloudwatch_read.json
}

data "aws_iam_policy_document" "iam_role_task_policy_cloudwatch_read" {
    statement [
        {
            effect = "Allow"
            actions = [
                "firehose:DescribeDeliveryStream"
            ]
            resources = [
                "${aws_kinesis_firehose_delivery_stream.stream.arn}"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "cloudwatch:GetMetricStream",
                "cloudwatch:ListMetricStreams",
                "cloudwatch:ListTagsForResource"
            ]
            resources = [
                "${aws_cloudwatch_metric_stream.stream.arn}"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "s3:ListBucket",
                "s3:GetBucketTagging",
                "s3:GetObject",
                "s3:GetObjectAttributes"
            ]
            resources = [
                "${aws_kinesis_firehose_delivery_stream.stream.arn}"
            ]
        }
    ]
}

# Stream -> S3

resource "aws_iam_role" "firehose_to_s3" {
    name               = "sysdig_firehose_service_role"
    assume_role_policy = data.aws_iam_policy_document.firehose_to_s3_assume_role.json
}

data "aws_iam_policy_document" "firehose_to_s3_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["firehose.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy" "firehose_read_s3" {
    name   = "s3_read"
    role   = aws_iam_role.firehose_to_s3.id
    policy = data.aws_iam_policy_document.iam_role_task_policy_firehose_read_s3.json
}

data "aws_iam_policy_document" "iam_role_task_policy_firehose_read_s3" {
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
            "${aws_s3_bucket.stream_fallback.arn}",
            "${aws_s3_bucket.stream_fallback.arn}/*"
        ]
    }
}

# Cloudwatch -> Stream

resource "aws_iam_role" "cloudwatch_to_firehose" {
    name               = "sysdig_cloudwatch_service_role"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch_to_firehose_assume_role.json
}

data "aws_iam_policy_document" "cloudwatch_to_firehose_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "execution" {
    name               = "${var.name}-ECSTaskExecutionRole"
    assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
    path               = "/"
    tags               = var.tags
}

data "aws_iam_policy_document" "execution_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["ecs-tasks.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy" "kinesis_write" {
    name   = "kinesis_write"
    role   = aws_iam_role.cloudwatch_to_firehose.id
    policy = data.aws_iam_policy_document.iam_role_task_policy_kinesis.json
}

data "aws_iam_policy_document" "iam_role_task_policy_kinesis" {
    statement {
        effect = "Allow"
        actions = [
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
        ]
        resources = [
            "${aws_kinesis_firehose_delivery_stream.stream.arn}"
        ]
    }
}