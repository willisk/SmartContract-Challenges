const { expect } = require('chai');
const { ethers, network } = require('hardhat');

describe('ExclusiveExchange', function () {
  let orderbook;

  before('Deploy!', async function () {
    const NFTOrderBook = await ethers.getContractFactory('NFTOrderBook');
    orderbook = await NFTOrderBook.deploy({ value: ethers.utils.parseEther('50') });
  });

  it('Attack!', async function () {
    // your attack here
  });

  after('Check!', async function () {
    console.log('orderbook balance', ethers.utils.formatEther(await ethers.provider.getBalance(orderbook.address)));
    expect(await ethers.provider.getBalance(orderbook.address)).to.be.lt(ethers.utils.parseEther('1'));
  });
});
