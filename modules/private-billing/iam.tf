resource "aws_iam_role" "cur_crawler_component_function" {
    name               = "AWSCURCrawlerComponentFunction"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cur_crawler_component_function_assume_role.json
    tags = var.tags
    
    managed_policy_arns = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSGlueServiceRole"
    ]
}

resource "aws_iam_role_policy" "cur_crawler_inline_policy" {
    name   = "AWSCURCrawlerComponentFunction"
    role   = aws_iam_role.cur_crawler_component_function.id
    policy = jsonencode({
        Statement = [
            {
                Effect   = "Allow"
                Action   = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
            },
            {
                Effect   = "Allow"
                Action   = [
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
                Effect   = "Allow"
                Action   = [
                    "lakeformation:Get*",
                    "lakeformation:Start*",
                    "lakeformation:List*"
                ]
                Resource = "*"
            },
            {
                Effect   = "Allow"
                Action   = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/${var.s3_bucket_prefix}/sysdig_aws_private_billing/sysdig_aws_private_billing*"
            }
        ]
    })
}

resource "aws_iam_role_policy" "cur_kms_decryption_inline_policy" {
    name   = "AWSCURKMSDecryption"
    role   = aws_iam_role.cur_crawler_component_function.id
    policy = jsonencode({
        Statement = [
            {
                Effect   = "Allow"
                Action   = [
                    "kms:Decrypt"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "cur_crawler_lambda_executor" {
    name = "AWSCURCrawlerLambdaExecutor"
    path = "/"
    tags = var.tags

    assume_role_policy = data.aws_iam_policy_document.cur_crawler_lambda_executor_assume_role.json
}

resource "aws_iam_role_policy" "cur_crawler_lambda_executor_inline_policy" {
    name   = "AWSCURCrawlerLambdaExecutor"
    role   = aws_iam_role.cur_crawler_lambda_executor.id

    policy = jsonencode({
        Statement = [
            {
                Effect   = "Allow"
                Action   = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:*"
            },
            {
                Effect   = "Allow"
                Action   = [
                    "glue:StartCrawler"
                ]
                Resource = "*"
            }
        ]
    })
}


resource "aws_iam_role" "s3_cur_lambda_executor" {
    name               = "AWSS3CURLambdaExecutor"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.s3_cur_lambda_executor_assume_role.json
    tags = var.tags
}

resource "aws_iam_policy" "s3_cur_lambda_executor_policy" {
    policy      = data.aws_iam_policy_document.s3_cur_lambda_executor_policy_document.json
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_cur_lambda_executor_attachment" {
    role       = aws_iam_role.s3_cur_lambda_executor.name
    policy_arn = aws_iam_policy.s3_cur_lambda_executor_policy.arn
}
resource "aws_iam_role" "private_billing_role" {
    count = var.create_new_role ? 1 : 0
    name = "${var.sysdig_cost_access_role_name}-${data.aws_caller_identity.me.account_id}"
    tags = var.tags

    assume_role_policy = data.aws_iam_policy_document.private_billing_assume_role.json
}

resource "aws_iam_policy" "spot_feed_policy" {
    count = var.spot_data_feed_bucket_name != "" ? 1 : 0 
    policy      = data.aws_iam_policy_document.spot_feed_policy_document.json
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "spot_feed_policy_attachment" {
    count = var.spot_data_feed_bucket_name != "" ? 1 : 0 

    role       = "${var.sysdig_cost_access_role_name}-${data.aws_caller_identity.me.account_id}"
    policy_arn = aws_iam_policy.spot_feed_policy[0].arn

    depends_on = [ aws_iam_role.private_billing_role, aws_iam_policy.spot_feed_policy[0] ]
}

resource "aws_iam_policy" "sysdig_cost_athena_access_policy" {
    policy      = data.aws_iam_policy_document.sysdig_cost_athena_access_policy_document.json
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sysdig_cost_athena_access_policy_attachment" {
    count = var.create_new_role ? 1 : 0

    role       = "${var.sysdig_cost_access_role_name}-${data.aws_caller_identity.me.account_id}"
    policy_arn = aws_iam_policy.sysdig_cost_athena_access_policy.arn

    depends_on = [ aws_iam_role.private_billing_role ]
}

