# Cauldron Contract Launch Script

This guide provides step-by-step instructions for deploying and configuring the Cauldron contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)
   - Deployed reward token contract (ERC20)
   - Deployed TCG Inventory NFT contract

2. **Required Information**
   - Reward token contract address (ERC20)
   - TCG Inventory NFT contract address
   - Your keystore file and password
   - Gateway address (for spillage distribution)

## Contract Overview

The Cauldron contract is a distribution system that allows users to burn NFT cards in exchange for reward tokens. Key features:

- **Card Burning**: Users can burn their NFT cards to increase their weight in the distribution system
- **Weighted Distribution**: Rewards are distributed based on user weights and time
- **Spillage System**: A portion of rewards goes to a gateway address
- **Point System**: Cards have different point values based on level and rarity
- **Bonus Multipliers**: Rare cards provide bonus multipliers

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the Cauldron contract was compiled
ls -la out/Cauldron.sol/
```

## Step 2: Deploy the Contract

Deploy the Cauldron contract using forge with keystore:

```bash
export KEY_PATH=.secrets/LaunchController
export RPC_URL=https://mainnet.base.org
export PASSWORD=<Password for keyfile, Delete before push>
export REWARD_TOKEN=0x46c8651dDedD50CBDF71de85D3de9AaC80247B62
export NFT_CONTRACT=0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1

# Deploy using keystore file
forge create ./src/contracts/agnosia/Cauldron.sol:Cauldron \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    $REWARD_TOKEN \
    $NFT_CONTRACT

# Flatten the contract for verification
forge flatten ./src/contracts/agnosia/Cauldron.sol -o ./src/contracts/flattened/flattened_Cauldron.sol
```

The system will prompt you for the keystore password during deployment.

## Step 3: Initialize the Contract

After deployment, initialize the point system:

```bash
# Current deployment address (replace with actual address)
export CONTRACT_ADDRESS=0xaA3Cc06FeB0076e5E6C78262b73DED3C2eC04454

# Initialize the point system (sets point values for each level)
cast send $CONTRACT_ADDRESS \
  "initialize()" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 4: Set Gateway Address

Configure the gateway address for spillage distribution:

```bash
export GATEWAY_ADDRESS=<Gateway address for spillage>

# Set the gateway address (can only be set once)
cast send $CONTRACT_ADDRESS \
  "setGateway(address)" \
  $GATEWAY_ADDRESS \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 5: Fund the Contract

Transfer reward tokens to the Cauldron contract for distribution:

```bash
# Transfer reward tokens to the contract
cast send $REWARD_TOKEN \
  "transfer(address,uint256)" \
  $CONTRACT_ADDRESS \
  1000000000000000000000000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 6: User Operations

### Burn Cards for Rewards

Users can burn their NFT cards to increase their weight in the distribution system:

```bash
# Burn multiple cards (replace with actual token IDs)
cast send $CONTRACT_ADDRESS \
  "increaseCauldronPortion(uint256[])" \
  "[1,2,3,4,5]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

### Claim Rewards

Users can claim their accumulated rewards:

```bash
# Claim rewards
cast send $CONTRACT_ADDRESS \
  "claim()" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 7: View Contract State

Check various contract parameters using cast call:

```bash
# View reward token address
cast call $CONTRACT_ADDRESS \
  "rewardToken()" \
  --rpc-url $RPC_URL

# View NFT contract address
cast call $CONTRACT_ADDRESS \
  "nft()" \
  --rpc-url $RPC_URL

# View gateway address
cast call $CONTRACT_ADDRESS \
  "gateway()" \
  --rpc-url $RPC_URL

# Check if gateway is set
cast call $CONTRACT_ADDRESS \
  "gatewaySet()" \
  --rpc-url $RPC_URL

# View spillage amount
cast call $CONTRACT_ADDRESS \
  "spillage()" \
  --rpc-url $RPC_URL

# View total cards burned
cast call $CONTRACT_ADDRESS \
  "totalCardsBurned()" \
  --rpc-url $RPC_URL

# View highest level burned
cast call $CONTRACT_ADDRESS \
  "highestLevelBurned()" \
  --rpc-url $RPC_URL

# View point values for each level
for i in {1..10}; do
  cast call $CONTRACT_ADDRESS \
    "pointPerLevel(uint256)" \
    $i \
    --rpc-url $RPC_URL
done

# View user-specific information
export USER_ADDRESS=<User address>

# View user's agnosia count
cast call $CONTRACT_ADDRESS \
  "agnosia(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's total cards burned
cast call $CONTRACT_ADDRESS \
  "totalCardsBurnedPerUser(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's highest level burned
cast call $CONTRACT_ADDRESS \
  "highestLevelBurnedPerUser(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View user's claimable tokens and weight
cast call $CONTRACT_ADDRESS \
  "UIHelperForUser(address)" \
  $USER_ADDRESS \
  --rpc-url $RPC_URL

# View general contract information
cast call $CONTRACT_ADDRESS \
  "UIHelperForGeneralInformation()" \
  --rpc-url $RPC_URL
```

## Step 8: Calculate Burn Values

Before burning cards, users can calculate the point values:

```bash
# Calculate bonus multiplier for a specific token
cast call $CONTRACT_ADDRESS \
  "bonusMultiplier(uint256)" \
  123 \
  --rpc-url $RPC_URL

# Calculate batch brew values for multiple tokens
cast call $CONTRACT_ADDRESS \
  "getBatchBrewValueMulti(uint256[])" \
  "[1,2,3,4,5]" \
  --rpc-url $RPC_URL
```

