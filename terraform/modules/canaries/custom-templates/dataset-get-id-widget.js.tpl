const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const AWS = require('aws-sdk');
const https = require('https');
const http = require('http');

const apiCanaryBlueprint = async function () {

    const verifyRequest = async function (requestOption, body = null) {
        return new Promise((resolve, reject) => {
            // Prep request
            log.info("Making request with options: " + JSON.stringify(requestOption));
            let req = (requestOption.port === 443) ? https.request(requestOption) : http.request(requestOption);

            // POST body data
            if (body) { req.write(JSON.stringify(body)); }

            // Handle response
            req.on('response', (res) => {
                log.info(`Status Code: ${res.statusCode}`)

                // Assert the status code returned
                if (res.statusCode !== 200) {
                    reject("Failed: " + requestOption.path + " with status code " + res.statusCode);
                }

                // Grab body chunks and piece returned body together
                let body = '';
                res.on('data', (chunk) => { body += chunk.toString(); });

                // Resolve providing the returned body
                res.on('end', () => resolve(JSON.parse(body)));
            });

            // Reject on error
            req.on('error', (error) => reject(error));
            req.end();
        });
    }

    // Build request options
    let requestOptions = {
        hostname: "api.resourcewatch.org",
        method: "GET",
        path: "/v1/dataset?includes=widget",
        port: 443,
        headers: {
            'User-Agent': synthetics.getCanaryUserAgentString(),
            'Content-Type': 'application/json',
        },
    };

    // Find and use secret for auth token
    const secretsManager = new AWS.SecretsManager();
    await secretsManager.getSecretValue({ SecretId: "gfw-api/token" }, function(err, data) {
        if (err) log.info(err, err.stack);
        log.info(data);
        requestOptions.headers['Authorization'] = "Bearer " + JSON.parse(data["SecretString"])["token"];
    }).promise();

    // Find and use secret for hostname
    await secretsManager.getSecretValue({ SecretId: "wri-api/smoke-tests-host" }, function(err, data) {
        if (err) log.info(err, err.stack);
        log.info(data);
        requestOptions.hostname = JSON.parse(data["SecretString"])["smoke-tests-host"];
    }).promise();

    const body = await verifyRequest(requestOptions);
    const dataset = body.data.find(ds => ds.attributes.widget.length > 0);
    if (!dataset) {
        throw new Error('No usable dataset.');
    }
    const datasetId = dataset.id;
    const widgetId = dataset.attributes.widget[0].id;

    // Change needed request options
    requestOptions.path = "/v1/dataset/"+datasetId+"/widget/"+widgetId;

    // Make second request
    await verifyRequest(requestOptions);
};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
