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
      "runs": 2000
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
    "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface AutomationCompatibleInterface {\n  /**\n   * @notice method that is simulated by the keepers to see if any work actually\n   * needs to be performed. This method does does not actually need to be\n   * executable, and since it is only ever simulated it can consume lots of gas.\n   * @dev To ensure that it is never called, you may want to add the\n   * cannotExecute modifier from KeeperBase to your implementation of this\n   * method.\n   * @param checkData specified in the upkeep registration so it is always the\n   * same for a registered upkeep. This can easily be broken down into specific\n   * arguments using `abi.decode`, so multiple upkeeps can be registered on the\n   * same contract and easily differentiated by the contract.\n   * @return upkeepNeeded boolean to indicate whether the keeper should call\n   * performUpkeep or not.\n   * @return performData bytes that the keeper should call performUpkeep with, if\n   * upkeep is needed. If you would like to encode data to decode later, try\n   * `abi.encode`.\n   */\n  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);\n\n  /**\n   * @notice method that is actually executed by the keepers, via the registry.\n   * The data returned by the checkUpkeep simulation will be passed into\n   * this method to actually be executed.\n   * @dev The input to this method should not be trusted, and the caller of the\n   * method should not even be restricted to any single registry. Anyone should\n   * be able call it, and the input should be validated, there is no guarantee\n   * that the data passed in is the performData returned from checkUpkeep. This\n   * could happen due to malicious keepers, racing keepers, or simply a state\n   * change while the performUpkeep transaction is waiting for confirmation.\n   * Always validate the data passed in.\n   * @param performData is the data which was passed back from the checkData\n   * simulation. If it is encoded, it can easily be decoded into other types by\n   * calling `abi.decode`. This data should not be trusted, and should be\n   * validated against the contract's current state.\n   */\n  function performUpkeep(bytes calldata performData) external;\n}\n"
    },
    "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\n/**\n * @notice This is a deprecated interface. Please use AutomationCompatibleInterface directly.\n */\npragma solidity ^0.8.0;\nimport {AutomationCompatibleInterface as KeeperCompatibleInterface} from \"./AutomationCompatibleInterface.sol\";\n"
    },
    "contracts/AutomationWrapper.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Matrixed.Link\npragma solidity ^0.8.7;\n\nimport \"@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol\";\n\n// Interface for interacting with a Chainlink consumer contract.\ninterface IChainlinkConsumer {\n    // Allows the contract to accept ownership transferred by another contract.\n    function acceptOwnership() external;\n    // Sends a request to the Chainlink Oracle.\n    function requestData() external;\n}\n\n// AutomationWrapper contract integrates Chainlink Keeper functionality for automated tasks\n// and interacts with a Chainlink consumer contract for Oracle requests.\ncontract AutomationWrapper is KeeperCompatibleInterface {\n    // Instance of the Chainlink consumer contract.\n    IChainlinkConsumer public chainlinkConsumer;\n    // Timestamp of the last successful upkeep.\n    uint256 public lastUpdateTime;\n    // Minimum interval in seconds between consecutive upkeeps.\n    uint256 public updateInterval;\n    // Address of the current owner.\n    address public owner;\n    // Address of the proposed new owner.\n    address public pendingOwner;\n\n    // Constructor initializes the Chainlink consumer contract and owner.\n    constructor(address _chainlinkConsumerAddress) {\n        chainlinkConsumer = IChainlinkConsumer(_chainlinkConsumerAddress);\n        lastUpdateTime = 1;\n        updateInterval = 84600; // Default interval set to 1 day\n        owner = msg.sender;\n    }\n\n    // Modifier to restrict function access to the current owner.\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Caller is not the owner\");\n        _;\n    }\n\n    // Proposes a new owner, can only be called by the current owner.\n    function proposeNewOwner(address _pendingOwner) external onlyOwner {\n        pendingOwner = _pendingOwner;\n    }\n\n    // Accepts the ownership of the AutomationWrapper contract, can only be called by the pending owner.\n    function acceptOwnership() external {\n        require(msg.sender == pendingOwner, \"Caller is not the pending owner\");\n        owner = pendingOwner;\n        pendingOwner = address(0);\n    }\n\n    // Accepts the ownership of the Chainlink consumer contract.\n    function acceptOwnershipConsumer() external {\n        chainlinkConsumer.acceptOwnership();\n    }\n\n    // Triggers a manual data request to the Chainlink Oracle, restricted to the owner.\n    function manualRequestData() external onlyOwner {\n        chainlinkConsumer.requestData();\n    }\n\n    // Checks if upkeep is needed based on the time elapsed since last update.\n    function checkUpkeep(bytes calldata)\n        external\n        view\n        override\n        returns (bool upkeepNeeded, bytes memory)\n    {\n        upkeepNeeded = (block.timestamp - lastUpdateTime) >= updateInterval;\n    }\n\n    // Performs the upkeep; sends a data request to the Chainlink Oracle.\n    function performUpkeep(bytes calldata) external override {\n        if ((block.timestamp - lastUpdateTime) >= updateInterval) {\n            chainlinkConsumer.requestData();\n            lastUpdateTime = block.timestamp;\n        }\n    }\n\n    // Allows the owner to set the interval for upkeep, restricted to the owner.\n    function setUpdateInterval(uint256 _updateInterval) external onlyOwner {\n        updateInterval = _updateInterval;\n    }\n}"
    }
  }
}}