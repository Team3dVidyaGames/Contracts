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
	

docs:
	forge doc
	mkdir -p docs/abis
	mkdir -p docs/interfaces
	mkdir -p docs/abis/testable

tidy:
	go mod tidy

deepclean: clean clean-web3

redocs: clean docs

gitmodule:
	git submodule update --init --recursive