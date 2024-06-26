import fetch from 'node-fetch';

// const fs = require("fs")
// const { Location, ReturnType, CodeLanguage } = require("@chainlink/functions-toolkit")
// const { simulateScript, decodeResult } = require("@chainlink/functions-toolkit")

// Replace with your own API key and secret
const API_KEY = 'PKGSU2AKQCTFJHNVB9AQ';
const API_SECRET = 'oCxTw7J8OuX5CwNRtd9NR1ooc0uGRDmfEcg3cW0v';
const BASE_URL = 'https://data.alpaca.markets'; // Data API URL


// const requestConfig = {
//     // String containing the source code to be executed
//     source: fs.readFileSync("./functions/sources/alpacaBalance.js").toString(),
//     //source: fs.readFileSync("./API-request-example.js").toString(),
//     // Location of source code (only Inline is currently supported)
//     codeLocation: Location.Inline,
//     // Optional. Secrets can be accessed within the source code with `secrets.varName` (ie: secrets.apiKey). The secrets object can only contain string values.
//     secrets: { alpacaKey: process.env.ALPACA_KEY ?? "", alpacaSecret: process.env.ALPACA_SECRET ?? "" },
//     // Optional if secrets are expected in the sourceLocation of secrets (only Remote or DONHosted is supported)
//     secretsLocation: Location.DONHosted,
//     // Args (string only array) can be accessed within the source code with `args[index]` (ie: args[0]).
//     args: [],
//     // Code language (only JavaScript is currently supported)
//     codeLanguage: CodeLanguage.JavaScript,
//     // Expected type of the returned value
//     expectedReturnType: ReturnType.uint256,
// }


// const alpacaRequest = Functions.makeHttpRequest({
//     url: url,
//     headers: {
//         'APCA-API-KEY-ID': API_KEY,
//         'APCA-API-SECRET-KEY': API_SECRET
//     }
//   })
  
//   const [response] = await Promise.all([
//     alpacaRequest,
//   ])
  
//   const portfolioBalance = response.data.portfolio_value
//   console.log(`Alpaca Portfolio Balance: $${portfolioBalance}`)
  // The source code MUST return a Buffer or the request will return an error message
  // Use one of the following functions to convert to a Buffer representing the response bytes that are returned to the consumer smart contract:
  // - Functions.encodeUint256
  // - Functions.encodeInt256
  // - Functions.encodeString
  // Or return a custom Buffer for a custom byte encoding
//   return Functions.encodeUint256(Math.round(portfolioBalance * 1000000000000000000))

// async function main() {
//     const { responseBytesHexstring, errorString, capturedTerminalOutput } = await simulateScript(requestConfig)
//     console.log(`${capturedTerminalOutput}\n`)
//     if (responseBytesHexstring) {
//         console.log(
//             `Response returned by script during local simulation: ${decodeResult(
//                 responseBytesHexstring,
//                 requestConfig.expectedReturnType
//             ).toString()}\n`
//         )
//     }
//     if (errorString) {
//         console.log(`Error returned by simulated script:\n${errorString}\n`)
//     }
// }

// main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });

// // Function to get latest price
async function getLatestPrice(symbol) {
  const url = `${BASE_URL}/v2/stocks/${symbol}/quotes/latest`;
  const headers = {
    'APCA-API-KEY-ID': API_KEY,
    'APCA-API-SECRET-KEY': API_SECRET
  };

  try {
    const response = await fetch(url, { headers });
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    return data.quote.ap;
  } catch (error) {
    console.error(`Error fetching latest price for ${symbol}: ${error.message}`);
  }
}

// Replace 'TSLA' with your desired stock symbol
const symbol = 'TSLA';
const url = `${BASE_URL}/v2/stocks/${symbol}/quotes/latest`;

getLatestPrice(symbol).then(latestPrice => {
  if (latestPrice !== undefined) {
    console.log(`The latest price of ${symbol} is $${latestPrice}`);
  }
});
