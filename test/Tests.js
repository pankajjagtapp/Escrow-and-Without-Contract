const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Test Cases', function () {
	let escrow;
	let operations;
	let orderExpiry = 60 * 60 * 24;
	let addr1;
	let addr2;
	let addr3;
	let addrs;

	beforeEach(async () => {
		[manager, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

		// For Escrow Model
		const Escrow = await hre.ethers.getContractFactory('EscrowModel');
		escrow = await Escrow.deploy();
		await escrow.deployed();

		// For Trade Operations
		const Operations = await hre.ethers.getContractFactory(
			'TradeOperations'
		);
		operations = await Operations.deploy();
		await operations.deployed();
	});

	describe('Deployment', async () => {
		it('Should track Order Expiry Time of the Operations', async () => {
			expect(await operations.orderExpiry()).to.equal(orderExpiry);
		});

		it('Should track Order Expiry Time of the Escrow Model', async () => {
			expect(await escrow.orderExpiry()).to.equal(orderExpiry);
		});
	});

	describe('Main Functions', async () => {
		it('Should place a Sell Order in Escrow Model Contract', async () => {
			await escrow.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.1'),
			});
			expect(await escrow.itemId()).to.equal(1);
		});

		it('Should place a Sell Order in Trade Operations Contract', async () => {
			await operations.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.25'),
			});
			expect(await operations.itemId()).to.equal(1);
		});

		it('Should cancel Sell Order in Escrow Model Contract', async () => {
			await escrow.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.1'),
			});
			await expect(
				escrow
					.cancelSale(1)
					.to.be.revertedWith('You are not the seller of the item')
			);
		});

		it('Should cancel Sell Order in Trade Operations Contract', async () => {
			await operations.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.25'),
			});
			await expect(
				operations
					.cancelSale(1)
					.to.be.revertedWith('You are not the seller')
			);
		});

		it('Should Bid in Trade Operations Contract', async () => {
			await operations.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.25'),
			});
			await expect(
				operations.connect(addr2).bid(1, 3000, {
					value: ethers.utils.parseEther('0.25'),
				})
			).not.to.be.reverted;
		});

        it('Should Buy Item in Escrow Model Contract', async () => {
			await escrow.connect(addr1).sellItem(2000, 'Description', {
				value: ethers.utils.parseEther('0.1'),
			});
			await expect(
				escrow.connect(addr2).buyItem(1, 3000, {
					value: ethers.utils.parseEther('0.000000000000003'),
				})
			).not.to.be.reverted;
		});
	});
});
