const { HardhatUserConfig } = require('hardhat/config');
require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();
const { ChainId, NetworkExplorer, NetworkName, rpcUrls } = require('./constants/network');

const yes = ['true', 't', 'yes', 'y', '1'];
const GAS_PROFILER = yes.includes((process.env.GAS_PROFILER || '').toLowerCase());

const { ETHSCAN_API_KEY, ARB_SCAN_API_KEY } = process.env;

const config = {
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
    enabled: GAS_PROFILER,
  },
  etherscan: {
    apiKey: {
      [NetworkName.Ethereum]: ETHSCAN_API_KEY || '',
      [NetworkName.ArbitrumOne]: ARB_SCAN_API_KEY || '',
      [NetworkName.ArbitrumSepolia]: ARB_SCAN_API_KEY || '',
    },
    customChains: [],
  },
  networks: {
    [NetworkName.Ethereum]: {
      chainId: ChainId.Ethereum,
      url: rpcUrls[ChainId.Ethereum],
      type: 'http',
    },
    [NetworkName.ArbitrumOne]: {
      chainId: ChainId.ArbitrumOne,
      url: rpcUrls[ChainId.ArbitrumOne],
      type: 'http',
    },
    [NetworkName.ArbitrumSepolia]: {
      url: rpcUrls[ChainId.ArbitrumSepolia],
      chainId: ChainId.ArbitrumSepolia,
      type: 'http',
    },
  },
};

module.exports = config;
