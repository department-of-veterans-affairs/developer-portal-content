const axios = require('axios');
const fs = require('fs');
const jwt = require('njwt');
const uuid = require('uuid');

const clientId = process.argv[2];
const keyPath = process.argv[3];
const lpbHost = process.argv[4];

const claims = { aud: 'https://deptva-eval.okta.com/oauth2/ausg95zxf6dFPccy02p7/v1/token', iss: clientId, sub: clientId, jti: uuid.v1() }
const privateKey = fs.readFileSync(keyPath, 'utf8');
const token = jwt.create(claims, privateKey, 'RS256')
token.setExpiration(new Date().getTime() + 60*1000)
console.log('OKTA Token: ', token.compact());
const oktaToken = token.compact();

const bearerEndpoint = `https://${lpbHost}/oauth2/consumer-management/system/v1/token`;
const headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
};
const data = {
    'grant_type': 'client_credentials',
    'client_assertion_type': 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
    'client_assertion': oktaToken,
    'scope': 'provider.read provider.write',
};

axios.post(bearerEndpoint, new URLSearchParams(data).toString(), {headers: headers})
    .then(response => {
        console.log(response.data);
        console.log('Bearer token: ', response.data.access_token);
        console.log(response);
        fs.writeFileSync('./bearer.token', response.data.access_token);
    });
