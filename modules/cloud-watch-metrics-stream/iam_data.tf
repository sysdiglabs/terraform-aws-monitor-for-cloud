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
    statement {
        effect = "Allow"
        actions = [
            "s3:Get*",
            "s3:List*"
        ]
        resources = [
            "arn:aws:s3:::cf-templates-cloudwatch-metric-streams*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "s3:*"
        ]
        resources = [
            "arn:aws:s3:::sysdig-backup-bucket*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "cloudformation:*"
        ]
        resources = [
            "arn:aws:cloudformation:*:${data.aws_caller_identity.me.account_id}:stack/StackSet-SysdigCloudwatchMetricStreams*",
            "arn:aws:cloudformation:*:${data.aws_caller_identity.me.account_id}:stackset/SysdigCloudwatchMetricStreams*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "sns:Publish"
        ]
        resources = [
            "arn:aws:sns:*:*:CfnNotificationSNSTopic"
        ]
    }
        
    statement {
        effect = "Allow"
        actions = [
            "iam:GetRole",
            "iam:PassRole"
        ]
        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "s3:CreateBucket",
            "s3:DeleteBucket",
            "s3:PutBucketTagging"
        ]
        resources = [
            "arn:aws:s3:::sysdig-backup-bucket*"
        ]
    }

    statement {
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
    }

    statement {
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
    }

    statement {
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
            "arn:aws:s3:::sysdig-backup-bucket*",
            "arn:aws:s3:::sysdig-backup-bucket*/*"
        ]
    }
    
    statement {
        effect = "Allow"
        actions = [
            "logs:PutLogEvents"
        ]
        resources = [
            "arn:aws:logs:*:${data.aws_caller_identity.me.account_id}:log-group:sysdig-cloudwatch-metric-stream*"
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
            "arn:aws:firehose:*:${data.aws_caller_identity.me.account_id}:deliverystream/sysdig-cloudwatch-metrics-stream*"
        ]
    }
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

data "aws_iam_policy_document" "iam_role_task_policy_cloud_monitoring_policy" {
    statement {
        effect = "Allow"
        actions = [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:GetObjectAttributes"
        ]
        resources = [
            "arn:aws:s3:::sysdig-backup-bucket*"
        ]
    }
    
    statement {
        effect = "Allow"
        actions = [
            "cloudwatch:GetMetricStream",
            "cloudwatch:ListMetricStreams"
        ]
        resources = [
            "arn:aws:cloudwatch:*:${data.aws_caller_identity.me.account_id}:metric-stream/*"
        ]
    }
    
    statement {
        effect = "Allow"
        actions = [
            "firehose:DescribeDeliveryStream"
        ]
        resources = [
            "arn:aws:firehose:*:${data.aws_caller_identity.me.account_id}:deliverystream/*"
        ]
    }
        
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
        
    statement {
        effect = "Allow"
        actions = [
            "s3:ListAllMyBuckets",
            "s3:ListBucket"
        ]
        resources = [
            "*"
        ]
    }
}