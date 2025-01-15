output "monitoring_role_name" {
    value       = "${var.sysdig_cost_access_role_name}-${data.aws_caller_identity.me.account_id}"
    description = "Name of the role which could be used to Cost feature"
}

output "athena_bucket_name" {
    value       = var.s3_bucket_name
    description = "Name of the S3 bucket where the Athena query results are stored"
}

output "athena_database_name" {
    value       = var.sysdig_cost_report_file_name
    description = "Prefix of the S3 bucket where the Athena query results are stored"
}

output "athena_region" {
    value       = "${data.aws_region.current.name}"
    description = "Region where the Athena query results are stored"
}

output "athena_table_name" {
    value       = var.sysdig_cost_report_file_name
    description = "Name of the Athena table"
}

output "athena_workgroup_name" {
    value       = "${var.sysdig_cost_report_file_name}-athena-workgroup"
    description = "Name of the Athena workgroup"
}