// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./Pricer.sol";
import "../interfaces/Pricing.sol";

contract Merchant is IMerchant, AccessControlEnumerable {
    address public jewelAddress = 0x72Cb10C6bfA5624dD07Ef608027E366bd690048F;
    address public payoutAddress;
    mapping(address => ICalculator) public calculators;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor(address _payout) {
        payoutAddress = _payout;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);
    }

    function setPayoutAddress(address _payout) external onlyRole(OWNER_ROLE) {
        payoutAddress = _payout;
    }

    function setItemValueCalculators(address[] memory _items, address[] memory _calculators)
        external
        onlyRole(OWNER_ROLE)
    {
        require(_items.length == _calculators.length, "Length of items and calculators must match");

        for (uint256 i = 0; i < _items.length; i++) {
            calculators[_items[i]] = ICalculator(_calculators[i]);
        }
    }

    function calculateClaimFee(address[] memory _items, uint256[] memory _quantities)
        public
        view
        override
        returns (uint256)
    {
        require(_items.length == _quantities.length, "Length of items and quantities must match");

        uint256 fee = 0;
        for (uint256 i = 0; i < _items.length; i++) {
            ICalculator calculator = calculators[_items[i]];
            fee += calculator.calculateFee(_items[i], _quantities[i]);
        }

        return fee;
    }
}
