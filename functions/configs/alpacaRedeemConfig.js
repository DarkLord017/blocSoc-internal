const fs = require('fs');
require('dotenv').config();
const { Location, ReturnType, CodeLanguage } = require("@chainlink/functions-toolkit");



const requestConfig = {
    source: fs.readFileSync("./functions/sources/sell.js").toString(),
    codeLocation: Location.Inline,
    secrets: { alpacaKey: process.env.ALPACA_API_KEY, alpacaSecret: process.env.ALPACA_SECRET_KEY },
    secretslocation: Location.DONHosted,
    args: ["2000000000000000"],
    CodeLanguage: CodeLanguage.JavaScript,
    expectedReturnType: ReturnType.uint256,

}

module.exports = requestConfig;
