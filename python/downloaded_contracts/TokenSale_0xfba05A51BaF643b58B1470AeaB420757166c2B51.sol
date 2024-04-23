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
      "enabled": false,
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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Tree proofs.\n *\n * The tree and the proofs can be generated using our\n * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].\n * You will find a quickstart guide in the readme.\n *\n * WARNING: You should avoid using leaf values that are 64 bytes long prior to\n * hashing, or use a hash function other than keccak256 for hashing leaves.\n * This is because the concatenation of a sorted pair of internal nodes in\n * the merkle tree could be reinterpreted as a leaf value.\n * OpenZeppelin's JavaScript library generates merkle trees that are safe\n * against this attack out of the box.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Calldata version of {verify}\n     *\n     * _Available since v4.7._\n     */\n    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProofCalldata(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Calldata version of {processProof}\n     *\n     * _Available since v4.7._\n     */\n    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by\n     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerify(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProof(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Calldata version of {multiProofVerify}\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerifyCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProofCalldata(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction\n     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another\n     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false\n     * respectively.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree\n     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the\n     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProof(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 proofLen = proof.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proofLen - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            require(proofPos == proofLen, \"MerkleProof: invalid multiproof\");\n            unchecked {\n                return hashes[totalHashes - 1];\n            }\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    /**\n     * @dev Calldata version of {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProofCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 proofLen = proof.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proofLen - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            require(proofPos == proofLen, \"MerkleProof: invalid multiproof\");\n            unchecked {\n                return hashes[totalHashes - 1];\n            }\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {\n        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);\n    }\n\n    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            mstore(0x00, a)\n            mstore(0x20, b)\n            value := keccak256(0x00, 0x40)\n        }\n    }\n}\n"
    },
    "contracts/TokenSale.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.16;\r\n\r\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\r\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\r\n\r\ncontract TokenSale {\r\n    address public multisig;\r\n    uint public tokenSaleStage = 0; // 0 = Omega, 1 = Alpha, 2 = Whitelist\r\n    uint public refPercentage = 1000; //3%\r\n    bytes32[3] public merkleRoots;\r\n    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;\r\n    address public lndx = 0x08A1C30BBB26425c1031ee9E43FA0B9960742539;\r\n    uint public priceMultiplier = 2; // $0.5/LNDX 1e6 = 5e5 = (x = 1e6 / 5e5) = 2\r\n    mapping(address => uint[3]) public claimed;\r\n\r\n    event Referral(uint256 amount, uint256 refAmount, address contributor, address referrer);\r\n\r\n    constructor() {\r\n        multisig = msg.sender;\r\n        merkleRoots[0] = 0x1f2ede652390c98d48f086e75cf059697b65eb6f58199258a061e1eb38f00772;\r\n        merkleRoots[1] = 0x223353dd9538fe9acd7e7469920d5a4a9c83b82a2377246f1c14ea09e43f9353;\r\n        merkleRoots[2] = 0xbaef4c074bdf663e724d3cd4ca9fafa42527b8582c0f30e3998ca4ed8568ce11;\r\n    }\r\n\r\n    function checkProof(address _user, bytes32[] calldata _merkleProof) public view returns(bool) {\r\n        bytes32 leaf = keccak256(abi.encodePacked(_user));\r\n        bool result = MerkleProof.verify(_merkleProof, merkleRoots[tokenSaleStage], leaf);\r\n        return result;\r\n    }\r\n\r\n    function buyTokens(uint _amountUSDC, bytes32[] calldata _merkleProof, address referrer) external {\r\n        claimed[msg.sender][tokenSaleStage] += _amountUSDC;\r\n        if (tokenSaleStage != 2) {\r\n            require(checkProof(msg.sender, _merkleProof) == true, \"Merkle proof does not validate\");\r\n        }\r\n        \r\n        IERC20(usdc).transferFrom(msg.sender, address(this), _amountUSDC);\r\n        if (referrer != address(0)) {\r\n            uint256 refAmount = _amountUSDC / 10000 * refPercentage;\r\n            IERC20(usdc).transfer(referrer, refAmount);\r\n            emit Referral(_amountUSDC, refAmount, msg.sender, referrer);\r\n        }\r\n        uint lndxOut = _amountUSDC * priceMultiplier;\r\n        IERC20(lndx).transfer(msg.sender, lndxOut);\r\n    }\r\n\r\n    function updateMultisig(address _multisig) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        multisig = _multisig;\r\n    }\r\n\r\n    function updateMerkleRoots(uint _tokenSaleStage, bytes32 _omegaRoot, bytes32 _alphaRoot, bytes32 _whitelistRoot) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        tokenSaleStage = _tokenSaleStage;\r\n        merkleRoots[0] = _omegaRoot;\r\n        merkleRoots[1] = _alphaRoot;\r\n        merkleRoots[2] = _whitelistRoot;\r\n    }\r\n\r\n    function updatePrice(uint _priceMultiplier) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        priceMultiplier = _priceMultiplier;\r\n    }\r\n\r\n     function updateRefPercentage(uint _percentage) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        refPercentage = _percentage;\r\n    }\r\n\r\n    function updateTokens(address _usdc, address _lndx) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        usdc = _usdc;\r\n        lndx = _lndx;\r\n    }\r\n\r\n    function reclaimToken(IERC20 token) external {\r\n        require(msg.sender == multisig, \"only multisig has access\");\r\n        require(address(token) != address(0));\r\n        uint256 balance = token.balanceOf(address(this));\r\n        token.transfer(msg.sender, balance);\r\n    }\r\n}"
    }
  }
}}