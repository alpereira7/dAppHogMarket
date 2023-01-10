// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HOG is ERC20, Ownable {

    constructor() ERC20("Harmonaut Original Token", "HOG") {
        _mint(msg.sender, 800000000000000000000000);
    }
 
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
   
    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}