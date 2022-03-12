const { expect } = require('chai');
const { ethers, network } = require('hardhat');

describe('ExclusiveExchange', function () {
  let exchange, nft1, nft2, nft3;

  before('Deploy!', async function () {
    const [attacker, deployer] = await ethers.getSigners();

    const ExclusiveExchange = await ethers.getContractFactory('ExclusiveExchange', deployer);
    exchange = await ExclusiveExchange.deploy({ value: ethers.utils.parseEther('50') });

    const ExclusiveNFT = await ethers.getContractFactory('ExclusiveNFT', deployer);
    nft1 = ExclusiveNFT.attach(await exchange.memberCollections(0));
    nft2 = ExclusiveNFT.attach(await exchange.memberCollections(1));
    nft3 = ExclusiveNFT.attach(await exchange.memberCollections(2));

    await ethers.provider.send('hardhat_setBalance', [attacker.address, ethers.utils.parseEther('5').toHexString()]);
  });

  it('Attack!', async function () {});

  after('Check!', async function () {
    expect(await ethers.provider.getBalance(exchange.address)).to.equal(ethers.utils.parseEther('0'));
  });
});
