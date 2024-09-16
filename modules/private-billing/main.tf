locals {
    has_spot_feed_bucket_name = var.spot_data_feed_bucket_name != ""
}

resource "aws_s3_bucket" "sysdig_curs3_bucket" {
    bucket = var.s3_bucket_name
    object_lock_enabled = false
}

resource "aws_s3_bucket_public_access_block" "sysdig_curs3_bucket_public_access_block" {
    bucket = aws_s3_bucket.sysdig_curs3_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "sysdig_curs3_bucket_acl" {
    bucket = aws_s3_bucket.sysdig_curs3_bucket.id
    acl    = "private"
}

resource "aws_s3_bucket_policy" "sysdig_cur_bucket_policy" {
    bucket = aws_s3_bucket.sysdig_curs3_bucket.id

    policy = jsonencode({
        Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "billingreports.amazonaws.com"
            }
            Action   = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
            Resource = aws_s3_bucket.sysdig_curs3_bucket.arn
            Condition = {
                StringEquals = {
                    "aws:SourceArn"    = "arn:aws:cur:${var.s3_region}:${data.aws_caller_identity.current.account_id}:definition/*"
                    "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
            }
        },
        {
            Effect = "Allow"
            Principal = {
                Service = "billingreports.amazonaws.com"
            }
            Action   = "s3:PutObject"
            Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
            Condition = {
                StringEquals = {
                    "aws:SourceArn"    = "arn:aws:cur:${var.s3_region}:${data.aws_caller_identity.current.account_id}:definition/*"
                    "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
            }
        }
        ]
    })

    depends_on = [ aws_s3_bucket.sysdig_curs3_bucket ]
}

resource "aws_cur_report_definition" "sysdig_created_cur" {
    report_name         = "sysdig_aws_private_billing"
    time_unit           = "HOURLY"
    format              = "Parquet"
    compression         = "Parquet"
    s3_bucket           = var.s3_bucket_name
    s3_prefix           = var.s3_bucket_prefix
    s3_region           = var.s3_region
    additional_schema_elements = ["RESOURCES"]
    additional_artifacts       = ["ATHENA"]
    report_versioning          = "OVERWRITE_REPORT"
    refresh_closed_reports     = true

    depends_on = [ aws_s3_bucket_policy.sysdig_cur_bucket_policy ]
}

resource "aws_glue_catalog_database" "aws_cur_database" {
    name = "sysdig_aws_private_billing"
    description = "AWS billing CUR database"
    target_database {
        database_name = "sysdig_aws_private_billing"
        catalog_id = data.aws_caller_identity.current.account_id
    }
    depends_on = [ aws_cur_report_definition.sysdig_created_cur ]
}

resource "aws_athena_workgroup" "athena_workgroup" {
    name = "sysdig-private-billing-athena-workgroup"
    state = "ENABLED"

    configuration {
        result_configuration {
            output_location = "s3://${var.s3_bucket_name}/${var.s3_athena_bucket_prefix}"
        }
    }

    depends_on = [ aws_glue_catalog_database.aws_cur_database ]
}

resource "aws_glue_crawler" "cur_crawler" {
    name          = "AWSCURCrawler-sysdig_aws_private_billing"
    description = "A recurring crawler that keeps your CUR table in Athena up-to-date."
    role          = aws_iam_role.cur_crawler_component_function.arn
    database_name = aws_glue_catalog_database.aws_cur_database.name
    
    s3_target {
        path = "s3://${var.s3_bucket_name}/${var.s3_bucket_prefix}/sysdig_aws_private_billing/sysdig_aws_private_billing"

        exclusions = [
            "**.json",
            "**.yml",
            "**.sql",
            "**.csv",
            "**.gz",
            "**.zip"
        ]
    }

    schema_change_policy {
        update_behavior = "UPDATE_IN_DATABASE"
        delete_behavior = "DELETE_FROM_DATABASE"
    }

    depends_on = [ aws_glue_catalog_database.aws_cur_database, aws_iam_role.cur_crawler_component_function ]
}

data "archive_file" "lambda_crawler_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda_crawler"
    output_path = "${path.module}/lambda_crawler.zip"
}

resource "aws_lambda_function" "cur_initializer" {
    function_name = "AWSCURInitializer"
    handler       = "index.handler"
    runtime       = "nodejs16.x"
    filename      = data.archive_file.lambda_crawler_zip.output_path
    timeout       = 30
    role          = aws_iam_role.cur_crawler_lambda_executor.arn
    memory_size   = 128
    reserved_concurrent_executions = 1

    environment {
        variables = {
            CrawlerSuffix = "sysdig_aws_private_billing"
        }
    }
}

// This resource is used to trigger the lambda function but im not sure if it is going to work because in Cloudformation it is using Custom::AWSStartCURCrawler
resource "aws_lambda_invocation" "start_cur_crawler" {
    function_name = aws_lambda_function.cur_initializer.function_name
    input         = jsonencode({})
    depends_on    = [aws_lambda_function.cur_initializer]
}

resource "aws_lambda_permission" "s3_cur_event_lambda" {
    statement_id  = "AllowS3InvokeLambda"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.cur_initializer.function_name
    principal     = "s3.amazonaws.com"
    source_account = var.sysdig_aws_account_id
    source_arn    = "arn:${data.aws_partition.current}:s3:::${var.s3_bucket_name}"
}

data "archive_file" "lambda_notification_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda_notification"
    output_path = "${path.module}/lambda_notification.zip"
}

resource "aws_lambda_function" "s3_cur_notification" {
    function_name = "s3_cur_notification"
    handler       = "index.handler"
    runtime       = "nodejs16.x"
    filename      = data.archive_file.lambda_notification_zip.output_path
    timeout       = 30
    role          = aws_iam_role.s3_cur_lambda_executor.arn

    reserved_concurrent_executions = 1
}

resource "null_resource" "put_s3_cur_notification" {
    provisioner "local-exec" {
        command = <<-EOT
        aws lambda invoke \
            --function-name ${aws_lambda_function.s3_cur_notification.function_name} \
            --payload '{
            "RequestType": "Create",
                "ResourceProperties": {
                    "BucketName": "${var.s3_bucket_name}",
                    "TargetLambdaArn": "${aws_lambda_function.cur_initializer.arn}",
                    "ReportKey": "${var.s3_bucket_prefix}/sysdig_aws_private_billing/sysdig_aws_private_billing"
                }
            }' \
            response.json
        EOT
    }

    triggers = {
        bucket_name    = var.s3_bucket_name
        target_lambda  = aws_lambda_function.cur_initializer.arn
        report_key     = "${var.s3_bucket_prefix}/sysdig_aws_private_billing/sysdig_aws_private_billing"
    }
}

resource "aws_glue_catalog_table" "cur_report_status_table" {
    name          = "sysdig_private_billing_cost_and_usage_data_status"
    database_name = aws_glue_catalog_database.cur_database.name
    catalog_id    = data.aws_caller_identity.current.account_id
    table_type    = "EXTERNAL_TABLE"

    storage_descriptor {
        location      = "s3://${var.s3_bucket_name}/${var.s3_bucket_prefix}/sysdig_aws_private_billing/cost_and_usage_data_status/"
        input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

        ser_de_info {
            serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
        }

        columns {
            name = "status"
            type = "string"
        }
    }
}