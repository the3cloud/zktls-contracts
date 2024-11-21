import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { ethers, upgrades } from "hardhat"
import { upgradeableDeploy } from "./helper/deployUpgradeable"

/**
 * hh deploy --network sepolia --tags the3cloudinit
 * Sepolia
 * Token:
 * TestResponseHandler deployed at: 0x8bd59647A733D4dE1f74d3e387c0DC33F3DB4cFE
 * ZkTlsManager deployed to: 0x894Bf834bc32c9c3c02c99b372283383a2C28f1F
 * Implementation address: 0x64cD398499c60efb4b052f1bE7cE088551351a1F
 *
 * ZkTlsGateway deployed to: 0x59ddAEb90B6226AF2af803e5Ab13443BbC89E883
 * Implementation address: 0x1802d062F756C77CE35DbEB87306FD19CB832101
 *
 * accountBeacon deployed to: 0x6cb4185c3D8723252650Ce2Cb6b539c5B8c649f3
 * accountBeaconProxy deployed at: 0x8622F295950BB1F09e8984B6e9193AF96cE837dA
 * // implementation address: 0x9f344D2Db02b7c65fdD9C4d116c932D5af5C60C8 // impl for beacon proxy
 *
 * hh --network sepolia verify 0x8622F295950BB1F09e8984B6e9193AF96cE837dA
 * hh --network sepolia verify 0x9f344D2Db02b7c65fdD9C4d116c932D5af5C60C8
 */

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const { deployer } = await hre.getNamedAccounts()
	const owner = deployer
	// basic setup constant
	const callbackBaseGas = ethers.parseUnits("2000", "gwei")
	const tokenWeiPerBytes = ethers.parseUnits("1", "gwei")
	const paymentToken = "0xc7A26aa53B2EBe73F713FD33Eb9c3EF94560C05b"
	const feeReceiver = deployer

	// deploy MockResponseHandler
	// const responseHandler = await ethers.deployContract("MockResponseHandler");
	// console.log("TestResponseHandler deployed at:", responseHandler.target)
	// deploy ZkTlsManager

	// const mgrInitParams = [
	// 	callbackBaseGas,
	// 	tokenWeiPerBytes,
	// 	feeReceiver,
	// 	ethers.ZeroAddress, // default account beacon
	// 	paymentToken,
	// 	deployer // owner
	// ]
	// await upgradeableDeploy(deployer, hre, mgrInitParams, "ZkTlsManager");

	// const zkTlsGatewayInitParams = [
	// 	"0x894Bf834bc32c9c3c02c99b372283383a2C28f1F", // change here
	// 	paymentToken,
	// 	owner,
	// ]
	// await upgradeableDeploy(deployer, hre, zkTlsGatewayInitParams, "ZkTlsGateway");

	// Deploy the beacon with the implementation address
	const accountContract = await ethers.getContractFactory("SimpleZkTlsAccount")
	const accountBeacon = await upgrades.deployBeacon(accountContract)
	await accountBeacon.waitForDeployment()
	console.log("accountBeacon deployed to:", await accountBeacon.getAddress())
	const accountBeaconProxy = await upgrades.deployBeaconProxy(await accountBeacon.getAddress(), accountContract, [
		"0x894Bf834bc32c9c3c02c99b372283383a2C28f1F", // change here, manager address
		"0x59ddAEb90B6226AF2af803e5Ab13443BbC89E883", // change here, gateway address
		paymentToken,
		"0x8622F295950BB1F09e8984B6e9193AF96cE837dA", // change here, response handler address without testing
		// "0x8bd59647A733D4dE1f74d3e387c0DC33F3DB4cFE",// change here, response handler address with testing loop
		owner, // refund address
	])
	await accountBeaconProxy.waitForDeployment()
	console.log("accountBeaconProxy deployed at:", await accountBeaconProxy.getAddress())
}
export default func
func.tags = ["the3cloudinit"]
