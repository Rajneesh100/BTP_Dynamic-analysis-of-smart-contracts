{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "paris",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 2
    },
    "remappings": [],
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
    "@openzeppelin/contracts/interfaces/IERC1967.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC1967.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.\n *\n * _Available since v4.8.3._\n */\ninterface IERC1967 {\n    /**\n     * @dev Emitted when the implementation is upgraded.\n     */\n    event Upgraded(address indexed implementation);\n\n    /**\n     * @dev Emitted when the admin account has changed.\n     */\n    event AdminChanged(address previousAdmin, address newAdmin);\n\n    /**\n     * @dev Emitted when the beacon is changed.\n     */\n    event BeaconUpgraded(address indexed beacon);\n}\n"
    },
    "@openzeppelin/contracts/interfaces/draft-IERC1822.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified\n * proxy whose upgrades are fully controlled by the current implementation.\n */\ninterface IERC1822Proxiable {\n    /**\n     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation\n     * address.\n     *\n     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks\n     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this\n     * function revert if invoked through a proxy.\n     */\n    function proxiableUUID() external view returns (bytes32);\n}\n"
    },
    "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../Proxy.sol\";\nimport \"./ERC1967Upgrade.sol\";\n\n/**\n * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an\n * implementation address that can be changed. This address is stored in storage in the location specified by\n * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the\n * implementation behind the proxy.\n */\ncontract ERC1967Proxy is Proxy, ERC1967Upgrade {\n    /**\n     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.\n     *\n     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded\n     * function call, and allows initializing the storage of the proxy like a Solidity constructor.\n     */\n    constructor(address _logic, bytes memory _data) payable {\n        _upgradeToAndCall(_logic, _data, false);\n    }\n\n    /**\n     * @dev Returns the current implementation address.\n     */\n    function _implementation() internal view virtual override returns (address impl) {\n        return ERC1967Upgrade._getImplementation();\n    }\n}\n"
    },
    "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (proxy/ERC1967/ERC1967Upgrade.sol)\n\npragma solidity ^0.8.2;\n\nimport \"../beacon/IBeacon.sol\";\nimport \"../../interfaces/IERC1967.sol\";\nimport \"../../interfaces/draft-IERC1822.sol\";\nimport \"../../utils/Address.sol\";\nimport \"../../utils/StorageSlot.sol\";\n\n/**\n * @dev This abstract contract provides getters and event emitting update functions for\n * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.\n *\n * _Available since v4.1._\n */\nabstract contract ERC1967Upgrade is IERC1967 {\n    // This is the keccak-256 hash of \"eip1967.proxy.rollback\" subtracted by 1\n    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;\n\n    /**\n     * @dev Storage slot with the address of the current implementation.\n     * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1, and is\n     * validated in the constructor.\n     */\n    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    /**\n     * @dev Returns the current implementation address.\n     */\n    function _getImplementation() internal view returns (address) {\n        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;\n    }\n\n    /**\n     * @dev Stores a new address in the EIP1967 implementation slot.\n     */\n    function _setImplementation(address newImplementation) private {\n        require(Address.isContract(newImplementation), \"ERC1967: new implementation is not a contract\");\n        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;\n    }\n\n    /**\n     * @dev Perform implementation upgrade\n     *\n     * Emits an {Upgraded} event.\n     */\n    function _upgradeTo(address newImplementation) internal {\n        _setImplementation(newImplementation);\n        emit Upgraded(newImplementation);\n    }\n\n    /**\n     * @dev Perform implementation upgrade with additional setup call.\n     *\n     * Emits an {Upgraded} event.\n     */\n    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {\n        _upgradeTo(newImplementation);\n        if (data.length > 0 || forceCall) {\n            Address.functionDelegateCall(newImplementation, data);\n        }\n    }\n\n    /**\n     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.\n     *\n     * Emits an {Upgraded} event.\n     */\n    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {\n        // Upgrades from old implementations will perform a rollback test. This test requires the new\n        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing\n        // this special case will break upgrade paths from old UUPS implementation to new ones.\n        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {\n            _setImplementation(newImplementation);\n        } else {\n            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {\n                require(slot == _IMPLEMENTATION_SLOT, \"ERC1967Upgrade: unsupported proxiableUUID\");\n            } catch {\n                revert(\"ERC1967Upgrade: new implementation is not UUPS\");\n            }\n            _upgradeToAndCall(newImplementation, data, forceCall);\n        }\n    }\n\n    /**\n     * @dev Storage slot with the admin of the contract.\n     * This is the keccak-256 hash of \"eip1967.proxy.admin\" subtracted by 1, and is\n     * validated in the constructor.\n     */\n    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;\n\n    /**\n     * @dev Returns the current admin.\n     */\n    function _getAdmin() internal view returns (address) {\n        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;\n    }\n\n    /**\n     * @dev Stores a new address in the EIP1967 admin slot.\n     */\n    function _setAdmin(address newAdmin) private {\n        require(newAdmin != address(0), \"ERC1967: new admin is the zero address\");\n        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;\n    }\n\n    /**\n     * @dev Changes the admin of the proxy.\n     *\n     * Emits an {AdminChanged} event.\n     */\n    function _changeAdmin(address newAdmin) internal {\n        emit AdminChanged(_getAdmin(), newAdmin);\n        _setAdmin(newAdmin);\n    }\n\n    /**\n     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.\n     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.\n     */\n    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;\n\n    /**\n     * @dev Returns the current beacon.\n     */\n    function _getBeacon() internal view returns (address) {\n        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;\n    }\n\n    /**\n     * @dev Stores a new beacon in the EIP1967 beacon slot.\n     */\n    function _setBeacon(address newBeacon) private {\n        require(Address.isContract(newBeacon), \"ERC1967: new beacon is not a contract\");\n        require(\n            Address.isContract(IBeacon(newBeacon).implementation()),\n            \"ERC1967: beacon implementation is not a contract\"\n        );\n        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;\n    }\n\n    /**\n     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does\n     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).\n     *\n     * Emits a {BeaconUpgraded} event.\n     */\n    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {\n        _setBeacon(newBeacon);\n        emit BeaconUpgraded(newBeacon);\n        if (data.length > 0 || forceCall) {\n            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/proxy/Proxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM\n * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to\n * be specified by overriding the virtual {_implementation} function.\n *\n * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a\n * different contract through the {_delegate} function.\n *\n * The success and return data of the delegated call will be returned back to the caller of the proxy.\n */\nabstract contract Proxy {\n    /**\n     * @dev Delegates the current call to `implementation`.\n     *\n     * This function does not return to its internal call site, it will return directly to the external caller.\n     */\n    function _delegate(address implementation) internal virtual {\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    /**\n     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function\n     * and {_fallback} should delegate.\n     */\n    function _implementation() internal view virtual returns (address);\n\n    /**\n     * @dev Delegates the current call to the address returned by `_implementation()`.\n     *\n     * This function does not return to its internal call site, it will return directly to the external caller.\n     */\n    function _fallback() internal virtual {\n        _beforeFallback();\n        _delegate(_implementation());\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other\n     * function in the contract matches the call data.\n     */\n    fallback() external payable virtual {\n        _fallback();\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data\n     * is empty.\n     */\n    receive() external payable virtual {\n        _fallback();\n    }\n\n    /**\n     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`\n     * call, or as part of the Solidity `fallback` or `receive` functions.\n     *\n     * If overridden should call `super._beforeFallback()`.\n     */\n    function _beforeFallback() internal virtual {}\n}\n"
    },
    "@openzeppelin/contracts/proxy/beacon/IBeacon.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev This is the interface that {BeaconProxy} expects of its beacon.\n */\ninterface IBeacon {\n    /**\n     * @dev Must return an address that can be used as a delegate call target.\n     *\n     * {BeaconProxy} will check that this address is a contract.\n     */\n    function implementation() external view returns (address);\n}\n"
    },
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (proxy/transparent/TransparentUpgradeableProxy.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../ERC1967/ERC1967Proxy.sol\";\n\n/**\n * @dev Interface for {TransparentUpgradeableProxy}. In order to implement transparency, {TransparentUpgradeableProxy}\n * does not implement this interface directly, and some of its functions are implemented by an internal dispatch\n * mechanism. The compiler is unaware that these functions are implemented by {TransparentUpgradeableProxy} and will not\n * include them in the ABI so this interface must be used to interact with it.\n */\ninterface ITransparentUpgradeableProxy is IERC1967 {\n    function admin() external view returns (address);\n\n    function implementation() external view returns (address);\n\n    function changeAdmin(address) external;\n\n    function upgradeTo(address) external;\n\n    function upgradeToAndCall(address, bytes memory) external payable;\n}\n\n/**\n * @dev This contract implements a proxy that is upgradeable by an admin.\n *\n * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector\n * clashing], which can potentially be used in an attack, this contract uses the\n * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two\n * things that go hand in hand:\n *\n * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if\n * that call matches one of the admin functions exposed by the proxy itself.\n * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the\n * implementation. If the admin tries to call a function on the implementation it will fail with an error that says\n * \"admin cannot fallback to proxy target\".\n *\n * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing\n * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due\n * to sudden errors when trying to call a function from the proxy implementation.\n *\n * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,\n * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.\n *\n * NOTE: The real interface of this proxy is that defined in `ITransparentUpgradeableProxy`. This contract does not\n * inherit from that interface, and instead the admin functions are implicitly implemented using a custom dispatch\n * mechanism in `_fallback`. Consequently, the compiler will not produce an ABI for this contract. This is necessary to\n * fully implement transparency without decoding reverts caused by selector clashes between the proxy and the\n * implementation.\n *\n * WARNING: It is not recommended to extend this contract to add additional external functions. If you do so, the compiler\n * will not check that there are no selector conflicts, due to the note above. A selector clash between any new function\n * and the functions declared in {ITransparentUpgradeableProxy} will be resolved in favor of the new one. This could\n * render the admin operations inaccessible, which could prevent upgradeability. Transparency may also be compromised.\n */\ncontract TransparentUpgradeableProxy is ERC1967Proxy {\n    /**\n     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and\n     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.\n     */\n    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {\n        _changeAdmin(admin_);\n    }\n\n    /**\n     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.\n     *\n     * CAUTION: This modifier is deprecated, as it could cause issues if the modified function has arguments, and the\n     * implementation provides a function with the same selector.\n     */\n    modifier ifAdmin() {\n        if (msg.sender == _getAdmin()) {\n            _;\n        } else {\n            _fallback();\n        }\n    }\n\n    /**\n     * @dev If caller is the admin process the call internally, otherwise transparently fallback to the proxy behavior\n     */\n    function _fallback() internal virtual override {\n        if (msg.sender == _getAdmin()) {\n            bytes memory ret;\n            bytes4 selector = msg.sig;\n            if (selector == ITransparentUpgradeableProxy.upgradeTo.selector) {\n                ret = _dispatchUpgradeTo();\n            } else if (selector == ITransparentUpgradeableProxy.upgradeToAndCall.selector) {\n                ret = _dispatchUpgradeToAndCall();\n            } else if (selector == ITransparentUpgradeableProxy.changeAdmin.selector) {\n                ret = _dispatchChangeAdmin();\n            } else if (selector == ITransparentUpgradeableProxy.admin.selector) {\n                ret = _dispatchAdmin();\n            } else if (selector == ITransparentUpgradeableProxy.implementation.selector) {\n                ret = _dispatchImplementation();\n            } else {\n                revert(\"TransparentUpgradeableProxy: admin cannot fallback to proxy target\");\n            }\n            assembly {\n                return(add(ret, 0x20), mload(ret))\n            }\n        } else {\n            super._fallback();\n        }\n    }\n\n    /**\n     * @dev Returns the current admin.\n     *\n     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the\n     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.\n     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`\n     */\n    function _dispatchAdmin() private returns (bytes memory) {\n        _requireZeroValue();\n\n        address admin = _getAdmin();\n        return abi.encode(admin);\n    }\n\n    /**\n     * @dev Returns the current implementation.\n     *\n     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the\n     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.\n     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`\n     */\n    function _dispatchImplementation() private returns (bytes memory) {\n        _requireZeroValue();\n\n        address implementation = _implementation();\n        return abi.encode(implementation);\n    }\n\n    /**\n     * @dev Changes the admin of the proxy.\n     *\n     * Emits an {AdminChanged} event.\n     */\n    function _dispatchChangeAdmin() private returns (bytes memory) {\n        _requireZeroValue();\n\n        address newAdmin = abi.decode(msg.data[4:], (address));\n        _changeAdmin(newAdmin);\n\n        return \"\";\n    }\n\n    /**\n     * @dev Upgrade the implementation of the proxy.\n     */\n    function _dispatchUpgradeTo() private returns (bytes memory) {\n        _requireZeroValue();\n\n        address newImplementation = abi.decode(msg.data[4:], (address));\n        _upgradeToAndCall(newImplementation, bytes(\"\"), false);\n\n        return \"\";\n    }\n\n    /**\n     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified\n     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the\n     * proxied contract.\n     */\n    function _dispatchUpgradeToAndCall() private returns (bytes memory) {\n        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));\n        _upgradeToAndCall(newImplementation, data, true);\n\n        return \"\";\n    }\n\n    /**\n     * @dev Returns the current admin.\n     *\n     * CAUTION: This function is deprecated. Use {ERC1967Upgrade-_getAdmin} instead.\n     */\n    function _admin() internal view virtual returns (address) {\n        return _getAdmin();\n    }\n\n    /**\n     * @dev To keep this contract fully transparent, all `ifAdmin` functions must be payable. This helper is here to\n     * emulate some proxy functions being non-payable while still allowing value to pass through.\n     */\n    function _requireZeroValue() private {\n        require(msg.value == 0);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     *\n     * Furthermore, `isContract` will also return true if the target contract within\n     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,\n     * which only has an effect at the end of a transaction.\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling\n     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.\n     *\n     * _Available since v4.8._\n     */\n    function verifyCallResultFromTarget(\n        address target,\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        if (success) {\n            if (returndata.length == 0) {\n                // only check isContract if the call was successful and the return data is empty\n                // otherwise we already know that it was a contract\n                require(isContract(target), \"Address: call to non-contract\");\n            }\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    /**\n     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason or using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    function _revert(bytes memory returndata, string memory errorMessage) private pure {\n        // Look for revert reason and bubble it up if present\n        if (returndata.length > 0) {\n            // The easiest way to bubble the revert reason is using memory via assembly\n            /// @solidity memory-safe-assembly\n            assembly {\n                let returndata_size := mload(returndata)\n                revert(add(32, returndata), returndata_size)\n            }\n        } else {\n            revert(errorMessage);\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/StorageSlot.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)\n// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for reading and writing primitive types to specific storage slots.\n *\n * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.\n * This library helps with reading and writing to such slots without the need for inline assembly.\n *\n * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.\n *\n * Example usage to set ERC1967 implementation slot:\n * ```solidity\n * contract ERC1967 {\n *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n *\n *     function _getImplementation() internal view returns (address) {\n *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;\n *     }\n *\n *     function _setImplementation(address newImplementation) internal {\n *         require(Address.isContract(newImplementation), \"ERC1967: new implementation is not a contract\");\n *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;\n *     }\n * }\n * ```\n *\n * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._\n * _Available since v4.9 for `string`, `bytes`._\n */\nlibrary StorageSlot {\n    struct AddressSlot {\n        address value;\n    }\n\n    struct BooleanSlot {\n        bool value;\n    }\n\n    struct Bytes32Slot {\n        bytes32 value;\n    }\n\n    struct Uint256Slot {\n        uint256 value;\n    }\n\n    struct StringSlot {\n        string value;\n    }\n\n    struct BytesSlot {\n        bytes value;\n    }\n\n    /**\n     * @dev Returns an `AddressSlot` with member `value` located at `slot`.\n     */\n    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.\n     */\n    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.\n     */\n    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.\n     */\n    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `StringSlot` with member `value` located at `slot`.\n     */\n    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.\n     */\n    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := store.slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BytesSlot` with member `value` located at `slot`.\n     */\n    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.\n     */\n    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := store.slot\n        }\n    }\n}\n"
    },
    "contracts/Upgradability/SlaqqProxy.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity ^0.8.7;\n\nimport \"@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol\";\n\n/**\n * @title SlaqqProxy\n * @notice Proxy contract that forwards calls to the main contract.\n * @dev Allows for upgrading the logic contract without changing the proxys address.\n */\n\ncontract SlaqqProxy is \n    TransparentUpgradeableProxy\n{   \n    /**\n     * @notice The constructor of the proxy that sets the admin and logic.\n     * @param logic: The address of the contract that implements the underlying logic.\n     * @param admin: The address of the admin of the proxy.\n     * @param data: Any data to send immediately to the implementation contract.\n     */\n    constructor(\n        address logic,\n        address admin,\n        bytes memory data\n    ) TransparentUpgradeableProxy(\n        logic, \n        admin, \n        data\n    ) {}\n}\n"
    }
  }
}}