{{
  "language": "Solidity",
  "sources": {
    "src/eco/Oracle.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.8.17;\n\nimport \"../Verifier.sol\";\nimport \"../interfaces/IFeedOracle.sol\";\n\ncontract Oracle is Verifier {\n    event Assigned(bytes32 indexed msgHash, uint256 fee);\n    event SetFee(uint256 indexed chainId, uint256 fee);\n    event SetApproved(address operator, bool approve);\n\n    address public immutable PROTOCOL;\n    address public immutable SUBAPI;\n\n    address public owner;\n    // chainId => price\n    mapping(uint256 => uint256) public feeOf;\n    // chainId => dapi\n    mapping(address => bool) public approvedOf;\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"!owner\");\n        _;\n    }\n\n    modifier onlyApproved() {\n        require(isApproved(msg.sender), \"!approve\");\n        _;\n    }\n\n    constructor(address dao, address ormp, address subapi) {\n        SUBAPI = subapi;\n        PROTOCOL = ormp;\n        owner = dao;\n    }\n\n    receive() external payable {}\n\n    function withdraw(address to, uint256 amount) external onlyApproved {\n        (bool success,) = to.call{value: amount}(\"\");\n        require(success, \"!withdraw\");\n    }\n\n    function isApproved(address operator) public view returns (bool) {\n        return approvedOf[operator];\n    }\n\n    function changeOwner(address owner_) external onlyOwner {\n        owner = owner_;\n    }\n\n    function setApproved(address operator, bool approve) external onlyOwner {\n        approvedOf[operator] = approve;\n        emit SetApproved(operator, approve);\n    }\n\n    function setFee(uint256 chainId, uint256 fee_) external onlyApproved {\n        feeOf[chainId] = fee_;\n        emit SetFee(chainId, fee_);\n    }\n\n    function fee(uint256 toChainId, address /*ua*/ ) public view returns (uint256) {\n        return feeOf[toChainId];\n    }\n\n    function assign(bytes32 msgHash) external payable {\n        require(msg.sender == PROTOCOL, \"!auth\");\n        emit Assigned(msgHash, msg.value);\n    }\n\n    function merkleRoot(uint256 chainId, uint256 /*blockNumber*/ ) public view override returns (bytes32) {\n        return IFeedOracle(SUBAPI).messageRootOf(chainId);\n    }\n}\n"
    },
    "src/Verifier.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.8.17;\n\nimport \"./interfaces/IVerifier.sol\";\nimport \"./imt/IncrementalMerkleTree.sol\";\n\nabstract contract Verifier is IVerifier {\n    /// @notice Message proof.\n    /// @param blockNumber The block number corresponding to the proof.\n    /// @param messageIndex Leaf index of the message hash in incremental merkle tree.\n    /// @param messageProof Merkle proof of the message hash.\n    struct Proof {\n        uint256 blockNumber;\n        uint256 messageIndex;\n        bytes32[32] messageProof;\n    }\n\n    /// @inheritdoc IVerifier\n    function merkleRoot(uint256 chainId, uint256 blockNumber) public view virtual returns (bytes32);\n\n    /// @inheritdoc IVerifier\n    function verifyMessageProof(uint256 fromChainId, bytes32 msgHash, bytes calldata proof)\n        external\n        view\n        returns (bool)\n    {\n        // decode proof\n        Proof memory p = abi.decode(proof, (Proof));\n\n        // fetch message root in block number from chain\n        bytes32 imtRootOracle = merkleRoot(fromChainId, p.blockNumber);\n        // calculate the expected root based on the proof\n        bytes32 imtRootProof = IncrementalMerkleTree.branchRoot(msgHash, p.messageProof, p.messageIndex);\n\n        // check oracle's merkle root equal relayer's merkle root\n        return imtRootOracle == imtRootProof;\n    }\n}\n"
    },
    "src/interfaces/IFeedOracle.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.8.17;\n\ninterface IFeedOracle {\n    function messageRootOf(uint256 chainid) external view returns (bytes32);\n}\n"
    },
    "src/interfaces/IVerifier.sol": {
      "content": "// This file is part of Darwinia.\n// Copyright (C) 2018-2023 Darwinia Network\n// SPDX-License-Identifier: GPL-3.0\n//\n// Darwinia is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// Darwinia is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n// GNU General Public License for more details.\n//\n// You should have received a copy of the GNU General Public License\n// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.8.17;\n\ninterface IVerifier {\n    /// @notice Fetch message root oracle.\n    /// @param chainId The destination chain id.\n    /// @param blockNumber The block number where the message root is located.\n    /// @return Message root in destination chain.\n    function merkleRoot(uint256 chainId, uint256 blockNumber) external view returns (bytes32);\n\n    /// @notice Verify message proof\n    /// @dev Message proof provided by relayer. Oracle should provide message root of\n    ///      source chain, and verify the merkle proof of the message hash.\n    /// @param fromChainId Source chain id.\n    /// @param msgHash Hash of the message.\n    /// @param proof Merkle proof of the message\n    /// @return Result of the message verify.\n    function verifyMessageProof(uint256 fromChainId, bytes32 msgHash, bytes calldata proof)\n        external\n        view\n        returns (bool);\n}\n"
    },
    "src/imt/IncrementalMerkleTree.sol": {
      "content": "// SPDX-License-Identifier: MIT OR Apache-2.0\npragma solidity 0.8.17;\n\n// Inspired: https://github.com/nomad-xyz/monorepo/blob/main/packages/contracts-core/contracts/libs/Merkle.sol\n\n/// @title IncrementalMerkleTree\n/// @author Illusory Systems Inc.\n/// @notice An incremental merkle tree modeled on the eth2 deposit contract.\nlibrary IncrementalMerkleTree {\n    uint256 private constant TREE_DEPTH = 32;\n    uint256 private constant MAX_LEAVES = 2 ** TREE_DEPTH - 1;\n\n    /// @notice Struct representing incremental merkle tree. Contains current\n    /// branch and the number of inserted leaves in the tree.\n    struct Tree {\n        bytes32[TREE_DEPTH] branch;\n        uint256 count;\n    }\n\n    /// @notice Inserts `_node` into merkle tree\n    /// @dev Reverts if tree is full\n    /// @param _node Element to insert into tree\n    function insert(Tree storage _tree, bytes32 _node) internal {\n        require(_tree.count < MAX_LEAVES, \"merkle tree full\");\n\n        _tree.count += 1;\n        uint256 size = _tree.count;\n        for (uint256 i = 0; i < TREE_DEPTH; i++) {\n            if ((size & 1) == 1) {\n                _tree.branch[i] = _node;\n                return;\n            }\n            _node = keccak256(abi.encodePacked(_tree.branch[i], _node));\n            size /= 2;\n        }\n        // As the loop should always end prematurely with the `return` statement,\n        // this code should be unreachable. We assert `false` just to be safe.\n        assert(false);\n    }\n\n    /// @notice Calculates and returns`_tree`'s current root given array of zero\n    /// hashes\n    /// @param _zeroes Array of zero hashes\n    /// @return _current Calculated root of `_tree`\n    function rootWithCtx(Tree storage _tree, bytes32[TREE_DEPTH] memory _zeroes)\n        internal\n        view\n        returns (bytes32 _current)\n    {\n        uint256 _index = _tree.count;\n\n        for (uint256 i = 0; i < TREE_DEPTH; i++) {\n            uint256 _ithBit = (_index >> i) & 0x01;\n            bytes32 _next = _tree.branch[i];\n            if (_ithBit == 1) {\n                _current = keccak256(abi.encodePacked(_next, _current));\n            } else {\n                _current = keccak256(abi.encodePacked(_current, _zeroes[i]));\n            }\n        }\n    }\n\n    /// @notice Calculates and returns`_tree`'s current root\n    function root(Tree storage _tree) internal view returns (bytes32) {\n        return rootWithCtx(_tree, zeroHashes());\n    }\n\n    /// @notice Returns array of TREE_DEPTH zero hashes\n    /// @return _zeroes Array of TREE_DEPTH zero hashes\n    function zeroHashes() internal pure returns (bytes32[TREE_DEPTH] memory _zeroes) {\n        _zeroes[0] = Z_0;\n        _zeroes[1] = Z_1;\n        _zeroes[2] = Z_2;\n        _zeroes[3] = Z_3;\n        _zeroes[4] = Z_4;\n        _zeroes[5] = Z_5;\n        _zeroes[6] = Z_6;\n        _zeroes[7] = Z_7;\n        _zeroes[8] = Z_8;\n        _zeroes[9] = Z_9;\n        _zeroes[10] = Z_10;\n        _zeroes[11] = Z_11;\n        _zeroes[12] = Z_12;\n        _zeroes[13] = Z_13;\n        _zeroes[14] = Z_14;\n        _zeroes[15] = Z_15;\n        _zeroes[16] = Z_16;\n        _zeroes[17] = Z_17;\n        _zeroes[18] = Z_18;\n        _zeroes[19] = Z_19;\n        _zeroes[20] = Z_20;\n        _zeroes[21] = Z_21;\n        _zeroes[22] = Z_22;\n        _zeroes[23] = Z_23;\n        _zeroes[24] = Z_24;\n        _zeroes[25] = Z_25;\n        _zeroes[26] = Z_26;\n        _zeroes[27] = Z_27;\n        _zeroes[28] = Z_28;\n        _zeroes[29] = Z_29;\n        _zeroes[30] = Z_30;\n        _zeroes[31] = Z_31;\n    }\n\n    /// @notice Calculates and returns the merkle root for the given leaf\n    /// `_item`, a merkle branch, and the index of `_item` in the tree.\n    /// @param _item Merkle leaf\n    /// @param _branch Merkle proof\n    /// @param _index Index of `_item` in tree\n    /// @return _current Calculated merkle root\n    function branchRoot(bytes32 _item, bytes32[TREE_DEPTH] memory _branch, uint256 _index)\n        internal\n        pure\n        returns (bytes32 _current)\n    {\n        _current = _item;\n\n        for (uint256 i = 0; i < TREE_DEPTH; i++) {\n            uint256 _ithBit = (_index >> i) & 0x01;\n            bytes32 _next = _branch[i];\n            if (_ithBit == 1) {\n                _current = keccak256(abi.encodePacked(_next, _current));\n            } else {\n                _current = keccak256(abi.encodePacked(_current, _next));\n            }\n        }\n    }\n\n    function prove(Tree storage _tree) internal view returns (bytes32[TREE_DEPTH] memory proof) {\n        uint256 _index = _tree.count - 1;\n        bytes32[TREE_DEPTH] memory left = _tree.branch;\n        bytes32[TREE_DEPTH] memory right = zeroHashes();\n        for (uint256 i = 0; i < TREE_DEPTH; i++) {\n            uint256 _ith_bit = (_index >> i) & 0x01;\n            if (_ith_bit == 1) {\n                proof[i] = left[i];\n            } else {\n                proof[i] = right[i];\n            }\n        }\n    }\n\n    // keccak256 zero hashes\n    bytes32 private constant Z_0 = hex\"0000000000000000000000000000000000000000000000000000000000000000\";\n    bytes32 private constant Z_1 = hex\"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5\";\n    bytes32 private constant Z_2 = hex\"b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30\";\n    bytes32 private constant Z_3 = hex\"21ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85\";\n    bytes32 private constant Z_4 = hex\"e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a19344\";\n    bytes32 private constant Z_5 = hex\"0eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d\";\n    bytes32 private constant Z_6 = hex\"887c22bd8750d34016ac3c66b5ff102dacdd73f6b014e710b51e8022af9a1968\";\n    bytes32 private constant Z_7 = hex\"ffd70157e48063fc33c97a050f7f640233bf646cc98d9524c6b92bcf3ab56f83\";\n    bytes32 private constant Z_8 = hex\"9867cc5f7f196b93bae1e27e6320742445d290f2263827498b54fec539f756af\";\n    bytes32 private constant Z_9 = hex\"cefad4e508c098b9a7e1d8feb19955fb02ba9675585078710969d3440f5054e0\";\n    bytes32 private constant Z_10 = hex\"f9dc3e7fe016e050eff260334f18a5d4fe391d82092319f5964f2e2eb7c1c3a5\";\n    bytes32 private constant Z_11 = hex\"f8b13a49e282f609c317a833fb8d976d11517c571d1221a265d25af778ecf892\";\n    bytes32 private constant Z_12 = hex\"3490c6ceeb450aecdc82e28293031d10c7d73bf85e57bf041a97360aa2c5d99c\";\n    bytes32 private constant Z_13 = hex\"c1df82d9c4b87413eae2ef048f94b4d3554cea73d92b0f7af96e0271c691e2bb\";\n    bytes32 private constant Z_14 = hex\"5c67add7c6caf302256adedf7ab114da0acfe870d449a3a489f781d659e8becc\";\n    bytes32 private constant Z_15 = hex\"da7bce9f4e8618b6bd2f4132ce798cdc7a60e7e1460a7299e3c6342a579626d2\";\n    bytes32 private constant Z_16 = hex\"2733e50f526ec2fa19a22b31e8ed50f23cd1fdf94c9154ed3a7609a2f1ff981f\";\n    bytes32 private constant Z_17 = hex\"e1d3b5c807b281e4683cc6d6315cf95b9ade8641defcb32372f1c126e398ef7a\";\n    bytes32 private constant Z_18 = hex\"5a2dce0a8a7f68bb74560f8f71837c2c2ebbcbf7fffb42ae1896f13f7c7479a0\";\n    bytes32 private constant Z_19 = hex\"b46a28b6f55540f89444f63de0378e3d121be09e06cc9ded1c20e65876d36aa0\";\n    bytes32 private constant Z_20 = hex\"c65e9645644786b620e2dd2ad648ddfcbf4a7e5b1a3a4ecfe7f64667a3f0b7e2\";\n    bytes32 private constant Z_21 = hex\"f4418588ed35a2458cffeb39b93d26f18d2ab13bdce6aee58e7b99359ec2dfd9\";\n    bytes32 private constant Z_22 = hex\"5a9c16dc00d6ef18b7933a6f8dc65ccb55667138776f7dea101070dc8796e377\";\n    bytes32 private constant Z_23 = hex\"4df84f40ae0c8229d0d6069e5c8f39a7c299677a09d367fc7b05e3bc380ee652\";\n    bytes32 private constant Z_24 = hex\"cdc72595f74c7b1043d0e1ffbab734648c838dfb0527d971b602bc216c9619ef\";\n    bytes32 private constant Z_25 = hex\"0abf5ac974a1ed57f4050aa510dd9c74f508277b39d7973bb2dfccc5eeb0618d\";\n    bytes32 private constant Z_26 = hex\"b8cd74046ff337f0a7bf2c8e03e10f642c1886798d71806ab1e888d9e5ee87d0\";\n    bytes32 private constant Z_27 = hex\"838c5655cb21c6cb83313b5a631175dff4963772cce9108188b34ac87c81c41e\";\n    bytes32 private constant Z_28 = hex\"662ee4dd2dd7b2bc707961b1e646c4047669dcb6584f0d8d770daf5d7e7deb2e\";\n    bytes32 private constant Z_29 = hex\"388ab20e2573d171a88108e79d820e98f26c0b84aa8b2f4aa4968dbb818ea322\";\n    bytes32 private constant Z_30 = hex\"93237c50ba75ee485f4c22adf2f741400bdf8d6a9cc7df7ecae576221665d735\";\n    bytes32 private constant Z_31 = hex\"8448818bb4ae4562849e949e17ac16e0be16688e156b5cf15e098c627c0056a9\";\n}\n"
    }
  },
  "settings": {
    "remappings": [],
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