# AgnosiaGame Contract Launch Script

This guide provides step-by-step instructions for deploying and configuring the AgnosiaGame contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)
   - Deployed TCGInventory contract (Agnosia cards NFT)
   - Deployed ERC20 token contract (Vidya token)

2. **Required Information**
   - TCGInventory contract address (Agnosia cards NFT)
   - ERC20 token contract address (Vidya token)
   - Your keystore file and password
   - Network-specific RPC URL

## Contract Dependencies

The AgnosiaGame contract requires two main dependencies:

### TCGInventory Contract
- **Purpose**: Manages Agnosia card NFTs
- **Interface**: ITCGInventory
- **Key Functions**: `dataReturn()`, `updateCardGameInformation()`, `ownerOf()`, `transferFrom()`

### ERC20 Token Contract
- **Purpose**: Vidya token for game wagers
- **Standard**: ERC20
- **Key Functions**: `transferFrom()`, `transfer()`, `balanceOf()`

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the AgnosiaGame contract was compiled
ls -la out/AgnosiaGame.sol/
```

## Step 2: Deploy the Contract

**⚠️ IMPORTANT: Contract Size Optimization Required**

The AgnosiaGame contract is large and may hit the contract size limit. Use the optimization strategies below:

### Contract Size Optimization Strategies

#### Strategy 1: Compiler Optimization (Recommended)
```bash
export KEY_PATH=<Path to keyfile>
export RPC_URL=https://mainnet.base.org
export PASSWORD=<Password for keyfile, Delete before push>

# Constructor arguments - Replace with actual addresses
export TOKEN_ADDRESS=0x46c8651dDedD50CBDF71de85D3de9AaC80247B62
export CARDS_ADDRESS=0x5176eA3fCAC068A0ed91D356e03db21A08430Cc1

# Deploy with maximum optimization
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 10000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### Strategy 2: ViaIR Compilation (For Very Large Contracts)
```bash
# Add to foundry.toml or use --via-ir flag
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --via-ir \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### Strategy 3: Gas Limit Override
```bash
# Deploy with higher gas limit
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --gas-limit 30000000 \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### Strategy 4: Alternative Deployment Methods

**Option A: Deploy via CREATE2 (Factory Pattern)**
```bash
# Deploy a factory contract first, then use it to deploy AgnosiaGame
# This can help with size limits in some cases
forge create ./src/contracts/factory/GameFactory.sol:GameFactory \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify
```

**Option B: Deploy with Libraries (Modular Approach)**
```bash
# Deploy libraries first
forge create ./src/contracts/libraries/AgnosiaGameLibrary.sol:AgnosiaGameLibrary \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast

# Then deploy main contract with library links
export LIBRARY_ADDRESS=0x[LIBRARY_DEPLOYED_ADDRESS]
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --libraries src/contracts/libraries/AgnosiaGameLibrary.sol:AgnosiaGameLibrary:$LIBRARY_ADDRESS \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

### Foundry Configuration for Large Contracts

Create or update `foundry.toml`:
```toml
[profile.default]
optimizer = true
optimizer_runs = 1000000
via_ir = true
bytecode_hash = "none"
evm_version = "london"

[profile.large_contracts]
optimizer = true
optimizer_runs = 1000000
via_ir = true
bytecode_hash = "none"
evm_version = "london"
size_limit = 24576
```

### Contract Size Reduction Techniques

#### 1. Code Optimization
- Remove unused functions
- Combine similar functions
- Use libraries for complex logic
- Optimize data structures

#### 2. Storage Optimization
- Pack structs efficiently
- Use smaller data types where possible
- Remove redundant storage variables

#### 3. Function Optimization
- Split large functions into smaller ones
- Use external functions where possible
- Remove duplicate code

#### 4. Event Optimization
- Remove unused events
- Optimize event parameters

### Deployment Commands by Network

#### Base Mainnet
```bash
# Base mainnet with optimization
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url https://mainnet.base.org \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --via-ir \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### Ethereum Mainnet
```bash
# Ethereum mainnet with optimization
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --via-ir \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

### Troubleshooting Contract Size Issues

#### Error: CreateContractSizeLimit
```bash
# Try these solutions in order:

