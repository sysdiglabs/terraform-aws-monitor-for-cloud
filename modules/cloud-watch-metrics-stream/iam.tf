resource "aws_iam_role" "service_role" {
    name               = "SysdigServiceRole-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.service_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_s3_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_service_role.json
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_role" {
    name                = "SysdigStreamRole-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    description         = "A metric stream role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.sysdig_cloudwatch_metric_stream_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_firehose_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_sysdig_cloudwatch_metric_stream_role.json
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_integration_monitoring_role" {
    count = var.create_new_role ? 1 : 0
    name   = "${var.monitoring_role_name}-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    path   = "/"
    description = "A role to check status of stack creation and metric stream itself"
    assume_role_policy = data.aws_iam_policy_document.sysdig_cloudwatch_integration_monitoring_role_assume_role.json
}

resource "aws_iam_role_policy" "cloud_monitoring_policy" {
    depends_on = [ aws_iam_role.sysdig_cloudwatch_integration_monitoring_role[0] ]
    name   = aws_iam_role.sysdig_cloudwatch_integration_monitoring_role[0].id
    role   = "${var.monitoring_role_name}-${data.aws_region.current.name}-${data.aws_caller_identity.me.account_id}"
    policy = data.aws_iam_policy_document.iam_role_task_policy_cloud_monitoring_policy.json
}
