# ChainlinkConsumer Contract Launch Script

This guide provides step-by-step instructions for deploying and configuring the ChainlinkConsumer contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)
   - Chainlink VRF subscription ID and coordinator address

2. **Required Information**
   - VRF Coordinator address (network-specific)
   - VRF Subscription ID
   - Key Hash for your network
   - Request confirmations (typically 3)
   - Callback gas limit (typically 100,000-500,000)
   - Your keystore file and password

## Network-Specific VRF Addresses

### blah Network
- VRF Coordinator: `address`
- Key Hash: `bytes`


## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the ChainlinkConsumer contract was compiled
ls -la out/ChainlinkConsumer.sol/
```

## Step 2: Deploy the Contract

Deploy the ChainlinkConsumer contract using forge with keystore:

```bash
export KEY_PATH=<Pathe to keyfile>
export RPC_URL=https://mainnet.base.org
export PASSWORD=<Password for keyfile, Delete before push>

# Deploy using keystore file
forge create ./src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    0xd5D517aBE5cF79B7e95eC98dB0f0277788aFF634 \ 
    Subscription_ID 
  
forge flatten ./src/contracts/randomness/ChainlinkConsumer.sol -o ./src/contracts/flattened/flattened_ChainlinkConsumer.sol

```

The system will prompt you for the keystore password during deployment.

## Step 3: Configure VRF Parameters

After deployment, configure the VRF parameters using cast:



```bash
#Current deployment on Base
export CONTRACT_ADDRESS=0x87857020355a55bbc88f7514Cf7F4e8De407Ea88

# Set key hash (replace CONTRACT_ADDRESS with actual address)
cast send $CONTRACT_ADDRESS \
  "setKeyHash(bytes32)" \
  0xdc2f87677b01473c763cb0aee938ed3341512f6057324a584e5944e786144d70 \
  --rpc-url $RPC_URL \ \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Set request parameters
cast send $CONTRACT_ADDRESS \
  "setParams(uint16,uint32)" \
  15 \
  500000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 4: Configure Fees

Set up the fee structure:

```bash
# Set fees (in wei)
cast send $CONTRACT_ADDRESS \
  "setFees(uint256,uint256,uint256)" \
  50000000000000 \
  5000000000000 \
  1000000000000000000 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

cast send $CONTRACT_ADDRESS \
  "setMaxNumWords(uint256)" \
  15 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 5: Set Up Roles

Configure user roles for the contract:

```bash
export USER=<Address of Role assingment>

# Grant requester role to an address
cast send $CONTRACT_ADDRESS \
  "setRequesterRole(address,bool,bool)" \
  $USER \
  true \
  false \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Grant randomness viewer role
cast send $CONTRACT_ADDRESS \
  "setRandomnessViewerRole(address,bool)" \
  $USER \
  true \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 6: Set ETH Overfund Address

Configure the address to receive excess ETH:

```bash
cast send $CONTRACT_ADDRESS \
  "setEthOverfundAddress(address)" \
  $USER \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 7: Request Randomness

Users can request randomness by sending ETH and calling the function:

```bash
# Request 1 random word (sending 1 ETH as fee)
cast send $CONTRACT_ADDRESS \
  "requestRandomness(uint32)" \
  15 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --value 50000000000000
```

## Step 8: Retrieve Randomness

After the request is fulfilled, retrieve the random numbers:

```bash
# Get randomness for a specific request ID
cast call $CONTRACT_ADDRESS \
  "getRandomness(uint256)" \
  123 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Get randomness by position (requires viewer fee if not RANDOMNESS_VIEWER role)