# 1. Increase optimizer runs
--optimizer-runs 1000000

# 2. Enable via-ir
--via-ir

# 3. Use different EVM version
--evm-version london

# 4. Check for unused code
forge build --sizes

# 5. Split contract into multiple contracts
# (See modular deployment section)
```

#### Check Contract Size
```bash
# Check contract size before deployment
forge build --sizes

# Look for AgnosiaGame in the output
# Size should be under 24KB (24576 bytes)
```

### Modular Deployment (Alternative Approach)

If the contract is still too large, consider splitting it:

#### 1. Core Game Logic Contract
```bash
# Deploy core game functions
forge create ./src/contracts/agnosia/AgnosiaGameCore.sol:AgnosiaGameCore \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### 2. Game Management Contract
```bash
# Deploy game management functions
forge create ./src/contracts/agnosia/AgnosiaGameManager.sol:AgnosiaGameManager \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $CORE_CONTRACT_ADDRESS
```

### Flatten Contract for Verification
```bash
# Flatten the contract for verification
forge flatten ./src/contracts/agnosia/AgnosiaGame.sol -o ./src/contracts/flattened/flattened_AgnosiaGame.sol
```

The system will prompt you for the keystore password during deployment.

## Step 3: Verify Contract Deployment

After deployment, verify the contract is working correctly:

```bash
# Set the deployed contract address
export CONTRACT_ADDRESS=0x[YOUR_DEPLOYED_CONTRACT_ADDRESS]

# Check token address
cast call $CONTRACT_ADDRESS \
  "token()" \
  --rpc-url $RPC_URL

# Check cards address
cast call $CONTRACT_ADDRESS \
  "cards()" \
  --rpc-url $RPC_URL

# Check minimum wager
cast call $CONTRACT_ADDRESS \
  "minimumWager()" \
  --rpc-url $RPC_URL

# Check games created counter
cast call $CONTRACT_ADDRESS \
  "gamesCreated()" \
  --rpc-url $RPC_URL
```

## Step 4: Configure Game Parameters (Optional)

The contract comes with default parameters, but you can check and modify them if needed:

```bash
# Check forfeit timers
cast call $CONTRACT_ADDRESS \
  "forfeitTimers(uint256)" \
  0 \
  --rpc-url $RPC_URL

# Check if minimum wager needs adjustment
cast call $CONTRACT_ADDRESS \
  "minimumWager()" \
  --rpc-url $RPC_URL
```

## Step 5: Test Basic Contract Functions

Test the core functionality of the contract:

### Check Available Games
```bash
# Get games waiting for players
cast call $CONTRACT_ADDRESS \
  "gamesNeedPlayer()" \
  --rpc-url $RPC_URL
```

### Check Player Deck (if you have cards)
```bash
# Replace with actual player address
export PLAYER_ADDRESS=0x[PLAYER_ADDRESS]

# Check player's deck
cast call $CONTRACT_ADDRESS \
  "deckInfo(address)" \
  $PLAYER_ADDRESS \
  --rpc-url $RPC_URL
```

### Check Available Cards for a Player
```bash
# Get deposited available cards for a player
cast call $CONTRACT_ADDRESS \
  "getDepositedAvailableCards(address)" \
  $PLAYER_ADDRESS \
  --rpc-url $RPC_URL
```

## Step 6: Initialize a Game (Example)

Here's how to initialize a game (requires cards to be deposited first):

