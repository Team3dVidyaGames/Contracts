.PHONY: clean generate docs test redocs forge tidy gitmodule

build: tidy forge generate docs

rebuild: clean build

generate: forge

test:
	forge test -vvv

clean:
	rm -rf out/* bin/* docs/docgen/* bindings/*

clean-web3:
	rm -rf node_modules

forge:
	forge fmt
	forge build
	
bin/inventory:
	mkdir -p bin	
	go mod tidy
	go build -o bin/inventory ./cmd/inventory

bindings/ChainlinkConsumer/ChainlinkConsumer.go: forge
	mkdir -p bindings/ChainlinkConsumer
	seer evm generate --package ChainlinkConsumer --output bindings/ChainlinkConsumer/ChainlinkConsumer.go --hardhat artifacts/src/contracts/randomness/ChainlinkConsumer.sol/ChainlinkConsumer.json --cli --struct ChainlinkConsumer

docs:
	forge doc
	mkdir -p docs/abis
	mkdir -p docs/interfaces
	mkdir -p docs/abis/testable

tidy:
	go mod tidy

deepclean: clean clean-web3

bindings: bindings/ChainlinkConsumer/ChainlinkConsumer.go

redocs: clean docs

gitmodule:
	git submodule update --init --recursive