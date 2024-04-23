{{
  "language": "Solidity",
  "sources": {
    "contracts/V2/MaxMintV2.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n// Modified from https://github.com/gelatodigital/w3f-solidity-synthetix\n\npragma solidity >=0.8.20;\n\nimport {AddressResolver} from \"../interfaces/AddressResolver.sol\";\nimport {DelegateApprovals} from \"../interfaces/DelegateApprovals.sol\";\nimport {OpsProxyFactory} from \"../interfaces/OpsProxyFactory.sol\";\nimport {IAutomate, IProxyModule, Module} from \"../interfaces/Gelato.sol\";\nimport {Synthetix} from \"../interfaces/Synthetix.sol\";\nimport {SystemSettings} from \"../interfaces/SystemSettings.sol\";\n\ncontract MaxMintV2 {\n    // @notice Configuration for minting\n    // @custom:mode 0 for disabled, 1 for price increase, 2 for using minimum issued sUSD\n    // @custom:parameter parameter to use for calculation, depending on mode selected\n    // @custom:maxBaseFee maximum block.basefee to not mint\n    enum Mode {DISABLED, BY_PRICE_INCRASE_PERCENT, BY_MINIMUM_SUSD_ISSUED }\n    \n    struct Configuation {\n        Mode mode;\n        uint120 parameter;\n        uint120 maxBaseFee;\n    }\n\n    // @notice: Name of Synthetix contracts to resolve\n\n    bytes32 private constant SYNTHETIX = \"Synthetix\";\n    bytes32 private constant DELEGATE_APPROVALS = \"DelegateApprovals\";\n    bytes32 private constant SYSTEM_SETTINGS = \"SystemSettings\";\n\n    AddressResolver immutable SNXAddressResolver;\n    OpsProxyFactory immutable OPS_PROXY_FACTORY ;\n    DelegateApprovals private delegateApprovals;\n    Synthetix private SNX;\n    SystemSettings private systemSettings;\n\n    mapping(address _account => Configuation) public config;\n\n    error ZeroAddressResolved(bytes32 name);\n    error InvalidConfig();\n\n    constructor(address _SNXAddressResolver, address _automate) {\n        SNXAddressResolver = AddressResolver(_SNXAddressResolver);\n        _rebuildCaches();\n        IAutomate automate = IAutomate(_automate);\n        IProxyModule proxyModule = IProxyModule(automate.taskModuleAddresses(Module.PROXY));\n        OPS_PROXY_FACTORY = OpsProxyFactory(proxyModule.opsProxyFactory());\n    }\n\n    function checker(\n        address _account\n    ) external view returns (bool, bytes memory execPayload) {\n        (address dedicatedMsgSender, ) = OPS_PROXY_FACTORY.getProxyOf(_account);\n\n        uint256 cRatio = SNX.collateralisationRatio(_account);\n        uint256 issuanceRatio = systemSettings.issuanceRatio();\n        Configuation memory currentConfig = config[_account];\n\n        if (currentConfig.mode == Mode.DISABLED) {\n            execPayload = bytes(\"Disabled\");\n            return (false, execPayload);\n        }\n\n        if (block.basefee > currentConfig.maxBaseFee && currentConfig.maxBaseFee > 0) {\n            execPayload = bytes(\"Base fee too high\");\n            return (false, execPayload);\n        }\n\n        else if (currentConfig.mode == Mode.BY_PRICE_INCRASE_PERCENT) {\n            uint256 targetCRatio = issuanceRatio * 10000 / (10000 + currentConfig.parameter);\n            if(cRatio >= targetCRatio) {\n                execPayload = bytes(\"Account C-ratio is lower than target\");\n                return (false, execPayload);\n            }\n        }\n        else if (currentConfig.mode == Mode.BY_MINIMUM_SUSD_ISSUED) {\n            (uint256 maxIssuable,, ) = SNX.remainingIssuableSynths(_account);\n            if(maxIssuable == 0) {\n                execPayload = bytes(\"Account already below max issuable\");\n                return (false, execPayload);\n            }\n            else if(currentConfig.parameter > maxIssuable) {\n                execPayload = bytes(\"sUSD avaliable is lower than set threshold\");\n                return (false, execPayload);\n            }\n        }\n\n        if (!delegateApprovals.canIssueFor(_account, dedicatedMsgSender)) {\n            execPayload = bytes(\"Not approved for issuing\");\n            return (false, execPayload);\n        }\n\n        execPayload = abi.encodeWithSelector(\n            SNX.issueMaxSynthsOnBehalf.selector,\n            _account\n        );\n\n        return (true, execPayload);\n    }\n\n    function setConfig(Mode _mode, uint120 _parameter, uint120 _maxBaseFee) external {\n        config[msg.sender] = Configuation({\n            mode: _mode,\n            parameter: _parameter,\n            maxBaseFee: _maxBaseFee\n        });\n    }\n\n    function rebuildCaches() external {\n        _rebuildCaches();\n    }\n\n    function _rebuildCaches() internal {\n        SNX = Synthetix(getAddress(SYNTHETIX));\n        delegateApprovals = DelegateApprovals(getAddress(DELEGATE_APPROVALS));\n        systemSettings = SystemSettings(getAddress(SYSTEM_SETTINGS));\n    }\n\n    function getAddress(bytes32 name) internal view returns (address) {\n        address resolved = SNXAddressResolver.getAddress(name);\n        if (resolved == address(0)) {\n            revert ZeroAddressResolved(name);\n        }\n        return resolved;\n    }\n}\n"
    },
    "contracts/interfaces/AddressResolver.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface AddressResolver {\n    function getAddress(bytes32 name) external view returns (address);\n}"
    },
    "contracts/interfaces/DelegateApprovals.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface DelegateApprovals {\n    function canIssueFor(\n        address authoriser,\n        address delegate\n    ) external view returns (bool);\n    function approveIssueOnBehalf(address delegate) external;\n\n    function canClaimFor(address authoriser, address delegate) external view returns (bool);\n\n    function approveClaimOnBehalf(address delegate) external;\n\n    function canBurnFor(address authoriser, address delegate) external view returns (bool);\n\n    function approveBurnOnBehalf(address delegate) external;\n}"
    },
    "contracts/interfaces/OpsProxyFactory.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface OpsProxyFactory {\n    function getProxyOf(address account) external view returns (address, bool);\n\n    function deployFor(address owner) external returns (address payable proxy);\n\n    function ops() external returns (address);\n}"
    },
    "contracts/interfaces/Gelato.sol": {
      "content": "pragma solidity ^0.8.20;\n\nenum Module {\n    RESOLVER,\n    DEPRECATED_TIME,\n    PROXY,\n    SINGLE_EXEC,\n    WEB3_FUNCTION,\n    TRIGGER\n}\n\nenum TriggerType {\n    TIME,\n    CRON,\n    EVENT,\n    BLOCK\n}\n\nstruct ModuleData {\n    Module[] modules;\n    bytes[] args;\n}\n\ninterface IAutomate {\n    function createTask(\n        address execAddress,\n        bytes calldata execDataOrSelector,\n        ModuleData calldata moduleData,\n        address feeToken\n    ) external returns (bytes32 taskId);\n\n    function cancelTask(bytes32 taskId) external;\n\n    function getFeeDetails() external view returns (uint256, address);\n\n    function gelato() external view returns (address payable);\n\n    function taskModuleAddresses(Module) external view returns (address);\n}\n\ninterface IProxyModule {\n    function opsProxyFactory() external view returns (address);\n}\n"
    },
    "contracts/interfaces/Synthetix.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface Synthetix {\n    function remainingIssuableSynths(address issuer)\n        external\n        view\n        returns (\n            uint maxIssuable,\n            uint alreadyIssued,\n            uint totalSystemDebt\n        );\n    \n    function collateralisationRatio(address issuer) external view returns (uint);\n\n    function issueMaxSynthsOnBehalf(address issueForAddress) external;\n\n    function burnSynthsToTargetOnBehalf(address burnForAddress) external;\n    function burnSynthsToTarget() external;\n}"
    },
    "contracts/interfaces/SystemSettings.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface SystemSettings {\n    function issuanceRatio() external view returns (uint);\n\n    function targetThreshold() external view returns (uint);\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "ds-test/=node_modules/ds-test/src/",
      "forge-std/=node_modules/forge-std/src/"
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
    "viaIR": true,
    "libraries": {}
  }
}}