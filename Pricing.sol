// SPDX-License-Identifier: MIT

/// @notice Master Merchant relays the pricing requests to the current merchant
// (which can be changed). There will be one master merchant and all the creches
// will point to the same one. When pricing strategy needs to be changed, a new
// merchant can be set.
interface IMasterMerchant {
    function setCurrentMerchant(IMerchant _merchant) external;

    function calculateClaimFee(address[] memory _items, uint256[] memory _quantities) external view returns (uint256);
}

interface IMerchant {
    function calculateClaimFee(address[] memory _items, uint256[] memory _quantities) external view returns (uint256);
}

interface ICalculator {
    function calculateFee(address _item, uint256 _quantity) external view returns (uint256);
}
