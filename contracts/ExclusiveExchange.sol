//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract ExclusiveNFT is ERC721('SoVIP', 'SoExclusive') {
    uint256 counter;
    uint256 price;

    constructor(uint256 price_) {
        price = price_;
    }

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

    mapping(uint256 => ExclusiveNFT) public memberCollections;

    mapping(uint256 => mapping(uint256 => Offer)) offers;
    mapping(address => uint256) accountData;

    // accountData:
    // 0xRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    // T: Tier
    // R: rewards

    // basically bitmaps because my twitter feed is full of @t11 and Russia made gas expensive

    constructor() payable {
        require(msg.value == 50 ether);
        for (uint256 i = 1; i < 4; i++) memberCollections[i] = new ExclusiveNFT(i * 1 ether);
    }

    /* ------------- Exchange ------------ */

    function offerNFT(
        uint256 tier,
        uint256 tokenId,
        uint256 price
    ) public onlyVIP {
        require(price >= 1 ether, 'No undercutting pls');

        memberCollections[tier].transferFrom(msg.sender, address(this), tokenId);
        offers[tier][tokenId] = Offer(msg.sender, price);

        accountData[msg.sender] += uint256(1) << 128; // store number of trades for rewards
    }

    function buyNFT(uint256 tier, uint256 tokenId) public payable onlyVIP {
        Offer memory offer = offers[tier][tokenId];
        require(msg.value >= offer.price, "Ser, where's the money?");

        memberCollections[tier].transferFrom(address(this), msg.sender, tokenId);
        payable(offer.owner).transfer((offer.price * 8) / 10); // 20% tax

        accountData[msg.sender] += uint256(1) << 128; // reward user

        delete offers[tier][tokenId];
    }

    /* ------------- Rewards ------------ */

    function claimRewards() external onlyVIP {
        uint256 data = accountData[msg.sender];

        uint256 tier = uint128(data);
        uint256 numRewards = data >> 128;

        payable(msg.sender).transfer(numRewards * tier * 0.01 ether);
        accountData[msg.sender] &= type(uint128).max; // wipe rewards
    }

    /* ------------- Memberships ------------ */

    function registerMember(uint256 tier) external {
        require(isVIP(msg.sender, tier), 'Ser, you are not welcome, pls leave.');
        accountData[msg.sender] = tier;
    }

    // user must still be a valid holder for every interaction
    function isVIP(address user, uint256 data) private view returns (bool) {
        uint256 tier = uint128(data);
        return memberCollections[tier].balanceOf(user) > 0;
    }

    modifier onlyVIP() {
        uint256 data = accountData[msg.sender];
        require(isVIP(msg.sender, data), 'Ser, no VIP, no trade.');
        _;
    }
}
