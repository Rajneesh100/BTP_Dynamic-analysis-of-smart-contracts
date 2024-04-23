{{
  "language": "Solidity",
  "sources": {
    "src/LineRegistry.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity ^0.8.17;\n\nimport \"@openzeppelin/contracts/access/Ownable2Step.sol\";\nimport \"./interfaces/ILineMetadata.sol\";\n\n/// @title LineRegistry\n/// @notice LineRegistry will be deployed on each chain.\n///         It is the registry of messageLine and can be used to verify whether the line has been registered.\ncontract LineRegistry is Ownable2Step {\n    event AddLine(string name, address line);\n\n    string[] private _names;\n    // lineName => lineAddress\n    mapping(string => address) private _lineLookup;\n\n    constructor(address dao) {\n        _transferOwnership(dao);\n    }\n\n    function count() public view returns (uint256) {\n        return _names.length;\n    }\n\n    function list() public view returns (string[] memory) {\n        return _names;\n    }\n\n    function getLine(string calldata name) external view returns (address) {\n        return _lineLookup[name];\n    }\n\n    function addLine(address line) external onlyOwner {\n        string memory name = ILineMetadata(line).name();\n        require(_lineLookup[name] == address(0), \"Line name already exists\");\n        _names.push(name);\n        _lineLookup[name] = line;\n        emit AddLine(name, line);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Ownable.sol\";\n\n/**\n * @dev Contract module which provides access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership} and {acceptOwnership}.\n *\n * This module is used through inheritance. It will make available all functions\n * from parent (Ownable).\n */\nabstract contract Ownable2Step is Ownable {\n    address private _pendingOwner;\n\n    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Returns the address of the pending owner.\n     */\n    function pendingOwner() public view virtual returns (address) {\n        return _pendingOwner;\n    }\n\n    /**\n     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual override onlyOwner {\n        _pendingOwner = newOwner;\n        emit OwnershipTransferStarted(owner(), newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual override {\n        delete _pendingOwner;\n        super._transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev The new owner accepts the ownership transfer.\n     */\n    function acceptOwnership() public virtual {\n        address sender = _msgSender();\n        require(pendingOwner() == sender, \"Ownable2Step: caller is not the new owner\");\n        _transferOwnership(sender);\n    }\n}\n"
    },
    "src/interfaces/ILineMetadata.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity ^0.8.0;\n\ninterface ILineMetadata {\n    event URI(string uri);\n\n    /// @notice Get the line name, it's globally unique and immutable.\n    /// @return The MessageLine name.\n    function name() external view returns (string memory);\n\n    /// @return The line metadata uri.\n    function uri() external view returns (string memory);\n}\n"
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
      "@axelar-network/axelar-gmp-sdk-solidity/=lib/axelar-gmp-sdk-solidity/",
      "@layerzerolabs/solidity-examples/=lib/solidity-examples/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "@darwinia/contracts-periphery/=lib/darwinia-messages-sol/contracts/periphery/",
      "sgn-v2-contracts/=lib/sgn-v2-contracts/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/forge-std/src/",
      "ORMP/=lib/ORMP/",
      "create3-deploy/=lib/create3-deploy/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 999999
    },
    "metadata": {
      "useLiteralContent": true,
      "bytecodeHash": "ipfs"
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
    "evmVersion": "london",
    "libraries": {}
  }
}}