```bash
# Example game initialization
# Note: This requires the caller to have deposited cards and approved the contract

# Initialize a game with:
# - 5 card token IDs
# - 1 ETH wager
# - Trade rule 0 (one card)
# - No specific friend (open game)
# - No level limits
# - Timer rule 0 (5 minutes)

cast send $CONTRACT_ADDRESS \
  "initializeGame(uint256[5],uint256,uint8,address,bool,uint8,uint256)" \
  "[1,2,3,4,5]" \
  1000000000000000000 \
  0 \
  0x0000000000000000000000000000000000000000 \
  false \
  0 \
  0 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 7: Join a Game (Example)

```bash
# Join a game (requires cards to be deposited first)
# Replace gameWaitingIndex with actual index from gamesNeedPlayer()

cast send $CONTRACT_ADDRESS \
  "joinGame(uint256[5],uint256,address)" \
  "[6,7,8,9,10]" \
  0 \
  0x[GAME_CREATOR_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 8: Transfer Cards to Deck

Before playing, players need to transfer their cards to the game contract:

```bash
# Transfer cards to deck (requires approval first)
cast send $CONTRACT_ADDRESS \
  "transferToDeck(uint256[])" \
  "[1,2,3,4,5]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 9: Play a Card

```bash
# Place a card on the board
# Parameters: indexInHand, gameIndex, boardPosition
cast send $CONTRACT_ADDRESS \
  "placeCardOnBoard(uint256,uint256,uint8)" \
  0 \
  1 \
  4 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Step 10: Collect Winnings

After a game is finished:

```bash
# Collect winnings (replace with actual game index and cards to claim)
cast send $CONTRACT_ADDRESS \
  "collectWinnings(uint256,uint256[])" \
  1 \
  "[1,2]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## View Contract State

Check various contract parameters using cast call:

```bash
# View token address
cast call $CONTRACT_ADDRESS \
  "token()" \
  --rpc-url $RPC_URL

# View cards address
cast call $CONTRACT_ADDRESS \
  "cards()" \
  --rpc-url $RPC_URL

# View minimum wager
cast call $CONTRACT_ADDRESS \
  "minimumWager()" \
  --rpc-url $RPC_URL

# View games created
cast call $CONTRACT_ADDRESS \
  "gamesCreated()" \
  --rpc-url $RPC_URL

# View games waiting for players
cast call $CONTRACT_ADDRESS \
  "gamesNeedPlayer()" \
  --rpc-url $RPC_URL

# View player deck
cast call $CONTRACT_ADDRESS \
  "deckInfo(address)" \
  $PLAYER_ADDRESS \
  --rpc-url $RPC_URL

# View game details
cast call $CONTRACT_ADDRESS \
  "getGameDetails(uint256)" \
  1 \
  --rpc-url $RPC_URL

# View top 10 players
cast call $CONTRACT_ADDRESS \
  "getTop10Players()" \
  --rpc-url $RPC_URL
```

## Testing on Local Network

For local testing with Anvil:

```bash
# Start local Anvil node
anvil

# Deploy TCGInventory contract first (if needed)
# Deploy ERC20 token contract first (if needed)

# In another terminal, deploy to local network
export TOKEN_ADDRESS=0x[LOCAL_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[LOCAL_CARDS_ADDRESS]

forge create \
  --rpc-url http://localhost:8545 \
  --keystore /path/to/test/keystore \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS \
  src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame
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

# Constructor arguments
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Verify the contract
forge verify-contract \
  --chain-id 1 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS)
```

#### Polygon Mainnet (Polygonscan)

```bash
# Set your Polygonscan API key
export POLYGONSCAN_API_KEY="your_polygonscan_api_key_here"

# Constructor arguments
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Verify the contract
forge verify-contract \
  --chain-id 137 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $POLYGONSCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS)
```

#### Base Mainnet (Basescan)

```bash
# Set your Basescan API key
export BASESCAN_API_KEY="your_basescan_api_key_here"

# Constructor arguments
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Verify the contract
forge verify-contract \
  --chain-id 8453 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $BASESCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS)
```

#### Base Sepolia Testnet (Basescan)

```bash
# Set your Basescan API key
export BASESCAN_API_KEY="your_basescan_api_key_here"

