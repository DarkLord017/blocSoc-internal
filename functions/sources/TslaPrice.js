if (!secrets.alpacaKey || !secrets.alpacaSecret) {
    throw Error("Need Alpaca keys.");
}

const apiResponse = await Functions.makeHttpRequest({
    url: "https://data.alpaca.markets/v2/stocks/TSLA/quotes/latest",
    headers: {
        'APCA-API-KEY-ID': secrets.alpacaKey,
        'APCA-API-SECRET-KEY': secrets.alpacaSecret
    }
});

if (apiResponse.error) {
    throw Error(`Request Failed: ${apiResponse.error}`);
}

const { data } = apiResponse;

if (!data || !data.quote) {
    throw Error("Invalid response structure from Alpaca.");
}

let latestPrice = data.quote.ap;

if (latestPrice === 0) {
    latestPrice = data.quote.bp;
}

if (latestPrice === 0) {
    throw Error("Both ask price and bid price are zero. No valid price available.");
}

console.log(`The latest price of TSLA is $${latestPrice}`);

return Functions.encodeUint256(Math.round(latestPrice * 1e8));
