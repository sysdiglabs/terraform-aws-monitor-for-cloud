resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_stack_set_administration_role" {
    name               = "SysdigStackSetAdminRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch_metric_stream_stack_set_administration_assume_role.json
    inline_policy {
        name   = "SysdigStreamCfnStackSetAssumeRole"
        policy = data.aws_iam_policy_document.iam_role_task_policy_cloudwatch_metric_stream_stack_set_administration.json
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_stack_set_execution_role" {
    name               = "SysdigStackSetExecRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.cloudwatch_metric_stream_stack_set_execution_assume_role.json
    inline_policy {
        name   = "SysdigStreamCfnStackAssumeRole"
        policy = data.aws_iam_policy_document.iam_role_task_policy_cloudwatch_metric_stream_stack_set_execution.json
    }
}

resource "aws_iam_role" "service_role" {
    name               = "SysdigServiceRole-${data.aws_caller_identity.me.account_id}"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.service_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_s3_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_service_role.json
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_metric_stream_role" {
    name                = "SysdigStreamRole-${data.aws_caller_identity.me.account_id}"
    description         = "A metric stream role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.sysdig_cloudwatch_metric_stream_role_assume_role.json
    inline_policy {
        name   = "sysdig_stream_firehose_policy"
        policy = data.aws_iam_policy_document.iam_role_task_policy_sysdig_cloudwatch_metric_stream_role.json
    }
}

resource "aws_iam_role" "sysdig_cloudwatch_integration_monitoring_role" {
    count = var.create_new_role ? 1 : 0 # This use CreateNewSysdigRole condition for cloudformation
    name   = var.monitoring_role_name
    path   = "/"
    description = "A role to check status of stack creation and metric stream itself"
    assume_role_policy = data.aws_iam_policy_document.sysdig_cloudwatch_integration_monitoring_role_assume_role[0].json
}

resource "aws_iam_role_policy" "cloud_monitoring_policy" {
    depends_on = [WaitCondition] ## RESEARCH terraform way to do this
    name   = "sysdig_cloudwatch_integration_monitoring_policy-${data.aws_caller_identity.me.account_id}"
    role   = var.monitoring_role_name ## Is this correct?
    policy = data.aws_iam_policy_document.iam_role_task_policy_cloud_monitoring_policy.json
}
