exports.handler = async (event) => {
    console.log('EVENT:', JSON.stringify(event, null, 2));
    const data = { message: "Hello world :)" };
    const response = {
        // "cookies" : ["cookie1", "cookie2"],
        "isBase64Encoded": false,
        "statusCode": 200,
        "headers": { "Content-Type": "application/json" },
        "body": JSON.stringify(data)
    };
    console.log("RESPONSE:", () => {
        const tmp = response;
        tmp.body = data;
        return JSON.stringify(tmp, null, 2);
    });
    return response;
};
