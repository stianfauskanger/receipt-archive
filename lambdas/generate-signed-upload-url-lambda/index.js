const AWS = require('aws-sdk');
const seedrandom = require('seedrandom');
const moment = require("moment");

const rng = seedrandom();

const awsRegion = process.env.AWS_REGION;
AWS.config.update({region: awsRegion});

const S3 = new AWS.S3({apiVersion: '2006-03-01'});

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

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

    const data = S3.createPresignedPost({
        Bucket: s3BucketName,
        Fields: { key: s3BucketKey },
        expiration: expiration,
        Conditions: conditions,
    });

    data.properties = {};
    data.properties.expiration = expiration;
    data.properties.conditions = conditions;

    return {
        statusCode: 200,
        body: data,
    };
};

const event = {
    "version": "2.0",
    "routeKey": "POST /test",
    "rawPath": "/prod/test",
    "rawQueryString": "",
    "headers": {
        "accept": "*/*",
        "accept-encoding": "gzip, deflate, br",
        "authorization": "Bearer eyJhb......GciOi==",
        "cache-control": "no-cache",
        "content-length": "15975",
        "content-type": "multipart/form-data; boundary=--------------------------786694497113313193448559",
        "host": "kx91lo01l5.execute-api.eu-north-1.amazonaws.com",
        "postman-token": "783fbea1-93d3-4dc6-8225-175fd26aba68",
        "user-agent": "PostmanRuntime/7.26.8",
        "x-amzn-trace-id": "Root=1-5f9b2632-7898868f26b954431ec37404",
        "x-forwarded-for": "10.1.2.3",
        "x-forwarded-port": "443",
        "x-forwarded-proto": "https"
    },
    "requestContext": {
        "accountId": "258466227301",
        "apiId": "ka92lo105l",
        "authorizer": {
            "jwt": {
                "claims": {
                    "aud": "[https://some.app.example.com https://some-tenant.eu.auth0.com/userinfo]",
                    "azp": "kjgk6UGYKJG&gu&gukGYku&gukGhjhgg",
                    "exp": "1604085585",
                    "iat": "1603999185",
                    "iss": "https://some-tenant.eu.auth0.com/",
                    "permissions": "[https://some.app.example.com/can-use-app]",
                    "scope": "openid profile email https://some.app.example.com/can-use-app",
                    "sub": "google-oauth2|542897963746391768377"
                },
                "scopes": [
                    "openid",
                    "profile",
                    "email",
                    "https://some.app.example.com/can-use-app"
                ]
            }
        },
        "domainName": "kx91lo01l5.execute-api.eu-north-1.amazonaws.com",
        "domainPrefix": "kx91lo01l5",
        "http": {
            "method": "POST",
            "path": "/prod/test",
            "protocol": "HTTP/1.1",
            "sourceIp": "10.1.2.3",
            "userAgent": "PostmanRuntime/7.26.8"
        },
        "requestId": "VMLn2ibAgi0EP-Q=",
        "routeKey": "POST /test",
        "stage": "prod",
        "time": "29/Oct/2020:20:29:38 +0000",
        "timeEpoch": 1604003378144
    },
    "body": "Q29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOwpDb250ZW50LVR5cGU6IHRleHQvcGxhaW4KCkhlbGxvIHdvcmxkCg==",
    "isBase64Encoded": true
};
const promise = exports.handler(event);
promise.then((response) => {
    console.log(JSON.stringify(response, null, 2));
}).catch(err => {
    console.error(err);
});