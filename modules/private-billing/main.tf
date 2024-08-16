resource "aws_s3_bucket" "sysdig_curs3_bucket" {
    bucket = var.s3_bucket_name
    acl    = "private"

    object_lock_configuration {
        object_lock_enabled = false
    }
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
        Version = "2008-10-17"
        Id      = "Policy1335892530063"
        Statement = [
        {
            Sid    = "Stmt1335892150622"
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
            Sid    = "Stmt1335892526596"
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
}

resource "aws_athena_workgroup" "athena_workgroup" {
    name = "sysdig-private-billing-athena-workgroup"
    state = "ENABLED"

    configuration {
        result_configuration {
            output_location = "s3://${var.s3_bucket_name}/${var.s3_athena_bucket_prefix}"
        }
    }
}

resource "aws_glue_catalog_database" "aws_cur_database" {
    name = "sysdig_aws_private_billing"
    description = "AWS billing CUR database"
    catalog_id = data.aws_caller_identity.current.account_id
}

resource "aws_glue_crawler" "cur_crawler" {
    database_name = aws_glue_catalog_database.aws_cur_database.name
    description = "A recurring crawler that keeps your CUR table in Athena up-to-date."
    name          = "AWSCURCrawler-sysdig_aws_private_billing"
    role          = aws_iam_role.cur_crawler_component_function.arn


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
}

resource "aws_lambda_function" "cur_initializer" {
    function_name = "AWSCURInitializer"
    handler       = "index.handler"
    runtime       = "nodejs16.x"
    timeout       = 30
    role          = aws_iam_role.cur_crawler_lambda_executor.arn
    memory_size   = 128
    reserved_concurrent_executions = 1

    environment {
        variables = {
            CrawlerSuffix = "sysdig_aws_private_billing"
        }
    }

    code {
        zip_file = <<-EOT
        const AWS = require('aws-sdk');
        const response = require('./cfn-response');
        exports.handler = function(event, context, callback) {
            if (event.RequestType === 'Delete') {
            response.send(event, context, response.SUCCESS);
            } else {
            const glue = new AWS.Glue();
            const suffix = process.env.CrawlerSuffix
            glue.startCrawler({ Name: `AWSCURCrawler-${suffix}` }, function(err, data) {
                if (err) {
                const responseData = JSON.parse(this.httpResponse.body);
                if (responseData['__type'] == 'CrawlerRunningException') {
                    callback(null, responseData.Message);
                } else {
                    const responseString = JSON.stringify(responseData);
                    if (event.ResponseURL) {
                    response.send(event, context, response.FAILED,{ msg: responseString });
                    } else {
                    callback(responseString);
                    }
                }
                }
                else {
                if (event.ResponseURL) {
                    response.send(event, context, response.SUCCESS);
                } else {
                    callback(null, response.SUCCESS);
                }
                }
            });
            }
        };
        EOT
    }
}