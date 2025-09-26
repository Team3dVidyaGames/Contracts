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

Deploy the AgnosiaGame contract using forge with keystore:

```bash
export KEY_PATH=<Path to keyfile>
export RPC_URL=https://mainnet.base.org
export PASSWORD=<Password for keyfile, Delete before push>

# Constructor arguments - Replace with actual addresses
export TOKEN_ADDRESS=0x[VIDYA_TOKEN_ADDRESS]
export CARDS_ADDRESS=0x[TCG_INVENTORY_ADDRESS]

# Deploy using keystore file
forge create ./src/contracts/agnosia/AgnosiaGame.sol:AgnosiaGame \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify \
  --constructor-args \
    $TOKEN_ADDRESS \
    $CARDS_ADDRESS

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

## Troubleshooting

### Common Issues

1. **Insufficient Gas**: Add `--gas-limit 2000000` to deployment commands
2. **Card Not Deposited**: Ensure cards are transferred to the contract before playing
3. **Card Already in Game**: Check that cards are not already in another game
4. **Insufficient Token Balance**: Ensure sufficient token balance for wagers
5. **Invalid Game State**: Check game status before attempting moves

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