# Constructor arguments
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Verify the contract
forge verify-contract \
  --chain-id 84532 \
  --num-of-optimizations 200 \
  --watch \
  --etherscan-api-key $BASESCAN_API_KEY \
  $CONTRACT_ADDRESS \
  src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --constructor-args \
    $(cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS)
```

### Manual Verification (Alternative Method)

If automatic verification fails, you can verify manually:

#### Step 1: Get Constructor Arguments

```bash
# Constructor arguments
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Get the constructor arguments in the correct format
cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS
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

### Complete Verification Script

Here's a complete script that handles verification for multiple networks:

```bash
#!/bin/bash

# Configuration
CONTRACT_ADDRESS="0x[YOUR_CONTRACT_ADDRESS]"
TOKEN_ADDRESS="0x[VIDYA_TOKEN_ADDRESS]"
CARDS_ADDRESS="0x[TCG_INVENTORY_ADDRESS]"

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
      src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
      --constructor-args \
        $(cast abi-encode "constructor(address,address)" $TOKEN_ADDRESS $CARDS_ADDRESS)
    
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

## Game Flow Examples

### Complete Game Flow

Here's a complete example of how to play a game:

```bash
# 1. First, approve the game contract to transfer your cards
# (This needs to be done on the TCGInventory contract)
cast send $CARDS_ADDRESS \
  "setApprovalForAll(address,bool)" \
  $CONTRACT_ADDRESS \
  true \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# 2. Transfer cards to your deck
cast send $CONTRACT_ADDRESS \
  "transferToDeck(uint256[])" \
  "[1,2,3,4,5]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# 3. Initialize a game
cast send $CONTRACT_ADDRESS \
  "initializeGame(uint256[5],uint256,uint8,address,bool,uint8,uint256)" \
  "[1,2,3,4,5]" \
  1000000000000000000 \
  0 \
  0x0000000000000000000000000000000000000000 \
  false \
  0 \
  0 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# 4. Check games waiting for players
cast call $CONTRACT_ADDRESS \
  "gamesNeedPlayer()" \
  --rpc-url $RPC_URL

# 5. Join the game (as second player)
cast send $CONTRACT_ADDRESS \
  "joinGame(uint256[5],uint256,address)" \
  "[6,7,8,9,10]" \
  0 \
  0x[FIRST_PLAYER_ADDRESS] \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# 6. Play cards (alternating turns)
cast send $CONTRACT_ADDRESS \
  "placeCardOnBoard(uint256,uint256,uint8)" \
  0 \
  1 \
  4 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# 7. Check game status
cast call $CONTRACT_ADDRESS \
  "getGameDetails(uint256)" \
  1 \
  --rpc-url $RPC_URL

# 8. Collect winnings when game is finished
cast send $CONTRACT_ADDRESS \
  "collectWinnings(uint256,uint256[])" \
  1 \
  "[1,2]" \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

## Monitoring and Events

Monitor contract events for game activities:

```bash
# Watch for GameInitialized events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[GAME_INITIALIZED_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for JoinedGame events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[JOINED_GAME_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for CardPlacedOnBoard events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[CARD_PLACED_EVENT_TOPIC] \
  --rpc-url $RPC_URL

# Watch for CollectWinnings events
cast logs \
  --from-block latest \
  --address $CONTRACT_ADDRESS \
  --topic 0x[COLLECT_WINNINGS_EVENT_TOPIC] \
  --rpc-url $RPC_URL
```

## Contract Size Optimization Guide

### Understanding Contract Size Limits

- **Ethereum Mainnet**: 24KB (24,576 bytes) limit
- **Base Mainnet**: 24KB (24,576 bytes) limit  
- **Polygon**: 24KB (24,576 bytes) limit
- **Current AgnosiaGame**: ~977 lines, likely over limit

### Size Optimization Strategies

#### 1. Compiler Optimizations (Immediate Solutions)

