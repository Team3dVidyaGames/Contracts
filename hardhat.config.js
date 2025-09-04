require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

const { INFURA_API_KEY, ETHSCAN_API_KEY, ARB_SCAN_API_KEY } = process.env;

const config = {
  paths: {
    sources: './src/contracts',
    tests: './test',
    cache: './cache/hardhat',
    artifacts: './artifacts',
  },
  solidity: {
    compilers: [
      {
        version: '0.5.10',
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: '0.8.24',
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: '0.8.28',
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
    ],
  },
  gasReporter: {
    enabled: process.env.GAS_PROFILER === 'true',
  },
  etherscan: {
    apiKey: {
      mainnet: ETHSCAN_API_KEY || '',
      arbitrumOne: ARB_SCAN_API_KEY || '',
      arbitrumSepolia: ARB_SCAN_API_KEY || '',
    },
    customChains: [],
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      url: 'http://127.0.0.1:8545',
      chainId: 1337,
    },
  },
};

module.exports = config;
