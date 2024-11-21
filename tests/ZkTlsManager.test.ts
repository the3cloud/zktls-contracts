import { expect } from "chai"
import { deployments, ethers, upgrades } from "hardhat"
import { ZkTlsManager } from "../typechain-types"
import { setupFixture } from "./fixtures/setup" // Import the setupFixture

describe("ZkTlsManager", function () {
	let contracts: any
	let data: any
	let functions: any
	let signers: any

	before(async () => {
		const fixture = await setupFixture()
		contracts = fixture.contracts
		data = fixture.data
		functions = fixture.functions
		signers = fixture.signers
	})

	describe("Deployment", () => {
		it("should set the correct token wei per bytes and owner", async () => {
			// await functions.printContractAddress(contracts);
			// await functions.printSigners(signers);
			expect(await contracts.zkTlsManager.accountBeacon()).to.equal(await contracts.accountBeacon.getAddress())
			expect(await contracts.zkTlsManager.owner()).to.equal(signers.owner.address)
		})

		it("should create a new account", async () => {
			const tx = await contracts.zkTlsManager.createAccount(
				await contracts.zkTlsGateway.getAddress(),
				await contracts.responseHandler2.getAddress(),
				await signers.applicationUser1.getAddress()
			)
			const receipt = await tx.wait() // Wait for the transaction to be mined
			const logs = receipt.logs.map((log: any) => contracts.zkTlsManager.interface.parseLog(log))
			const events = logs.filter((e: any) => e?.name === "SimpleZkTlsAccountCreated")
			// Check if the event was emitted: gatewayId:1, created gateway address and newly created beacon proxy address
			expect(events.length).to.equal(1)
			expect(events[0].args.gateway).to.equal(await contracts.zkTlsGateway.getAddress())
			expect(events[0].args.beaconProxy).not.to.equal(await contracts.accountBeaconProxy.getAddress())

			// check if the proxy is ready to use by calling VERSION
			expect(await contracts.accountBeaconProxy.VERSION()).to.equal(1)
		})
	})
})
