// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../uniswapv2/interfaces/IUniswapV2Router02.sol";
import "../interfaces/Pricing.sol";

contract Pricer {
    address public jewelAddress = 0x72Cb10C6bfA5624dD07Ef608027E366bd690048F;
    address public routerAddress = 0x24ad62502d1C652Cc7684081169D04896aC20f30;

    /// @notice jewelValue converts the price of a given item to jewel using the AMM.
    function jewelValue(address _item, uint256 _quantity) internal view returns (uint256 value) {
        address[] memory path = new address[](2);
        path[0] = _item;
        path[1] = jewelAddress;

        return IUniswapV2Router02(routerAddress).getAmountsOut(_quantity, path)[1];
    }
}

contract ItemCalculator is ICalculator, Pricer {
    uint256 public feePercent = 20;

    // Returns 20% of the AMM value
    function calculateFee(address _item, uint256 _quantity) public view override returns (uint256) {
        uint256 value = jewelValue(_item, _quantity);
        return (feePercent * value) / 100;
    }
}

// // e.g. for pet eggs
contract RareItemCalculator is ICalculator {
    // Returns flat fee of 1 Jewel
    function calculateFee(address _item, uint256 _quantity) public pure override returns (uint256) {
        return 1 ether * _quantity;
    }
}

contract JewelCalculator is ICalculator {
    uint256 public feePercent = 20;

    function calculateFee(address _item, uint256 _quantity) public view override returns (uint256) {
        return (feePercent * _quantity) / 100;
    }
}

contract FreeCalculator is ICalculator {
    function calculateFee(address _item, uint256 _quantity) public pure override returns (uint256) {
        return 0;
    }
}
