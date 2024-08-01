resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_stack_set_administration_role" {
    name               = "SysdigStackSetAdminRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch_metric_stream_stack_set_administration_assume_role.json
    inline_policy {
        name   = "SysdigStreamCfnStackSetAssumeRole"
        policy = data.aws_iam_policy_document.iam_role_task_policy_cloudwatch_metric_stream_stack_set_administration.json
    }
}

data "aws_iam_policy_document" "cloudwatch_metric_stream_stack_set_administration_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["cloudformation.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "iam_role_task_policy_cloudwatch_metric_stream_stack_set_administration" {
    statement {
        effect = "Allow"
        actions = [
            "cloudformation:*"
        ]
        resources = [
            "*"
        ]
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_stack_set_execution_role" {
    name               = "SysdigStackSetExecRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch_metric_stream_stack_set_execution_assume_role.json
    inline_policy {
        name   = "SysdigStreamCfnStackAssumeRole"
        policy = data.aws_iam_policy_document.iam_role_task_policy_cloudwatch_metric_stream_stack_set_execution.json
    }
}

data "aws_iam_policy_document" "cloudwatch_metric_stream_stack_set_execution_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = [aws_iam_role.sysdig_cloudwatch_metric_stream_stack_set_administration_role.arn] ## This is the role created above ??
            type        = "AWS"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "iam_role_task_policy_cloudwatch_metric_stream_stack_set_execution" {
    statement [
        {
            effect = "Allow"
            actions = [
                "s3:Get*",
                "s3:List*"
            ]
            resources = [
                "arn:aws:s3:::cf-templates-cloudwatch-metric-streams*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "s3:*"
            ]
            resources = [
                "arn:aws:s3:::sysdig-backup-bucket*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "cloudformation:*"
            ]
            resources = [
                "arn:aws:cloudformation:*:${data.aws_caller_identity.me.account_id}:stack/StackSet-SysdigCloudwatchMetricStreams*",
                "arn:aws:cloudformation:*:${data.aws_caller_identity.me.account_id}:stackset/SysdigCloudwatchMetricStreams*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "sns:Publish"
            ]
            resources = [
                "arn:aws:sns:*:*:CfnNotificationSNSTopic"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "iam:GetRole",
                "iam:PassRole"
            ]
            resources = [
                "*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutBucketTagging"
            ]
            resources = [
                "arn:aws:s3:::sysdig-backup-bucket*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:PutRetentionPolicy",
                "logs:CreateLogStream",
                "logs:DeleteLogStream",
                "logs:DescribeLogStreams",
                "logs:TagLogGroup",
                "logs:UntagLogGroup"
            ]
            resources = [
                "arn:aws:logs:*:${data.aws_caller_identity.me.account_id}:log-group:sysdig-cloudwatch-metric-stream*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "firehose:CreateDeliveryStream",
                "firehose:DescribeDeliveryStream",
                "firehose:DeleteDeliveryStream",
                "firehose:UntagDeliveryStream",
                "firehose:TagDeliveryStream"
            ]
            resources = [
                "arn:aws:firehose:*:${data.aws_caller_identity.me.account_id}:deliverystream/sysdig-cloudwatch-metrics-stream*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "cloudwatch:PutMetricStream",
                "cloudwatch:GetMetricStream",
                "cloudwatch:ListMetricStreams",
                "cloudwatch:DeleteMetricStream",
                "cloudwatch:TagResource"
            ]
            resources = [
                "arn:aws:cloudwatch:*:${data.aws_caller_identity.me.account_id}:metric-stream/sysdig-cloudwatch-metrics-stream*"
            ]
        }
    ]
}

resource "aws_iam_role" "service_role" {
    name               = "SysdigServiceRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.service_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_s3_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_service_role.json
    }
}

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
    statement [
        {
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
                "arn:aws:s3:::sysdig-backup-bucket*",
                "arn:aws:s3:::sysdig-backup-bucket*/*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "logs:PutLogEvents"
            ]
            resources = [
                "arn:aws:logs:*:${data.aws_caller_identity.me.account_id}:log-group:sysdig-cloudwatch-metric-stream*"
            ]
        }
    ]
}

resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_role" {
    name                = "SysdigStreamRole-${data.aws_caller_identity.me.account_id}"
    description         = "A metric stream role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.sysdig_cloudwatch_metric_stream_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_firehose_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_sysdig_cloudwatch_metric_stream_role.json
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
            "arn:aws:firehose:*:${data.aws_caller_identity.me.account_id}:deliverystream/sysdig-cloudwatch-metrics-stream*"
        ]
    }
}

resource "aws_iam_policy" "sysdig_cloudwatch_integration_monitoring_role" {
    count = var.create_new_role ? 1 : 0 # This use CreateNewSysdigRole condition for cloudformation
    name   = var.monitoring_role_name
    path   = "/"
    description = "A role to check status of stack creation and metric stream itself"
    assume_role_policy = data.aws_iam_policy_document.sysdig_cloudwatch_integration_monitoring_role_assume_role[0].json
}

data "aws_iam_policy_document" "sysdig_cloudwatch_integration_monitoring_role_assume_role" {
    count = var.sysdig_external_id ? "sts:ExternalId" : 0 # Check this condition
    statement {
        effect = "Allow"
        principals {
            identifiers = ["arn:aws:iam::${data.aws_caller_identity.me.account_id}:root"]
            type        = "AWS"
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy" "cloud_monitoring_policy" {
    depends_on = [WaitCondition] ## RESEARCH terraform way to do this
    name   = "sysdig_cloudwatch_integration_monitoring_policy-${data.aws_caller_identity.me.account_id}"
    role   = var.monitoring_role_name ## Is this correct?
    policy = data.aws_iam_policy_document.iam_role_task_policy_cloud_monitoring_policy.json
}

data "aws_iam_policy_document" "iam_role_task_policy_cloud_monitoring_policy" {
    statement [
        {
            effect = "Allow"
            actions = [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:GetObjectAttributes"
            ]
            resources = [
                "arn:aws:s3:::sysdig-backup-bucket*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "cloudwatch:GetMetricStream",
                "cloudwatch:ListMetricStreams"
            ]
            resources = [
                "arn:aws:cloudwatch:*:${data.aws_caller_identity.me.account_id}:metric-stream/*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "firehose:DescribeDeliveryStream"
            ]
            resources = [
                "arn:aws:firehose:*:${data.aws_caller_identity.me.account_id}:deliverystream/*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "cloudwatch:GetMetricData",
                "cloudwatch:ListMetrics"
            ]
            resources = [
                "*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "ec2:DescribeInstances"
            ]
            resources = [
                "*"
            ]
        },
        {
            effect = "Allow"
            actions = [
                "s3:ListAllMyBuckets",
                "s3:ListBucket"
            ]
            resources = [
                "*"
            ]
        }
    ]
}
