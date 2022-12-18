// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Quinque is ERC20 {
    address public theTokenAddress;

    constructor(address _theTokenAddress) ERC20("Quinque LP Token", "QLP") {
        require(_theTokenAddress != address(0), "address can't be empty");
        theTokenAddress = _theTokenAddress;
    }

    function getReserve() public view returns (uint256) {
        return ERC20(theTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 theTokenReserve = getReserve();
        ERC20 theToken = ERC20(theTokenAddress);

        if (theTokenReserve == 0) {
            theToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint256 ethReserve = ethBalance - msg.value;
            uint256 theTokenAmount = (msg.value * theTokenReserve) /
                (ethReserve);
            require(
                _amount >= theTokenAmount,
                "amount is less than the minimum required amount"
            );

            theToken.transferFrom(msg.sender, address(this), theTokenAmount);
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }
}
