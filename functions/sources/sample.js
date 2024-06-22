const http = require('https');

const options = {
    method: 'POST',
    hostname: 'paper-api.alpaca.markets',
    port: null,
    path: '/v2/wallets/whitelists',
    headers: {
        accept: 'application/json',
        'content-type': 'application/json',
        'APCA-API-KEY-ID': 'PKC3KOKYVYKQ2X5MEHTF',
        'APCA-API-SECRET-KEY': 'doTHdKDhjQpKGLoOuRTwEOM1W6k1YnDfv7sg9WNC'
    }
};

const req = http.request(options, function (res) {
    const chunks = [];

    res.on('data', function (chunk) {
        chunks.push(chunk);
    });

    res.on('end', function () {
        const body = Buffer.concat(chunks);
        console.log(body.toString());
    });
});

req.write(JSON.stringify({ address: '0x7358D4CDF1c468aA018ec41ddD98b44879a10962', asset: 'USDC/USD' }));
req.end();

console.log(req)