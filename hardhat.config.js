require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");

require('dotenv').config();

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;

module.exports = {
	solidity: '0.8.8',
	networks: {
		rinkeby: {
			url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
			accounts: [`${RINKEBY_PRIVATE_KEY}`],
		},
	},
};
