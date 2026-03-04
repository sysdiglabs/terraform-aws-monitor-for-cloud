const { GlueClient, StartCrawlerCommand } = require('@aws-sdk/client-glue');
const response = require('cfn-response');

exports.handler = async function(event, context) {
    if (event.RequestType === 'Delete') {
        await response.send(event, context, response.SUCCESS);
        return;
    }

    const glue = new GlueClient({});
    const suffix = process.env.CrawlerSuffix;

    try {
        const data = await glue.send(new StartCrawlerCommand({ Name: `AWSCURCrawler-${suffix}` }));
        if (event.ResponseURL) {
            await response.send(event, context, response.SUCCESS);
        }
        return data;
    } catch (err) {
        if (err.name === 'CrawlerRunningException') {
            return err.message;
        }
        const responseString = JSON.stringify({ name: err.name, message: err.message });
        if (event.ResponseURL) {
            await response.send(event, context, response.FAILED, { msg: responseString });
        } else {
            throw err;
        }
    }
};
