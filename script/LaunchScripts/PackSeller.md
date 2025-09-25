# PackSeller Contract Launch Script

This guide provides step-by-step instructions for deploying and configuring the PackSeller contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)
   - Deployed TCG Inventory NFT contract
   - Deployed VRF Consumer contract
   - Uniswap V3 Router address for the target network

2. **Required Information**
   - TCG Inventory NFT contract address
   - VRF Consumer contract address
   - Uniswap V3 Router address
   - Primary token address (ERC20)
   - Splitter address (for dev funds)
   - Vault address (for vault funds)
   - Your keystore file and password

## Contract Overview

The PackSeller contract is a comprehensive pack selling and NFT minting system with the following key features:

- **Starter Pack Sales**: Users can buy starter packs containing 7 random NFT cards
- **Ascension System**: Users can upgrade 11 cards of the same level to get 1 card of the next level
- **Referral System**: Users can refer others and earn referral rewards
- **Fund Splitting**: Automatic distribution of funds between dev, vault, and referrals
- **VRF Integration**: Uses Chainlink VRF for random card selection
- **Uniswap Integration**: Automatically swaps ETH to primary tokens for rewards

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the PackSeller contract was compiled
ls -la out/StarterPackSeller.sol/
```

## Step 2: Deploy the Contract

Deploy the PackSeller contract using forge with keystore:

```bash
export KEY_PATH=.secrets/LaunchController
export RPC_URL=https://mainnet.base.org
export PASSWORD=<Password for keyfile, Delete before push>
export UNISWAP_V3_ROUTER=0x2626664c2603336E57B271c5C0b26F421741e481

# Deploy using keystore file
forge create ./src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    $UNISWAP_V3_ROUTER

# Flatten the contract for verification
forge flatten ./src/contracts/agnosia/PackSeller.sol -o ./src/contracts/flattened/flattened_PackSeller.sol
```

The system will prompt you for the keystore password during deployment.

## Step 3: Configure Core Contracts

After deployment, configure the essential contract addresses:

```bash
# Current deployment address (replace with actual address)
export CONTRACT_ADDRESS=0x4d2F9CC0b137a8757280b158f50FE508336580aE
export NFT_CONTRACT=0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1
export VRF_CONSUMER=0xf4A796f7a10b86897F7236C1f111e5887526FEc4
export PRIMARY_TOKEN=0x46c8651dDedD50CBDF71de85D3de9AaC80247B62
export SPLITTER_ADDRESS=0x26f8d863819210A81D3CA079720e71056F0f1823
export VAULT_ADDRESS=0xaA3Cc06FeB0076e5E6C78262b73DED3C2eC04454

# Test UniswapV3Integration buyTokenETH function
# This will swap ETH for the primary token using Uniswap V3
# Replace UNISWAP_INTEGRATION_ADDRESS with the actual deployed address
export POOL_FEE=10000  # 0.3% fee tier (common for major pairs)

# Buy primary token with ETH (example: 0.1 ETH)
cast send $CONTRACT_ADDRESS \
  "buyTokenETH(address,uint24)" \
  $PRIMARY_TOKEN \
  $POOL_FEE \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --value 10000000000000  # 0.1 ETH in wei


# Set NFT contract address
cast send $CONTRACT_ADDRESS \
  "changeNFT(address)" \
  $NFT_CONTRACT \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Set VRF Consumer address
cast send $CONTRACT_ADDRESS \
  "changeConsumer(address)" \
  $VRF_CONSUMER \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Set splitter address
cast send $CONTRACT_ADDRESS \
  "changeSplitter(address)" \
  $SPLITTER_ADDRESS \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Set vault address
cast send $CONTRACT_ADDRESS \
  "changeVault(address)" \
  $VAULT_ADDRESS \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Grant REQUESTER_ROLE to PackSeller contract in ChainlinkConsumer
# This is required for the PackSeller to retrieve randomness from VRF
cast send $VRF_CONSUMER \
  "setRequesterRole(address,bool,bool)" \
  $CONTRACT_ADDRESS \
  true \
  true \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 4: Configure Pack Cost

Set the cost for starter packs:

