{{
  "language": "Solidity",
  "sources": {
    "UpdateTargetValidatorLimits.sol": {
      "content": "// SPDX-FileCopyrightText: 2023 Lido <info@lido.fi>\n// SPDX-License-Identifier: GPL-3.0\n\npragma solidity 0.8.6;\n\nimport \"TrustedCaller.sol\";\nimport \"EVMScriptCreator.sol\";\nimport \"IEVMScriptFactory.sol\";\nimport \"INodeOperatorsRegistry.sol\";\n\n/// @notice Creates EVMScript to set node operators target validators limit\ncontract UpdateTargetValidatorLimits is TrustedCaller, IEVMScriptFactory {\n    struct TargetValidatorsLimit {\n        uint256 nodeOperatorId;\n        bool isTargetLimitActive;\n        uint256 targetLimit;\n    }\n\n    // -------------\n    // CONSTANTS\n    // -------------\n\n    uint256 internal constant UINT64_MAX = 0xFFFFFFFFFFFFFFFF;\n\n    // -------------\n    // ERRORS\n    // -------------\n\n    string private constant ERROR_NODE_OPERATOR_INDEX_OUT_OF_RANGE =\n        \"NODE_OPERATOR_INDEX_OUT_OF_RANGE\";\n    string private constant ERROR_NODE_OPERATORS_IS_NOT_SORTED = \"NODE_OPERATORS_IS_NOT_SORTED\";\n    string private constant ERROR_TARGET_LIMIT_GREATER_THEN_UINT64 =\n        \"TARGET_LIMIT_GREATER_THEN_UINT64\";\n    string private constant ERROR_EMPTY_CALLDATA = \"EMPTY_CALLDATA\";\n\n    // -------------\n    // VARIABLES\n    // -------------\n\n    /// @notice Address of NodeOperatorsRegistry contract\n    INodeOperatorsRegistry public immutable nodeOperatorsRegistry;\n\n    // -------------\n    // CONSTRUCTOR\n    // -------------\n\n    constructor(\n        address _trustedCaller,\n        address _nodeOperatorsRegistry\n    ) TrustedCaller(_trustedCaller) {\n        nodeOperatorsRegistry = INodeOperatorsRegistry(_nodeOperatorsRegistry);\n    }\n\n    // -------------\n    // EXTERNAL METHODS\n    // -------------\n\n    /// @notice Creates EVMScript to set node operators target validators limit\n    /// @param _creator Address who creates EVMScript\n    /// @param _evmScriptCallData Encoded (TargetValidatorsLimit[])\n    function createEVMScript(\n        address _creator,\n        bytes memory _evmScriptCallData\n    ) external view override onlyTrustedCaller(_creator) returns (bytes memory) {\n        TargetValidatorsLimit[] memory decodedCallData = abi.decode(\n            _evmScriptCallData,\n            (TargetValidatorsLimit[])\n        );\n\n        _validateInputData(decodedCallData);\n\n        bytes[] memory updateTargetLimitsCallData = new bytes[](decodedCallData.length);\n\n        for (uint256 i = 0; i < decodedCallData.length; ++i) {\n            updateTargetLimitsCallData[i] = abi.encode(decodedCallData[i]);\n        }\n\n        return\n            EVMScriptCreator.createEVMScript(\n                address(nodeOperatorsRegistry),\n                nodeOperatorsRegistry.updateTargetValidatorsLimits.selector,\n                updateTargetLimitsCallData\n            );\n    }\n\n    /// @notice Decodes call data used by createEVMScript method\n    /// @param _evmScriptCallData Encoded (TargetValidatorsLimit[])\n    /// @return TargetValidatorsLimit[]\n    function decodeEVMScriptCallData(\n        bytes memory _evmScriptCallData\n    ) external pure returns (TargetValidatorsLimit[] memory) {\n        return _decodeEVMScriptCallData(_evmScriptCallData);\n    }\n\n    // ------------------\n    // PRIVATE METHODS\n    // ------------------\n\n    function _decodeEVMScriptCallData(\n        bytes memory _evmScriptCallData\n    ) private pure returns (TargetValidatorsLimit[] memory) {\n        return abi.decode(_evmScriptCallData, (TargetValidatorsLimit[]));\n    }\n\n    function _validateInputData(TargetValidatorsLimit[] memory _decodedCallData) private view {\n        uint256 nodeOperatorsCount = nodeOperatorsRegistry.getNodeOperatorsCount();\n        require(_decodedCallData.length > 0, ERROR_EMPTY_CALLDATA);\n        require(\n            _decodedCallData[_decodedCallData.length - 1].nodeOperatorId < nodeOperatorsCount,\n            ERROR_NODE_OPERATOR_INDEX_OUT_OF_RANGE\n        );\n\n        for (uint256 i = 0; i < _decodedCallData.length; ++i) {\n            require(\n                i == 0 ||\n                    _decodedCallData[i].nodeOperatorId > _decodedCallData[i - 1].nodeOperatorId,\n                ERROR_NODE_OPERATORS_IS_NOT_SORTED\n            );\n            require(\n                _decodedCallData[i].targetLimit <= UINT64_MAX,\n                ERROR_TARGET_LIMIT_GREATER_THEN_UINT64\n            );\n        }\n    }\n}\n"
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
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "UpdateTargetValidatorLimits.sol": {}
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