// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./ClaimableCreche.sol";

contract CrecheFactory is AccessControlEnumerable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    event CrecheCreated(address crecheAddress);

    AddressProxy public addressProxy;
    ItemProxy public itemProxy;
    IMasterMerchant public masterMerchant;

    address private crank;
    address private admin;

    address[] public creches;
    mapping(address => address) public ownerToCreche;

    // Eligibility
    bool isAllowlistOnly;
    bool isEnabled;
    mapping(address => bool) public allowlistAddresses;

    constructor(
        AddressProxy _addressProxy,
        ItemProxy _itemProxy,
        IMasterMerchant _masterMerchant,
        address _crank
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        addressProxy = _addressProxy;
        itemProxy = _itemProxy;
        masterMerchant = _masterMerchant;

        admin = msg.sender;
        crank = _crank;
        isEnabled = true;
        isAllowlistOnly = true;
    }

    // Eligibility

    function canCreateCreche() internal view returns (bool) {
        if (!isEnabled) {
            return false;
        }
        if (isAllowlistOnly) {
            return allowlistAddresses[msg.sender];
        }
        return true;
    }

    function setAllowlistAddress(address addr, bool val) external onlyRole(MANAGER_ROLE) {
        allowlistAddresses[addr] = val;
    }

    function setEnabled(bool val) external onlyRole(MANAGER_ROLE) {
        isEnabled = val;
    }

    // Factory

    function createCreche(string memory name) external {
        require(canCreateCreche(), "Not able to create creche");
        require(ownerToCreche[msg.sender] == address(0), "Only 1 creche per wallet");

        ClaimableCreche creche = new ClaimableCreche(addressProxy, itemProxy, msg.sender, name, masterMerchant);
        creche.grantRole(creche.CRANK_ROLE(), crank);

        address child = address(creche);
        creches.push(child);
        ownerToCreche[msg.sender] = child;
        emit CrecheCreated(child);
    }

    function getAllCreches() external view returns (address[] memory) {
        return creches;
    }
}