**Maximum Optimization Settings:**
```bash
# In foundry.toml
[profile.default]
optimizer = true
optimizer_runs = 1000000
via_ir = true
bytecode_hash = "none"
evm_version = "london"
```

**Deployment with Optimization:**
```bash
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --via-ir \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

#### 2. Code Structure Optimizations

**A. Move Large Functions to Libraries:**
```solidity
// Create AgnosiaGameLogic.sol library
library AgnosiaGameLogic {
    function placeCardOnBoard(...) external pure returns (...) {
        // Move complex game logic here
    }
    
    function calculateWinnings(...) external pure returns (...) {
        // Move calculation logic here
    }
}
```

**B. Split Contract into Multiple Contracts:**
```solidity
// AgnosiaGameCore.sol - Core game logic
contract AgnosiaGameCore {
    // Essential game functions only
}

// AgnosiaGameManager.sol - Game management
contract AgnosiaGameManager {
    // Player management, statistics
}

// AgnosiaGameStorage.sol - Storage contract
contract AgnosiaGameStorage {
    // All storage variables
}
```

#### 3. Storage Optimizations

**A. Pack Structs Efficiently:**
```solidity
// Before (inefficient)
struct Card {
    uint256 tokenID;        // 32 bytes
    uint8[4] powers;        // 4 bytes
    address owner;          // 20 bytes
    uint256 userIndex;     // 32 bytes
    uint256 currentGameIndex; // 32 bytes
    uint8 level;           // 1 byte
}
// Total: 121 bytes

// After (packed)
struct Card {
    uint256 tokenID;        // 32 bytes
    address owner;          // 20 bytes
    uint256 userIndex;      // 32 bytes
    uint256 currentGameIndex; // 32 bytes
    uint8[4] powers;        // 4 bytes
    uint8 level;           // 1 byte
}
// Total: 121 bytes (same, but better packing)
```

**B. Use Smaller Data Types:**
```solidity
// Instead of uint256 for small values
uint8 level;           // 0-255 levels
uint32 wins;           // 0-4 billion wins
uint64 discordId;      // Discord IDs fit in 64 bits
```

#### 4. Function Optimizations

**A. Remove Unused Functions:**
```bash
# Check for unused functions
forge build --sizes
```

**B. Combine Similar Functions:**
```solidity
// Instead of separate functions
function getPlayer1Hand() external view returns (uint256[] memory);
function getPlayer2Hand() external view returns (uint256[] memory);

// Use one function
function getPlayerHand(address player) external view returns (uint256[] memory);
```

**C. Use External Functions:**
```solidity
// External functions are cheaper to call
function initializeGame(...) external nonReentrant {
    // Function body
}
```

#### 5. Event Optimizations

**A. Remove Unused Events:**
```solidity
// Remove events that are never emitted
// Keep only essential events
```

**B. Optimize Event Parameters:**
```solidity
// Instead of large arrays in events
event GameInitialized(uint256 indexed gameId, uint256 wager, uint8 tradeRule);

// Use indexed parameters for filtering
event CardPlaced(uint256 indexed gameId, uint256 indexed tokenId, uint8 position);
```

### Advanced Size Reduction Techniques

#### 1. Proxy Pattern Implementation

**Deploy a Proxy Contract:**
```bash
# Deploy implementation contract
forge create ./src/contracts/agnosia/AgnosiaGameImplementation.sol:AgnosiaGameImplementation \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000

# Deploy proxy contract
forge create ./src/contracts/proxy/GameProxy.sol:GameProxy \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    $IMPLEMENTATION_ADDRESS
```

#### 2. Diamond Pattern (EIP-2535)

**For extremely large contracts:**
```solidity
// Split into facets
contract AgnosiaGameFacet1 {
    // Game initialization functions
}

contract AgnosiaGameFacet2 {
    // Gameplay functions
}

contract AgnosiaGameFacet3 {
    // Player management functions
}
```

#### 3. Modular Deployment

**Step-by-step deployment:**
```bash
# 1. Deploy core game logic
forge create ./src/contracts/agnosia/AgnosiaGameCore.sol:AgnosiaGameCore \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000

