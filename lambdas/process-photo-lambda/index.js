exports.handler = async (event) => {
    console.debug('EVENT:', JSON.stringify(event, null, 2));
    const { Records: [ { s3: { bucket: { name, arn }, object: { key, size } } } ] } = event;
    const s3ref = { bucket: { arn, name }, object: { key, size } };
    const response = {
        // "cookies" : ["cookie1", "cookie2"],
        "isBase64Encoded": false,
        "statusCode": 200,
        "headers": { "Content-Type": "application/json" },
        "body": JSON.stringify(s3ref)
    };
    console.debug("RESPONSE:", response);
    console.debug("s3ref:", s3ref);
    return response;
};
