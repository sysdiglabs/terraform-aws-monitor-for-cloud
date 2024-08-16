resource "aws_iam_role" "cur_crawler_component_function" {
    name = "AWSCURCrawlerComponentFunction"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
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
        Version = "2012-10-17"
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
        Version = "2012-10-17"
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
        Version = "2012-10-17"
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
        Version = "2012-10-17"
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
                    
                ]
                Resource = "*"
            }
        ]
    })
}