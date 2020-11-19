const AWS = require('aws-sdk');
const seedrandom = require('seedrandom');
const moment = require("moment");

const rng = seedrandom();

const awsRegion = process.env.AWS_REGION;
AWS.config.update({region: awsRegion});

const S3 = new AWS.S3({apiVersion: '2006-03-01'});

exports.handler = async (event) => {
    console.log('EVENT:', JSON.stringify(event, null, 2));

    try {
        const maxSizeMB = 20;
        const s3BucketName = process.env.S3_PHOTO_INBOX_ID;
        const userId = Buffer.from(event.requestContext.authorizer.jwt.claims.sub).toString('base64')
        let randomFilename = Math.floor(rng()*0xFFFF).toString(16);
        randomFilename += Math.floor(rng()*0xFFFF).toString(16);
        randomFilename += Math.floor(rng()*0xFFFF).toString(16);
        randomFilename += Math.floor(rng()*0xFFFF).toString(16);
        const s3BucketKey = "/files/" + userId + "/" + randomFilename;
        const expiration = moment().add(5, "minutes").toDate().toISOString();
        const conditions = [
            ["content-length-range", 0, maxSizeMB*1024*1024],
            {"bucket": s3BucketName},
            ["eq", "$key", s3BucketKey],
            ["starts-with", "$Content-Type", "image/"],
            ["starts-with", "$X-Amz-Meta-Original-Filename", ""],
        ];

        const data = await S3.createPresignedPost({
            Bucket: s3BucketName,
            Fields: { key: s3BucketKey },
            expiration: expiration,
            Conditions: conditions,
        });

        data.properties = {};
        data.properties.expiration = expiration;
        data.properties.conditions = conditions;

        const response = {
            // "cookies" : ["cookie1", "cookie2"],
            "isBase64Encoded": false,
            "statusCode": 200,
            "headers": { "Content-Type": "application/json" },
            "body": JSON.stringify(data)
        };

        const tmp = response;
        tmp.body = data;
        console.log("RESPONSE:", JSON.stringify(tmp, null, 2));
        return response;
    }
    catch (err) {
        console.error("Error in index.js::exports.handler():", err);
        return {
            // "cookies" : ["cookie1", "cookie2"],
            "isBase64Encoded": false,
            "statusCode": 500,
            "headers": { "Content-Type": "application/json" },
            "body": JSON.stringify({
                error: "Error in index.js::exports.handler()"
            })
        };
    }
};