```bash
# Set pack cost (in wei, e.g., 0.001 ETH = 1000000000000000)
cast send $CONTRACT_ADDRESS \
  "changeCost(uint256)" \
  1000000000000000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 5: Configure Fund Splits

Set up the fund distribution percentages:

```bash
# Set splits: dev split, vault split, referral split
# Example: 50% dev, 25% vault, 10% referral (total 85%)
cast send $CONTRACT_ADDRESS \
  "setSplits(uint256,uint256,uint256)" \
  50 \
  25 \
  10 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 6: Add Template IDs

Add template IDs for each level to enable minting:

```bash
# Add template IDs for level 1 (starter packs)
cast send $CONTRACT_ADDRESS \
  "addTemplateId(uint256[])" \
  "[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

```

## Step 7: Fund the Contract

Transfer ETH to the contract for VRF requests and operations:

```bash
# Transfer ETH to the contract (adjust amount as needed)
cast send $CONTRACT_ADDRESS \
  --value 1000000000000000000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 8: User Operations

### Buy Starter Pack

Users can buy starter packs:

```bash
# Buy a starter pack (with optional referral address)
cast send $CONTRACT_ADDRESS \
  "buyStarterPack(address)" \
  0x0000000000000000000000000000000000000000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --value 1000000000000000

