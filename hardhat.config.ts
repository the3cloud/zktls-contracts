import "@nomicfoundation/hardhat-toolbox"
import "@openzeppelin/hardhat-upgrades"
import * as dotenv from "dotenv"
dotenv.config()

import { HardhatUserConfig } from "hardhat/config"

import "hardhat-deploy"
import "@nomiclabs/hardhat-solhint"
import "hardhat-deploy"
import "solidity-coverage"

import "dotenv/config"

import "./tasks/utils/accounts"
import "./tasks/utils/balance"
import "./tasks/utils/block-number"
import "./tasks/utils/send-eth"

import "./tasks/erc721/mint"
import "./tasks/erc721/base-uri"
import "./tasks/erc721/contract-uri"

import "./tasks/erc20/mint"

import "./tasks/erc1155/mint"
import "./tasks/erc1155/base-uri"
import "./tasks/erc1155/contract-uri"

const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL || "https://eth-mainnet.g.alchemy.com/v2/your-api-key"
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "https://eth-sepolia.g.alchemy.com/v2/your-api-key"
const HOLESKY_RPC_URL = process.env.HOLESKY_RPC_URL || "https://eth-holesky.g.alchemy.com/v2/your-api-key"
const MATIC_RPC_URL = process.env.MATIC_RPC_URL || "https://polygon-mainnet.g.alchemy.com/v2/your-api-key"
const MUMBAI_RPC_URL = process.env.MUMBAI_RPC_URL || "https://polygon-mumbai.g.alchemy.com/v2/v3/your-api-key"

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "api-key"
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY || "api-key"

// Import MNEMONIC or single private key
const MNEMONIC = process.env.MNEMONIC || "your mnemonic"
const PRIVATE_KEY = process.env.PRIVATE_KEY

const config: HardhatUserConfig = {
	defaultNetwork: "hardhat",
	networks: {
		mainnet: {
			url: MAINNET_RPC_URL,
			accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
		},
		hardhat: {
			// // If you want to do some forking, uncomment this
			// forking: {
			//   url: MAINNET_RPC_URL
			// }
		},
		localhost: {
			url: "http://127.0.0.1:8545",
		},
		sepolia: {
			url: SEPOLIA_RPC_URL,
			accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
		},
		holesky: {
			url: HOLESKY_RPC_URL,
			accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
		},
		matic: {
			url: MATIC_RPC_URL,
			accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
		},
		mumbai: {
			url: MUMBAI_RPC_URL,
			accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
		},
		goerli: {
			url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
			accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
		},
	},
	etherscan: {
		// Your API key for Etherscan
		// Obtain one at https://etherscan.io/
		apiKey: {
			mainnet: ETHERSCAN_API_KEY,
			sepolia: ETHERSCAN_API_KEY,
			holesky: ETHERSCAN_API_KEY,
			// Polygon
			polygon: POLYGONSCAN_API_KEY,
			polygonMumbai: POLYGONSCAN_API_KEY,
		},
		customChains: [
			{
				network: "holesky",
				chainId: 17000,
				urls: {
					apiURL: "https://api-holesky.etherscan.io/api",
					browserURL: "https://holesky.etherscan.io",
				},
			},
		],
	},
	namedAccounts: {
		deployer: {
			default: 0, // here this will by default take the first account as deployer
		},
		owner: {
			default: 1, // here this will by default take the second account as owner
		},
	},
	solidity: {
		compilers: [
			{
				version: "0.8.28",
				settings: {
					viaIR: true,
				},
			},
		],
	},
	sourcify: {
		enabled: false,
	},
}

export default config
