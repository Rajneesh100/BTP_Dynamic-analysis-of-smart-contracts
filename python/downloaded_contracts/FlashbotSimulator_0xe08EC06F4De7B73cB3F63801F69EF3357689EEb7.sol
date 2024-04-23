{{
  "language": "Solidity",
  "sources": {
    "src/FlashbotSimulator.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.19;\n\nimport { Ownable2Step } from \"@openzeppelin/contracts/access/Ownable2Step.sol\";\nimport { ReentrancyGuard } from \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\n\ncontract FlashbotSimulator is Ownable2Step, ReentrancyGuard {\n    uint256 public depositedAmount;\n\n    uint256 public counter;\n\n    bool public isStarted;\n\n    address public starter;\n\n    mapping(address => bool) public whitelist;\n\n    error DepositAmountMustBeGreaterThanZero();\n\n    error CallerIsNotStarter();\n\n    error CallerIsNotWhitelisted();\n\n    error NotStarted();\n\n    error CounterIsSmallerThanPrevious();\n\n    error NotEnoughAmountToPayMiners();\n\n    modifier onlyStarter() {\n        if (msg.sender != starter) {\n            revert CallerIsNotStarter();\n        }\n        _;\n    }\n\n    modifier onlyWhitelisted() {\n        if (!whitelist[msg.sender]) {\n            revert CallerIsNotWhitelisted();\n        }\n        _;\n    }\n\n    function withdawAll() external onlyOwner {\n        depositedAmount = 0;\n        payable(msg.sender).transfer(address(this).balance);\n    }\n\n    function setWhitelist(address _address, bool _isWhitelisted) external onlyOwner {\n        whitelist[_address] = _isWhitelisted;\n    }\n\n    function setStarter(address _starter) external onlyOwner {\n        starter = _starter;\n    }\n\n    function setStart(bool _isStarted) external onlyStarter {\n        if (!_isStarted) {\n            counter = 0;\n        }\n        isStarted = _isStarted;\n    }\n\n    function deposit() external payable {\n        if(msg.value == 0) {\n            revert DepositAmountMustBeGreaterThanZero();\n        }\n        depositedAmount += msg.value;\n    }\n\n    function execute(uint256 _counter, uint256 _amountToPayMiners) external nonReentrant onlyWhitelisted {\n        if (!isStarted) {\n            revert NotStarted();\n        }\n        if (_counter <= counter) {\n            revert CounterIsSmallerThanPrevious();\n        }\n        if (_amountToPayMiners > depositedAmount) {\n            revert NotEnoughAmountToPayMiners();\n        }\n        counter = _counter;\n\n        depositedAmount -= _amountToPayMiners;\n        block.coinbase.transfer(_amountToPayMiners);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Ownable.sol\";\n\n/**\n * @dev Contract module which provides access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership} and {acceptOwnership}.\n *\n * This module is used through inheritance. It will make available all functions\n * from parent (Ownable).\n */\nabstract contract Ownable2Step is Ownable {\n    address private _pendingOwner;\n\n    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Returns the address of the pending owner.\n     */\n    function pendingOwner() public view virtual returns (address) {\n        return _pendingOwner;\n    }\n\n    /**\n     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual override onlyOwner {\n        _pendingOwner = newOwner;\n        emit OwnershipTransferStarted(owner(), newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual override {\n        delete _pendingOwner;\n        super._transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev The new owner accepts the ownership transfer.\n     */\n    function acceptOwnership() public virtual {\n        address sender = _msgSender();\n        require(pendingOwner() == sender, \"Ownable2Step: caller is not the new owner\");\n        _transferOwnership(sender);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/forge-std/src/",
      "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/",
      "openzeppelin/=lib/openzeppelin-contracts/contracts/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200000
    },
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "ipfs",
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
    "viaIR": true,
    "libraries": {}
  }
}}