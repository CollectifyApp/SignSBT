require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");

if (process.env.REPORT_GAS) {
  require('hardhat-gas-reporter');
}

if (process.env.REPORT_COVERAGE) {
  require('solidity-coverage');
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.11',
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    showTimeSpent: true,
  },
  etherscan: {
    apiKey: {
      rinkeby: process.env.ETHERSCAN_API_KEY || '3JSHQXPY5D3NENRIUJDTVJ9WD4NXG16TMR',
      bsc: process.env.ETHERSCAN_API_KEY || 'IQTUHGGZEGHS1R9NZV97I3N8A16PWN9G9M',
      goerli: process.env.ETHERSCAN_API_KEY || '3JSHQXPY5D3NENRIUJDTVJ9WD4NXG16TMR',
    },
  },
  networks: {
    development: {
      url: "http://localhost:24012/rpc",
    },
    rinkeby: {
      url: "http://localhost:24012/rpc",
    },
    bsc: {
      url: "http://localhost:24012/rpc",
    },
    goerli: {
      url: "http://localhost:24012/rpc",
    },
  },
  plugins: ['solidity-coverage'],
};