OUTPUT=$(cast send $CONTRACT_ADDRESS \
  "getRandomnessPosition(uint256[])" \
  "[0,3,6]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --value 30000000000000)
```

## View Contract State

Check various contract parameters using cast call:

```bash
# View VRF coordinator
cast call $CONTRACT_ADDRESS \
  "vrfCoordinator()" \
  --rpc-url $RPC_URL

# View subscription ID
cast call $CONTRACT_ADDRESS \
  "subscriptionId()" \
  --rpc-url $RPC_URL

# View key hash
cast call $CONTRACT_ADDRESS \
  "keyHash()" \
  --rpc-url $RPC_URL

# View request confirmations
cast call $CONTRACT_ADDRESS \
  "requestConfirmations()" \
  --rpc-url $RPC_URL

# View callback gas limit
cast call $CONTRACT_ADDRESS \
  "callbackGasLimit()" \
  --rpc-url $RPC_URL

# View fees
cast call $CONTRACT_ADDRESS \
  "requestFee()" \
  --rpc-url $RPC_URL

cast call $CONTRACT_ADDRESS \
  "viewerFee()" \
  --rpc-url $RPC_URL

# View randomness counter
cast call $CONTRACT_ADDRESS \
  "getRandomnessCounter()" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
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
  --constructor-args \
    0x[VRF_COORDINATOR] \
    1 \
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer
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
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --constructor-args \
    $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID)
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
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --constructor-args \
    $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID)
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
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --constructor-args \
    $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID)
```

#### Sepolia Testnet (Etherscan)

```bash
# Set your Etherscan API key
export ETHERSCAN_API_KEY="your_etherscan_api_key_here"

# Verify the contract
forge verify-contract \
  --chain-id 11155111 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --constructor-args \
    $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID)
```

### Manual Verification (Alternative Method)

If automatic verification fails, you can verify manually:

#### Step 1: Get Constructor Arguments

```bash
# Get the constructor arguments in the correct format
cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID
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
  src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
  --constructor-args \
    $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID) \
  --libraries \
    @openzeppelin/contracts/access/AccessControl.sol:AccessControl:0x[LIBRARY_ADDRESS]
```

### Complete Verification Script

Here's a complete script that handles verification for multiple networks:

```bash
#!/bin/bash

# Configuration
CONTRACT_ADDRESS="0x[YOUR_CONTRACT_ADDRESS]"
VRF_COORDINATOR="0x271682DEB8C4E0901D1a1550aD2e64D568E69909"
SUBSCRIPTION_ID="123"

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
      src/contracts/randomness/ChainlinkConsumer.sol:ChainlinkConsumer \
      --constructor-args \
        $(cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID)
    
    if [ $? -eq 0 ]; then
        echo "✅ Contract verified successfully on $network_name"
    else
        echo "❌ Contract verification failed on $network_name"
    fi
}

# Verify on different networks (uncomment as needed)
# verify_contract 1 $ETHERSCAN_API_KEY "Ethereum Mainnet"
# verify_contract 137 $POLYGONSCAN_API_KEY "Polygon Mainnet"
# verify_contract 84532 $BASESCAN_API_KEY "Base Sepolia"
# verify_contract 11155111 $ETHERSCAN_API_KEY "Sepolia Testnet"

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
   cast abi-encode "constructor(address,uint256)" $VRF_COORDINATOR $SUBSCRIPTION_ID
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
2. **Invalid VRF Coordinator**: Ensure you're using the correct coordinator for your network
3. **Subscription Issues**: Verify your Chainlink VRF subscription is active and funded
4. **Role Permissions**: Ensure the caller has the appropriate role for the operation

### Gas Estimation

- **Deployment**: ~1,500,000 gas
- **Configuration calls**: ~100,000-200,000 gas each
- **Randomness requests**: ~200,000-500,000 gas (depending on callback gas limit)

### Security Notes

- Never commit keystore files or passwords to version control
- Use environment variables for sensitive information like keystore paths
- Test on testnets before deploying to mainnet
- Ensure proper role management for production deployments
- Consider using hardware wallets for mainnet deployments
- Keep keystore files secure and use strong passwords

## Monitoring and Events

Monitor contract events for randomness requests:

```bash
# Watch for RequestRandomness events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[REQUEST_RANDOMNESS_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for FulfillRandomWords events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[FULFILL_RANDOM_WORDS_EVENT_TOPIC] \
  --rpc-url $RPC_URL
```