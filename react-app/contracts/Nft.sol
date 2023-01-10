// SPDX-License-Identifier:UNLICENSED

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract nft is ERC721("nft", "NFT") {
    uint tokenId;
    function mint(address recipient) public {
        _safeMint(recipient, tokenId);
        tokenId = tokenId + 1;
    }
}