# Buy with referral
cast send $CONTRACT_ADDRESS \
  "buyStarterPack(address)" \
  0x[REFERRAL_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --value 5000000000000000
```

### Open Starter Pack

After buying, users can open their packs:

```bash
# Open starter pack (mints the NFTs)
cast send $CONTRACT_ADDRESS \
  "openStarterPack()" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

### Ascend to Next Level

Users can upgrade 11 cards of the same level:

```bash
# Ascend to next level (replace with actual token IDs)
cast send $CONTRACT_ADDRESS \
  "ascendToNextLevel(uint256[11])" \
  "[1,2,3,4,5,6,7,8,9,10,11]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

### Claim Referral Rewards

Users can claim their referral rewards:

```bash
# Claim referral rewards
cast send $CONTRACT_ADDRESS \
  "claimRewards()" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 9: View Contract State

Check various contract parameters using cast call:

```bash
# View pack cost
cast call $CONTRACT_ADDRESS \
  "packCost()" \
  --rpc-url $RPC_URL

# View NFT contract address
cast call $CONTRACT_ADDRESS \
  "nft()" \
  --rpc-url $RPC_URL

# View VRF consumer address
cast call $CONTRACT_ADDRESS \
  "consumer()" \
  --rpc-url $RPC_URL

# View splitter address
cast call $CONTRACT_ADDRESS \
  "splitter()" \
  --rpc-url $RPC_URL

# View vault address
cast call $CONTRACT_ADDRESS \
  "vault()" \
  --rpc-url $RPC_URL

# View primary token address
cast call $CONTRACT_ADDRESS \
  "primaryToken()" \
  --rpc-url $RPC_URL

# View split percentages
cast call $CONTRACT_ADDRESS \
  "split()" \
  --rpc-url $RPC_URL

cast call $CONTRACT_ADDRESS \
  "referralSplit()" \
  --rpc-url $RPC_URL

cast call $CONTRACT_ADDRESS \
  "vaultSplit()" \
  --rpc-url $RPC_URL

cast call $CONTRACT_ADDRESS \
  "totalSplit()" \
  --rpc-url $RPC_URL

# View cards in pack
cast call $CONTRACT_ADDRESS \
  "cardsInPack()" \
  --rpc-url $RPC_URL

# View stored templates for a level
cast call $CONTRACT_ADDRESS \
  "storedTemplates(uint8)" \
  1 \
  --rpc-url $RPC_URL

# View user-specific information
export USER_ADDRESS=<User address>

# View user points
cast call $CONTRACT_ADDRESS \
  "userPoint(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's pending request status
cast call $CONTRACT_ADDRESS \
  "userHasPendingRequest(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's request ID
cast call $CONTRACT_ADDRESS \
  "userToRequestID(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's referral count
cast call $CONTRACT_ADDRESS \
  "referralCount(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's ascension count
cast call $CONTRACT_ADDRESS \
  "ascensionCount(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's packs opened count
cast call $CONTRACT_ADDRESS \
  "packsOpened(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's referral rewards to claim
cast call $CONTRACT_ADDRESS \
  "referralToClaim(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# Check if user can claim rewards
cast call $CONTRACT_ADDRESS \
  "canClaimRewards(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# Check if user can open starter pack
cast call $CONTRACT_ADDRESS \
  "canOpenStarterPack(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL
```

## Step 10: Administrative Functions

### Remove Template IDs

Remove template IDs from a level:

```bash
# Remove template ID at position 0 from level 1
cast send $CONTRACT_ADDRESS \
  "removeTemplateIds(uint8,uint256)" \
  1 \
  0 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Testing on Local Network

For local testing with Anvil:

```bash
# Start local Anvil node
anvil

# Deploy mock contracts first
# Deploy a mock ERC20 token
forge create \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  lib/openzeppelin/contracts/token/ERC20/ERC20.sol:ERC20 \
  --constructor-args "TestToken" "TT"

# Deploy a mock NFT contract (you'll need to create this)
# Deploy a mock VRF consumer (you'll need to create this)
# Then deploy PackSeller with the mock addresses
forge create \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --constructor-args \
    0x[UNISWAP_V3_ROUTER_ADDRESS] \
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller
```

## Contract Verification

Verify the contract on block explorers to make it publicly readable and enable interaction through their interfaces.

### Prerequisites for Verification

1. **API Keys**: Get API keys from block explorers:
   - **Etherscan**: https://etherscan.io/apis
   - **Polygonscan**: https://polygonscan.com/apis
   - **Basescan**: https://basescan.org/apis
   - **Arbiscan**: https://arbiscan.io/apis

2. **Constructor Arguments**: You'll need the exact constructor arguments used during deployment

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
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --constructor-args \
    $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER)
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
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --constructor-args \
    $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER)
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
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --constructor-args \
    $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER)
```

#### Base Sepolia Testnet (Basescan)

```bash
# Set your Basescan API key
export BASESCAN_API_KEY="your_basescan_api_key_here"

# Verify the contract
forge verify-contract \
  --chain-id 84532 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $BASESCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --constructor-args \
    $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER)
```

### Manual Verification (Alternative Method)

If automatic verification fails, you can verify manually:

#### Step 1: Get Constructor Arguments

```bash
# Get the constructor arguments in the correct format
cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER
```

#### Step 2: Get Contract Metadata

```bash
# Get the contract metadata hash
cast code $CONTRACT_ADDRESS --rpc-url $RPC_URL
```

#### Step 3: Manual Upload

1. Go to the appropriate block explorer (Etherscan, Polygonscan, etc.)
2. Navigate to "Verify and Publish" section
3. Select "Solidity (Single file)" or "Solidity (Standard JSON Input)"
4. Upload your contract source code
5. Enter the constructor arguments from Step 1
6. Submit for verification

### Verification with Libraries

If your contract uses external libraries, you may need to specify them:

```bash
# Example with OpenZeppelin libraries
forge verify-contract \
  --chain-id 1 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
  --constructor-args \
    $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER) \
  --libraries \
    @openzeppelin/contracts/access/AccessControl.sol:AccessControl:0x[LIBRARY_ADDRESS] \
    @openzeppelin/contracts/utils/ReentrancyGuard.sol:ReentrancyGuard:0x[LIBRARY_ADDRESS]
```

### Complete Verification Script

Here's a complete script that handles verification for multiple networks:

```bash
#!/bin/bash

# Configuration
CONTRACT_ADDRESS="0x[YOUR_CONTRACT_ADDRESS]"
UNISWAP_V3_ROUTER="0x[UNISWAP_V3_ROUTER_ADDRESS]"

# API Keys (set these as environment variables)
# export ETHERSCAN_API_KEY="your_key_here"
# export POLYGONSCAN_API_KEY="your_key_here"
# export BASESCAN_API_KEY="your_key_here"

# Function to verify contract
verify_contract() {
    local chain_id=$1
    local api_key=$2
    local network_name=$3
    
    echo "Verifying contract on $network_name..."
    
    forge verify-contract \
      --chain-id $chain_id \
      --num-of-optimizations 200 \
      --watch \
      --etherscan-api-key $api_key \
      $CONTRACT_ADDRESS \
      src/contracts/agnosia/PackSeller.sol:StarterPackSeller \
      --constructor-args \
        $(cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER)
    
    if [ $? -eq 0 ]; then
        echo "✅ Contract verified successfully on $network_name"
    else
        echo "❌ Contract verification failed on $network_name"
    fi
}

# Verify on different networks (uncomment as needed)
# verify_contract 1 $ETHERSCAN_API_KEY "Ethereum Mainnet"
# verify_contract 137 $POLYGONSCAN_API_KEY "Polygon Mainnet"
# verify_contract 8453 $BASESCAN_API_KEY "Base Mainnet"
# verify_contract 84532 $BASESCAN_API_KEY "Base Sepolia"

echo "Verification process complete!"
```

### Troubleshooting Verification

#### Common Issues and Solutions

1. **"Already Verified" Error**
   ```bash
   # Check if contract is already verified
   curl "https://api.etherscan.io/api?module=contract&action=getsourcecode&address=$CONTRACT_ADDRESS&apikey=$ETHERSCAN_API_KEY"
   ```

2. **Constructor Arguments Mismatch**
   ```bash
   # Double-check constructor arguments
   cast abi-encode "constructor(address)" $UNISWAP_V3_ROUTER
   ```

3. **Compilation Settings Mismatch**
   - Ensure optimization is set to 200 (or match your foundry.toml)
   - Check Solidity version matches your contract

4. **Network Issues**
   ```bash
   # Test API connectivity
   curl "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=$ETHERSCAN_API_KEY"
   ```

### Post-Verification

After successful verification:

1. **Check Contract on Explorer**: Visit the contract address on the block explorer
2. **Test Read Functions**: Use the explorer's "Read Contract" tab to test view functions
3. **Test Write Functions**: Use the "Write Contract" tab to interact with the contract
4. **Monitor Events**: Watch for contract events in the "Events" tab

### Benefits of Verification

- **Transparency**: Contract source code is publicly available
- **Trust**: Users can verify the contract matches the deployed bytecode
- **Interactions**: Users can interact with the contract through the explorer interface
- **Debugging**: Easier to debug issues with verified contracts
- **Integration**: Other developers can easily integrate with your contract

## Troubleshooting

### Common Issues

1. **Insufficient Gas**: Add `--gas-limit 2000000` to deployment commands
2. **Invalid Contract Addresses**: Ensure all contract addresses are correct
3. **Pending Request**: Users must wait for VRF fulfillment before opening packs
4. **Insufficient Funds**: Ensure contract has enough ETH for VRF requests
5. **Template Not Found**: Ensure template IDs exist in the NFT contract
6. **Not Card Owner**: Users can only ascend cards they own
7. **Invalid Ascension**: All 11 cards must be unique and of the same level

### Gas Estimation

- **Deployment**: ~3,000,000 gas
- **Configuration calls**: ~100,000-200,000 gas each
- **Buy Starter Pack**: ~200,000-300,000 gas
- **Open Starter Pack**: ~300,000-500,000 gas
- **Ascend to Next Level**: ~400,000-600,000 gas
- **Claim Rewards**: ~100,000-200,000 gas

### Security Notes

- Never commit keystore files or passwords to version control
- Use environment variables for sensitive information like keystore paths
- Test on testnets before deploying to mainnet
- Ensure proper role management for production deployments
- Consider using hardware wallets for mainnet deployments
- Keep keystore files secure and use strong passwords
- Verify that all contract addresses are legitimate before deployment
- Monitor contract balance to ensure sufficient funds for VRF requests

## Monitoring and Events

Monitor contract events for user interactions:

```bash
# Watch for cost updates
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[COST_UPDATE_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for NFT updates
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[NFT_UPDATE_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for success events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[SUCCESS_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for template additions
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[TEMPLATE_ADDED_EVENT_TOPIC] \
  --rpc-url $RPC_URL
```

## Integration Examples

### Web3 Integration

```javascript
// Example web3 integration for pack operations
const packSellerContract = new web3.eth.Contract(packSellerABI, packSellerAddress);

// Buy starter pack
async function buyStarterPack(referralAddress = null) {
  try {
    const tx = await packSellerContract.methods.buyStarterPack(referralAddress || "0x0000000000000000000000000000000000000000").send({
      from: userAddress,
      value: web3.utils.toWei("0.005", "ether"),
      gas: 300000
    });
    console.log('Starter pack purchased successfully:', tx.transactionHash);
  } catch (error) {
    console.error('Error buying starter pack:', error);
  }
}

// Open starter pack
async function openStarterPack() {
  try {
    const tx = await packSellerContract.methods.openStarterPack().send({
      from: userAddress,
      gas: 500000
    });
    console.log('Starter pack opened successfully:', tx.transactionHash);
  } catch (error) {
    console.error('Error opening starter pack:', error);
  }
}

// Ascend to next level
async function ascendToNextLevel(tokenIds) {
  try {
    const tx = await packSellerContract.methods.ascendToNextLevel(tokenIds).send({
      from: userAddress,
      gas: 600000
    });
    console.log('Ascension successful:', tx.transactionHash);
  } catch (error) {
    console.error('Error ascending:', error);
  }
}

// Claim referral rewards
async function claimRewards() {
  try {
    const tx = await packSellerContract.methods.claimRewards().send({
      from: userAddress,
      gas: 200000
    });
    console.log('Rewards claimed successfully:', tx.transactionHash);
  } catch (error) {
    console.error('Error claiming rewards:', error);
  }
}

// Get user information
async function getUserInfo(userAddress) {
  try {
    const [
      userPoints,
      hasPendingRequest,
      requestId,
      referralCount,
      ascensionCount,
      packsOpened,
      referralToClaim,
      canClaimRewards,
      canOpenPack
    ] = await Promise.all([
      packSellerContract.methods.userPoint(userAddress).call(),
      packSellerContract.methods.userHasPendingRequest(userAddress).call(),
      packSellerContract.methods.userToRequestID(userAddress).call(),
      packSellerContract.methods.referralCount(userAddress).call(),
      packSellerContract.methods.ascensionCount(userAddress).call(),
      packSellerContract.methods.packsOpened(userAddress).call(),
      packSellerContract.methods.referralToClaim(userAddress).call(),
      packSellerContract.methods.canClaimRewards(userAddress).call(),
      packSellerContract.methods.canOpenStarterPack(userAddress).call()
    ]);
    
    return {
      userPoints,
      hasPendingRequest,
      requestId,
      referralCount,
      ascensionCount,
      packsOpened,
      referralToClaim,
      canClaimRewards,
      canOpenPack
    };
  } catch (error) {
    console.error('Error getting user info:', error);
  }
}
```

### Batch Operations

```bash
# Batch add multiple template sets
for level in 1 2 3 4 5; do
  cast send $CONTRACT_ADDRESS \
    "addTemplateId(uint256[])" \
    "[$((level*10+1)),$((level*10+2)),$((level*10+3)),$((level*10+4)),$((level*10+5))]" \
    --rpc-url $RPC_URL \
    --keystore $KEY_PATH \
    --password $PASSWORD
done
```

## Best Practices

1. **Template Management**: Regularly review and update template IDs for each level
2. **Fund Monitoring**: Keep track of contract balance for VRF requests
3. **Gas Optimization**: Monitor gas prices for optimal transaction timing
4. **User Education**: Provide clear documentation for users on pack mechanics
5. **Referral Tracking**: Monitor referral system performance and adjust splits as needed
6. **Security**: Regularly audit contract permissions and access controls
7. **Testing**: Thoroughly test all functions on testnets before mainnet deployment

## Support and Resources

- **Team3D Discord**: https://discord.gg/team3d
- **Team3D Website**: https://team3d.io
- **Contract Source**: Available in the project repository
- **Documentation**: This launch script and related documentation

For additional support or questions, please refer to the Team3D community channels or project documentation.
