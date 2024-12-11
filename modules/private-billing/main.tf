resource "aws_s3_bucket" "sysdig_curs3_bucket" {
    bucket = var.s3_bucket_name
    object_lock_enabled = false
    force_destroy = true //todo: remove this line in production
    tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "sysdig_curs3_bucket_public_access_block" {
    bucket = aws_s3_bucket.sysdig_curs3_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
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
            Action   = [
                "s3:GetBucketLocation", 
                "s3:GetBucketAcl", 
                "s3:GetBucketPolicy"
            ]
            Resource = "arn:aws:s3:::${var.s3_bucket_name}"
            Condition = {
                StringEquals = {
                    "aws:SourceArn"    = "arn:aws:cur:us-east-1:${data.aws_caller_identity.me.account_id}:definition/*"
                    "aws:SourceAccount" = "${data.aws_caller_identity.me.account_id}"
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
                    "aws:SourceArn"    = "arn:aws:cur:us-east-1:${data.aws_caller_identity.me.account_id}:definition/*"
                    "aws:SourceAccount" = "${data.aws_caller_identity.me.account_id}"
                }
            }
        },
        {
            Effect = "Allow"
            Principal = {
                AWS = aws_iam_role.cur_crawler_component_function.arn
            }
            Action   = [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject"
            ]
            Resource = [
                "arn:aws:s3:::${var.s3_bucket_name}",
                "arn:aws:s3:::${var.s3_bucket_name}/*"
            ]
        }
        ]
    })

    depends_on = [ aws_s3_bucket.sysdig_curs3_bucket ]
}

resource "aws_cur_report_definition" "sysdig_created_cur" {
    provider            = aws.us-east-1
    report_name         = var.sysdig_cost_report_file_name
    time_unit           = "HOURLY"
    format              = "Parquet"
    compression         = "Parquet"
    s3_bucket           = var.s3_bucket_name
    s3_prefix           = var.s3_bucket_prefix
    s3_region           = data.aws_region.current.name
    additional_schema_elements = ["RESOURCES"]
    additional_artifacts       = ["ATHENA"]
    report_versioning          = "OVERWRITE_REPORT"
    refresh_closed_reports     = true
    tags = var.tags

    depends_on = [ aws_s3_bucket_policy.sysdig_cur_bucket_policy ]
}

resource "aws_glue_catalog_database" "aws_cur_database" {
    name = var.sysdig_cost_report_file_name
    catalog_id = data.aws_caller_identity.me.account_id
    tags = var.tags

    create_table_default_permission {
        permissions = ["ALL"]

        principal {
            data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
        }
    }
    depends_on = [ aws_cur_report_definition.sysdig_created_cur ]
}

resource "aws_lakeformation_permissions" "sysdig_db_permissions" {
    principal  = "IAM_ALLOWED_PRINCIPALS"
    permissions = ["ALL"]

    database {
        name = aws_glue_catalog_database.aws_cur_database.name
    }
}

resource "aws_athena_workgroup" "athena_workgroup" {
    name = "${var.sysdig_cost_report_file_name}-athena-workgroup"
    state = "ENABLED"
    tags = var.tags

    configuration {
        result_configuration {
            output_location = "s3://${var.s3_bucket_name}/${var.s3_athena_bucket_prefix}"
        }
    }

    depends_on = [ aws_glue_catalog_database.aws_cur_database ]
}

resource "aws_glue_crawler" "cur_crawler" {
    name          = "AWSCURCrawler-${var.sysdig_cost_crawler_name_suffix}"
    description = "A recurring crawler that keeps your CUR table in Athena up-to-date."
    role          = aws_iam_role.cur_crawler_component_function.arn
    database_name = aws_glue_catalog_database.aws_cur_database.name
    tags = var.tags
    
    s3_target {
        path = "s3://${var.s3_bucket_name}/${var.s3_bucket_prefix}/${var.sysdig_cost_report_file_name}/${var.sysdig_cost_report_file_name}"

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
    function_name = "AWSCURInitializer-${data.aws_caller_identity.me.account_id}"
    handler       = "index.handler"
    runtime       = "nodejs16.x"
    filename      = data.archive_file.lambda_crawler_zip.output_path
    timeout       = 30
    role          = aws_iam_role.cur_crawler_lambda_executor.arn
    memory_size   = 128
    reserved_concurrent_executions = 1
    tags = var.tags

    environment {
        variables = {
            CrawlerSuffix = "${var.sysdig_cost_crawler_name_suffix}"
        }
    }
}

resource "null_resource" "run_cur_initializer" {
    provisioner "local-exec" {
        command = <<-EOT
        aws lambda invoke \
            --function-name ${aws_lambda_function.cur_initializer.function_name} \
            --region ${data.aws_region.current.name} \
            --cli-binary-format raw-in-base64-out \
            --payload '{
            "RequestType": "Create"
            }' \
            response.json
        EOT
    
        when = create
    }

    depends_on = [aws_lambda_function.cur_initializer]
}

