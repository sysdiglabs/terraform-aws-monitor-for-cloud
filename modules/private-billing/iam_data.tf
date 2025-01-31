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

data "aws_iam_policy_document" "sysdig_cost_athena_access_policy_document" {
    statement {
        sid    = "AthenaAccess"
        effect = "Allow"
        actions = ["athena:*"]
        resources = [
            "arn:${data.aws_partition.current.partition}:athena:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:workgroup/${aws_athena_workgroup.athena_workgroup.name}",
        ]
    }

    statement {
        sid    = "ReadAccessToAthenaCurDataViaGlue"
        effect = "Allow"
        actions = [
            "glue:GetDatabase*",
            "glue:GetTable*",
            "glue:GetPartition*",
            "glue:GetUserDefinedFunction",
            "glue:BatchGetPartition"
        ]
        resources = [
            "arn:aws:glue:*:*:catalog",
            "arn:aws:glue:*:*:database/${var.sysdig_cost_report_file_name}",
            "arn:aws:glue:*:*:table/${var.sysdig_cost_report_file_name}/*"
        ]
    }

    statement {
        sid    = "AthenaQueryResultsOutput"
        effect = "Allow"
        actions = [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:CreateBucket",
            "s3:PutObject"
        ]
        resources = [
            "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_athena_bucket_prefix}*"
        ]
    }

    statement {
        sid    = "S3ReadAccessToAwsBillingData"
        effect = "Allow"
        actions = [
            "s3:Get*",
            "s3:List*"
        ]
        resources = [
            "arn:aws:s3:::${var.s3_bucket_name}*"
        ]
    }

    statement {
        sid    = "ReadAccessToAccountTags"
        effect = "Allow"
        actions = [
            "organizations:ListAccounts",
            "organizations:ListTagsForResource",
            "organizations:ListAccountsForParent",
            "organizations:ListParents"
        ]
        resources = ["*"]
    }

    statement {
        sid    = "ListEC2Metadata"
        effect = "Allow"
        actions = ["ec2:DescribeInstances"]
        resources = ["*"]
    }

    statement {
        sid    = "LakeFormation"
        effect = "Allow"
        actions = ["lakeformation:GetDataAccess"]
        resources = ["*"]
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

