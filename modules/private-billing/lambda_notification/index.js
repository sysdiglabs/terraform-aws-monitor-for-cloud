const { S3Client, PutBucketNotificationConfigurationCommand } = require('@aws-sdk/client-s3');
const response = require('cfn-response');

exports.handler = async function(event, context) {
    const s3 = new S3Client({});
    const newNotificationConfig = {};

    if (event.RequestType !== 'Delete') {
        newNotificationConfig.LambdaFunctionConfigurations = [{
            Events: ['s3:ObjectCreated:*'],
            LambdaFunctionArn: event.ResourceProperties.TargetLambdaArn || 'missing arn',
            Filter: { Key: { FilterRules: [{ Name: 'prefix', Value: event.ResourceProperties.ReportKey }] } }
        }];
    }

    try {
        const result = await s3.send(new PutBucketNotificationConfigurationCommand({
            Bucket: event.ResourceProperties.BucketName,
            NotificationConfiguration: newNotificationConfig
        }));
        if (event.ResponseURL) {
            await response.send(event, context, response.SUCCESS, result);
        }
        return result;
    } catch (error) {
        if (event.ResponseURL) {
            await response.send(event, context, response.FAILED, { name: error.name, message: error.message });
        }
        console.log(error);
        throw error;
    }
};
