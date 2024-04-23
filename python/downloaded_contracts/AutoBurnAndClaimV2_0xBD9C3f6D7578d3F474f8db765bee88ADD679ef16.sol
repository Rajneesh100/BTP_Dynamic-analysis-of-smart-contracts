{{
  "language": "Solidity",
  "sources": {
    "contracts/V2/AutoBurnAndClaimV2.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity >=0.8.20;\n\nimport {ERC20} from \"../interfaces/ERC20.sol\";\n\n// Gelato Dependency\nimport {OpsProxy} from \"../interfaces/OpsProxy.sol\";\nimport {OpsProxyFactory} from \"../interfaces/OpsProxyFactory.sol\";\nimport {IAutomate, IProxyModule, Module} from \"../interfaces/Gelato.sol\";\n// Synthetix Dependency\nimport {AddressResolver} from \"../interfaces/AddressResolver.sol\";\nimport {DelegateApprovals} from \"../interfaces/DelegateApprovals.sol\";\nimport {FeePool} from \"../interfaces/FeePool.sol\";\nimport {Issuer} from \"../interfaces/Issuer.sol\";\nimport {Synthetix} from \"../interfaces/Synthetix.sol\";\nimport {SystemSettings} from \"../interfaces/SystemSettings.sol\";\n\ncontract AutoBurnAndClaimV2 {\n    bytes32 private constant DELEGATE_APPROVALS = \"DelegateApprovals\";\n    bytes32 private constant SYSTEM_SETTINGS = \"SystemSettings\";\n    bytes32 private constant FEE_POOL = \"FeePool\";\n    bytes32 private constant ISSUER = \"Issuer\";\n    bytes32 private constant SUSD_PROXY = \"ProxyERC20sUSD\";\n    bytes32 private constant SYNTHETIX = \"Synthetix\";\n\n    AddressResolver immutable SNXAddressResolver;\n    OpsProxyFactory immutable OPS_PROXY_FACTORY;\n    DelegateApprovals private delegateApprovals;\n    FeePool private feePool;\n    Issuer private issuer;\n    ERC20 private sUSD;\n    SystemSettings private systemSettings;\n    address private SNX;\n\n    mapping(address => uint256) public baseFee;\n\n    error ZeroAddressResolved(bytes32 name);\n\n    constructor(address _SNXAddressResolver, address _automate) {\n        SNXAddressResolver = AddressResolver(_SNXAddressResolver);\n        _rebuildCaches();\n        IAutomate automate = IAutomate(_automate);\n        IProxyModule proxyModule = IProxyModule(automate.taskModuleAddresses(Module.PROXY));\n        OPS_PROXY_FACTORY = OpsProxyFactory(proxyModule.opsProxyFactory());\n    }\n\n    function checker(\n        address _account\n    ) external view returns (bool, bytes memory execPayload) {\n        (address dedicatedMsgSender, ) = OPS_PROXY_FACTORY.getProxyOf(_account);\n\n        // first off, check gas price\n        uint256 _gasPrice = baseFee[_account];\n        if(_gasPrice != 0 && block.basefee > _gasPrice) {\n            return (false, \"basefee too high\");\n        }\n\n        //second, check claim permission\n        if(!delegateApprovals.canClaimFor(_account, dedicatedMsgSender) ) {\n            return (false, \"no claim permission for gelato\");\n        }\n\n        //third, is reward avaliable to claim?\n        (uint256 fee, uint256 SNXRewards) = feePool.feesAvailable(_account);\n        if((fee + SNXRewards) == 0 || feePool.totalRewardsAvailable() == 0) {\n            return (false, \"no reward avaliable\");\n        }\n\n        // forth, check burn permission and if need to burn\n        uint256 issuanceRatio = systemSettings.issuanceRatio();\n        uint256 cRatio = issuer.collateralisationRatio(_account);\n\n        address[] memory targets;\n        bytes[] memory datas;\n        uint256[] memory values;\n\n        if(cRatio > issuanceRatio) {\n            uint256 threshold = 1e18 + systemSettings.targetThreshold();\n            uint256 issuanceAdjusted = issuanceRatio * threshold / 1e18;\n            if(cRatio > issuanceAdjusted) {\n                bool burnPerms = delegateApprovals.canBurnFor(_account, dedicatedMsgSender);\n                if(!burnPerms) {\n                    return (false, \"no burn permission and c-ratio too low\");\n                }\n                else {\n                    uint256 debtBalance = issuer.debtBalanceOf(_account, \"sUSD\");\n                    uint256 maxIssuable = issuer.maxIssuableSynths(_account);\n                    uint256 burnAmount = debtBalance - maxIssuable;\n                    uint256 sUSDBalance = sUSD.balanceOf(_account);\n                    if(sUSDBalance < burnAmount) {\n                        return (false, \"not enough sUSD to fix c-ratio\");\n                    }\n                    else {\n                        targets = new address[](2);\n                        datas = new bytes[](2);\n                        values = new uint256[](2);\n                        targets[0] = SNX;\n                        targets[1] = address(feePool);\n                        datas[0] = abi.encodeWithSelector(Synthetix.burnSynthsToTargetOnBehalf.selector, _account);\n                        datas[1] = abi.encodeWithSelector(feePool.claimOnBehalf.selector, _account);\n                        values[0] = 0;\n                        values[1] = 0;\n                        return (true, \n                            abi.encodeWithSelector(\n                                OpsProxy.batchExecuteCall.selector, \n                                targets,\n                                datas,\n                                values));\n                    }\n                }\n            }\n        }\n\n        targets = new address[](1);\n        datas = new bytes[](1);\n        values = new uint256[](1);\n        targets[0] = address(feePool);\n        datas[0] = abi.encodeWithSelector(feePool.claimOnBehalf.selector, _account);\n        // values[0] = 0;\n        return (true,\n                abi.encodeWithSelector(\n                    OpsProxy.batchExecuteCall.selector,\n                    targets,\n                    datas,\n                    values\n                    )\n            );\n    }\n\n    function setBaseFee(uint256 _baseFee) external {\n        baseFee[msg.sender] = _baseFee;\n    }\n\n    function rebuildCaches() external {\n        _rebuildCaches();\n    }\n\n    function _rebuildCaches() internal {\n        feePool = FeePool(getAddress(FEE_POOL));\n        delegateApprovals = DelegateApprovals(getAddress(DELEGATE_APPROVALS));\n        systemSettings = SystemSettings(getAddress(SYSTEM_SETTINGS));\n        issuer = Issuer(getAddress(ISSUER));\n        SNX = getAddress(SYNTHETIX);\n        sUSD = ERC20(getAddress(SUSD_PROXY));\n    }\n\n    function getAddress(bytes32 name) internal view returns (address) {\n        address resolved = SNXAddressResolver.getAddress(name);\n        if (resolved == address(0)) {\n            revert ZeroAddressResolved(name);\n        }\n        return resolved;\n    }\n}"
    },
    "contracts/interfaces/ERC20.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface ERC20 {\n    function balanceOf(address _who) external view returns (uint256);\n}"
    },
    "contracts/interfaces/OpsProxy.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface OpsProxy {\n    function batchExecuteCall(\n        address[] calldata _targets,\n        bytes[] calldata _datas,\n        uint256[] calldata _values\n    ) external payable;\n\n    function owner() external returns (address);\n}"
    },
    "contracts/interfaces/OpsProxyFactory.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface OpsProxyFactory {\n    function getProxyOf(address account) external view returns (address, bool);\n\n    function deployFor(address owner) external returns (address payable proxy);\n\n    function ops() external returns (address);\n}"
    },
    "contracts/interfaces/Gelato.sol": {
      "content": "pragma solidity ^0.8.20;\n\nenum Module {\n    RESOLVER,\n    DEPRECATED_TIME,\n    PROXY,\n    SINGLE_EXEC,\n    WEB3_FUNCTION,\n    TRIGGER\n}\n\nenum TriggerType {\n    TIME,\n    CRON,\n    EVENT,\n    BLOCK\n}\n\nstruct ModuleData {\n    Module[] modules;\n    bytes[] args;\n}\n\ninterface IAutomate {\n    function createTask(\n        address execAddress,\n        bytes calldata execDataOrSelector,\n        ModuleData calldata moduleData,\n        address feeToken\n    ) external returns (bytes32 taskId);\n\n    function cancelTask(bytes32 taskId) external;\n\n    function getFeeDetails() external view returns (uint256, address);\n\n    function gelato() external view returns (address payable);\n\n    function taskModuleAddresses(Module) external view returns (address);\n}\n\ninterface IProxyModule {\n    function opsProxyFactory() external view returns (address);\n}\n"
    },
    "contracts/interfaces/AddressResolver.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface AddressResolver {\n    function getAddress(bytes32 name) external view returns (address);\n}"
    },
    "contracts/interfaces/DelegateApprovals.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface DelegateApprovals {\n    function canIssueFor(\n        address authoriser,\n        address delegate\n    ) external view returns (bool);\n    function approveIssueOnBehalf(address delegate) external;\n\n    function canClaimFor(address authoriser, address delegate) external view returns (bool);\n\n    function approveClaimOnBehalf(address delegate) external;\n\n    function canBurnFor(address authoriser, address delegate) external view returns (bool);\n\n    function approveBurnOnBehalf(address delegate) external;\n}"
    },
    "contracts/interfaces/FeePool.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface FeePool {\n    function feesAvailable(\n        address account\n    ) external view returns (uint256, uint256);\n\n    function totalRewardsAvailable() external view returns (uint);\n\n    function claimOnBehalf(address claimingForAddress) external returns (bool);\n\n    function claimFees() external returns (bool);\n}"
    },
    "contracts/interfaces/Issuer.sol": {
      "content": "pragma solidity ^0.8.20;\n\ninterface Issuer {\n    function collateralisationRatio(address issuer) external view returns (uint);\n\n    function debtBalanceOf(address _issuer, bytes32 currencyKey) external view returns (uint256);\n\n    function maxIssuableSynths(address _issuer) external view returns (uint);\n}"
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