

const contractAddress = "0xfC3A719CE42B10A32F1D98c8F5a7f0B834532301";
const ABI = ["function getPrice() external view returns(uint256)",
    "event RequestVolume ( bytes32 indexed requestId, uint256 volume)"];

var price;

const rpcUrl = "https://eth-sepolia.g.alchemy.com/v2/IwxDLF249rDhcON6Sr0UkwWdeDzV7A0a"

if (!rpcUrl)
    throw new Error(`rpcUrl not provided  - check your environment variables`)

const provider = new ethers.providers.JsonRpcProvider(rpcUrl)

const contract = new ethers.Contract(contractAddress, ABI, provider);

function UpdatePrice() {


    contract.on("RequestVolume", async (requestId, volume) => {
        price = await volume.toString();
        contract.removeAllListeners("RequestVolume");
        console.log(`Price: ${price}`);
        return Functions.encodeUint256(price);
    });


}

UpdatePrice();



// create ethers signer for signing transactions
