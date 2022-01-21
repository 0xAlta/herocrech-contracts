// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/dfk/QuestCore.sol";
import "./interfaces/dfk/Profiles.sol";
import "./interfaces/Types.sol";
import "./AddressProxy.sol";
import "./ItemProxy.sol";
import "./Treasury.sol";

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

enum QuestType {
    Unknown,
    Foraging,
    Fishing,
    MiningGold
}

contract BasicCreche is AccessControlEnumerable {
    struct HeroQuestSetting {
        uint256 heroId;
        QuestType quest;
    }

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");
    bytes32 public constant CRANK_ROLE = keccak256("CRANK_ROLE");

    AddressProxy public addressProxy;
    ItemProxy public itemProxy;

    /// @notice The person who the heroes belong to. Any returned heroes
    /// get sent to this address.
    address public heroOwner;

    /// @dev list of staked hero Ids
    uint256[] public heroes;

    /// @notice Mapping of heroId to quest type
    mapping(uint256 => QuestType) public heroQuestConfig;

    // Modifiers

    modifier ownerOrManager() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(MANAGER_ROLE, msg.sender));
        _;
    }

    modifier onlyPlayer() {
        require(hasRole(PLAYER_ROLE, msg.sender));
        _;
    }

    modifier managerOrPlayer() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(MANAGER_ROLE, msg.sender) ||
                hasRole(PLAYER_ROLE, msg.sender)
        );
        _;
    }

    constructor(
        AddressProxy _addressProxy,
        ItemProxy _itemProxy,
        address _heroOwner,
        string memory _profileName
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setupRole(PLAYER_ROLE, _heroOwner);

        heroOwner = _heroOwner;
        addressProxy = _addressProxy;
        itemProxy = _itemProxy;

        // Create a DFK profile.
        Profiles profilesContract = Profiles(addressProxy.getAddress(AddressProxy.DFKContract.PROFILES));
        profilesContract.createProfile(_profileName, 6);
    }

    // Proxy accessors

    function getQuestCore() internal view returns (QuestCore) {
        return QuestCore(addressProxy.getAddress(AddressProxy.DFKContract.QUESTCORE));
    }

    // Staking

    /// @notice Get all staked heroes for the frontend
    function getStakedHeroes() external view returns (uint256[] memory) {
        return heroes;
    }

    /// @notice Add heroes to be used for farming
    function stakeHero(uint256 _tokenId, QuestType _qt) external onlyRole(PLAYER_ROLE) {
        require(_qt != QuestType.Unknown, "Invalid quest type");

        /// Used for simplicity for now as we are the receiver
        address herocoreAddress = addressProxy.getAddress(AddressProxy.DFKContract.HEROCORE);
        IERC721(herocoreAddress).transferFrom(msg.sender, address(this), _tokenId);
        heroes.push(_tokenId);
        heroQuestConfig[_tokenId] = _qt;
    }

    /// @notice Transfer a hero back to the owner. Including NFTs that were sent
    /// directly to the contract.
    function unstakeHero(uint256 tokenId) public managerOrPlayer {
        address herocoreAddress = addressProxy.getAddress(AddressProxy.DFKContract.HEROCORE);
        IERC721(herocoreAddress).safeTransferFrom(address(this), heroOwner, tokenId);

        /// @dev Gas-efficient way to remove the character
        int256 index = -1;
        for (uint256 i = 0; i < heroes.length; i++) {
            if (heroes[i] == tokenId) {
                index = int256(i);
            }
        }
        if (index > -1) {
            // swap index with last element
            heroes[uint256(index)] = heroes[heroes.length - 1];
            // pop last element
            heroes.pop();
        }
    }

    function unstakeAll() external managerOrPlayer {
        while (heroes.length > 0) {
            unstakeHero(heroes[0]);
        }
    }

    /// @notice Transfer heroes not sent via the stakeHero function.
    /// @dev This should not occur in practice but is implemented to prevent random
    /// NFTs being accidentally sent to the contract.
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        address herocoreAddress = addressProxy.getAddress(AddressProxy.DFKContract.HEROCORE);
        require(msg.sender == address(herocoreAddress), "WRONG_NFT_CONTRACT");
        require(_from == heroOwner, "Can only receive NFTs owned by the owner");

        // we assume msg.sender is the NFT contract conducting the transfer
        heroes.push(_tokenId);

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    // Settings

    function setHeroQuestType(uint256 _heroId, QuestType _qt) public onlyPlayer {
        heroQuestConfig[_heroId] = _qt;
    }

    function getHeroQuestTypes() public view returns (HeroQuestSetting[] memory) {
        HeroQuestSetting[] memory settings = new HeroQuestSetting[](heroes.length);

        for (uint256 index = 0; index < heroes.length; index++) {
            uint256 hero = heroes[index];
            settings[index] = HeroQuestSetting(hero, heroQuestConfig[hero]);
        }
        return settings;
    }

    // Questing

    function startAttemptQuest(
        uint256[] memory _heroIds,
        address _questAddress,
        uint8 _attempts
    ) external onlyRole(CRANK_ROLE) {
        getQuestCore().startQuest(_heroIds, _questAddress, _attempts);
    }

    function completeQuest(uint256 _heroId) external {
        getQuestCore().completeQuest(_heroId);
    }

    function getActiveQuests() external view returns (IQuestTypes.Quest[] memory) {
        return getQuestCore().getActiveQuests(address(this));
    }

    // Rewards

    function getItemBalances(address[] memory items) external view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](items.length);
        for (uint256 index = 0; index < items.length; index++) {
            balances[index] = IERC20(items[index]).balanceOf(address(this));
        }
        return balances;
    }
}
