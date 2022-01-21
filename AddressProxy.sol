// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./interfaces/dfk/QuestCore.sol";
import "./interfaces/dfk/Profiles.sol";
import "./interfaces/Types.sol";

contract AddressProxy is AccessControlEnumerable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    enum DFKContract {
        QUESTCORE,
        HEROCORE,
        PROFILES,
        ROUTERV2,
        JEWEL
    }

    mapping(DFKContract => address) public contractMapping;
    address public payoutAddress;

    constructor(address _payoutAddress) {
        payoutAddress = _payoutAddress;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);

        // During testing its simpler to hardcode the latest values here
        contractMapping[DFKContract.QUESTCORE] = 0x5100Bd31b822371108A0f63DCFb6594b9919Eaf4;
        contractMapping[DFKContract.HEROCORE] = 0x5F753dcDf9b1AD9AabC1346614D1f4746fd6Ce5C;
        contractMapping[DFKContract.PROFILES] = 0xabD4741948374b1f5DD5Dd7599AC1f85A34cAcDD;
        contractMapping[DFKContract.ROUTERV2] = 0x24ad62502d1C652Cc7684081169D04896aC20f30;
        contractMapping[DFKContract.JEWEL] = 0x72Cb10C6bfA5624dD07Ef608027E366bd690048F;
    }

    function setPayoutAddress(address _address) external onlyRole(MANAGER_ROLE) {
        payoutAddress = _address;
    }

    function setAddress(DFKContract key, address _address) external onlyRole(MANAGER_ROLE) {
        contractMapping[key] = _address;
    }

    function getAddress(DFKContract key) public view returns (address) {
        return contractMapping[key];
    }
}
