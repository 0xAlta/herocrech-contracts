// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../interfaces/Pricing.sol";

contract MasterMerchant is IMasterMerchant, AccessControlEnumerable {
    IMerchant public currentMerchant;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor(IMerchant _merchant) {
        currentMerchant = _merchant;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);
    }

    function setCurrentMerchant(IMerchant _merchant) external override onlyRole(OWNER_ROLE) {
        currentMerchant = _merchant;
    }

    function calculateClaimFee(address[] memory _items, uint256[] memory _quantities)
        external
        view
        override
        returns (uint256)
    {
        return IMerchant(currentMerchant).calculateClaimFee(_items, _quantities);
    }
}
