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

export CONTRACT_ADDRESS=0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1

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
  --keystore $KEY_PATH \
  --password $PASSWORD

# Grant contract role to an address
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0x4f51faf6c4561ff95f067657e43439f0f856d97c04d9ec9070a6199ad418e235 \
  0x[CONTRACT_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Grant admin role to an address
cast send $CONTRACT_ADDRESS \
  "grantRole(bytes32,address)" \
  0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775 \
  0xCda26dF2674A1eF2A451e43Ab3122F228F95c900 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 4: Add Card Templates

Create card templates for the TCG system:

```bash
#Extract templates from a deployed contract
node script/LaunchScripts/migration/TemplateIDExtraction.js \
  --rpc "https://arb1.arbitrum.io/rpc" \
  --address "0x83D4137A37c1e4DB8eB804f3e29e724fB79B26a6" \
  --start 1 \
  --end 110 \
  --out ./jsons/local_templates.json

#Clean the json file
node script/LaunchScripts/migration/Clean-templates.js ./jsons/local_templates.json ./jsons/cleaned_templates.json

#dry run check output
node script/LaunchScripts/migration/Push-templates.js \
  --rpc "https://mainnet.base.org" \
  --address "0xCfBD8ABa030c1A1a721efc42C44cb4E1152e8069" \
  --input jsons/cleaned_templates.json \
  --keystore ".secrets/LaunchController" \
  --start 6 \
  --end 10

#Live run
node script/LaunchScripts/migration/Push-templates.js \
  --address "0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1" \
  --input jsons/cleaned_templates.json \
  --rpc $RPC_URL \
  --keyfile $KEY_PATH \
  --password $PASSWORD \
  --start 97 \
  --end 110 \
  --confirm

# Add a level 1 card template
export IMAGEURL=https://team3d.io/games/tcg_base/cards/005.gif
export DESCRIPTION="Years of meditative mountain solitude granted this hermit psychokinetic hands of ethereal iron."
export NAME="Evoker"
export TOP=2
export LEFT=5
export RIGHT=3
export BOTTOM=1
export LEVEL=1

cast send $CONTRACT_ADDRESS \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "$IMAGEURL" \
  "$DESCRIPTION" \
  "$NAME" \
  $TOP \
  $LEFT \
  $RIGHT \
  $BOTTOM \
  $LEVEL \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Add a level 2 card template
export IMAGEURL=https://team3d.io/games/tcg_base/cards/002.gif
export DESCRIPTION="An elite level 2 card with enhanced abilities"
export NAME="Ice Phoenix"
export TOP=15
export LEFT=12
export RIGHT=18
export BOTTOM=10
export LEVEL=2

cast send $CONTRACT_ADDRESS \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "$IMAGEURL" \
  "$DESCRIPTION" \
  "$NAME" \
  $TOP \
  $LEFT \
  $RIGHT \
  $BOTTOM \
  $LEVEL \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
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

# Template 1 variables
export IMAGEURL1="https://example.com/fire-dragon.png"
export DESCRIPTION1="A powerful fire dragon card"
export NAME1="Fire Dragon"
export TOP1=10
export LEFT1=8
export RIGHT1=12
export BOTTOM1=6
export LEVEL1=1

cast send "$CONTRACT_ADDRESS" \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "$IMAGEURL1" \
  "$DESCRIPTION1" \
  "$NAME1" \
  $TOP1 $LEFT1 $RIGHT1 $BOTTOM1 $LEVEL1 \
  --rpc-url "$RPC_URL" \
  --keystore "$KEYSTORE_PATH"

# Template 2 variables
export IMAGEURL2="https://example.com/ice-phoenix.png"
export DESCRIPTION2="An elite ice phoenix card"
export NAME2="Ice Phoenix"
export TOP2=15
export LEFT2=12
export RIGHT2=18
export BOTTOM2=10
export LEVEL2=2

cast send "$CONTRACT_ADDRESS" \
  "addTemplateId(string,string,string,uint8,uint8,uint8,uint8,uint8)" \
  "$IMAGEURL2" \
  "$DESCRIPTION2" \
  "$NAME2" \
  $TOP2 $LEFT2 $RIGHT2 $BOTTOM2 $LEVEL2 \
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
