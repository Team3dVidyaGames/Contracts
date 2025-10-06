# SplitterAccessControl Contract Launch Script

This guide provides step-by-step instructions for deploying and operating the SplitterAccessControl contract using Foundry and direct contract interactions.

## Prerequisites

1. **Environment Setup**
   - Foundry (forge, cast, anvil) installed
   - A funded Ethereum account with keystore file
   - Access to a JSON-RPC endpoint (Infura, Alchemy, or local node)

2. **Required Information**
   - Network RPC URL
   - Your keystore file path and password

## Step 1: Build the Contract

First, ensure the contract is compiled:

```bash
# Build the contracts
forge build

# Verify the SplitterAccessControl contract was compiled
ls -la out/SplitterAccessControl.sol/
```

## Step 2: Deploy the Contract

Deploy the SplitterAccessControl contract using forge with keystore:

```bash
export KEY_PATH=<Path to keyfile>
export RPC_URL=<https or ws RPC URL>
export PASSWORD=<Password for keyfile, Delete before push>

# Deploy using keystore file (no constructor args)
forge create ./src/contracts/splitter/SplitterAccessControl.sol:SplitterAccessControl \
  --rpc-url $RPC_URL \
  --keystore $KEY_PATH \
  --password $PASSWORD \
  --broadcast \
  --verify

# Optionally flatten for explorers that prefer flat sources
forge flatten ./src/contracts/splitter/SplitterAccessControl.sol -o ./src/contracts/flattened/flattened_SplitterAccessControl.sol
```

The system will prompt you for the keystore password during deployment if `--password` is omitted.

Record the deployed contract address as `SPLITTER_ADDR` for the following steps.

```bash
export SPLITTER_ADDR=0x7d36F441fAD902df930b9F11DAcfEF3f898dd1D1
```

## Step 3: Post-Deploy Administration

On deployment, the deployer is granted `DEFAULT_ADMIN_ROLE` and `ADMIN_ROLE`.

- **Check roles and member count**

```bash
# DEFAULT_ADMIN_ROLE and ADMIN_ROLE constants are publicly readable on many AccessControl variants,
# but for simple checks we can call standard getters provided by this contract

# Member count
cast call $SPLITTER_ADDR "memberCount()(uint256)" --rpc-url $RPC_URL

# SPLITTER_ROLE hash (optional reference)
cast keccak "SPLITTER_ROLE"
```

- **Add a member to the splitter** (admin only)

```bash
cast send $SPLITTER_ADDR "addMemberToSplitter(address)" <memberAddress> \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD

# Confirm state
cast call $SPLITTER_ADDR "memberCount()(uint256)" --rpc-url $RPC_URL
cast call $SPLITTER_ADDR "userPosition(address)(uint256)" <memberAddress> --rpc-url $RPC_URL
```

- **Remove a member from the splitter** (admin only)

```bash
cast send $SPLITTER_ADDR "removeMemberFromSplitter(address)" <memberAddress> \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD

# Confirm state
cast call $SPLITTER_ADDR "memberCount()(uint256)" --rpc-url $RPC_URL
cast call $SPLITTER_ADDR "userPosition(address)(uint256)" <memberAddress> --rpc-url $RPC_URL
```

- **Change a member's position address** (current position holder only; must have `SPLITTER_ROLE`)

```bash
# Caller must be the current position holder; they can replace their address with a new address
cast send $SPLITTER_ADDR "changePositionAddress(address)" <newAddress> \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD
```

## Step 4: Funding and Distribution

To distribute, the contract must hold ETH and/or ERC20 tokens.

- **Fund with ETH**

```bash
cast send $SPLITTER_ADDR --value 0.0000005ether \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD
```

- **Fund with ERC20**

```bash
# From a holder of the token, transfer tokens to the splitter
export TOKEN=<ERC20 token address>
cast send $TOKEN "transfer(address,uint256)" $SPLITTER_ADDR 100000000000000000000 \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD
```

- **Distribute funds**

`distributeFunds(address erc20, bool ethAsWell)` splits available balances equally across all members.

```bash
# Distribute only ETH
cast send $SPLITTER_ADDR "distributeFunds(address,bool)" 0x0000000000000000000000000000000000000000 true \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD

# Distribute only ERC20
cast send $SPLITTER_ADDR "distributeFunds(address,bool)" $TOKEN false \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD

# Distribute both ETH and ERC20
cast send $SPLITTER_ADDR "distributeFunds(address,bool)" $TOKEN true \
  --rpc-url $RPC_URL --keystore $KEY_PATH --password $PASSWORD
```

## Useful Reads

- Contract source: `src/contracts/splitter/SplitterAccessControl.sol`
- ABI/Docs: `docs/src/src/contracts/splitter/SplitterAccessControl.sol/contract.SplitterAccessControl.md`


