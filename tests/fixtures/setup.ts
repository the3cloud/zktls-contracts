import { deployments, ethers, upgrades } from "hardhat"
import { IZkTlsResponseHandler } from "../../typechain-types"

const printContractAddress = async (contracts: { [key: string]: any }) => {
	for (const [key, contract] of Object.entries(contracts)) {
		console.log(`${key}: ${await contract.getAddress()}`)
	}
}

const printSigners = async (signers: { [key: string]: any }) => {
	for (const [key, signer] of Object.entries(signers)) {
		console.log(`${key}: ${signer.address}`)
	}
}

export const setupFixture = deployments.createFixture(async () => {
	await deployments.fixture()
	// basic setup constant
	const callbackBaseGas = ethers.parseUnits("2000", "gwei")
	const tokenWeiPerBytes = ethers.parseUnits("1", "gwei")
	// prover id
	const prover1Id = ethers.keccak256(ethers.toUtf8Bytes("prover1"))
	const prover1VKey = ethers.keccak256(ethers.toUtf8Bytes("prover1-vkey"))
	// set up signers
	const [owner, deployer, accountBeaconAdmin, applicationUser1, applicationUser2, feeReceiver] =
		await ethers.getSigners()
	const paymentToken = await ethers.deployContract("BasicERC20", ["Payment Token", "PT", owner.address])
	const verifier = await ethers.deployContract("SP1MockVerifier")
	const responseHandler = await ethers.deployContract("MockResponseHandler")
	const responseHandler2 = await ethers.deployContract("MockResponseHandler")
	// deploy ZkTlsManager
	const ZkTlsManagerFactory = await ethers.getContractFactory("ZkTlsManager")
	const zkTlsManager = await upgrades.deployProxy(
		ZkTlsManagerFactory,
		[
			callbackBaseGas,
			tokenWeiPerBytes,
			await feeReceiver.getAddress(),
			ethers.ZeroAddress, // default account beacon
			await paymentToken.getAddress(),
			owner.address,
		],
		{ initializer: "initialize" }
	)
	await zkTlsManager.waitForDeployment()
	// deploy ZkTlsGateway
	const zkTlsGatewayFactory = await ethers.getContractFactory("ZkTlsGateway")
	const zkTlsGateway = await upgrades.deployProxy(zkTlsGatewayFactory, [
		await zkTlsManager.getAddress(),
		await paymentToken.getAddress(),
		owner.address,
	])
	await zkTlsGateway.waitForDeployment()

	// Deploy the implementation contract
	const accountContract = await ethers.getContractFactory("SimpleZkTlsAccount")
	const accountBeacon = await upgrades.deployBeacon(accountContract)
	await accountBeacon.waitForDeployment()
	console.log("accountBeacon deployed to:", await accountBeacon.getAddress())
	// Deploy the beacon with the implementation address
	const accountBeaconProxy = await upgrades.deployBeaconProxy(await accountBeacon.getAddress(), accountContract, [
		await zkTlsManager.getAddress(),
		await zkTlsGateway.getAddress(),
		await paymentToken.getAddress(),
		await responseHandler.getAddress(),
		await applicationUser1.getAddress(),
	])
	await accountBeaconProxy.waitForDeployment()
	console.log("Beacon Proxy deployed to:", await accountBeaconProxy.getAddress())
	// set prover in zkTlsGateway
	await zkTlsGateway.setProver(prover1Id, await verifier.getAddress(), prover1VKey)
	// set beacon to zkTlsManager
	await zkTlsManager.setAccountBeacon(await accountBeacon.getAddress())
	await zkTlsManager.setProxyAccount(await accountBeaconProxy.getAddress(), true)
	// token transfer
	await paymentToken.mint(await accountBeaconProxy.getAddress(), ethers.parseEther("1000000"))
	await owner.sendTransaction({
		to: await accountBeaconProxy.getAddress(),
		value: ethers.parseEther("1"),
	})
	console.log("accountBeaconProxy balance: ", await ethers.provider.getBalance(await accountBeaconProxy.getAddress()))
	console.log(
		"token balance of accountBeaconProxy: ",
		await accountBeaconProxy.getAddress(),
		await paymentToken.balanceOf(await accountBeaconProxy.getAddress())
	)
	// request info and data
	const requestInfo = {
		remote: "https://httpbin.org",
		serverName: "httpbin.org",
		templatedRequest: {
			requestTemplateHash: ethers.randomBytes(32),
			responseTemplateHash: ethers.randomBytes(32),
			fields: [1, 2, 3],
			values: [ethers.randomBytes(32), ethers.randomBytes(32), ethers.randomBytes(32)],
		},
		data: [ethers.randomBytes(32), ethers.randomBytes(32), ethers.randomBytes(32)],
	}
	const feeConfig = {
		fee: ethers.parseEther("4"),
		maxResponseBytes: 1024n * 100n, // 100KB
		encryptedKey: ethers.ZeroHash,
		enableEncryption: false,
	}

	const genRequestId = (gatewayAddress: string, accountAddress: string, gatewayNonce: number) => {
		return ethers.keccak256(
			ethers.solidityPacked(["address", "address", "uint256"], [gatewayAddress, accountAddress, gatewayNonce])
		)
	}

	return {
		contracts: {
			zkTlsGateway,
			zkTlsManager,
			accountBeacon,
			accountBeaconProxy,
			paymentToken,
			verifier,
			responseHandler,
			responseHandler2,
		},
		data: {
			requestInfo,
			feeConfig,
			callbackBaseGas,
			tokenWeiPerBytes,
			responseBytes: ethers.randomBytes(1024 * 60),
			provers: {
				prover1: { proverId: prover1Id, vKey: prover1VKey },
			},
		},
		functions: {
			genRequestId,
			printContractAddress,
			printSigners,
		},
		signers: {
			owner,
			deployer,
			accountBeaconAdmin,
			applicationUser1,
			applicationUser2,
		},
	}
})
