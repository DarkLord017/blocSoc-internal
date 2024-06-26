let inputString = args[0]

let number = BigInt(inputString);
let divisor = BigInt("1000000000000000000");
let result = number / divisor;
let remainder = number % divisor;
let resultString = result.toString();
let remainderString = remainder.toString().padStart(18, '0');

const amountTsla = resultString + "." + remainderString;

if (
    secrets.alpacaKey == "" ||
    secrets.alpacaSecret === ""
) {
    throw Error(
        "need alpaca keys"
    )
}

const isStockMarketOpen = Functions.makeHttpRequest({
    url: "https://paper-api.alpaca.markets/v2/clock",
    headers: {
        accept: 'application/json',
        'APCA-API-KEY-ID': secrets.alpacaKey,
        'APCA-API-SECRET-KEY': secrets.alpacaSecret
    }
})

const [responseClock] = await Promise.all([
    isStockMarketOpen,
])

const { is_open } = responseClock.data
if (is_open === "false") {
    console.log("Stock market is closed")
    return Functions.encodeUint256(0)
}




const alpacaSellRequest = Functions.makeHttpRequest({
    method: 'POST',
    url: "https://paper-api.alpaca.markets/v2/orders",
    headers: {
        accept: 'application/json',
        'content-type': 'application/json',
        'APCA-API-KEY-ID': secrets.alpacaKey,
        'APCA-API-SECRET-KEY': secrets.alpacaSecret
    },
    data: {
        side: "sell",
        type: "market",
        time_in_force: "day",
        symbol: "TSLA",
        qty: amountTsla
    }
})

const [response] = await Promise.all([
    alpacaSellRequest,
])

console.log(response.data)
const { status } = response.data

if (status === "accepted" || status === "pending_new" || status === "new" || status === "partially_filled" || status === "filled") {
    return Functions.encodeUint256(Math.round(amountTsla * 1000000000000000000))
}
return Functions.encodeUint256(0)













