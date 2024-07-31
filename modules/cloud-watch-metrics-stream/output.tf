output "aws_iam_role_name" {
    description = "Name of the IAM role for Sysdig's SaaS to assume (needed to configure integration)"
    value       = aws_iam_role.sysdig_to_cloudwatch.name
}

data "aws_caller_identity" "current" {}

output "aws_account_id" {
    description = "Current AWS account ID (needed to configure integration)"
    value       = data.aws_caller_identity.current.account_id
}