resource "aws_lambda_permission" "s3_cur_event_lambda" {
    statement_id  = "AllowS3InvokeLambda"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.cur_initializer.function_name
    principal     = "s3.amazonaws.com"
    source_account = data.aws_caller_identity.me.account_id
    source_arn    = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
}

data "archive_file" "lambda_notification_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda_notification"
    output_path = "${path.module}/lambda_notification.zip"
}

resource "aws_lambda_function" "s3_cur_notification" {
    function_name = "s3_cur_notification-${data.aws_caller_identity.me.account_id}"
    handler       = "index.handler"
    runtime       = "nodejs16.x"
    filename      = data.archive_file.lambda_notification_zip.output_path
    timeout       = 30
    role          = aws_iam_role.s3_cur_lambda_executor.arn
    tags = var.tags

    reserved_concurrent_executions = 1
}

resource "null_resource" "put_s3_cur_notification" {
    provisioner "local-exec" {
        command = <<-EOT
        aws lambda invoke \
            --function-name ${aws_lambda_function.s3_cur_notification.function_name} \
            --region ${data.aws_region.current.name} \
            --cli-binary-format raw-in-base64-out \
            --payload '{
            "RequestType": "Create",
            "ResourceProperties": {
                "BucketName": "${var.s3_bucket_name}",
                "TargetLambdaArn": "${aws_lambda_function.cur_initializer.arn}",
                "ReportKey": "${var.s3_bucket_prefix}/${var.sysdig_cost_report_file_name}/${var.sysdig_cost_report_file_name}"
            }
            }' \
            response.json
        EOT

        when = create
    }

    triggers = {
        bucket_name    = var.s3_bucket_name
        target_lambda  = aws_lambda_function.cur_initializer.arn
        report_key     = "${var.s3_bucket_prefix}/${var.sysdig_cost_report_file_name}/${var.sysdig_cost_report_file_name}"
    }

    depends_on = [aws_lambda_function.s3_cur_notification]
}

resource "aws_glue_catalog_table" "cur_report_status_table" {
    name          = "sysdig_private_billing_cost_and_usage_data_status"
    database_name = aws_glue_catalog_database.aws_cur_database.name
    catalog_id    = data.aws_caller_identity.me.account_id
    table_type    = "EXTERNAL_TABLE"

    storage_descriptor {
        location      = "s3://${var.s3_bucket_name}/${var.s3_bucket_prefix}/${var.sysdig_cost_report_file_name}/cost_and_usage_data_status/"
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

    depends_on = [ aws_glue_catalog_database.aws_cur_database ]
}

resource "time_sleep" "wait_60_seconds" {
    count = var.create_new_role ? 1 : 0
    create_duration = "60s"

    depends_on = [ aws_iam_role.private_billing_role[0] ]
}

resource "sysdig_monitor_cloud_account" "assume_role_cloud_account" {
    count = var.create_new_role ? 1 : 0
    cloud_provider = "AWS"
    integration_type = "Cost"
    account_id = "${data.aws_caller_identity.me.account_id}"
    role_name = "${var.sysdig_cost_access_role_name}-${data.aws_caller_identity.me.account_id}"
    config = {
        athena_bucket_name = var.s3_bucket_name
        athena_database_name = aws_glue_catalog_database.aws_cur_database.name
        athena_region = data.aws_region.current.name
        athena_workgroup = aws_athena_workgroup.athena_workgroup.name
        athena_table_name = aws_glue_catalog_database.aws_cur_database.name
        spot_prices_bucket_name = var.s3_bucket_name
    }

    depends_on = [ time_sleep.wait_60_seconds[0] ]
}