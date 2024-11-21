import { expect } from "chai"
import { deployments, ethers, upgrades } from "hardhat"
import { ZkTlsGateway, IERC20, IZkTlsResponseHandler } from "../typechain-types"
import { setupFixture } from "./fixtures/setup" // Import the setupFixture
import { LogDescription, Signer } from "ethers"

describe("ZkTlsGateway", () => {
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

	const responseHandlerGasEstimation = async (
		responseHandler: IZkTlsResponseHandler,
		requestId: string,
		requestHash: string,
		responseBytes: any
	) => {
		// const gasEstimate = await responseHandler.handleResponse.estimateGas(
		//   requestId,
		//   requestHash,
		//   responseBytes
		// );
		const gasEstimate = await contracts.accountBeaconProxy.estimateCallbackGas(responseBytes.length)
		console.log("estimate gas: ", gasEstimate) // 1516093n for none-loop, 3506127n for 5000-iterations
		return gasEstimate
	}

	const computeRequestId = (gatewayAddress: string, accountProxyAddress: string, gatewayNonce: number) =>
		ethers.keccak256(
			ethers.solidityPacked(
				["address", "address", "uint256"],
				[gatewayAddress, accountProxyAddress, gatewayNonce]
			)
		)

	const computeRequestHash = (
		remote: string,
		serverName: string,
		encryptedKey: string,
		requestTemplateHash: any,
		fields: any,
		values: any
	) => {
		return ethers.keccak256(
			ethers.AbiCoder.defaultAbiCoder().encode(
				["string", "string", "bytes", "bytes32", "uint64[]", "bytes[]"],
				[remote, serverName, encryptedKey, requestTemplateHash, fields, values]
			)
		)
	}

	const testRequestTLSCall = async (requestInfo: any, feeConfig: any) => {
		const requestBytes = requestInfo.templatedRequest.values.reduce(
			(acc: number, value: any) => acc + value.length,
			0
		)
		const estimatedFee = await contracts.zkTlsGateway.estimateFee(requestBytes, feeConfig.maxResponseBytes)
		// callback gas estimation
		const nonce = 0
		const expectedRequestId = computeRequestId(
			await contracts.zkTlsGateway.getAddress(),
			await contracts.accountBeaconProxy.getAddress(),
			nonce
		)
		const expectedRequestHash = computeRequestHash(
			requestInfo.remote,
			requestInfo.serverName,
			feeConfig.encryptedKey,
			requestInfo.templatedRequest.requestTemplateHash,
			requestInfo.templatedRequest.fields,
			requestInfo.templatedRequest.values
		)
		const paidGas = await responseHandlerGasEstimation(
			contracts.responseHandler,
			expectedRequestId,
			expectedRequestHash,
			data.responseBytes
		)
		// // test beacon proxy
		const tx = await contracts.accountBeaconProxy
			.connect(signers.applicationUser1)
			.requestTLSCallTemplate(
				data.provers.prover1.proverId,
				requestInfo.remote,
				requestInfo.serverName,
				feeConfig.encryptedKey,
				false,
				requestInfo.templatedRequest,
				estimatedFee,
				feeConfig.maxResponseBytes,
				{ value: paidGas * 2n }
			)

		return { requestBytes, expectedRequestId, expectedRequestHash, estimatedFee, tx }
	}

	describe("Deployment", async () => {
		it("should constracts with correct configuration", async () => {
			expect(await contracts.zkTlsGateway.manager()).to.equal(await contracts.zkTlsManager.getAddress())
			expect(await contracts.zkTlsGateway.paymentToken()).to.equal(await contracts.paymentToken.getAddress())
		})
	})

	describe("Request TLS Call", () => {
		it("should create a request and emit events", async () => {
			const requestInfo = data.requestInfo
			const { requestBytes, expectedRequestId, estimatedFee, tx } = await testRequestTLSCall(
				data.requestInfo,
				data.feeConfig
			)

			// test fee estimation
			expect(estimatedFee).to.equal(
				(BigInt(requestBytes) + BigInt(data.feeConfig.maxResponseBytes)) * BigInt(data.tokenWeiPerBytes)
			)

			const receipt = await tx.wait()
			const logs = receipt?.logs.map((log: any) => contracts.zkTlsGateway.interface.parseLog(log))
			// console.log("logs: ", logs);
			// test logs: RequestTLSCallBegin & RequestTLSCallTemplateField
			logs.forEach((log: any) => {
				log?.name === "RequestTLSCallBegin" &&
					expect(log.args.requestId).to.equal(expectedRequestId) &&
					expect(log.args.requestTemplateHash).to.equal(
						ethers.hexlify(requestInfo.templatedRequest.requestTemplateHash)
					) &&
					expect(log.args.responseTemplateHash).to.equal(
						ethers.hexlify(requestInfo.templatedRequest.responseTemplateHash)
					) &&
					expect(log.args.remote).to.equal(requestInfo.remote) &&
					expect(log.args.serverName).to.equal(requestInfo.serverName) &&
					expect(log.args.encryptedKey).to.equal(data.feeConfig.encryptedKey) &&
					expect(log.args.maxResponseBytes).to.equal(data.feeConfig.maxResponseBytes)
			})
		})
	})

	describe("Delivery Response", () => {
		it("should process a response and emit GasUsed", async () => {
			const requestInfo = data.requestInfo
			console.log("contract zktls proxy address: (msg.sender)", await contracts.accountBeaconProxy.getAddress())
			const { requestBytes, expectedRequestId, expectedRequestHash, estimatedFee, tx } = await testRequestTLSCall(
				requestInfo,
				data.feeConfig
			)
			await tx.wait()
			const responseTx = await contracts.zkTlsGateway.deliveryResponse(
				expectedRequestId,
				expectedRequestHash,
				data.responseBytes,
				"0x" // an emptry bytes
			)
			const responseReceipt = await responseTx.wait()
			// console.log("responseReceipt: ", responseReceipt.logs);
			const gatewayLogs = responseReceipt.logs.map((log: any) => contracts.zkTlsGateway.interface.parseLog(log))
			const responseHandlerLogs = responseReceipt.logs.map((log: any) =>
				contracts.responseHandler.interface.parseLog(log)
			)
			console.log("gatewayLogs: ", gatewayLogs)
			console.log("responseHandlerLogs: ", responseHandlerLogs)
			// test logs: RequestTLSCallEnd
		})
	})
})
