{{
  "language": "Solidity",
  "sources": {
    "AddNodeOperators.sol": {
      "content": "// SPDX-FileCopyrightText: 2023 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity 0.8.6;\n\nimport \"TrustedCaller.sol\";\nimport \"EVMScriptCreator.sol\";\nimport \"IEVMScriptFactory.sol\";\nimport \"INodeOperatorsRegistry.sol\";\nimport \"IACL.sol\";\n\n/// @notice Creates EVMScript to add new batch of node operators\ncontract AddNodeOperators is TrustedCaller, IEVMScriptFactory {\n    struct AddNodeOperatorInput {\n        string name;\n        address rewardAddress;\n        address managerAddress;\n    }\n\n    // -------------\n    // CONSTANTS\n    // -------------\n\n    bytes4 private constant ADD_NODE_OPERATOR_SELECTOR =\n        bytes4(keccak256(\"addNodeOperator(string,address)\"));\n    bytes4 private constant GRANT_PERMISSION_P_SELECTOR =\n        bytes4(keccak256(\"grantPermissionP(address,address,bytes32,uint256[])\"));\n    bytes32 private constant MANAGE_SIGNING_KEYS_ROLE = keccak256(\"MANAGE_SIGNING_KEYS\");\n\n    // -------------\n    // VARIABLES\n    // -------------\n\n    /// @notice Address of NodeOperatorsRegistry contract\n    INodeOperatorsRegistry public immutable nodeOperatorsRegistry;\n    /// @notice Address of Aragon ACL contract\n    IACL public immutable acl;\n    /// @notice Address of Lido contract\n    address public immutable lido;\n\n    // -------------\n    // ERRORS\n    // -------------\n\n    string private constant ERROR_MANAGER_ALREADY_HAS_ROLE = \"MANAGER_ALREADY_HAS_ROLE\";\n    string private constant ERROR_MANAGER_ADDRESSES_HAS_DUPLICATE =\n        \"MANAGER_ADDRESSES_HAS_DUPLICATE\";\n    string private constant ERROR_NODE_OPERATORS_COUNT_MISMATCH = \"NODE_OPERATORS_COUNT_MISMATCH\";\n    string private constant ERROR_LIDO_REWARD_ADDRESS = \"LIDO_REWARD_ADDRESS\";\n    string private constant ERROR_ZERO_REWARD_ADDRESS = \"ZERO_REWARD_ADDRESS\";\n    string private constant ERROR_ZERO_MANAGER_ADDRESS = \"ZERO_MANAGER_ADDRESS\";\n    string private constant ERROR_WRONG_NAME_LENGTH = \"WRONG_NAME_LENGTH\";\n    string private constant ERROR_MAX_OPERATORS_COUNT_EXCEEDED = \"MAX_OPERATORS_COUNT_EXCEEDED\";\n    string private constant ERROR_EMPTY_CALLDATA = \"EMPTY_CALLDATA\";\n\n    // -------------\n    // CONSTRUCTOR\n    // -------------\n\n    constructor(\n        address _trustedCaller,\n        address _nodeOperatorsRegistry,\n        address _acl,\n        address _lido\n    ) TrustedCaller(_trustedCaller) {\n        nodeOperatorsRegistry = INodeOperatorsRegistry(_nodeOperatorsRegistry);\n        acl = IACL(_acl);\n        lido = _lido;\n    }\n\n    // -------------\n    // EXTERNAL METHODS\n    // -------------\n\n    /// @notice Creates EVMScript to add batch of node operators\n    /// @param _creator Address who creates EVMScript\n    /// @param _evmScriptCallData Encoded (uint256,AddNodeOperatorInput[])\n    function createEVMScript(\n        address _creator,\n        bytes memory _evmScriptCallData\n    ) external view override onlyTrustedCaller(_creator) returns (bytes memory) {\n        (\n            uint256 nodeOperatorsCount,\n            AddNodeOperatorInput[] memory decodedCallData\n        ) = _decodeEVMScriptCallData(_evmScriptCallData);\n\n        address[] memory toAddresses = new address[](decodedCallData.length * 2);\n        bytes4[] memory methodIds = new bytes4[](decodedCallData.length * 2);\n        bytes[] memory encodedCalldata = new bytes[](decodedCallData.length * 2);\n\n        _validateInputData(nodeOperatorsCount, decodedCallData);\n\n        for (uint256 i = 0; i < decodedCallData.length; ++i) {\n            toAddresses[i * 2] = address(nodeOperatorsRegistry);\n            methodIds[i * 2] = ADD_NODE_OPERATOR_SELECTOR;\n            encodedCalldata[i * 2] = abi.encode(\n                decodedCallData[i].name,\n                decodedCallData[i].rewardAddress\n            );\n\n            // See https://legacy-docs.aragon.org/developers/tools/aragonos/reference-aragonos-3#parameter-interpretation for details\n            uint256[] memory permissionParams = new uint256[](1);\n            permissionParams[0] = (1 << 240) + nodeOperatorsCount + i;\n\n            toAddresses[i * 2 + 1] = address(acl);\n            methodIds[i * 2 + 1] = GRANT_PERMISSION_P_SELECTOR;\n            encodedCalldata[i * 2 + 1] = abi.encode(\n                decodedCallData[i].managerAddress,\n                address(nodeOperatorsRegistry),\n                MANAGE_SIGNING_KEYS_ROLE,\n                permissionParams\n            );\n        }\n\n        return EVMScriptCreator.createEVMScript(toAddresses, methodIds, encodedCalldata);\n    }\n\n    /// @notice Decodes call data used by createEVMScript method\n    /// @param _evmScriptCallData Encoded (uint256, AddNodeOperatorInput[])\n    /// @return nodeOperatorsCount current number of node operators in registry\n    /// @return nodeOperators AddNodeOperatorInput[]\n    function decodeEVMScriptCallData(\n        bytes memory _evmScriptCallData\n    )\n        external\n        pure\n        returns (uint256 nodeOperatorsCount, AddNodeOperatorInput[] memory nodeOperators)\n    {\n        return _decodeEVMScriptCallData(_evmScriptCallData);\n    }\n\n    // ------------------\n    // PRIVATE METHODS\n    // ------------------\n\n    function _decodeEVMScriptCallData(\n        bytes memory _evmScriptCallData\n    )\n        private\n        pure\n        returns (uint256 nodeOperatorsCount, AddNodeOperatorInput[] memory nodeOperators)\n    {\n        (nodeOperatorsCount, nodeOperators) = abi.decode(\n            _evmScriptCallData,\n            (uint256, AddNodeOperatorInput[])\n        );\n    }\n\n    function _validateInputData(\n        uint256 _nodeOperatorsCount,\n        AddNodeOperatorInput[] memory _nodeOperatorInputs\n    ) private view {\n        uint256 maxNameLength = nodeOperatorsRegistry.MAX_NODE_OPERATOR_NAME_LENGTH();\n        uint256 calldataLength = _nodeOperatorInputs.length;\n\n        require(calldataLength > 0, ERROR_EMPTY_CALLDATA);\n        \n        require(\n            nodeOperatorsRegistry.getNodeOperatorsCount() == _nodeOperatorsCount,\n            ERROR_NODE_OPERATORS_COUNT_MISMATCH\n        );\n\n        require(\n            _nodeOperatorsCount + calldataLength <= nodeOperatorsRegistry.MAX_NODE_OPERATORS_COUNT(),\n            ERROR_MAX_OPERATORS_COUNT_EXCEEDED\n        );\n\n        for (uint256 i = 0; i < calldataLength; ++i) {\n            address managerAddress = _nodeOperatorInputs[i].managerAddress;\n            address rewardAddress = _nodeOperatorInputs[i].rewardAddress;\n            string memory name = _nodeOperatorInputs[i].name;\n            for (uint256 testIndex = i + 1; testIndex < calldataLength; ++testIndex) {\n                require(\n                    managerAddress != _nodeOperatorInputs[testIndex].managerAddress,\n                    ERROR_MANAGER_ADDRESSES_HAS_DUPLICATE\n                );\n            }\n\n            require(\n                acl.hasPermission(\n                    managerAddress,\n                    address(nodeOperatorsRegistry),\n                    MANAGE_SIGNING_KEYS_ROLE\n                ) == false,\n                ERROR_MANAGER_ALREADY_HAS_ROLE\n            );\n            require(\n                acl.getPermissionParamsLength(\n                    managerAddress,\n                    address(nodeOperatorsRegistry),\n                    MANAGE_SIGNING_KEYS_ROLE\n                ) == 0,\n                ERROR_MANAGER_ALREADY_HAS_ROLE\n            );\n\n            require(rewardAddress != lido, ERROR_LIDO_REWARD_ADDRESS);\n            require(rewardAddress != address(0), ERROR_ZERO_REWARD_ADDRESS);\n            require(managerAddress != address(0), ERROR_ZERO_MANAGER_ADDRESS);\n\n            require(\n                bytes(name).length > 0 && bytes(name).length <= maxNameLength,\n                ERROR_WRONG_NAME_LENGTH\n            );\n        }\n    }\n}\n"
    },
    "TrustedCaller.sol": {
      "content": "// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.4;\n\n/// @author psirex\n/// @notice A helper contract contains logic to validate that only a trusted caller has access to certain methods.\n/// @dev Trusted caller set once on deployment and can't be changed.\ncontract TrustedCaller {\n    string private constant ERROR_TRUSTED_CALLER_IS_ZERO_ADDRESS = \"TRUSTED_CALLER_IS_ZERO_ADDRESS\";\n    string private constant ERROR_CALLER_IS_FORBIDDEN = \"CALLER_IS_FORBIDDEN\";\n\n    address public immutable trustedCaller;\n\n    constructor(address _trustedCaller) {\n        require(_trustedCaller != address(0), ERROR_TRUSTED_CALLER_IS_ZERO_ADDRESS);\n        trustedCaller = _trustedCaller;\n    }\n\n    modifier onlyTrustedCaller(address _caller) {\n        require(_caller == trustedCaller, ERROR_CALLER_IS_FORBIDDEN);\n        _;\n    }\n}\n"
    },
    "EVMScriptCreator.sol": {
      "content": "// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.4;\n\n/// @author psirex\n/// @notice Contains methods for convenient creation\n/// of EVMScripts in EVMScript factories contracts\nlibrary EVMScriptCreator {\n    // Id of default CallsScript Aragon's executor.\n    bytes4 private constant SPEC_ID = hex\"00000001\";\n\n    /// @notice Encodes one method call as EVMScript\n    function createEVMScript(\n        address _to,\n        bytes4 _methodId,\n        bytes memory _evmScriptCallData\n    ) internal pure returns (bytes memory _commands) {\n        return\n            abi.encodePacked(\n                SPEC_ID,\n                _to,\n                uint32(_evmScriptCallData.length) + 4,\n                _methodId,\n                _evmScriptCallData\n            );\n    }\n\n    /// @notice Encodes multiple calls of the same method on one contract as EVMScript\n    function createEVMScript(\n        address _to,\n        bytes4 _methodId,\n        bytes[] memory _evmScriptCallData\n    ) internal pure returns (bytes memory _evmScript) {\n        for (uint256 i = 0; i < _evmScriptCallData.length; ++i) {\n            _evmScript = bytes.concat(\n                _evmScript,\n                abi.encodePacked(\n                    _to,\n                    uint32(_evmScriptCallData[i].length) + 4,\n                    _methodId,\n                    _evmScriptCallData[i]\n                )\n            );\n        }\n        _evmScript = bytes.concat(SPEC_ID, _evmScript);\n    }\n\n    /// @notice Encodes multiple calls to different methods within the same contract as EVMScript\n    function createEVMScript(\n        address _to,\n        bytes4[] memory _methodIds,\n        bytes[] memory _evmScriptCallData\n    ) internal pure returns (bytes memory _evmScript) {\n        require(_methodIds.length == _evmScriptCallData.length, \"LENGTH_MISMATCH\");\n\n        for (uint256 i = 0; i < _methodIds.length; ++i) {\n            _evmScript = bytes.concat(\n                _evmScript,\n                abi.encodePacked(\n                    _to,\n                    uint32(_evmScriptCallData[i].length) + 4,\n                    _methodIds[i],\n                    _evmScriptCallData[i]\n                )\n            );\n        }\n        _evmScript = bytes.concat(SPEC_ID, _evmScript);\n    }\n\n    /// @notice Encodes multiple calls to different contracts as EVMScript\n    function createEVMScript(\n        address[] memory _to,\n        bytes4[] memory _methodIds,\n        bytes[] memory _evmScriptCallData\n    ) internal pure returns (bytes memory _evmScript) {\n        require(_to.length == _methodIds.length, \"LENGTH_MISMATCH\");\n        require(_to.length == _evmScriptCallData.length, \"LENGTH_MISMATCH\");\n\n        for (uint256 i = 0; i < _to.length; ++i) {\n            _evmScript = bytes.concat(\n                _evmScript,\n                abi.encodePacked(\n                    _to[i],\n                    uint32(_evmScriptCallData[i].length) + 4,\n                    _methodIds[i],\n                    _evmScriptCallData[i]\n                )\n            );\n        }\n        _evmScript = bytes.concat(SPEC_ID, _evmScript);\n    }\n}\n"
    },
    "IEVMScriptFactory.sol": {
      "content": "// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.4;\n\n/// @author psirex\n/// @notice Interface which every EVMScript factory used in EasyTrack contract has to implement\ninterface IEVMScriptFactory {\n    function createEVMScript(address _creator, bytes memory _evmScriptCallData)\n        external\n        returns (bytes memory);\n}\n"
    },
    "INodeOperatorsRegistry.sol": {
      "content": "// SPDX-FileCopyrightText: 2023 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.4;\n\n/// @author bulbozaur\ninterface INodeOperatorsRegistry {\n    function activateNodeOperator(uint256 _nodeOperatorId) external;\n\n    function deactivateNodeOperator(uint256 _nodeOperatorId) external;\n\n    function getNodeOperatorIsActive(uint256 _nodeOperatorId) external view returns (bool);\n\n    function getNodeOperatorsCount() external view returns (uint256);\n\n    function addNodeOperator(\n        string memory _name,\n        address _rewardAddress\n    ) external returns (uint256 id);\n\n    function MAX_NODE_OPERATOR_NAME_LENGTH() external view returns (uint256);\n\n    function MAX_NODE_OPERATORS_COUNT() external view returns (uint256);\n\n    function setNodeOperatorRewardAddress(uint256 _nodeOperatorId, address _rewardAddress) external;\n\n    function setNodeOperatorName(uint256 _nodeOperatorId, string memory _name) external;\n\n    function getNodeOperator(\n        uint256 _id,\n        bool _fullInfo\n    )\n        external\n        view\n        returns (\n            bool active,\n            string memory name,\n            address rewardAddress,\n            uint64 stakingLimit,\n            uint64 stoppedValidators,\n            uint64 totalSigningKeys,\n            uint64 usedSigningKeys\n        );\n\n    function canPerform(\n        address _sender,\n        bytes32 _role,\n        uint256[] memory _params\n    ) external view returns (bool);\n\n    function setNodeOperatorStakingLimit(uint256 _id, uint64 _stakingLimit) external;\n\n    function updateTargetValidatorsLimits(\n        uint256 _nodeOperatorId,\n        bool _isTargetLimitActive,\n        uint256 _targetLimit\n    ) external;\n}\n"
    },
    "IACL.sol": {
      "content": "// SPDX-FileCopyrightText: 2023 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.4;\n\ninterface IACL {\n    function grantPermissionP(\n        address _entity,\n        address _app,\n        bytes32 _role,\n        uint256[] memory _params\n    ) external;\n\n    function revokePermission(address _entity, address _app, bytes32 _role) external;\n\n    function hasPermission(\n        address _entity,\n        address _app,\n        bytes32 _role\n    ) external view returns (bool);\n\n    function hasPermission(\n        address _entity,\n        address _app,\n        bytes32 _role,\n        uint256[] memory _params\n    ) external view returns (bool);\n\n    function getPermissionParamsLength(\n        address _entity,\n        address _app,\n        bytes32 _role\n    ) external view returns (uint256);\n\n    function getPermissionParam(\n        address _entity,\n        address _app,\n        bytes32 _role,\n        uint256 _index\n    ) external view returns (uint8, uint8, uint240);\n\n    function getPermissionManager(address _app, bytes32 _role) external view returns (address);\n\n    function removePermissionManager(address _app, bytes32 _role) external;\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "AddNodeOperators.sol": {}
    },
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
  }
}}