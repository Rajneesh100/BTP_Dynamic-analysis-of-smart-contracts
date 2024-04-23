{{
  "language": "Solidity",
  "sources": {
    "src/SafeDaoFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.17;\n\nimport {IGnosisSafeProxyFactory} from \"./IGnosisSafeProxyFactory.sol\";\nimport {ISafeDaoFactory} from \"./ISafeDaoFactory.sol\";\nimport {CREATE3} from \"solmate/utils/CREATE3.sol\";\n\ncontract SafeDaoFactory is ISafeDaoFactory {\n    event ProxyCreation(address proxy, address singleton);\n\n    address public immutable SAFE_FACTORY;\n    address public immutable SAFE_SINGLETON;\n\n    constructor(address safe, address singleton) {\n        require(safe != address(0), \"za\");\n        require(singleton != address(0), \"za\");\n        SAFE_FACTORY = safe;\n        SAFE_SINGLETON = singleton;\n    }\n\n    function deploy(bytes32 salt, bytes memory initializer) external payable returns (address proxy) {\n        bytes memory creationCode = IGnosisSafeProxyFactory(SAFE_FACTORY).proxyCreationCode();\n        bytes memory deploymentCode = abi.encodePacked(creationCode, uint256(uint160(SAFE_SINGLETON)));\n        salt = keccak256(abi.encodePacked(msg.sender, salt));\n        proxy = CREATE3.deploy(salt, deploymentCode, msg.value);\n        require(initializer.length > 0, \"!setup\");\n        assembly {\n            if eq(call(gas(), proxy, 0, add(initializer, 0x20), mload(initializer), 0, 0), 0) { revert(0, 0) }\n        }\n        emit ProxyCreation(proxy, SAFE_SINGLETON);\n    }\n\n    function getDeployed(address deployer, bytes32 salt) external view override returns (address deployed) {\n        salt = keccak256(abi.encodePacked(deployer, salt));\n        return CREATE3.getDeployed(salt);\n    }\n}\n"
    },
    "src/IGnosisSafeProxyFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.17;\n\ninterface IGnosisSafeProxyFactory {\n    function proxyCreationCode() external pure returns (bytes memory);\n}\n"
    },
    "src/ISafeDaoFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.17;\n\ninterface ISafeDaoFactory {\n    function deploy(bytes32 salt, bytes memory initializer) external payable returns (address proxy);\n    function getDeployed(address deployer, bytes32 salt) external view returns (address deployed);\n}\n"
    },
    "lib/create3-deploy/lib/solmate/src/utils/CREATE3.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\nimport {Bytes32AddressLib} from \"./Bytes32AddressLib.sol\";\n\n/// @notice Deploy to deterministic addresses without an initcode factor.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/CREATE3.sol)\n/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)\nlibrary CREATE3 {\n    using Bytes32AddressLib for bytes32;\n\n    //--------------------------------------------------------------------------------//\n    // Opcode     | Opcode + Arguments    | Description      | Stack View             //\n    //--------------------------------------------------------------------------------//\n    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //\n    // 0x37       |  0x37                 | CALLDATACOPY     |                        //\n    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //\n    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //\n    // 0xf0       |  0xf0                 | CREATE           | newContract            //\n    //--------------------------------------------------------------------------------//\n    // Opcode     | Opcode + Arguments    | Description      | Stack View             //\n    //--------------------------------------------------------------------------------//\n    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //\n    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //\n    // 0x52       |  0x52                 | MSTORE           |                        //\n    // 0x60       |  0x6008               | PUSH1 08         | 8                      //\n    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //\n    // 0xf3       |  0xf3                 | RETURN           |                        //\n    //--------------------------------------------------------------------------------//\n    bytes internal constant PROXY_BYTECODE = hex\"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3\";\n\n    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);\n\n    function deploy(\n        bytes32 salt,\n        bytes memory creationCode,\n        uint256 value\n    ) internal returns (address deployed) {\n        bytes memory proxyChildBytecode = PROXY_BYTECODE;\n\n        address proxy;\n        /// @solidity memory-safe-assembly\n        assembly {\n            // Deploy a new contract with our pre-made bytecode via CREATE2.\n            // We start 32 bytes into the code to avoid copying the byte length.\n            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)\n        }\n        require(proxy != address(0), \"DEPLOYMENT_FAILED\");\n\n        deployed = getDeployed(salt);\n        (bool success, ) = proxy.call{value: value}(creationCode);\n        require(success && deployed.code.length != 0, \"INITIALIZATION_FAILED\");\n    }\n\n    function getDeployed(bytes32 salt) internal view returns (address) {\n        address proxy = keccak256(\n            abi.encodePacked(\n                // Prefix:\n                bytes1(0xFF),\n                // Creator:\n                address(this),\n                // Salt:\n                salt,\n                // Bytecode hash:\n                PROXY_BYTECODE_HASH\n            )\n        ).fromLast20Bytes();\n\n        return\n            keccak256(\n                abi.encodePacked(\n                    // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)\n                    // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)\n                    hex\"d6_94\",\n                    proxy,\n                    hex\"01\" // Nonce of the proxy contract (1)\n                )\n            ).fromLast20Bytes();\n    }\n}\n"
    },
    "lib/create3-deploy/lib/solmate/src/utils/Bytes32AddressLib.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Library for converting between addresses and bytes32 values.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Bytes32AddressLib.sol)\nlibrary Bytes32AddressLib {\n    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {\n        return address(uint160(uint256(bytesValue)));\n    }\n\n    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {\n        return bytes32(bytes20(addressValue));\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "ds-test/=lib/create3-deploy/lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/create3-deploy/lib/forge-std/src/",
      "solmate/=lib/create3-deploy/lib/solmate/src/",
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