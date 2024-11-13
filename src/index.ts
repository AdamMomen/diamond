import { createPublicClient, createWalletClient, http, parseAbi } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { foundry } from "viem/chains";
import "dotenv/config";

// Load from .env
const PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;
const DIAMOND_ADDRESS = process.env.DIAMOND_ADDRESS as `0x${string}`;
const RPC_URL = "http://127.0.0.1:8545"; // anvil

if (!PRIVATE_KEY || !DIAMOND_ADDRESS) {
  throw new Error("Missing environment variables. Check your .env file");
}

// Anvil local chain
const localChain = {
  ...foundry,
  id: 31337,
  name: "Foundry Local",
  network: "foundry",
  rpcUrls: {
    default: { http: [RPC_URL] },
    public: { http: [RPC_URL] },
  },
};

// Create clients with correct chain
const publicClient = createPublicClient({
  chain: localChain,
  transport: http(),
});

const walletClient = createWalletClient({
  chain: localChain,
  transport: http(),
});

// Create account from private key
const account = privateKeyToAccount(PRIVATE_KEY);
console.log("Account:\n", account);

async function main() {
  try {
    // Increment count
    const hash = await walletClient.writeContract({
      address: DIAMOND_ADDRESS as `0x${string}`,
      chain: localChain,
      abi: parseAbi(["function increment() external"]),
      functionName: "increment",
      account,
    });
    console.log("Increment tx:", hash);

    // Read count
    const count = await publicClient.readContract({
      address: DIAMOND_ADDRESS as `0x${string}`,
      abi: parseAbi([
        "function getCount() view returns (uint256)",
        "function increment() external",
      ]),
      functionName: "getCount",
    });
    console.log("Current count:", count);
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
