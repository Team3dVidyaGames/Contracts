# TemplateCounter Contract Launch Script

This guide provides step-by-step instructions for deploying and operating the TemplateCounter contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)

2. **Required Information**
   - Network RPC URL
   - Your keystore file path and password
   - TCG Inventory contract address
   - Game contract address

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the TemplateCounter contract was compiled
ls -la out/TemplateCounter.sol/
```

## Step 2: Deploy the Contract

Deploy the TemplateCounter contract using forge with keystore:

```bash
export KEY_PATH=<Path to keyfile>
export RPC_URL=<https or ws RPC URL>
export PASSWORD=<Password for keyfile, Delete before push>

# Constructor arguments
export TCG_INVENTORY_ADDR=0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1
export GAME_ADDR=0xb0f6B6a346b8EbC49DA9636264a79a6380b588cd

# Deploy using keystore file
forge create ./src/contracts/agnosia/templateCounter.sol:TemplateCounter \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    $TCG_INVENTORY_ADDR \
    $GAME_ADDR

# Optionally flatten for explorers that prefer flat sources
forge flatten ./src/contracts/agnosia/templateCounter.sol -o ./src/contracts/flattened/flattened_TemplateCounter.sol
```

The system will prompt you for the keystore password during deployment if `--password` is omitted.

Record the deployed contract address as `TEMPLATE_COUNTER_ADDR` for the following steps.

```bash
export TEMPLATE_COUNTER_ADDR=<Deployed TemplateCounter address>
```

## Step 3: Post-Deploy Operations

The TemplateCounter contract is a view-only contract that counts template ownership across owned and deposited tokens.

- **Count templates by owner**

```bash
# Get template counts for a specific owner
cast call $TEMPLATE_COUNTER_ADDR "countTemplatesByOwner(address)((uint256,uint256)[])" <ownerAddress> \
  --rpc-url $RPC_URL

# Example with a specific address
cast call $TEMPLATE_COUNTER_ADDR "countTemplatesByOwner(address)((uint256,uint256)[])" 0x1234567890123456789012345678901234567890 \
  --rpc-url $RPC_URL
```

## Step 4: Understanding the Results

The `countTemplatesByOwner` function returns an array of `TemplateCount` structs containing:
- `templateId`: The template ID (1-110)
- `count`: The number of tokens with that template ID

The function counts tokens from two sources:
1. **Owned tokens**: Tokens in the owner's wallet (via `inventoryContract.ownerTokenArray`)
2. **Deposited tokens**: Tokens deposited in the game (via `gameContract.deckInfo`)

## Step 5: Integration Examples

- **Check specific template counts**

```bash
# Get all template counts for an owner and parse results
cast call $TEMPLATE_COUNTER_ADDR "countTemplatesByOwner(address)((uint256,uint256)[])" <ownerAddress> \
  --rpc-url $RPC_URL | jq '.[] | select(.templateId == 1) | .count'
```

- **Verify contract dependencies**

```bash
# Check that the inventory contract is accessible
cast call $TCG_INVENTORY_ADDR "ownerTokenArray(address)(uint256[])" <ownerAddress> \
  --rpc-url $RPC_URL

# Check that the game contract is accessible  
cast call $GAME_ADDR "deckInfo(address)(uint256,uint256[])" <ownerAddress> \
  --rpc-url $RPC_URL
```

## Useful Reads

- Contract source: `src/contracts/agnosia/templateCounter.sol`
- ABI/Docs: `docs/src/src/contracts/agnosia/templateCounter.sol/contract.TemplateCounter.md`
- Dependencies: TCG Inventory and Game contracts must be deployed and accessible
