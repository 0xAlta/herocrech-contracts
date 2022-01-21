// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./interfaces/dfk/QuestCore.sol";
import "./interfaces/dfk/Profiles.sol";
import "./interfaces/Types.sol";

contract ItemProxy is AccessControlEnumerable {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    address[] public itemAddresses;

    modifier ownerOrManager() {
        require(hasRole(OWNER_ROLE, msg.sender) || hasRole(MANAGER_ROLE, msg.sender));
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);

        // During testing use hardcoded item addresses.
        address[24] memory items = [
            // Misc
            0x3a4EDcf3312f44EF027acfd8c21382a5259936e7, // Gold
            0x24eA0D436d3c2602fbfEfBe6a16bBc304C963D04, // Tears
            // Plants
            0x6e1bC01Cc52D165B357c42042cF608159A2B81c1,
            0xc0214b37FCD01511E6283Af5423CF24C96BB9808,
            0x68EA4640C5ce6cC0c9A1F17B7b882cB1cBEACcd7,
            0x600541aD6Ce0a8b5dae68f086D46361534D20E80,
            0x19B9F05cdE7A61ab7aae5b0ed91aA62FF51CF881,
            0x043F9bd9Bb17dFc90dE3D416422695Dd8fa44486,
            0x094243DfABfBB3E6F71814618ace53f07362a84c,
            0x6B10Ad6E3b99090De20bF9f95F960addC35eF3E2,
            0xAC5c49Ff7E813dE1947DC74bbb1720c353079ac9,
            0xCdfFe898E687E941b124dfB7d24983266492eF1d,
            // Fish
            0x78aED65A2Cc40C7D8B0dF1554Da60b38AD351432,
            0xe4Cfee5bF05CeF3418DA74CFB89727D8E4fEE9FA,
            0x8Bf4A0888451C6b5412bCaD3D9dA3DCf5c6CA7BE,
            0xc5891912718ccFFcC9732D1942cCD98d5934C2e1,
            0xb80A07e13240C31ec6dc0B5D72Af79d461dA3A70,
            0x372CaF681353758f985597A35266f7b330a2A44D,
            0x2493cfDAcc0f9c07240B5B1C4BE08c62b8eEff69,
            // Runes
            0x66F5BfD910cd83d3766c4B39d13730C911b2D286,
            // Eggs
            0x9678518e04Fe02FB30b55e2D0e554E26306d0892,
            0x6d605303e9Ac53C59A3Da1ecE36C9660c7A71da5,
            0x95d02C1Dc58F05A015275eB49E107137D9Ee81Dc,
            0x3dB1fd0Ad479A46216919758144FD15A21C3e93c
        ];

        for (uint256 index = 0; index < items.length; index++) {
            itemAddresses.push(items[index]);
        }
    }

    function getItemAddresses() public view returns (address[] memory) {
        return itemAddresses;
    }

    function addAddress(address _address) public ownerOrManager {
        itemAddresses.push(_address);
    }

    function addAddresses(address[] memory addresses) public ownerOrManager {
        for (uint256 i = 0; i < addresses.length; i++) {
            itemAddresses.push(addresses[i]);
        }
    }

    // @dev Removing addresses leaves the array sparse, so this must be filtered
    // on the client side. This will probably never be used, so not worried too
    // much about it.
    function removeAddress(address _address) public ownerOrManager {
        for (uint256 i = 0; i < itemAddresses.length; i++) {
            if (itemAddresses[i] == _address) {
                delete itemAddresses[i];
            }
        }
    }
}
