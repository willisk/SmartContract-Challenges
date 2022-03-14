const { expect } = require('chai');
const { ethers, network } = require('hardhat');

describe('ExclusiveExchange', function () {
  let exchange, nft1, nft2, nft3;

  before('Deploy!', async function () {
    const ExclusiveExchange = await ethers.getContractFactory('ExclusiveExchange');
    exchange = await ExclusiveExchange.deploy({ value: ethers.utils.parseEther('50') });

    const ExclusiveNFT = await ethers.getContractFactory('ExclusiveNFT');
    nft1 = ExclusiveNFT.attach(await exchange.memberCollections(1));
    nft2 = ExclusiveNFT.attach(await exchange.memberCollections(2));
    nft3 = ExclusiveNFT.attach(await exchange.memberCollections(3));
  });

  it('Attack!', async function () {
    // your attack here
  });

  after('Check!', async function () {
    console.log('exchange balance', ethers.utils.formatEther(await ethers.provider.getBalance(exchange.address)));
    expect(await ethers.provider.getBalance(exchange.address)).to.equal(ethers.utils.parseEther('0'));
  });
});
