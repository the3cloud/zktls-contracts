const { ethers, upgrades } = require("hardhat")

async function main() {
	// deploy implementation for v1
	const BeaconProxyPatternV1 = await ethers.getContractFactory("BeaconProxyPatternV1")
	// deploy the beacon
	const beacon = await upgrades.deployBeacon(BeaconProxyPatternV1, { unsafeAllow: ["constructor"] })
	await beacon.deployed()
	console.log(`Beacon with Beacon Proxy Pattern V1 as implementation is deployed to address: ${beacon.address}`)

	// proxy1 for v1
	const beaconProxy1 = await upgrades.deployBeaconProxy(beacon.address, BeaconProxyPatternV1, [])
	let versionAwareContractName = await beaconProxy1.getContractNameWithVersion()
	console.log(`Proxy Pattern and Version from Proxy 1 Implementation: ${versionAwareContractName}`)

	// proxy2 for v1
	const beaconProxy2 = await upgrades.deployBeaconProxy(beacon.address, BeaconProxyPatternV1, [])
	versionAwareContractName = await beaconProxy2.getContractNameWithVersion()
	console.log(`Proxy Pattern and Version from Proxy 2 Implementation: ${versionAwareContractName}`)

	// deploy implementation for v2
	const BeaconProxyPatternV2 = await ethers.getContractFactory("BeaconProxyPatternV2")
	// upgrade the beacon to v2
	const upgradedBeacon = await upgrades.upgradeBeacon(beacon.address, BeaconProxyPatternV2, {
		unsafeAllow: ["constructor"],
	})
	console.log(`Beacon upgraded with Beacon Proxy Pattern V2 as implementation at address: ${upgradedBeacon.address}`)

	// check the proxy1 for v2
	versionAwareContractName = await beaconProxy1.getContractNameWithVersion()
	console.log(`Proxy Pattern and Version from Proxy 1 Implementation: ${versionAwareContractName}`)
	// check the proxy2 for v2
	versionAwareContractName = await beaconProxy2.getContractNameWithVersion()
	console.log(`Proxy Pattern and Version from Proxy 2 Implementation: ${versionAwareContractName}`)
	versionAwareContractName = await beaconProxy1.versionAwareContractName()
	console.log(`Proxy Pattern and Version from Proxy 1 Storage: ${versionAwareContractName}`)
	versionAwareContractName = await beaconProxy2.versionAwareContractName()
	console.log(`Proxy Pattern and Version from Proxy 2 Storage: ${versionAwareContractName}`)

	const initTx = await beaconProxy1.initialize()
	const receipt = await initTx.wait()
	versionAwareContractName = await beaconProxy1.versionAwareContractName()
	console.log(`Proxy Pattern and Version from Proxy 1 Storage: ${versionAwareContractName}`)
	versionAwareContractName = await beaconProxy2.versionAwareContractName()
	console.log(`Proxy Pattern and Version from Proxy 2 Storage: ${versionAwareContractName}`)
}

main().catch((error) => {
	console.error(error)
	process.exitCode = 1
})
