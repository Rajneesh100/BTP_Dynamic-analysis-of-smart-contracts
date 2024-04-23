{{
  "language": "Solidity",
  "sources": {
    "src/StashVerifier.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.23;\n\nimport {IStash} from \"./interfaces/IStash.sol\";\nimport {IStashFactory} from \"./interfaces/IStashFactory.sol\";\n\n/**\n * @title StashVerifier\n * @author Yuga Labs\n * @custom:security-contact security@yugalabs.io\n * @notice Helper contract used by the StashFactory to make external calls to the Stash contract.\n */\ncontract StashVerifier {\n    address private immutable _STASH_FACTORY_ADDRESS;\n\n    constructor() {\n        _STASH_FACTORY_ADDRESS = msg.sender;\n    }\n\n    function isStash(address stashAddress) external view returns (bool) {\n        IStash stashContract = IStash(stashAddress);\n\n        uint256 size;\n        assembly {\n            size := extcodesize(stashAddress)\n        }\n        if (size == 0) return false;\n\n        // call owner() method on stash\n        (bool success, bytes memory result) = address(stashContract).staticcall(abi.encodeWithSelector(0x8da5cb5b));\n        if (!success) return false;\n\n        address stashOwner;\n        assembly {\n            // extract stash owner address from result\n            stashOwner := and(mload(add(result, 32)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)\n        }\n\n        address predictedAddress = IStashFactory(_STASH_FACTORY_ADDRESS).stashAddressFor(stashOwner);\n\n        // ensure that the stash owner would have deployed to the provided stashAddress\n        return predictedAddress == stashAddress;\n    }\n\n    function stashVersion(address stashAddress) external view returns (uint256) {\n        IStash stashContract = IStash(stashAddress);\n\n        return stashContract.version();\n    }\n}\n"
    },
    "src/interfaces/IStash.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nimport {OrderType} from \"../helpers/Enum.sol\";\nimport {Order} from \"../helpers/Struct.sol\";\n\ninterface IStash {\n    function placeOrder(uint80 pricePerUnit, uint16 numberOfUnits) external payable;\n    function processOrder(uint80 pricePerUnit, uint16 numberOfUnits) external;\n    function availableLiquidity(address tokenAddress) external view returns (uint256);\n    function wrapPunk(uint256 punkIndex) external;\n    function getOrder(address paymentToken) external view returns (Order memory);\n    function withdraw(address tokenAddress, uint256 amount) external;\n    function owner() external view returns (address);\n    function version() external view returns (uint256);\n}\n"
    },
    "src/interfaces/IStashFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\ninterface IStashFactory {\n    function isStash(address stash) external view returns (bool);\n    function deployStash(address owner) external returns (address);\n    function isAuction(address auction) external view returns (bool);\n    function stashAddressFor(address owner) external view returns (address);\n}\n"
    },
    "src/helpers/Enum.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nenum OrderType\n{\n    // 0: Can replace previous bid. Alters bid price and adds `numberOfUnits`\n    SUBSEQUENT_BIDS_OVERWRITE_PRICE_AND_ADD_UNITS,\n    // 1: Can replace previous bid if new bid has higher `pricePerUnit`\n    SUBSEQUENT_BIDS_REPLACE_EXISTING_PRICE_INCREASE_REQUIRED,\n    // 2: Cannot replace previous bid under any circumstance\n    UNREPLACEABLE\n}\n"
    },
    "src/helpers/Struct.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nimport {OrderType} from \"./Enum.sol\";\n\nstruct Order {\n    uint16 numberOfUnits;\n    uint80 pricePerUnit;\n    address auction;\n}\n\nstruct PunkBid {\n    Order order;\n    uint256 accountNonce;\n    uint256 bidNonce;\n    uint256 expiration;\n    bytes32 root;\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "forge-std/=lib/forge-std/src/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "ERC721A/=lib/ERC721A/contracts/",
      "solady/=lib/solady/src/",
      "soladytest/=lib/solady/test/",
      "sol-json/=lib/sol-json/src/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "solmate/=lib/sol-json/lib/solady/lib/solmate/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200
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
    "libraries": {}
  }
}}