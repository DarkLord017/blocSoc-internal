const fs = require('fs');
require('dotenv').config();
const { Location, ReturnType, CodeLanguage } = require("@chainlink/functions-toolkit");

const requestConfig = {
    source: fs.readFileSync("./functions/sources/TslaPrice.js").toString(),
    codeLocation: Location.Inline,
    args: [],
    CodeLanguage: CodeLanguage.JavaScript,
    expectedReturnType: ReturnType.uint256,
}

module.exports = requestConfig;
