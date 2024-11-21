# The3Cloud ZkTls Contracts

The core contracts for the3cloud ZkTls.

## Hardhat Configuration

-   [Typechain](https://github.com/dethcrypto/TypeChain) plugin enabled (typescript type bindings for smart contracts)
-   [hardhat-deploy](https://github.com/wighawag/hardhat-deploy) plugin enabled
-   Testing environment configured and operational, with test coverage
-   Prettier and eslint configured for project files and solidity smart contract
-   [Solhint](https://github.com/protofire/solhint) configured for enforcing best practices
-   Github actions workflows prepared for CI/CD

Check the Hardhat documentation for more information.

https://hardhat.org/getting-started/

## Supported Networks

-   Hardhat Network (localhost)
-   Ethereum Sepolia Testnet
-   Ethereum Mainnet (In Progress)

Feel free to add more networks in `hardhat.config.ts` file.

## Hardhat Shorthand

We recommend installing `hh autocomplete` so you can use `hh` shorthand globally.

```shell
npm i -g hardhat-shorthand
```

https://hardhat.org/guides/shorthand.html

### Common Shorthand Commands

-   `hh compile` - to compile smart contract and generate typechain ts bindings
-   `hh test` - to run tests
-   `hh deploy` - to deploy to local network (see options for more)
-   `hh node` - to run a localhost node
-   `hh help` - to see all available commands
-   `hh TABTAB` - to use autocomplete

## Usage

### Setup

#### 1. Install Dependencies

```shell
npm install
```

#### 2. Compile Contracts

```shell
npm run compile
```

#### 3. Environment Setup

Create `.env` file and add your environment variables. You can use `.env.example` as a template.

If you are going to use public network, make sure you include the right RPC provider for that network.

Make sure you include either `MNEMONIC` or `PRIVATE_KEY` in your `.env` file.

#### 1. Deploy Contract

```shell
hh deploy --network sepolia --tags <tag>
hh deploy --network sepolia --tags the3cloudcoin
hh deploy --network sepolia --tags the3cloudinit
```

#### 2. Verify Contract

```shell
hh --network sepolia verify <contract_address> [constructor_args]
```

---

### Testing

#### Run Tests

```shell
hh test ./tests/ZkTlsManager.test.ts
hh test tests/ZkTlsGateway.test.ts
```

#### Run Coverage

```shell
npm run coverage
```

---

### Project Hygiene

#### Prettier - Non Solidity Files

```shell
npm run format:check
npm run format:write
```

#### Lint - Non Solidity Files

```shell
npm run lint:check
npm run lint:fix
```

#### Prettier - Solidity

```shell
npm run sol:format:check
npm run sol:format:write
```

#### Solhint - Enforcing styles and security best practices

```shell
npm run solhint
```

## Deployed Contracts

```sh

```

```
 * Sepolia
 * Token: 0xc7A26aa53B2EBe73F713FD33Eb9c3EF94560C05b
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
```

## Contributing

Guidelines for contributing to the project...

## License

This project is licensed under the MIT License.
