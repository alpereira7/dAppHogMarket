// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HogMarket is Ownable, IERC721Receiver {

    uint public totalLocked = 0;

    uint public allowancePeriod = 60*60*24;
    uint public lockAllowance   = 100000000000000000000;
    uint public dailyAllowance  =   1000000000000000000;
    uint public burnAllowance   = 200000000000000000000;
    uint public buyPrice        = 300000000000000000000;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    struct Locking {
        uint24 tokenID;
        uint48 stakingStartTime;
        address owner;
    }
    mapping(uint => Locking) lockedNFT;

    ERC20 token;
    ERC721 nft;

    event Locked(address indexed user, uint tokenId);
    event Bought(address indexed user, uint tokenId);
    event Burned(address indexed user, uint tokenId);
    event Claimed(address indexed user, uint amount);

    constructor(ERC20 _token, ERC721 _nft) {
        token = _token;
        nft = _nft;
    }

    /*function lock(uint24[] calldata tokenIds) external {
        uint24 tokenId;
        totalLocked += tokenIds.length;

        for(uint24 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT.");
            require(lockedNFT[tokenId].stakingStartTime == 0, "NFT already locked.");
            require(token.balanceOf(address(this)) >= lockAllowance, "Insufficent balance in contract.");

            nft.transferFrom(msg.sender, address(this), tokenId);
            token.transferFrom(address(this), msg.sender, lockAllowance);
            emit Locked(msg.sender, tokenId);

            lockedNFT[tokenId] = Locking ({
                tokenID: tokenId,
                stakingStartTime: uint48(block.timestamp),
                owner: msg.sender
            });
        }
    }*/

    /*function burn(uint24 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT.");
        require(lockedNFT[tokenId].stakingStartTime == 0, "NFT is locked.");
        require(nft.ownerOf(tokenId) != burnAddress, "NFT locked.");
        require(token.balanceOf(address(this)) >= burnAllowance, "Insufficent balance in contract.");

        nft.transferFrom(msg.sender, burnAddress, tokenId);
        //token.transferFrom(address(this), msg.sender, burnAllowance);
        token.transfer(msg.sender, burnAllowance);

        emit Burned(msg.sender, tokenId);
    }*/

    function simpleBuy(uint24 tokenId) external {
        require(nft.balanceOf(address(this)) > 0, "No NFT to buy");
        //require(lockedNFT[tokenId].stakingStartTime > 0, "NFT is not locked.");
        require(token.balanceOf(msg.sender) >= buyPrice, "Insufficent balance.");

        //uint earned;
        //totalLocked -= 1;

        // Send daily rewards to former owner
        //Locking memory locking = lockedNFT[tokenId];
        //uint stakingStartTime = locking.stakingStartTime;
        //earned = (block.timestamp - stakingStartTime) * dailyAllowance / allowancePeriod;
        //token.transferFrom(address(this), locking.owner, earned);
        
        token.transferFrom(msg.sender, address(this), buyPrice);
        //nft.transferFrom(address(this), msg.sender, tokenId);
        nft.transferFrom(address(this), msg.sender, tokenId);

        //delete lockedNFT[tokenId];

        emit Bought(msg.sender, tokenId);
    }

    function buy(uint24 tokenId) external {
        require(nft.balanceOf(address(this)) > 0, "No NFT to buy");
        require(lockedNFT[tokenId].stakingStartTime > 0, "NFT is not locked.");
        require(token.balanceOf(msg.sender) >= buyPrice, "Insufficent balance.");

        uint earned;
        totalLocked -= 1;

        // Send daily rewards to former owner
        Locking memory locking = lockedNFT[tokenId];
        uint stakingStartTime = locking.stakingStartTime;
        earned = (block.timestamp - stakingStartTime) * dailyAllowance / allowancePeriod;
        token.transferFrom(address(this), locking.owner, earned);
        
        token.transferFrom(msg.sender, address(this), buyPrice);
        //nft.transferFrom(address(this), msg.sender, tokenId);
        nft.transferFrom(address(this), msg.sender, tokenId);

        delete lockedNFT[tokenId];

        emit Bought(msg.sender, tokenId);
    }

    /*function claimAllowance(uint24[] calldata tokenIds) external {
        uint24 tokenId;
        uint earned;
        uint totalEarned;

        for(uint24 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Locking memory locking = lockedNFT[tokenId];
            require(locking.owner == msg.sender, "Not the owner");

            uint stakingStartTime = locking.stakingStartTime;
            earned = (block.timestamp - stakingStartTime) * dailyAllowance / allowancePeriod;
            totalEarned += earned;
            lockedNFT[tokenId] = Locking({
                tokenID: uint24(tokenId),
                stakingStartTime: uint48(block.timestamp),
                owner: locking.owner
            });
        }

        if(totalEarned > 0) {
            token.transferFrom(address(this), msg.sender, totalEarned);
        }

        emit Claimed(msg.sender, totalEarned);
    }

    function getAllowance(address owner, uint24[] calldata tokenIds) external view returns(uint) {
        uint24 tokenId;
        uint earned;
        uint totalEarned;

        for(uint24 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Locking memory locking = lockedNFT[tokenId];
            require(locking.owner == owner, "Not the owner");
            
            uint stakingStartTime = locking.stakingStartTime;
            earned = (block.timestamp - stakingStartTime) * dailyAllowance / allowancePeriod;
            totalEarned += earned;
        }
        return totalEarned;
    }*/

    /*function NftLockedByOwner(address owner) external view returns(uint[] memory) {
        uint totalSupply = nft.totalSupply();
    }*/

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function withdrawERC721Tokens(address _addressOfToken, address _recipient, uint256 _id) external onlyOwner returns(bool){
        require(
            _addressOfToken != address(0)
            && _recipient != address(0)
        );
        nft.transferFrom(address(this), _recipient, _id);
        return true;
    }

    function withdrawHog(address _recipient, uint256 _value) external onlyOwner returns(bool){
        require(
            _recipient != address(0)
            && _value > 0
        );
        //ERCInterface token = ERCInterface(_addressOfToken);
        token.transfer(_recipient, _value);
        //emit ERC20TokensWithdrawn(_addressOfToken, _recipient, _value);
        return true;
    }
}