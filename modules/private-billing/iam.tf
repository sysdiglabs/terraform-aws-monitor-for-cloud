resource "aws_iam_role" "cur_crawler_component_function" {
    name = "AWSCURCrawlerComponentFunction"

    assume_role_policy = jsonencode({
        Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "glue.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
        ]
    })

    path = "/"

    managed_policy_arns = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSGlueServiceRole"
    ]
}

resource "aws_iam_role_policy" "cur_crawler_component_policy" {
    name   = "AWSCURCrawlerComponentFunction"
    role   = aws_iam_role.cur_crawler_component_function.id

    policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
            },
        {
            Effect = "Allow"
            Action = [
                "glue:CreateDatabase",
                "glue:UpdateDatabase",
                "glue:GetDatabase",
                "glue:UpdatePartition",
                "glue:CreatePartition",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:GetPartition",
                "glue:GetTable",
                "glue:ImportCatalogToGlue"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
                "lakeformation:Get*",
                "lakeformation:Start*",
                "lakeformation:List*"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
                "s3:GetObject",
                "s3:PutObject"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/${var.s3_bucket_prefix}/sysdig_aws_private_billing/sysdig_aws_private_billing*"
        }
        ]
    })
}

resource "aws_iam_role_policy" "cur_kms_decryption_policy" {
    name   = "AWSCURKMSDecryption"
    role   = aws_iam_role.cur_crawler_component_function.id

    policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "kms:Decrypt"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "cur_crawler_lambda_executor" {
    name = "AWSCURCrawlerLambdaExecutor"

    assume_role_policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    path = "/"
}

resource "aws_iam_role_policy" "cur_crawler_lambda_executor_policy" {
    name = "AWSCURCrawlerLambdaExecutor"
    role = aws_iam_role.cur_crawler_lambda_executor.id

    policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
            },
            {
                Effect = "Allow"
                Action = [
                    "glue:StartCrawler"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "s3_cur_lambda_executor" {
    name               = "AWSS3CURLambdaExecutor"
    assume_role_policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    path = "/"
}

resource "aws_iam_policy" "s3_cur_lambda_executor_policy" {
    name        = "AWSS3CURLambdaExecutor"
    description = "Policy for S3 CUR Lambda Executor"
    policy      = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:${data.aws_partition.current}:logs:*:*:*"
            },
            {
                Effect = "Allow"
                Action = "s3:PutBucketNotification"
                Resource = "arn:${data.aws_partition.current}:s3:::${var.s3_bucket_name}"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "s3_cur_lambda_executor_attachment" {
    role       = aws_iam_role.s3_cur_lambda_executor.name
    policy_arn = aws_iam_policy.s3_cur_lambda_executor_policy.arn
}

resource "aws_iam_role" "private_billing_role" {
    count = var.create_new_role ? 1 : 0

    name = var.sysdig_cost_access_role_name

    assume_role_policy = jsonencode({
        Statement = [{
            Effect    = "Allow"
            Principal = {
                AWS = "arn:aws:iam::${var.sysdig_aws_account_id}:root"
            }
            Action    = "sts:AssumeRole"
            Condition = {
                StringEquals = {
                "sts:ExternalId" = var.sysdig_external_id
                }
            }
        }]
    })
}

resource "aws_iam_policy" "spot_feed_policy" {
    count = local.has_spot_feed_bucket_name ? 1 : 0

    name   = "sysdig-spot-data-feed-access"
    policy = jsonencode({
        Statement = [{
            Sid    = "SpotDataAccess"
            Effect = "Allow"
            Action = [
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:HeadBucket",
                "s3:HeadObject",
                "s3:List*",
                "s3:Get*"
            ]
            Resource = "*"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "spot_feed_policy_attachment" {
    count = local.has_spot_feed_bucket_name ? 1 : 0

    role       = var.sysdig_cost_access_role_name
    policy_arn = aws_iam_policy.spot_feed_policy[count.index].arn
}