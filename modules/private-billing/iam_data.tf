data "aws_iam_policy_document" "cur_crawler_component_function_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["glue.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "cur_crawler_lambda_executor_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["lambda.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "s3_cur_lambda_executor_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["lambda.amazonaws.com"]
            type        = "Service"
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "s3_cur_lambda_executor_policy_document" {
    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = [
            "arn:${data.aws_partition.current.partition}:logs:*:*:*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "s3:PutBucketNotification"
        ]
        resources = [
            "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
        ]
    }
}

data "aws_iam_policy_document" "private_billing_assume_role" {
    statement {
        effect = "Allow"
        principals {
            identifiers = ["arn:aws:iam::${var.sysdig_aws_account_id}:root"]
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

data "aws_iam_policy_document" "spot_feed_policy_document" {
    statement {
        effect = "Allow"
        actions = [
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:HeadBucket",
            "s3:HeadObject",
            "s3:List*",
            "s3:Get*"
        ]
        resources = [
            "*"
        ]
    }
}

