// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
import "./BasicCreche.sol";
import "./pricing/MasterMerchant.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./AddressProxy.sol";

interface IClaimable {
    function claimFee(address[] memory _items, uint256[] memory _quantities) external view returns (uint256);

    function claim(address[] memory _items, uint256[] memory _quantities) external;
}

contract ClaimableCreche is BasicCreche, IClaimable {
    using SafeERC20 for IERC20;

    event Withdraw(address indexed user, address indexed item, uint256 amount);

    /// @notice Master Merchant is responsible for all the pricing and claiming.
    /// All the creche contracts will point to the same master
    /// merchant
    IMasterMerchant public masterMerchant;

    constructor(
        AddressProxy _addressProxy,
        ItemProxy _itemProxy,
        address _heroOwner,
        string memory _profileName,
        IMasterMerchant _masterMerchant
    ) BasicCreche(_addressProxy, _itemProxy, _heroOwner, _profileName) {
        masterMerchant = _masterMerchant;
    }

    function setMasterMerchant(IMasterMerchant _masterMerchant) external onlyRole(MANAGER_ROLE) {
        masterMerchant = _masterMerchant;
    }

    function claimFee(address[] memory _items, uint256[] memory _quantities) public view override returns (uint256) {
        return IMasterMerchant(masterMerchant).calculateClaimFee(_items, _quantities);
    }

    function _payFeeAndJewel(uint256 _fee, uint256 jewelQuantity) private {
        address jewelAddress = addressProxy.getAddress(AddressProxy.DFKContract.JEWEL);
        address payoutAddress = addressProxy.payoutAddress();
        uint256 jewelBalance = IERC20(jewelAddress).balanceOf(address(this));

        // when insufficient funds
        if (jewelBalance < _fee) {
            uint256 remainingFee = _fee - jewelBalance;
            // pay fee from user's wallet
            IERC20(jewelAddress).transferFrom(heroOwner, payoutAddress, remainingFee);
            if (jewelBalance > 0) {
                IERC20(jewelAddress).transfer(payoutAddress, jewelBalance);
            }
            return;
        }

        // pay fee
        if (_fee > 0) {
            IERC20(jewelAddress).transfer(payoutAddress, _fee);
            jewelBalance -= _fee;
        }

        // withdraw jewel
        if (jewelQuantity > 0) {
            uint256 withdrawAmount = jewelBalance >= jewelQuantity ? jewelQuantity : jewelBalance;
            IERC20(jewelAddress).transfer(heroOwner, withdrawAmount);
            emit Withdraw(heroOwner, jewelAddress, withdrawAmount);
        }
    }

    /// @notice Claim items from the creche inventory
    // We allow manager to claim as well, but the claim always goes to the player. This is to allow
    // force claiming for orphaned accounts in migration scenarios.
    function claim(address[] memory _items, uint256[] memory _quantities) external override managerOrPlayer {
        for (uint256 i = 0; i < _items.length - 1; i++) {
            for (uint256 j = i + 1; j < _items.length; j++) {
                if (_items[i] == _items[j]) {
                    revert("Duplicate item in claim");
                }
            }
        }

        require(_items.length == _quantities.length, "Length of items and quantities must match");
        address jewelAddress = addressProxy.getAddress(AddressProxy.DFKContract.JEWEL);

        uint256 jewelWithdrawAmount = 0;
        for (uint256 i = 0; i < _items.length; i++) {
            if (_items[i] == jewelAddress) {
                jewelWithdrawAmount = _quantities[i];
            }
        }

        // Note that this doesn't do a trasnfer is fee is 0
        uint256 fee = claimFee(_items, _quantities);
        _payFeeAndJewel(fee, jewelWithdrawAmount);

        for (uint256 i = 0; i < _items.length; i++) {
            if (_items[i] == jewelAddress) {
                continue;
            }

            IERC20(_items[i]).transfer(heroOwner, _quantities[i]);
            emit Withdraw(heroOwner, _items[i], _quantities[i]);
        }
    }
}
