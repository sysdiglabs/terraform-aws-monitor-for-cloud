resource "aws_iam_role" "cur_crawler_component_function" {
    name               = "AWSCURCrawlerComponentFunction"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cur_crawler_component_function_assume_role.json
    
    managed_policy_arns = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSGlueServiceRole"
    ]
    
    inline_policy {
        name   = "AWSCURCrawlerComponentFunction"
        policy = data.aws_iam_policy_document.cur_crawler_component_policy.json
    }

    inline_policy {
        name   = "AWSCURKMSDecryption"
        policy = data.aws_iam_policy_document.cur_kms_decryption_policy.json
    }
}

resource "aws_iam_role" "cur_crawler_lambda_executor" {
    name = "AWSCURCrawlerLambdaExecutor"
    path = "/"

    assume_role_policy = data.aws_iam_policy_document.cur_crawler_lambda_executor_assume_role.json

    inline_policy {
        name   = "AWSCURCrawlerLambdaExecutor"
        policy = data.aws_iam_policy_document.cur_crawler_lambda_executor_policy.json
    }
}

resource "aws_iam_role" "s3_cur_lambda_executor" {
    name               = "AWSS3CURLambdaExecutor"
    path = "/"
    assume_role_policy = data.aws_iam_policy_document.s3_cur_lambda_executor_assume_role.json
}

resource "aws_iam_policy" "s3_cur_lambda_executor_policy" {
    policy      = data.aws_iam_policy_document.s3_cur_lambda_executor_policy_document.json
}

resource "aws_iam_role_policy_attachment" "s3_cur_lambda_executor_attachment" {
    role       = aws_iam_role.s3_cur_lambda_executor.name
    policy_arn = aws_iam_policy.s3_cur_lambda_executor_policy.arn
}
resource "aws_iam_role" "private_billing_role" {
    count = var.create_new_role ? 1 : 0
    name = var.sysdig_cost_access_role_name

    assume_role_policy = data.aws_iam_policy_document.private_billing_assume_role.json
}

resource "aws_iam_policy" "spot_feed_policy" {
    policy      = data.aws_iam_policy_document.spot_feed_policy_document.json
}

resource "aws_iam_role_policy_attachment" "spot_feed_policy_attachment" {
    count = var.create_new_role ? 1 : 0

    role       = var.sysdig_cost_access_role_name
    policy_arn = aws_iam_policy.spot_feed_policy.arn
}