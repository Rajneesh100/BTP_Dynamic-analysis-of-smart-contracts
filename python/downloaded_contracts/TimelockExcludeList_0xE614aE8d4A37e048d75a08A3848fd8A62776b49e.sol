{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
    },
    "remappings": [
      ":@mocks/=src/mocks/",
      ":@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      ":@openzeppelin/=lib/openzeppelin-contracts/",
      ":@permit2/=lib/permit2/src/",
      ":@src/=src/",
      ":@test/=test/",
      ":@uni-core/=src/uniswap/v3-core/",
      ":@uni-periphery/=src/uniswap/v3-periphery/",
      ":@uniswap/lib/=lib/solidity-lib/",
      ":@uniswap/v2-core/=lib/v2-core/",
      ":@uniswap/v3-core/contracts/=src/uniswap/v3-core/",
      ":base64-sol/=src/uniswap/v3-periphery/libraries/",
      ":ds-test/=lib/forge-std/lib/ds-test/src/",
      ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
      ":forge-std/=lib/forge-std/src/",
      ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
      ":permit2/=lib/permit2/",
      ":solidity-lib/=lib/solidity-lib/contracts/",
      ":solmate/=lib/permit2/lib/solmate/",
      ":v2-core/=lib/v2-core/contracts/"
    ],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "src/TimelockExcludeList.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.8.15;\n\nimport {Ownable} from \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract TimelockExcludeList is Ownable {\n    mapping(address => bool) public excludeFromAll;\n    mapping(address => mapping(uint256 => bool)) public excludeFromVault;\n\n    event ExcludeFromAllSet(address, bool);\n    event ExcludeFromVaultSet(address, uint256, bool);\n\n    function isExcludedFromAll(address addr) public view returns (bool) {\n        return excludeFromAll[addr];\n    }\n\n    function isExcludedFromVault(\n        address addr,\n        uint256 vaultId\n    ) public view returns (bool) {\n        return excludeFromVault[addr][vaultId];\n    }\n\n    function isExcluded(\n        address addr,\n        uint256 vaultId\n    ) external view returns (bool) {\n        return isExcludedFromAll(addr) || isExcludedFromVault(addr, vaultId);\n    }\n\n    function setExcludeFromAll(address addr, bool setting) external onlyOwner {\n        excludeFromAll[addr] = setting;\n        emit ExcludeFromAllSet(addr, setting);\n    }\n\n    function setExcludeFromVault(\n        address addr,\n        uint256 vaultId,\n        bool setting\n    ) external onlyOwner {\n        excludeFromVault[addr][vaultId] = setting;\n        emit ExcludeFromVaultSet(addr, vaultId, setting);\n    }\n}\n"
    }
  }
}}