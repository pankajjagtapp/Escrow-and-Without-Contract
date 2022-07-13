const hre = require('hardhat');

async function main() {

	const Operations = await hre.ethers.getContractFactory('TradeOperations');
	const operations = await Operations.deploy();
	console.log('Trade Operations address: ', operations.address);

	const Escrow = await hre.ethers.getContractFactory('EscrowModel');
	const escrow = await Escrow.deploy();
	console.log('Escrow Contract address: ', escrow.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
