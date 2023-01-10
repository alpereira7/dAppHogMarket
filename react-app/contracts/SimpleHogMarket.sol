// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Hog.sol";

contract SimpleHogMarket is Ownable, IERC721Receiver {
    uint public buyPrice = 400000000000000000000;
    uint public burnRate = 10;

    HOG token;
    ERC721 nft;

    event Bought(address indexed user, uint tokenId);

    constructor(HOG _token, ERC721 _nft) {
        token = _token;
        nft = _nft;
    }

    function simpleBuy(uint24 tokenId) external {
        require(nft.balanceOf(address(this)) > 0, "No NFT to buy");
        require(token.balanceOf(msg.sender) >= buyPrice, "Insufficent balance.");

        uint toBurn = (buyPrice*burnRate)/100;
        
        token.transferFrom(msg.sender, address(this), buyPrice);
        nft.transferFrom(address(this), msg.sender, tokenId);
        token.burn(toBurn);

        emit Bought(msg.sender, tokenId);
    }

    // Admin functions

    function setBuyPrice(uint _buyPrice) external onlyOwner {
        buyPrice = _buyPrice;
    }

    function setBurnRate(uint _burnRate) external onlyOwner {
        burnRate = _burnRate;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function withdrawERC721Tokens(address _addressOfToken, address _recipient, uint256 _id) external onlyOwner returns(bool){
        require(
            _addressOfToken != address(0)
            && _recipient != address(0)
        );
        ERC721 _nft = ERC721(_addressOfToken);
        _nft.transferFrom(address(this), _recipient, _id);
        return true;
    }

    function withdrawHog(address _recipient, uint256 _value) external onlyOwner returns(bool){
        require(
            _recipient != address(0)
            && _value > 0
        );
        token.transfer(_recipient, _value);
        return true;
    }
}