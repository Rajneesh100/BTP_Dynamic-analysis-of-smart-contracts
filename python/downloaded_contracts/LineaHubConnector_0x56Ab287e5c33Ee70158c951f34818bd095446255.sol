{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
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
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling\n     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.\n     *\n     * _Available since v4.8._\n     */\n    function verifyCallResultFromTarget(\n        address target,\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        if (success) {\n            if (returndata.length == 0) {\n                // only check isContract if the call was successful and the return data is empty\n                // otherwise we already know that it was a contract\n                require(isContract(target), \"Address: call to non-contract\");\n            }\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    /**\n     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason or using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    function _revert(bytes memory returndata, string memory errorMessage) private pure {\n        // Look for revert reason and bubble it up if present\n        if (returndata.length > 0) {\n            // The easiest way to bubble the revert reason is using memory via assembly\n            /// @solidity memory-safe-assembly\n            assembly {\n                let returndata_size := mload(returndata)\n                revert(add(32, returndata), returndata_size)\n            }\n        } else {\n            revert(errorMessage);\n        }\n    }\n}\n"
    },
    "contracts/messaging/connectors/Connector.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\nimport {Address} from \"@openzeppelin/contracts/utils/Address.sol\";\n\nimport {ProposedOwnable} from \"../../shared/ProposedOwnable.sol\";\nimport {IConnector} from \"../interfaces/IConnector.sol\";\n\n/**\n * @title Connector\n * @author Connext Labs, Inc.\n * @notice This contract has the messaging interface functions used by all connectors.\n *\n * @dev This contract stores information about mirror connectors, but can be used as a\n * base for contracts that do not have a mirror (i.e. the connector handling messaging on\n * mainnet). In this case, the `mirrorConnector` and `MIRROR_DOMAIN`\n * will be empty\n *\n * @dev If ownership is renounced, this contract will be unable to update its `mirrorConnector`\n * or `mirrorGas`\n */\nabstract contract Connector is ProposedOwnable, IConnector {\n  // ========== Custom Errors ===========\n\n  error Connector__processMessage_notUsed();\n\n  // ============ Events ============\n\n  event NewConnector(\n    uint32 indexed domain,\n    uint32 indexed mirrorDomain,\n    address amb,\n    address rootManager,\n    address mirrorConnector\n  );\n\n  event MirrorConnectorUpdated(address previous, address current);\n\n  /**\n   * @notice Emitted when funds are withdrawn by the admin\n   * @dev See comments in `withdrawFunds`\n   * @param to The recipient of the funds\n   * @param amount The amount withdrawn\n   */\n  event FundsWithdrawn(address indexed to, uint256 amount);\n\n  // ============ Public Storage ============\n\n  /**\n   * @notice The domain of this Messaging (i.e. Connector) contract.\n   */\n  uint32 public immutable DOMAIN;\n\n  /**\n   * @notice Address of the AMB on this domain.\n   */\n  address public immutable AMB;\n\n  /**\n   * @notice RootManager contract address.\n   */\n  address public immutable ROOT_MANAGER;\n\n  /**\n   * @notice The domain of the corresponding messaging (i.e. Connector) contract.\n   */\n  uint32 public immutable MIRROR_DOMAIN;\n\n  /**\n   * @notice Connector on L2 for L1 connectors, and vice versa.\n   */\n  address public mirrorConnector;\n\n  // ============ Modifiers ============\n\n  /**\n   * @notice Errors if the msg.sender is not the registered AMB\n   */\n  modifier onlyAMB() {\n    require(msg.sender == AMB, \"!AMB\");\n    _;\n  }\n\n  /**\n   * @notice Errors if the msg.sender is not the registered ROOT_MANAGER\n   */\n  modifier onlyRootManager() {\n    // NOTE: RootManager will be zero address for spoke connectors.\n    // Only root manager can dispatch a message to spokes/L2s via the hub connector.\n    require(msg.sender == ROOT_MANAGER, \"!rootManager\");\n    _;\n  }\n\n  // ============ Constructor ============\n\n  /**\n   * @notice Creates a new HubConnector instance\n   * @dev The connectors are deployed such that there is one on each side of an AMB (i.e.\n   * for optimism, there is one connector on optimism and one connector on mainnet)\n   * @param _domain The domain this connector lives on\n   * @param _mirrorDomain The spoke domain\n   * @param _amb The address of the amb on the domain this connector lives on\n   * @param _rootManager The address of the RootManager on mainnet\n   * @param _mirrorConnector The address of the spoke connector\n   */\n  constructor(\n    uint32 _domain,\n    uint32 _mirrorDomain,\n    address _amb,\n    address _rootManager,\n    address _mirrorConnector\n  ) ProposedOwnable() {\n    // set the owner\n    _setOwner(msg.sender);\n\n    // sanity checks on values\n    require(_domain != 0, \"empty domain\");\n    require(_rootManager != address(0), \"empty rootManager\");\n    // see note at top of contract on why the mirror values are not sanity checked\n\n    // set immutables\n    DOMAIN = _domain;\n    AMB = _amb;\n    ROOT_MANAGER = _rootManager;\n    MIRROR_DOMAIN = _mirrorDomain;\n    // set mutables if defined\n    if (_mirrorConnector != address(0)) {\n      _setMirrorConnector(_mirrorConnector);\n    }\n\n    emit NewConnector(_domain, _mirrorDomain, _amb, _rootManager, _mirrorConnector);\n  }\n\n  // ============ Receivable ============\n  /**\n   * @notice Connectors may need to receive native asset to handle fees when sending a\n   * message\n   */\n  receive() external payable {}\n\n  // ============ Admin Functions ============\n\n  /**\n   * @notice Sets the address of the l2Connector for this domain\n   */\n  function setMirrorConnector(address _mirrorConnector) public onlyOwner {\n    _setMirrorConnector(_mirrorConnector);\n  }\n\n  /**\n   * @notice This function should be callable by owner, and send funds trapped on\n   * a connector to the provided recipient.\n   * @dev Withdraws the entire balance of the contract.\n   *\n   * @param _to The recipient of the funds withdrawn\n   */\n  function withdrawFunds(address _to) public onlyOwner {\n    uint256 amount = address(this).balance;\n    Address.sendValue(payable(_to), amount);\n    emit FundsWithdrawn(_to, amount);\n  }\n\n  // ============ Public Functions ============\n\n  /**\n   * @notice Processes a message received by an AMB\n   * @dev This is called by AMBs to process messages originating from mirror connector\n   */\n  function processMessage(bytes memory _data) external virtual onlyAMB {\n    _processMessage(_data);\n    emit MessageProcessed(_data, msg.sender);\n  }\n\n  /**\n   * @notice Checks the cross domain sender for a given address\n   */\n  function verifySender(address _expected) external returns (bool) {\n    return _verifySender(_expected);\n  }\n\n  // ============ Virtual Functions ============\n\n  /**\n   * @notice This function is used by the Connext contract on the l2 domain to send a message to the\n   * l1 domain (i.e. called by Connext on optimism to send a message to mainnet with roots)\n   * @param _data The contents of the message\n   * @param _encodedData Data used to send the message; specific to connector\n   */\n  function _sendMessage(bytes memory _data, bytes memory _encodedData) internal virtual;\n\n  /**\n   * @notice This function is used by the AMBs to handle incoming messages. Should store the latest\n   * root generated on the l2 domain.\n   */\n  function _processMessage(\n    bytes memory /* _data */\n  ) internal virtual {\n    // By default, reverts. This is to ensure the call path is not used unless this function is\n    // overridden by the inheriting class\n    revert Connector__processMessage_notUsed();\n  }\n\n  /**\n   * @notice Verify that the msg.sender is the correct AMB contract, and that the message's origin sender\n   * is the expected address.\n   * @dev Should be overridden by the implementing Connector contract.\n   */\n  function _verifySender(address _expected) internal virtual returns (bool);\n\n  // ============ Private Functions ============\n\n  function _setMirrorConnector(address _mirrorConnector) internal virtual {\n    emit MirrorConnectorUpdated(mirrorConnector, _mirrorConnector);\n    mirrorConnector = _mirrorConnector;\n  }\n}\n"
    },
    "contracts/messaging/connectors/HubConnector.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\nimport {Connector} from \"./Connector.sol\";\n\n/**\n * @title HubConnector\n * @author Connext Labs, Inc.\n * @notice This contract implements the messaging functions needed on the hub-side of a given AMB.\n * The HubConnector has a limited set of functionality compared to the SpokeConnector, namely that\n * it contains no logic to store or prove messages.\n *\n * @dev This contract should be deployed on the hub-side of an AMB (i.e. on L1), and contracts\n * which extend this should implement the virtual functions defined in the BaseConnector class\n */\nabstract contract HubConnector is Connector {\n  /**\n   * @notice Creates a new HubConnector instance\n   * @dev The connectors are deployed such that there is one on each side of an AMB (i.e.\n   * for optimism, there is one connector on optimism and one connector on mainnet)\n   * @param _domain The domain this connector lives on\n   * @param _mirrorDomain The spoke domain\n   * @param _amb The address of the amb on the domain this connector lives on\n   * @param _rootManager The address of the RootManager on mainnet\n   * @param _mirrorConnector The address of the spoke connector\n   */\n  constructor(\n    uint32 _domain,\n    uint32 _mirrorDomain,\n    address _amb,\n    address _rootManager,\n    address _mirrorConnector\n  ) Connector(_domain, _mirrorDomain, _amb, _rootManager, _mirrorConnector) {}\n\n  // ============ Public fns ============\n  /**\n   * @notice Sends a message over the amb\n   * @dev This is called by the root manager *only* on mainnet to propagate the aggregate root\n   */\n  function sendMessage(bytes memory _data, bytes memory _encodedData) external payable onlyRootManager {\n    _sendMessage(_data, _encodedData);\n    emit MessageSent(_data, _encodedData, msg.sender);\n  }\n}\n"
    },
    "contracts/messaging/connectors/linea/LineaBase.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\nimport {LineaAmb} from \"../../interfaces/ambs/LineaAmb.sol\";\n\nabstract contract LineaBase {\n  // ============ Private fns ============\n\n  /**\n   * @dev Asserts the sender of a cross domain message\n   */\n  function _verifySender(address _amb, address _expected) internal view returns (bool) {\n    require(msg.sender == _amb, \"!bridge\");\n    return LineaAmb(_amb).sender() == _expected;\n  }\n}\n"
    },
    "contracts/messaging/connectors/linea/LineaHubConnector.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\nimport {IRootManager} from \"../../interfaces/IRootManager.sol\";\nimport {LineaAmb} from \"../../interfaces/ambs/LineaAmb.sol\";\n\nimport {Connector} from \"../Connector.sol\";\nimport {HubConnector} from \"../HubConnector.sol\";\n\nimport {LineaBase} from \"./LineaBase.sol\";\n\ncontract LineaHubConnector is HubConnector, LineaBase {\n  // ============ Constructor ============\n  constructor(\n    uint32 _domain,\n    uint32 _mirrorDomain,\n    address _amb,\n    address _rootManager,\n    address _mirrorConnector\n  ) HubConnector(_domain, _mirrorDomain, _amb, _rootManager, _mirrorConnector) LineaBase() {}\n\n  // ============ Private fns ============\n  /**\n   * @dev Asserts the sender of a cross domain message\n   */\n  function _verifySender(address _expected) internal view override returns (bool) {\n    return _verifySender(AMB, _expected);\n  }\n\n  /**\n   * @notice Deliver a message to the destination chain.\n   * @param _calldata The calldata used by the destination message service to call/forward to the destination contract.\n   * @param _nonce Unique message number.\n   */\n  function claimMessage(bytes calldata _calldata, uint256 _nonce) external {\n    //  * @param _from = mirror connector address. The msg.sender calling the origin message service.\n    //  * @param _to = hub connector address. The destination address on the destination chain.\n    //  * @param _value = 0. The value to be transferred to the destination address.\n    //  * @param _fee = 0. The message service fee on the origin chain.\n    //  * @param _feeRecipient = address(0). Address that will receive the fees.\n    LineaAmb(AMB).claimMessage(mirrorConnector, address(this), 0, 0, payable(address(0)), _calldata, _nonce);\n  }\n\n  /**\n   * @dev Messaging uses this function to send data to l2 via amb\n   */\n  function _sendMessage(bytes memory _data, bytes memory _encodedData) internal override {\n    // Should always be dispatching the aggregate root\n    require(_data.length == 32, \"!length\");\n\n    // Should not include specialized calldata\n    require(_encodedData.length == 0, \"!data length\");\n\n    // send message via AMB, should call \"processMessage\" which will update aggregate root\n    LineaAmb(AMB).sendMessage{value: msg.value}(\n      mirrorConnector,\n      msg.value, // fee is the passed in value\n      abi.encodeWithSelector(Connector.processMessage.selector, _data)\n    );\n  }\n\n  /**\n   * @dev L2 connector calls this function to pass down latest outbound root\n   */\n  function _processMessage(bytes memory _data) internal override {\n    // ensure the l1 connector sent the message\n    require(_verifySender(mirrorConnector), \"!l2Connector\");\n    // get the data (should be the outbound root)\n    require(_data.length == 32, \"!length\");\n    // update the root on the root manager\n    IRootManager(ROOT_MANAGER).aggregate(MIRROR_DOMAIN, bytes32(_data));\n  }\n}\n"
    },
    "contracts/messaging/interfaces/IConnector.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\nimport {IProposedOwnable} from \"../../shared/interfaces/IProposedOwnable.sol\";\n\n/**\n * @notice This interface is what the Connext contract will send and receive messages through.\n * The messaging layer should conform to this interface, and should be interchangeable (i.e.\n * could be Nomad or a generic AMB under the hood).\n *\n * @dev This uses the nomad format to ensure nomad can be added in as it comes back online.\n *\n * Flow from transfer from polygon to optimism:\n * 1. User calls `xcall` with destination specified\n * 2. This will swap in to the bridge assets\n * 3. The swapped assets will get burned\n * 4. The Connext contract will call `dispatch` on the messaging contract to add the transfer\n *    to the root\n * 5. [At some time interval] Relayers call `send` to send the current root from polygon to\n *    mainnet. This is done on all \"spoke\" domains.\n * 6. [At some time interval] Relayers call `propagate` [better name] on mainnet, this generates a new merkle\n *    root from all of the AMBs\n *    - This function must be able to read root data from all AMBs and aggregate them into a single merkle\n *      tree root\n *    - Will send the mixed root from all chains back through the respective AMBs to all other chains\n * 7. AMB will call `update` to update the latest root on the messaging contract on spoke domains\n * 8. [At any point] Relayers can call `proveAndProcess` to prove inclusion of dispatched message, and call\n *    process on the `Connext` contract\n * 9. Takes minted bridge tokens and credits the LP\n *\n * AMB requirements:\n * - Access `msg.sender` both from mainnet -> spoke and vice versa\n * - Ability to read *our root* from the AMB\n *\n * AMBs:\n * - PoS bridge from polygon\n * - arbitrum bridge\n * - optimism bridge\n * - gnosis chain\n * - bsc (use multichain for messaging)\n */\ninterface IConnector is IProposedOwnable {\n  // ============ Events ============\n  /**\n   * @notice Emitted whenever a message is successfully sent over an AMB\n   * @param data The contents of the message\n   * @param encodedData Data used to send the message; specific to connector\n   * @param caller Who called the function (sent the message)\n   */\n  event MessageSent(bytes data, bytes encodedData, address caller);\n\n  /**\n   * @notice Emitted whenever a message is successfully received over an AMB\n   * @param data The contents of the message\n   * @param caller Who called the function\n   */\n  event MessageProcessed(bytes data, address caller);\n\n  // ============ Public fns ============\n\n  function processMessage(bytes memory _data) external;\n\n  function verifySender(address _expected) external returns (bool);\n}\n"
    },
    "contracts/messaging/interfaces/IRootManager.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\ninterface IRootManager {\n  /**\n   * @notice This is called by relayers to generate + send the mixed root from mainnet via AMB to\n   * spoke domains.\n   * @dev This must read information for the root from the registered AMBs.\n   */\n  function propagate(\n    address[] calldata _connectors,\n    uint256[] calldata _fees,\n    bytes[] memory _encodedData\n  ) external payable;\n\n  /**\n   * @notice Called by the connectors for various domains on the hub to aggregate their latest\n   * inbound root.\n   * @dev This must read information for the root from the registered AMBs\n   */\n  function aggregate(uint32 _domain, bytes32 _outbound) external;\n}\n"
    },
    "contracts/messaging/interfaces/ambs/LineaAmb.sol": {
      "content": "// SPDX-License-Identifier: OWNED BY ConsenSys Software Inc.\npragma solidity ^0.8.15;\n\n// PASTED FROM https://docs.linea.build/developers/bridge-architecture/message-service  #IMessageService.sol\n\n/// @title The bridge interface implemented on both chains\ninterface LineaAmb {\n  /**\n   * @dev Emitted when a message is sent.\n   * @dev We include the message hash to save hashing costs on the rollup.\n   */\n  event MessageSent(\n    address indexed _from,\n    address indexed _to,\n    uint256 _fee,\n    uint256 _value,\n    uint256 _nonce,\n    bytes _calldata,\n    bytes32 indexed _messageHash\n  );\n\n  /**\n   * @dev Emitted when a message is claimed.\n   */\n  event MessageClaimed(bytes32 indexed _messageHash);\n\n  /**\n   * @dev Thrown when fees are lower than the minimum fee.\n   */\n  error FeeTooLow();\n\n  /**\n   * @dev Thrown when fees are lower than value.\n   */\n  error ValueShouldBeGreaterThanFee();\n\n  /**\n   * @dev Thrown when the value sent is less than the fee.\n   * @dev Value to forward on is msg.value - _fee.\n   */\n  error ValueSentTooLow();\n\n  /**\n   * @dev Thrown when the destination address reverts.\n   */\n  error MessageSendingFailed(address destination);\n\n  /**\n   * @dev Thrown when the destination address reverts.\n   */\n  error FeePaymentFailed(address recipient);\n\n  /**\n   * @notice Sends a message for transporting from the given chain.\n   * @dev This function should be called with a msg.value = _value + _fee. The fee will be paid on the destination chain.\n   * @param _to The destination address on the destination chain.\n   * @param _fee The message service fee on the origin chain.\n   * @param _calldata The calldata used by the destination message service to call the destination contract.\n   */\n  function sendMessage(address _to, uint256 _fee, bytes calldata _calldata) external payable;\n\n  /**\n   * @notice Deliver a message to the destination chain.\n   * @notice Is called automatically by the Postman, dApp or end user.\n   * @param _from The msg.sender calling the origin message service.\n   * @param _to The destination address on the destination chain.\n   * @param _value The value to be transferred to the destination address.\n   * @param _fee The message service fee on the origin chain.\n   * @param _feeRecipient Address that will receive the fees.\n   * @param _calldata The calldata used by the destination message service to call/forward to the destination contract.\n   * @param _nonce Unique message number.\n   */\n  function claimMessage(\n    address _from,\n    address _to,\n    uint256 _fee,\n    uint256 _value,\n    address payable _feeRecipient,\n    bytes calldata _calldata,\n    uint256 _nonce\n  ) external;\n\n  /**\n   * @notice Returns the original sender of the message on the origin layer.\n   * @return The original sender of the message on the origin layer.\n   */\n  function sender() external view returns (address);\n}\n"
    },
    "contracts/shared/ProposedOwnable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.17;\n\nimport {IProposedOwnable} from \"./interfaces/IProposedOwnable.sol\";\n\n/**\n * @title ProposedOwnable\n * @notice Contract module which provides a basic access control mechanism,\n * where there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed via a two step process:\n * 1. Call `proposeOwner`\n * 2. Wait out the delay period\n * 3. Call `acceptOwner`\n *\n * @dev This module is used through inheritance. It will make available the\n * modifier `onlyOwner`, which can be applied to your functions to restrict\n * their use to the owner.\n *\n * @dev The majority of this code was taken from the openzeppelin Ownable\n * contract\n *\n */\nabstract contract ProposedOwnable is IProposedOwnable {\n  // ========== Custom Errors ===========\n\n  error ProposedOwnable__onlyOwner_notOwner();\n  error ProposedOwnable__onlyProposed_notProposedOwner();\n  error ProposedOwnable__ownershipDelayElapsed_delayNotElapsed();\n  error ProposedOwnable__proposeNewOwner_invalidProposal();\n  error ProposedOwnable__proposeNewOwner_noOwnershipChange();\n  error ProposedOwnable__renounceOwnership_noProposal();\n  error ProposedOwnable__renounceOwnership_invalidProposal();\n\n  // ============ Properties ============\n\n  address private _owner;\n\n  address private _proposed;\n  uint256 private _proposedOwnershipTimestamp;\n\n  uint256 private constant _delay = 7 days;\n\n  // ======== Getters =========\n\n  /**\n   * @notice Returns the address of the current owner.\n   */\n  function owner() public view virtual returns (address) {\n    return _owner;\n  }\n\n  /**\n   * @notice Returns the address of the proposed owner.\n   */\n  function proposed() public view virtual returns (address) {\n    return _proposed;\n  }\n\n  /**\n   * @notice Returns the address of the proposed owner.\n   */\n  function proposedTimestamp() public view virtual returns (uint256) {\n    return _proposedOwnershipTimestamp;\n  }\n\n  /**\n   * @notice Returns the delay period before a new owner can be accepted.\n   */\n  function delay() public view virtual returns (uint256) {\n    return _delay;\n  }\n\n  /**\n   * @notice Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    if (_owner != msg.sender) revert ProposedOwnable__onlyOwner_notOwner();\n    _;\n  }\n\n  /**\n   * @notice Throws if called by any account other than the proposed owner.\n   */\n  modifier onlyProposed() {\n    if (_proposed != msg.sender) revert ProposedOwnable__onlyProposed_notProposedOwner();\n    _;\n  }\n\n  /**\n   * @notice Throws if the ownership delay has not elapsed\n   */\n  modifier ownershipDelayElapsed() {\n    // Ensure delay has elapsed\n    if ((block.timestamp - _proposedOwnershipTimestamp) <= _delay)\n      revert ProposedOwnable__ownershipDelayElapsed_delayNotElapsed();\n    _;\n  }\n\n  /**\n   * @notice Indicates if the ownership has been renounced() by\n   * checking if current owner is address(0)\n   */\n  function renounced() public view returns (bool) {\n    return _owner == address(0);\n  }\n\n  // ======== External =========\n\n  /**\n   * @notice Sets the timestamp for an owner to be proposed, and sets the\n   * newly proposed owner as step 1 in a 2-step process\n   */\n  function proposeNewOwner(address newlyProposed) public virtual onlyOwner {\n    // Contract as source of truth\n    if (_proposed == newlyProposed && _proposedOwnershipTimestamp != 0)\n      revert ProposedOwnable__proposeNewOwner_invalidProposal();\n\n    // Sanity check: reasonable proposal\n    if (_owner == newlyProposed) revert ProposedOwnable__proposeNewOwner_noOwnershipChange();\n\n    _setProposed(newlyProposed);\n  }\n\n  /**\n   * @notice Renounces ownership of the contract after a delay\n   */\n  function renounceOwnership() public virtual onlyOwner ownershipDelayElapsed {\n    // Ensure there has been a proposal cycle started\n    if (_proposedOwnershipTimestamp == 0) revert ProposedOwnable__renounceOwnership_noProposal();\n\n    // Require proposed is set to 0\n    if (_proposed != address(0)) revert ProposedOwnable__renounceOwnership_invalidProposal();\n\n    // Emit event, set new owner, reset timestamp\n    _setOwner(address(0));\n  }\n\n  /**\n   * @notice Transfers ownership of the contract to a new account (`newOwner`).\n   * Can only be called by the current owner.\n   */\n  function acceptProposedOwner() public virtual onlyProposed ownershipDelayElapsed {\n    // NOTE: no need to check if _owner == _proposed, because the _proposed\n    // is 0-d out and this check is implicitly enforced by modifier\n\n    // NOTE: no need to check if _proposedOwnershipTimestamp > 0 because\n    // the only time this would happen is if the _proposed was never\n    // set (will fail from modifier) or if the owner == _proposed (checked\n    // above)\n\n    // Emit event, set new owner, reset timestamp\n    _setOwner(_proposed);\n  }\n\n  // ======== Internal =========\n\n  function _setOwner(address newOwner) internal {\n    emit OwnershipTransferred(_owner, newOwner);\n    _owner = newOwner;\n    delete _proposedOwnershipTimestamp;\n    delete _proposed;\n  }\n\n  function _setProposed(address newlyProposed) private {\n    _proposedOwnershipTimestamp = block.timestamp;\n    _proposed = newlyProposed;\n    emit OwnershipProposed(newlyProposed);\n  }\n}\n"
    },
    "contracts/shared/interfaces/IProposedOwnable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.17;\n\n/**\n * @title IProposedOwnable\n * @notice Defines a minimal interface for ownership with a two step proposal and acceptance\n * process\n */\ninterface IProposedOwnable {\n  /**\n   * @dev This emits when change in ownership of a contract is proposed.\n   */\n  event OwnershipProposed(address indexed proposedOwner);\n\n  /**\n   * @dev This emits when ownership of a contract changes.\n   */\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n  /**\n   * @notice Get the address of the owner\n   * @return owner_ The address of the owner.\n   */\n  function owner() external view returns (address owner_);\n\n  /**\n   * @notice Get the address of the proposed owner\n   * @return proposed_ The address of the proposed.\n   */\n  function proposed() external view returns (address proposed_);\n\n  /**\n   * @notice Set the address of the proposed owner of the contract\n   * @param newlyProposed The proposed new owner of the contract\n   */\n  function proposeNewOwner(address newlyProposed) external;\n\n  /**\n   * @notice Set the address of the proposed owner of the contract\n   */\n  function acceptProposedOwner() external;\n}\n"
    }
  }
}}