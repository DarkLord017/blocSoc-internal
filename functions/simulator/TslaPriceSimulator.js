const { simulateScript, decodeResult } = require("@chainlink/functions-toolkit");
const requestConfig = require("../configs/TslaPriceConfig.js");
async function main() {
    const { responseBytesHexstring, errorString, capturedTerminalOutput } = await simulateScript(requestConfig);
    if (responseBytesHexstring) {
        console.log(`Response: ${decodeResult(responseBytesHexstring, requestConfig.expectedReturnType).toString()}`)
    }
    if (errorString) {
        console.log(`Error: ${errorString}`)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});