# 2. Deploy game manager
forge create ./src/contracts/agnosia/AgnosiaGameManager.sol:AgnosiaGameManager \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --constructor-args \
    $CORE_CONTRACT_ADDRESS

# 3. Deploy storage contract
forge create ./src/contracts/agnosia/AgnosiaGameStorage.sol:AgnosiaGameStorage \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000
```

### Size Checking Commands

```bash
# Check contract sizes
forge build --sizes

# Check specific contract
forge build --sizes | grep AgnosiaGame

# Check with optimization
forge build --sizes --optimize --optimizer-runs 1000000

# Check with via-ir
forge build --sizes --via-ir --optimize --optimizer-runs 1000000
```

### Recommended Deployment Strategy

**For AgnosiaGame contract:**

1. **Try Strategy 1 first** (Compiler optimization)
2. **If still too large, try Strategy 2** (ViaIR compilation)
3. **If still too large, use Strategy 4** (Modular deployment)
4. **Last resort: Proxy pattern**

**Quick deployment command:**
```bash
# Try this first - most likely to work
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --optimize \
  --optimizer-runs 1000000 \
  --via-ir \
  --gas-limit 30000000 \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS
```

## Troubleshooting

### Common Issues

1. **CreateContractSizeLimit Error**: Use optimization strategies above
2. **Insufficient Gas**: Add `--gas-limit 30000000` to deployment commands
3. **Card Not Deposited**: Ensure cards are transferred to the contract before playing
4. **Card Already in Game**: Check that cards are not already in another game
5. **Insufficient Token Balance**: Ensure sufficient token balance for wagers
6. **Invalid Game State**: Check game status before attempting moves

### Gas Estimation

- **Deployment**: ~2,000,000 gas
- **Transfer Cards to Deck**: ~150,000 gas per card
- **Initialize Game**: ~200,000 gas
- **Join Game**: ~150,000 gas
- **Place Card**: ~100,000 gas
- **Collect Winnings**: ~150,000 gas

### Security Notes

- Never commit keystore files or passwords to version control
- Use environment variables for sensitive information like keystore paths
- Test on testnets before deploying to mainnet
- Ensure proper card management for production deployments
- Consider using hardware wallets for mainnet deployments
- Keep keystore files secure and use strong passwords
- Always verify contract addresses before interacting

### Game Rules Summary

- **Trade Rules**: 0 = one card, 1 = difference, 2 = direct, 3 = all
- **Timer Rules**: 0 = 5min, 1 = 15min, 2 = 30min, 3 = 1hr, 4 = 12hr, 5 = 24hr
- **Board Positions**: 0-8 (3x3 grid)
- **Hand Size**: 5 cards per player
- **Minimum Wager**: 1 ETH (configurable)

## Advanced Usage

### Player Management

```bash
# Register Discord ID
cast send $CONTRACT_ADDRESS \
  "registerId(uint64)" \
  123456789 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD

# Update profile picture
cast send $CONTRACT_ADDRESS \
  "updatePfp(address,uint256)" \
  0x[NFT_CONTRACT_ADDRESS] \
  1 \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD
```

### Game Analytics

```bash
# Get player statistics
cast call $CONTRACT_ADDRESS \
  "playerData(address)" \
  $PLAYER_ADDRESS \
  --rpc-url $RPC_URL

# Get top 10 players
cast call $CONTRACT_ADDRESS \
  "getTop10Players()" \
  --rpc-url $RPC_URL

# Get active games for a player
cast call $CONTRACT_ADDRESS \
  "getActivePlayerGames(address)" \
  $PLAYER_ADDRESS \
  --rpc-url $RPC_URL
```

This launch script provides comprehensive instructions for deploying, configuring, and using the AgnosiaGame contract. Make sure to replace placeholder addresses with actual contract addresses and test thoroughly on testnets before mainnet deployment.
