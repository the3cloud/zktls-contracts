# Load environment variables from .env file
include .env_anvil
export

# default variables if env is not set.
DEPLOY_CONFIG ?= anvil
RPC ?= http://localhost:8545
CHAINID ?= 31337
DEPLOYER_PK ?= $(shell cast wallet new 2>&1 | grep "Private key" | cut -d' ' -f3)
DEPLOYER_ADDRESS ?= $(shell cast wallet address --private-key $(DEPLOYER_PK))
OWNER_PK ?= $(shell cast wallet new | grep "Private key" | cut -d' ' -f3)
OWNER_ADDRESS ?= $(shell bash -c 'cast wallet address --private-key $(OWNER_PK)')

# Parse config/xxx.toml and extract values
get-config-value:
	@if [ -z "$(KEY)" ]; then \
		echo "Usage: make get-config-value KEY=<section.key>"; \
		exit 1; \
	fi; \
	section=$$(echo $(KEY) | cut -d. -f1); \
	key=$$(echo $(KEY) | cut -d. -f2); \
	awk -v section="$$section" -v key="$$key" ' \
		/^\[.*\]/ { \
			current_section=substr($$0,2,length($$0)-2); \
		} \
		current_section == section && $$1 == key { \
			gsub(/["]/,"",$$3); \
			print $$3; \
		}' config/$(DEPLOY_CONFIG).toml

transfer_tokens:
	@if [ "$(CHAINID)" = "31337" ]; then \
		echo "Transferring tokens on ${DEPLOY_CONFIG} network..."; \
		cast send \
			--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
			--value 10ether \
			--rpc-url $(RPC) \
			$(DEPLOYER_ADDRESS); \
	fi
	@echo ">> wait for transaction finalized..."
	@sleep 5
	@echo ">> balance of deployer: $(DEPLOYER_ADDRESS): "
	@cast balance --rpc-url $(RPC) $(DEPLOYER_ADDRESS)

deploy_deployer:
	@echo "Deploying deployer..."
	@forge script script/DeployCreate2.s.sol \
		--rpc-url $(RPC) \
		--private-key $(DEPLOYER_PK) \
		$(if $(filter-out 31337, $(CHAINID)),--verify) \
		--broadcast

deploy_payment_token:
	@echo "Deploying payment token..."
	@forge script script/DeployPaymentToken.s.sol \
		--rpc-url $(RPC) \
		--private-key $(DEPLOYER_PK) \
		$(if $(filter-out 31337, $(CHAINID)),--verify) \
		--broadcast
		
deploy_faucet:
	@echo "Deploying faucet..."
	@forge script script/DeployFaucet.s.sol \
		--rpc-url $(RPC) \
		--private-key $(DEPLOYER_PK) \
		$(if $(filter-out 31337, $(CHAINID)),--verify) \
		--broadcast


deploy_zktls_core:
	@echo "Deploying zktls core..."
	@echo forge script script/Deploy.s.sol \
		--rpc-url $(RPC) \
		--private-key $(DEPLOYER_PK) \
		--broadcast

verify_deployer:
	@if [ $(CHAINID) = 31337 ]; then \
		echo "contracts verification is not supported on anvil network"; \
		exit 0; \
	fi; \
	@echo "Verifying deployer..." \
	@echo forge verify-contract \
		--chain-id $(CHAINID) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		$(DEPLOYER_ADDRESS) $(CONTRACT_PATH)

verify_contracts:
	@echo "Verifying contracts..."
	@echo forge verify-contract \
		--chain-id $(CHAINID) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		$(CONTRACT_ADDRESS) $(CONTRACT_PATH)

help:
	@echo "Available commands:"
	@echo "  make transfer_tokens         - Transfer ETH to deployer address (local network only)"
	@echo "  make deploy_deployer        - Deploy the Create2 deployer contract"
	@echo "  make deploy_payment_token   - Deploy the payment token contract"
	@echo "  make deploy_zktls_core     - Deploy the ZKTLS core contracts"
	@echo "  make verify_deployer       - Verify the deployer contract on Etherscan"
	@echo "  make verify_contracts      - Verify contracts on Etherscan"
	@echo "  make get-config-value KEY=<section.key> - Get a value from the config file"
	@echo ""
	@echo "Environment variables (can be set in .env):"
	@echo "  DEPLOY_CONFIG     - Config file to use (default: anvil)"
	@echo "  RPC              - RPC endpoint (default: http://localhost:8545)"
	@echo "  CHAINID          - Chain ID (default: 31337)"
	@echo "  DEPLOYER_PK      - Deployer private key (default: generated)"
	@echo "  OWNER_PK         - Owner private key (default: generated)"

prepare: transfer_tokens deploy_deployer deploy_payment_token deploy_faucet
