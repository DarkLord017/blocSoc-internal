const alpacaRequest = Functions.makeHttpRequest({
    url: "https://paper-api.alpaca.markets/v2/positions/TSLA",
    headers: {
        accept: 'application/json',
        'APCA-API-KEY-ID': secrets.alpacaKey,
        'APCA-API-SECRET-KEY': secrets.alpacaSecret
    }
})

const [response] = await Promise.all([
    alpacaRequest,
])

const portfolioBalance = response.data.market_value

console.log(`Alpaca Portfolio Balance: $${portfolioBalance}`)

return Functions.encodeUint256(Math.round(portfolioBalance * 1000000000000000000))