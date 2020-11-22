const { handler } = require("./index");

const event = {
    "Records": [
        {
            "eventVersion": "2.1",
            "eventSource": "aws:s3",
            "awsRegion": "eu-north-1",
            "eventTime": "2020-11-21T12:12:09.680Z",
            "eventName": "ObjectCreated:Post",
            "userIdentity": {
                "principalId": "AWS:AROAR2REE2Q4ZYKSBMQ5E:generate_signed_upload_url_lambda"
            },
            "requestParameters": {
                "sourceIPAddress": "10.1.2.3"
            },
            "responseElements": {
                "x-amz-request-id": "754A672634F497A3",
                "x-amz-id-2": "1Nx4eIztTuEoKdv8Na5BtAgeMJCde3g2euRcPziYeGrboeVQCi8lJNRX81rBkGs1pDgiGbdykq/f4IoiRX8w2577itNyXYzcuduaCUnl3rk="
            },
            "s3": {
                "s3SchemaVersion": "1.0",
                "configurationId": "tf-s3-lambda-20201121121135034600000001",
                "bucket": {
                    "name": "photos-inbox-42c23688a3de6ce2",
                    "ownerIdentity": {
                        "principalId": "A3KUT7MSH6OX8S"
                    },
                    "arn": "arn:aws:s3:::photos-inbox-42c23688a3de6ce2"
                },
                "object": {
                    "key": "/files/Z29vZ2xlLW9hdXRoMnwxMDQ4MzM1MTM5NjE4MDU2MDEzMzE%3D/cd6481b183faba1f",
                    "size": 198330,
                    "eTag": "ec268aa01d809a680b85a2d51f678d72",
                    "sequencer": "005FB9041A256B06C1"
                }
            }
        }
    ]
};
const promise = handler(event);
promise.then((response) => {
    console.debug(JSON.stringify(response, null, 2));
}).catch(err => {
    console.error(err);
});