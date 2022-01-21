// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/dfk/QuestCore.sol";
import "./interfaces/dfk/Profiles.sol";
import "./interfaces/Types.sol";

contract Treasury is AccessControlEnumerable {
    using SafeERC20 for IERC20;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    address[] public itemAddresses;

    modifier ownerOrManager() {
        require(hasRole(OWNER_ROLE, msg.sender) || hasRole(MANAGER_ROLE, msg.sender));
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function withdraw(address token, address to) public ownerOrManager {
        IERC20 item = IERC20(token);
        item.safeTransfer(to, item.balanceOf(address(this)));
    }
}