## Step 9: Administrative Functions

### Change Time Period

The owner can change the time period for reward distribution:

```bash
# Change time period (in seconds, e.g., 90 days = 7776000)
cast send $CONTRACT_ADDRESS \
  "changeTime(uint256)" \
  7776000 \
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
# Then deploy Cauldron with the mock addresses
forge create \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --constructor-args \
    0x[ERC20_ADDRESS] \
    0x[NFT_ADDRESS] \
  src/contracts/agnosia/Cauldron.sol:Cauldron
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
  src/contracts/agnosia/Cauldron.sol:Cauldron \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT)
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
  src/contracts/agnosia/Cauldron.sol:Cauldron \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT)
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
  src/contracts/agnosia/Cauldron.sol:Cauldron \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT)
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
  src/contracts/agnosia/Cauldron.sol:Cauldron \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT)
```

### Manual Verification (Alternative Method)

If automatic verification fails, you can verify manually:

#### Step 1: Get Constructor Arguments

```bash
# Get the constructor arguments in the correct format
cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT
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
  src/contracts/agnosia/Cauldron.sol:Cauldron \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT) \
  --libraries \
    @openzeppelin/contracts/access/Ownable.sol:Ownable:0x[LIBRARY_ADDRESS]
```

### Complete Verification Script

Here's a complete script that handles verification for multiple networks:

```bash
#!/bin/bash

# Configuration
CONTRACT_ADDRESS="0x[YOUR_CONTRACT_ADDRESS]"
REWARD_TOKEN="0x[REWARD_TOKEN_ADDRESS]"
NFT_CONTRACT="0x[NFT_CONTRACT_ADDRESS]"

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
      src/contracts/agnosia/Cauldron.sol:Cauldron \
      --constructor-args \
        $(cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT)
    
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
   cast abi-encode "constructor(address,address)" $REWARD_TOKEN $NFT_CONTRACT
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
2. **Invalid Contract Addresses**: Ensure reward token and NFT contract addresses are correct
3. **Gateway Already Set**: The gateway can only be set once
4. **Not Card Owner**: Users can only burn cards they own
5. **Nothing to Claim**: Users must have burned cards before they can claim rewards

### Gas Estimation

- **Deployment**: ~2,000,000 gas
- **Initialize**: ~200,000 gas
- **Set Gateway**: ~100,000 gas
- **Burn Cards**: ~150,000-300,000 gas (depending on number of cards)
- **Claim Rewards**: ~100,000-200,000 gas

### Security Notes

- Never commit keystore files or passwords to version control
- Use environment variables for sensitive information like keystore paths
- Test on testnets before deploying to mainnet
- Ensure proper ownership management for production deployments
- Consider using hardware wallets for mainnet deployments
- Keep keystore files secure and use strong passwords
- Verify that reward token and NFT contracts are legitimate before deployment

## Monitoring and Events

Monitor contract events for user interactions:

```bash
# Watch for weight updates
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[WEIGHT_UPDATED_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for claims
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[CLAIMED_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for gateway set events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[GATEWAY_SET_EVENT_TOPIC] \
  --rpc-url $RPC_URL
```

## Integration Examples

### Web3 Integration

```javascript
// Example web3 integration for burning cards
const cauldronContract = new web3.eth.Contract(cauldronABI, cauldronAddress);

// Burn cards
async function burnCards(tokenIds) {
  try {
    const tx = await cauldronContract.methods.increaseCauldronPortion(tokenIds).send({
      from: userAddress,
      gas: 300000
    });
    console.log('Cards burned successfully:', tx.transactionHash);
  } catch (error) {
    console.error('Error burning cards:', error);
  }
}

// Claim rewards
async function claimRewards() {
  try {
    const tx = await cauldronContract.methods.claim().send({
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
    const [tokensClaimable, userWeight, totalWeight, rewardsClaimed] = 
      await cauldronContract.methods.UIHelperForUser(userAddress).call();
    
    return {
      tokensClaimable,
      userWeight,
      totalWeight,
      rewardsClaimed
    };
  } catch (error) {
    console.error('Error getting user info:', error);
  }
}
```

### Batch Operations

```bash
# Batch burn multiple sets of cards
for tokenSet in "[1,2,3]" "[4,5,6]" "[7,8,9]"; do
  cast send $CONTRACT_ADDRESS \
    "increaseCauldronPortion(uint256[])" \
    $tokenSet \
    --rpc-url $RPC_URL \
    --keystore $KEY_PATH \
    --password $PASSWORD
done
```

## Best Practices

1. **Pre-calculate Values**: Always use `getBatchBrewValueMulti` before burning cards
2. **Monitor Gas**: Keep track of gas prices for optimal transaction timing
3. **Batch Operations**: Group multiple card burns in single transactions when possible
4. **Regular Claims**: Encourage users to claim rewards regularly to avoid large gas costs
5. **Gateway Management**: Set up the gateway address early in the deployment process
6. **Token Supply**: Ensure adequate reward token supply in the contract
7. **User Education**: Provide clear documentation for users on how to interact with the contract

## Support and Resources

- **Team3D Discord**: https://discord.gg/team3d
- **Team3D Website**: https://team3d.io
- **Contract Source**: Available in the project repository
- **Documentation**: This launch script and related documentation

For additional support or questions, please refer to the Team3D community channels or project documentation.
