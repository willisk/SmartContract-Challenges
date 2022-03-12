//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract ExclusiveNFT is ERC721('SoVIP', 'SoExclusive') {
    uint256 counter;

    function mint() external payable {
        require(msg.value >= 1 ether);
        _mint(msg.sender, counter++);
    }
}

/// Gated Exchange that only allows owners of allowed NFT collections to participate
/// pays dividends to its members
contract ExclusiveExchange {
    struct Offer {
        address owner;
        uint256 price;
    }

    ExclusiveNFT[] public memberCollections;

    mapping(uint256 => mapping(uint256 => Offer)) offers;
    mapping(address => uint256) accountData;

    // accountData:
    // 0xRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRCCCCCCCCCCCCCCCCMMMMMMMMMMMMMMMM
    // M: membership Id
    // C: creation date
    // R: rewards

    // basically bitmaps because my twitter feed is full of @t11 and Russia made gas expensive

    constructor() payable {
        require(msg.value == 50 ether);
        for (uint256 i; i < 3; i++) memberCollections.push(new ExclusiveNFT());
    }

    /* ------------- Memberships ------------ */

    function registerMember(uint256 collection) external {
        require(accountData[msg.sender] == 0, 'Ser, you already registered.');

        uint256 newAccountData = ((block.timestamp << 64) | collection);
        require(isVIP(msg.sender, newAccountData), 'Ser, you are not welcome, pls leave.');

        accountData[msg.sender] = newAccountData;
    }

    /* ------------- Exchange ------------ */

    function offerNFT(
        uint256 collection,
        uint256 tokenId,
        uint256 price
    ) public onlyVIP {
        require(price >= 1 ether, 'No undercutting pls');

        memberCollections[collection].transferFrom(msg.sender, address(this), tokenId);
        offers[collection][tokenId] = Offer(msg.sender, price);

        accountData[msg.sender] += uint256(1) << 128; // reward user
    }

    function buyNFT(uint256 collection, uint256 tokenId) public payable onlyVIP {
        Offer storage offer = offers[collection][tokenId];
        require(msg.value >= offer.price);

        memberCollections[collection].transferFrom(address(this), msg.sender, tokenId);
        payable(offer.owner).transfer((offer.price * 8) / 10);

        accountData[msg.sender] += uint256(1) << 128;

        delete offers[collection][tokenId];
    }

    /* ------------- Rewards ------------ */

    function claimRewards() external onlyVIP {
        uint256 data = accountData[msg.sender];
        uint256 numRewards = data >> 128;

        payable(msg.sender).transfer(numRewards * 0.01 ether);
        accountData[msg.sender] &= ~(type(uint256).max << 128); // wipe rewards
    }

    /* ------------- Internal ------------ */

    function isVIP(address user, uint256 data) private view returns (bool) {
        uint256 collection = data & 0xFFFFFFFFFFFFFFFF;
        return memberCollections[collection].balanceOf(user) > 0;
    }

    modifier onlyVIP() {
        uint256 data = accountData[msg.sender];
        require(isVIP(msg.sender, data), 'Ser, no VIP, no trade.');
        _;
    }
}
