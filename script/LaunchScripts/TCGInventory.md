# TCGInventory Contract Launch Script

This guide provides step-by-step instructions for deploying and configuring the TCGInventory contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)

2. **Required Information**
   - Your keystore file and password
   - Network RPC URL
   - Initial admin address

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the TCGInventory contract was compiled
ls -la out/TCGInventory.sol/
```

## Step 2: Deploy the Contract

Deploy the TCGInventory contract using forge with keystore:

```bash
export KEY_PATH=.secrets/LaunchController
export RPC_URL=https://mainnet.base.org

# Deploy using keystore file
forge create ./src/contracts/agnosia/TCGInventory.sol:TCGInventory \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify

# Flatten the contract for verification
forge flatten ./src/contracts/agnosia/TCGInventory.sol -o ./src/contracts/flattened/flattened_TCGInventory.sol
```

The system will prompt you for the keystore password during deployment.

## Step 3: Configure Access Control

After deployment, configure the access control roles:

```bash
# Grant minter role to an address
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
  0x[MINTER_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH

# Grant contract role to an address
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0x4f51faf6c4561ff95f067657e43439f0f856d97c04d9ec9070a6199ad418e235 \
  0x[CONTRACT_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH

# Grant admin role to an address
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775 \
  0x[ADMIN_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH
```

## Step 4: Add Card Templates

Create card templates for the TCG system:

```bash
# Add a level 1 card template
cast send $CONTRACT_ADDRESS \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "https://example.com/card1.png" \
  "A powerful level 1 card" \
  "Fire Dragon" \
  10 \
  8 \
  12 \
  6 \
  1 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH

# Add a level 2 card template
cast send $CONTRACT_ADDRESS \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "https://example.com/card2.png" \
  "An elite level 2 card" \
  "Ice Phoenix" \
  15 \
  12 \
  18 \
  10 \
  2 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH
```

## Step 5: Mint Cards

Mint cards to users:

```bash
# Mint a card to a user (requires MINTER_ROLE)
cast send $CONTRACT_ADDRESS \
  "mint(uint256,address)" \
  1 \
  0x[USER_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $MINTER_KEYSTORE_PATH
```

## Step 6: Update Card Data

Update card game statistics and stats:

```bash
# Update card game information (requires CONTRACT_ROLE)
cast send $CONTRACT_ADDRESS \
  "updateCardGameInformation(uint256,uint256,uint256)" \
  1 \
  1 \
  1 \
  --rpc-url $RPC_URL \
  --keystore $CONTRACT_KEYSTORE_PATH

# Update card stats (requires CONTRACT_ROLE)
cast send $CONTRACT_ADDRESS \
  "updateCardData(uint256,uint8,uint8,uint8,uint8,uint8)" \
  1 \
  12 \
  10 \
  14 \
  8 \
  --rpc-url $RPC_URL \
  --keystore $CONTRACT_KEYSTORE_PATH
```

## Step 7: Update Template Metadata

Update template information:

```bash
# Update image URL
cast send $CONTRACT_ADDRESS \
  "updateImageURL(uint256,string)" \
  1 \
  "https://new-example.com/card1.png" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH

# Update description
cast send $CONTRACT_ADDRESS \
  "updateDescription(uint256,string)" \
  1 \
  "Updated description for the card" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH

# Update name
cast send $CONTRACT_ADDRESS \
  "updateName(uint256,string)" \
  1 \
  "Updated Card Name" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH
```

## Step 8: View Contract State

Check various contract parameters using cast call:

```bash
# View template information
cast call $CONTRACT_ADDRESS \
  "template(uint256)" \
  1 \
  --rpc-url $RPC_URL

# View card data
cast call $CONTRACT_ADDRESS \
  "cardData(uint256)" \
  1 \
  --rpc-url $RPC_URL

# Check if template exists
cast call $CONTRACT_ADDRESS \
  "templateExists(uint256)" \
  1 \
  --rpc-url $RPC_URL

# Get card return data
cast call $CONTRACT_ADDRESS \
  "dataReturn(uint256)" \
  1 \
  --rpc-url $RPC_URL

# Get owner's token array
cast call $CONTRACT_ADDRESS \
  "ownerTokenArray(address)" \
  0x[OWNER_ADDRESS] \
  --rpc-url $RPC_URL

# Get highest level card for owner
cast call $CONTRACT_ADDRESS \
  "getHighestLevelCard(address)" \
  0x[OWNER_ADDRESS] \
  --rpc-url $RPC_URL

# View token URI
cast call $CONTRACT_ADDRESS \
  "tokenURI(uint256)" \
  1 \
  --rpc-url $RPC_URL
```

## Complete Deployment Script

Here's a complete bash script for deploying and configuring the contract:

```bash
#!/bin/bash

# Configuration
KEYSTORE_PATH="/path/to/your/keystore"
RPC_URL="https://your-rpc-endpoint.com"
ADMIN_ADDRESS="0x[YOUR_ADDRESS]"
MINTER_ADDRESS="0x[MINTER_ADDRESS]"
CONTRACT_ROLE_ADDRESS="0x[CONTRACT_ROLE_ADDRESS]"

echo "Building contracts..."
forge build

echo "Deploying TCGInventory contract..."

# Deploy contract
CONTRACT_ADDRESS=$(forge create \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH" \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory \
  | grep "Deployed to:" | cut -d' ' -f3)

echo "Contract deployed at: $CONTRACT_ADDRESS"

# Grant roles
echo "Configuring access control..."
cast send "$CONTRACT_ADDRESS" \
  "grantRole(bytes32,address)" \
  0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
  "$MINTER_ADDRESS" \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH"

cast send "$CONTRACT_ADDRESS" \
  "grantRole(bytes32,address)" \
  0x4f51faf6c4561ff95f067657e43439f0f856d97c04d9ec9070a6199ad418e235 \
  "$CONTRACT_ROLE_ADDRESS" \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH"

# Add initial templates
echo "Adding card templates..."
cast send "$CONTRACT_ADDRESS" \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "https://example.com/fire-dragon.png" \
  "A powerful fire dragon card" \
  "Fire Dragon" \
  10 8 12 6 1 \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH"

cast send "$CONTRACT_ADDRESS" \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "https://example.com/ice-phoenix.png" \
  "An elite ice phoenix card" \
  "Ice Phoenix" \
  15 12 18 10 2 \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH"

echo "TCGInventory contract deployment and configuration complete!"
echo "Contract Address: $CONTRACT_ADDRESS"
```

## Using Environment Variables

For security, use environment variables:

```bash
# Set environment variables
export KEYSTORE_PATH="/path/to/your/keystore"
export RPC_URL="https://your-rpc-endpoint.com"
export ADMIN_ADDRESS="0x[YOUR_ADDRESS]"

# Deploy using environment variables
forge create \
  --rpc-url $RPC_URL \
  --keystore $KEYSTORE_PATH \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory
```

## Testing on Local Network

For local testing with Anvil:

```bash
# Start local Anvil node
anvil

# Create a keystore for testing (optional - you can use the default account)
# In another terminal, deploy to local network using keystore
forge create \
  --rpc-url http://localhost:8545 \
  --keystore /path/to/test/keystore \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory
```

## Contract Verification

Verify the contract on block explorers to make it publicly readable and enable interaction through their interfaces.

### Prerequisites for Verification

1. **API Keys**: Get API keys from block explorers:
   - **Etherscan**: https://etherscan.io/apis
   - **Polygonscan**: https://polygonscan.com/apis
   - **Basescan**: https://basescan.org/apis
   - **Arbiscan**: https://arbiscan.io/apis

### Verification Commands

#### Ethereum Mainnet (Etherscan)

```bash
# Set your Etherscan API key
export ETHERSCAN_API_KEY="your_etherscan_api_key_here"

# Verify the contract
forge verify-contract \
  --chain-id 1 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory
```

#### Polygon Mainnet (Polygonscan)

```bash
# Set your Polygonscan API key
export POLYGONSCAN_API_KEY="your_polygonscan_api_key_here"

# Verify the contract
forge verify-contract \
  --chain-id 137 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $POLYGONSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory
```

#### Base Mainnet (Basescan)

```bash
# Set your Basescan API key
export BASESCAN_API_KEY="your_basescan_api_key_here"

# Verify the contract
forge verify-contract \
  --chain-id 8453 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $BASESCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/TCGInventory.sol:TCGInventory
```

## Role Management

### Role Hashes

- **ADMIN_ROLE**: `0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775`
- **MINTER_ROLE**: `0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`
- **CONTRACT_ROLE**: `0x4f51faf6c4561ff95f067657e43439f0f856d97c04d9ec9070a6199ad418e235`

### Granting Roles

```bash
# Grant admin role
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775 \
  0x[NEW_ADMIN_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEYSTORE_PATH
```

### Revoking Roles

```bash
# Revoke minter role
cast send $CONTRACT_ADDRESS \
  "revokeRole(bytes32,address)" \
  0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
  0x[ADDRESS_TO_REVOKE] \
  --rpc-url $RPC_URL \
  --keystore $KEYSTORE_PATH
```

## Troubleshooting

### Common Issues

1. **Insufficient Gas**: Add `--gas-limit 2000000` to deployment commands
2. **Role Permission Errors**: Ensure the caller has the appropriate role for the operation
3. **Template Limits**: Each level can only have 11 slots (0-10)
4. **Token Existence**: Ensure tokens exist before updating their data

### Gas Estimation

- **Deployment**: ~2,000,000 gas
- **Add Template**: ~200,000 gas
- **Mint Card**: ~150,000 gas
- **Update Card Data**: ~100,000 gas
- **Role Management**: ~80,000 gas

### Security Notes

- Never commit keystore files or passwords to version control
- Use environment variables for sensitive information like keystore paths
- Test on testnets before deploying to mainnet
- Ensure proper role management for production deployments
- Consider using hardware wallets for mainnet deployments
- Keep keystore files secure and use strong passwords

## Monitoring and Events

Monitor contract events for card activities:

```bash
# Watch for template added events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[TEMPLATE_ADDED_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for card stats updates
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[UPDATED_CARD_STATS_EVENT_TOPIC] \
  --rpc-url $RPC_URL
```

## Card Template Structure

When adding templates, use this structure:

```bash
# Template parameters:
# 1. imageURL: string - URL to card image
# 2. description: string - Card description
# 3. name: string - Card name
# 4. top: uint8 - Top stat value
# 5. left: uint8 - Left stat value  
# 6. right: uint8 - Right stat value
# 7. bottom: uint8 - Bottom stat value
# 8. level: uint8 - Card level (1-11)
```

## Benefits of Verification

- **Transparency**: Contract source code is publicly available
- **Trust**: Users can verify the contract matches the deployed bytecode
- **Interactions**: Users can interact with the contract through the explorer interface
- **Debugging**: Easier to debug issues with verified contracts
- **Integration**: Other developers can easily integrate with your contract
