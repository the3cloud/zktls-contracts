import { ethers } from "hardhat"

interface ErrorSelectors {
	[key: string]: string
}

async function getAllErrorSelectors(): Promise<void> {
	// SimpleZkTlsAccount Custom Errors
	const customErrors: ErrorSelectors = {
		// SimpleZkTlsAccount errors
		UnauthorizedAccess: ethers.id("UnauthorizedAccess()").slice(0, 10),
		ResponseExceedsMaxSize: ethers.id("ResponseExceedsMaxSize()").slice(0, 10),
		InvalidProver: ethers.id("InvalidProver()").slice(0, 10),
		InvalidRequestHash: ethers.id("InvalidRequestHash()").slice(0, 10),
		InvalidProof: ethers.id("InvalidProof()").slice(0, 10),

		// OpenZeppelin Standard Errors
		OwnableUnauthorizedAccount: ethers.id("OwnableUnauthorizedAccount(address)").slice(0, 10),
		ERC1155InsufficientBalance: ethers
			.id("ERC1155InsufficientBalance(address,uint256,uint256,uint256)")
			.slice(0, 10),
		ERC1155InvalidSender: ethers.id("ERC1155InvalidSender(address)").slice(0, 10),
		ERC1155InvalidReceiver: ethers.id("ERC1155InvalidReceiver(address)").slice(0, 10),
		ERC1155MissingApprovalForAll: ethers.id("ERC1155MissingApprovalForAll(address,address)").slice(0, 10),
		EnforcedPause: ethers.id("EnforcedPause()").slice(0, 10),
		ExpectedPause: ethers.id("ExpectedPause()").slice(0, 10),
		ERC1155InvalidApprover: ethers.id("ERC1155InvalidApprover(address)").slice(0, 10),
		ERC1155InvalidOperator: ethers.id("ERC1155InvalidOperator(address)").slice(0, 10),
		InitializableAlreadyInitialized: ethers.id("InitializableAlreadyInitialized()").slice(0, 10),
		InitializablePaused: ethers.id("InitializablePaused()").slice(0, 10),
	}

	console.log("Error Selectors:")
	for (const [name, selector] of Object.entries(customErrors)) {
		console.log(`${name}: ${selector}`)
	}
}

// Execute if running directly
if (require.main === module) {
	getAllErrorSelectors()
		.then(() => process.exit(0))
		.catch((error: Error) => {
			console.error(error)
			process.exit(1)
		})
}

export { getAllErrorSelectors, type ErrorSelectors }
