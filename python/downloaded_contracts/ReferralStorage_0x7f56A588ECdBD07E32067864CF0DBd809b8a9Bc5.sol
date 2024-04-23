{{
  "language": "Solidity",
  "sources": {
    "src/referrals/ReferralStorage.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity >=0.8.21;\n\nimport { Ownable } from \"@openzeppelin/contracts/access/Ownable.sol\";\nimport { IReferralStorage } from \"./interfaces/IReferralStorage.sol\";\n\ncontract ReferralStorage is Ownable, IReferralStorage {\n    mapping(address => bool) public isHandler;\n    mapping(bytes32 => address) public override codeOwner;\n    mapping(address => bytes32) public override accountCodeOwned;\n    mapping(address => bytes32) public override accountReferralCode;\n\n    event RegisterCode(address account, bytes32 code);\n    event SetAccountReferralCode(address account, bytes32 code);\n    event SetCodeOwner(bytes32 code, address newAccount);\n    event AdminSetCodeOwner(bytes32 code, address newAccount);\n\n    // solhint-disable-next-line no-empty-blocks\n    constructor() Ownable(msg.sender) { }\n\n    /// @dev Registers an handler.\n    /// @param _account The account.\n    /// @param _isActive Flag to activate/deactivate the handler.\n    function registerHandler(address _account, bool _isActive) external onlyOwner {\n        isHandler[_account] = _isActive;\n    }\n\n    /// @dev Registers a referral code.\n    /// @param _code The referral code.\n    function registerCode(bytes32 _code) external {\n        require(_code != bytes32(0), \"ReferralStorage: invalid code\");\n        require(codeOwner[_code] == address(0), \"ReferralStorage: code already exists\");\n        require(accountCodeOwned[msg.sender] == bytes32(0), \"ReferralStorage: account already has a code\");\n\n        codeOwner[_code] = msg.sender;\n        accountCodeOwned[msg.sender] = _code;\n\n        emit RegisterCode(msg.sender, _code);\n    }\n\n    /// @dev Sets a referral code for the given account.\n    /// @param _account The account to set the referral code for.\n    /// @param _code The referral code.\n    function setAccountReferralCode(address _account, bytes32 _code) external override {\n        require(isHandler[msg.sender], \"ReferralStorage: forbidden\");\n        require(codeOwner[_code] != address(0), \"ReferralStorage: code doesn't exist\");\n        require(codeOwner[_code] != _account, \"ReferralStorage: can't set own code\");\n        _setAccountReferralCode(_account, _code);\n    }\n\n    /// @dev Sets a referral code for the caller.\n    /// @param _code The referral code.\n    function adminSetCodeOwner(bytes32 _code, address _newAccount) external override onlyOwner {\n        require(_code != bytes32(0), \"ReferralStorage: invalid _code\");\n\n        address oldOwner = codeOwner[_code];\n\n        codeOwner[_code] = _newAccount;\n        accountCodeOwned[_newAccount] = _code;\n        accountCodeOwned[oldOwner] = bytes32(0);\n\n        emit AdminSetCodeOwner(_code, _newAccount);\n    }\n\n    /// @dev Returns referral info for the account.\n    /// @param _account The account.\n    function getAccountReferralInfo(address _account) external view override returns (bytes32, address) {\n        bytes32 code = accountReferralCode[_account];\n        address referrer;\n        if (code != bytes32(0)) {\n            referrer = codeOwner[code];\n        }\n        return (code, referrer);\n    }\n\n    /// @dev Sets a referral code for the account.\n    /// @param _account The account.\n    /// @param _code The referral code.\n    function _setAccountReferralCode(address _account, bytes32 _code) private {\n        accountReferralCode[_account] = _code;\n        emit SetAccountReferralCode(_account, _code);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "src/referrals/interfaces/IReferralStorage.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity >=0.8.21;\n\ninterface IReferralStorage {\n    function codeOwner(bytes32 _code) external view returns (address);\n    function accountCodeOwned(address _account) external view returns (bytes32);\n    function accountReferralCode(address _account) external view returns (bytes32);\n    function setAccountReferralCode(address _account, bytes32 _code) external;\n    function getAccountReferralInfo(address _account) external view returns (bytes32, address);\n    function adminSetCodeOwner(bytes32 _code, address _newAccount) external;\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@prb/test/=lib/prb-test/src/",
      "forge-std/=lib/forge-std/src/",
      "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
      "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",
      "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/",
      "prb-test/=lib/prb-test/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 10000
    },
    "viaIR": true,
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "none",
      "appendCBOR": true
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "evmVersion": "paris",
    "libraries": {}
  }
}}