import { task } from "hardhat/config"

/**
 Example:
 hardhat deploy:zktls-account \
 --contractName SimpleZkTlsAccount \
 --network localhost
 */
task("deploy:zktls-simple-account", "Deploy ZkTls Simple Account Contract")
	.addParam<string>("zkTlsGateway", "ZkTls Gateway Contract Address")
	.addParam<string>("paymentToken", "Payment Token Contract Address")
	.setAction(async (taskArgs, { ethers }) => {
		const contract = await ethers.deployContract("SimpleZktlsAccount", [
			taskArgs.zkTlsGateway,
			taskArgs.paymentToken,
		])

		console.log(`Account Address: ${contract.add}`)

		// console.log(`Transaction Hash: ${mintTrx.hash}`)
		// await mintTrx.wait(2)
		console.log("Transaction confirmed")
	})
