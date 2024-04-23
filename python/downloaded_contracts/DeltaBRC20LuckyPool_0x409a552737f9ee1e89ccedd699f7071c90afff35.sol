{{
  "language": "Solidity",
  "sources": {
    "contracts/contracts/BRC20Delta/LuckyPool/DeltaBRC20LuckyPool.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\n\nimport \"../../library/TransferHelper.sol\";\nimport \"../../interfaces/IDeltaNFT.sol\";\n\ncontract DeltaBRC20LuckyPool is ReentrancyGuard, Ownable {\n    bool private initialized_; // Flag of initialize data\n    bytes32 public merkleRoot;\n\n    address public controllAddress;\n\n    address public targetToken;\n    address public costToken;\n    address public poolAddress;\n\n    uint256 public oneSharePrice;\n\n    uint256 public totalOfferFund = 0;\n    uint256 public totalOfferUser = 0;\n\n    uint256 public oneShareAmount;\n    uint256 public offerStartTime;\n    uint256 public offerEndTime;\n\n    uint256 public totalShares;\n\n    uint256 public drawTime;\n    address public deltaNFT;\n    IDeltaNFT.UnlockArgs public unlockArgs;\n\n    mapping(address => uint256) public userStatus; // 0: init, 1: offer, 2: refund, 3: draw\n\n    mapping(address => bool) public whitelists;\n\n    string[] public btcAddresses;\n\n    event SetUnlockArgsAndRoot(IDeltaNFT.UnlockArgs unlockArgs, bytes32 root);\n    event Offer(address indexed user, uint256 oneSharePrice);\n    event Draw(\n        address indexed user,\n        uint256 tokenId,\n        IDeltaNFT.UnlockArgs unlockArgs\n    );\n    event SetWhiteList(address indexed sender, address indexed user);\n    event Withdraw(address indexed user, uint256 totalOfferFund);\n\n    function initialize(\n        address[5] calldata args1,\n        uint256[6] calldata args2,\n        address _poolAddress\n    ) external returns (address) {\n        require(!initialized_, \"DeltaPool: Already initialized!\");\n\n        _transferOwnership(args1[0]);\n        controllAddress = args1[1];\n        targetToken = args1[2];\n        costToken = args1[3];\n        deltaNFT = args1[4];\n\n        oneSharePrice = args2[0];\n        oneShareAmount = args2[1];\n        offerStartTime = args2[2];\n        offerEndTime = args2[3];\n\n        drawTime = args2[4];\n        totalShares = args2[5];\n        poolAddress = _poolAddress;\n        initialized_ = true;\n        return address(this);\n    }\n\n    function setUnlockArgsAddRoot(\n        IDeltaNFT.UnlockArgs calldata _unlockArgs,\n        bytes32 _merkleRoot\n    ) external {\n        require(\n            msg.sender == owner() || msg.sender == controllAddress,\n            \"DeltaPool:No auth\"\n        );\n        unlockArgs = _unlockArgs;\n        merkleRoot = _merkleRoot;\n        emit SetUnlockArgsAndRoot(_unlockArgs, _merkleRoot);\n    }\n\n    function getUnlockArgs()\n        external\n        view\n        returns (\n            uint256 firstReleaseTime,\n            uint256 firstBalance,\n            uint256 remainingUnlockedType,\n            uint256[4] memory remainingUnlocked,\n            uint256 totalBalance\n        )\n    {\n        firstReleaseTime = unlockArgs.firstReleaseTime;\n        firstBalance = unlockArgs.firstBalance;\n        remainingUnlockedType = unlockArgs.remainingUnlockedType;\n        remainingUnlocked = unlockArgs.remainingUnlocked;\n        totalBalance = unlockArgs.totalBalance;\n    }\n\n    function subOffer(\n        uint256 senderIndex,\n        address account,\n        uint256 amount,\n        bytes32[] memory merkleProof\n    ) external payable nonReentrant {\n        address user = msg.sender;\n        require(account == user, \"sender != account\");\n\n        require(userStatus[account] == 0, \"has offer\");\n        require(\n            offerStartTime <= block.timestamp &&\n                block.timestamp <= offerEndTime,\n            \"not start or has end\"\n        );\n\n        // Verify the merkle proof.\n        bytes32 node = keccak256(\n            abi.encodePacked(senderIndex, account, amount)\n        );\n        bool isWhitelist = false;\n        if (\n            MerkleProof.verify(merkleProof, merkleRoot, node) ||\n            whitelists[account]\n        ) {\n            isWhitelist = true;\n        }\n        require(isWhitelist, \"DeltaPool: not in whitelist.\");\n\n        if (costToken == address(0)) {\n            require(msg.value == oneSharePrice, \"DeltaPool: value error.\");\n        } else {\n            TransferHelper.safeTransferFrom(\n                costToken,\n                user,\n                address(this),\n                oneSharePrice\n            );\n        }\n        totalOfferUser++;\n        totalOfferFund += oneSharePrice;\n\n        userStatus[user] = 1;\n\n        emit Offer(user, oneSharePrice);\n    }\n\n    // for view\n    function isPublish() public view returns (bool) {\n        return block.timestamp > offerEndTime;\n    }\n\n    // for front\n    function refund() external nonReentrant {\n        require(false, \"not end\");\n    }\n\n    // for view\n    function isLuckyDog(address user) public view returns (bool) {\n        require(block.timestamp > offerEndTime, \"Offer stage!!!\");\n        if (userStatus[user] == 0 || userStatus[user] == 2) {\n            return false;\n        }\n\n        if (userStatus[user] == 3 || userStatus[user] == 1) {\n            return true;\n        }\n        return false;\n    }\n\n    // get nft\n    function draw() external nonReentrant {\n        require(block.timestamp > offerEndTime, \"Offer stage!!!\");\n        address user = msg.sender;\n        require(userStatus[user] == 1, \"not offer\");\n        require(block.timestamp > drawTime, \"not end\");\n        require(isLuckyDog(user), \"not lucky dog\");\n        userStatus[user] = 3;\n        uint256 tokenId = IDeltaNFT(deltaNFT).mintNFT(\n            _msgSender(),\n            unlockArgs,\n            IDeltaNFT.TargetArgs({\n                targetToken: targetToken,\n                poolAddress: poolAddress\n            })\n        );\n        emit Draw(user, tokenId, unlockArgs);\n    }\n\n    function setWhiteList(address user) external nonReentrant onlyOwner {\n        whitelists[user] = true;\n        emit SetWhiteList(msg.sender, user);\n    }\n\n    function withdraw() external nonReentrant onlyOwner {\n        uint256 total = totalShares * oneSharePrice;\n        if (costToken == address(0)) {\n            payable(msg.sender).transfer(total);\n        } else {\n            TransferHelper.safeTransfer(costToken, msg.sender, total);\n        }\n\n        emit Withdraw(msg.sender, total);\n    }\n\n    function onERC721Received(\n        address /*operator*/,\n        address /*from*/,\n        uint256 /*tokenId*/,\n        bytes memory /*data*/\n    ) external pure returns (bytes4) {\n        return this.onERC721Received.selector;\n    }\n}\n"
    },
    "contracts/contracts/interfaces/IDeltaNFT.sol": {
      "content": "// SPDX-License-Identifier: SEE LICENSE IN LICENSE\npragma solidity ^0.8.6;\n\nimport \"@openzeppelin/contracts/token/ERC721/IERC721.sol\";\nimport \"@openzeppelin/contracts/access/IAccessControl.sol\";\n\ninterface IDeltaNFT is IAccessControl, IERC721 {\n    /**\n     * @param firstReleaseTime\n     * @param firstBalance  \n     * @param remainingUnlockedType [0|1|2]\n     * @args: type == 0: direct type args = [startTime, 0],\n     *        type == 1: linear type args = [startTime, endTime, 0]\n              type == 2: period type args = [startTime, interval, stepBalance, 0]\n     */\n    struct UnlockArgs {\n        uint256 firstReleaseTime;\n        uint256 firstBalance;\n        uint256 remainingUnlockedType;\n        uint256[4] remainingUnlocked;\n        uint256 totalBalance;\n    }\n\n    struct TargetArgs {\n        address targetToken;\n        address poolAddress;\n    }\n\n    function mintNFT(\n        address to,\n        UnlockArgs calldata unlockArgs,\n        TargetArgs calldata targetArgs\n    ) external returns (uint256 tokenId);\n\n    function getTokenUnlockArgs(\n        uint256 tokenId\n    )\n        external\n        view\n        returns (\n            uint256 firstReleaseTime,\n            uint256 firstBalance,\n            uint256 remainingUnlockedType,\n            uint256[4] calldata remainingUnlocked,\n            uint256 totalBalance\n        );\n\n    function getTokenTargetToken(\n        uint256 tokenId\n    ) external view returns (address targetToken, address poolAddress);\n\n    function burnNFT(uint256 tokenId) external;\n}\n"
    },
    "contracts/contracts/library/TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false\nlibrary TransferHelper {\n    function safeApprove(address token, address to, uint value) internal {\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0x095ea7b3, to, value)\n        );\n        require(\n            success && (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper: APPROVE_FAILED\"\n        );\n    }\n\n    function safeTransfer(address token, address to, uint value) internal {\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0xa9059cbb, to, value)\n        );\n        require(\n            success && (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper: TRANSFER_FAILED\"\n        );\n    }\n\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint value\n    ) internal {\n        (bool success, bytes memory data) = token.call(\n            abi.encodeWithSelector(0x23b872dd, from, to, value)\n        );\n        require(\n            success && (data.length == 0 || abi.decode(data, (bool))),\n            \"TransferHelper: TRANSFER_FROM_FAILED\"\n        );\n    }\n\n    function safeTransferETH(address to, uint value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, \"TransferHelper: ETH_TRANSFER_FAILED\");\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Tree proofs.\n *\n * The tree and the proofs can be generated using our\n * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].\n * You will find a quickstart guide in the readme.\n *\n * WARNING: You should avoid using leaf values that are 64 bytes long prior to\n * hashing, or use a hash function other than keccak256 for hashing leaves.\n * This is because the concatenation of a sorted pair of internal nodes in\n * the merkle tree could be reinterpreted as a leaf value.\n * OpenZeppelin's JavaScript library generates merkle trees that are safe\n * against this attack out of the box.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Calldata version of {verify}\n     *\n     * _Available since v4.7._\n     */\n    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProofCalldata(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Calldata version of {processProof}\n     *\n     * _Available since v4.7._\n     */\n    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by\n     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerify(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProof(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Calldata version of {multiProofVerify}\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerifyCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProofCalldata(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction\n     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another\n     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false\n     * respectively.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree\n     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the\n     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProof(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 proofLen = proof.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proofLen - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            require(proofPos == proofLen, \"MerkleProof: invalid multiproof\");\n            unchecked {\n                return hashes[totalHashes - 1];\n            }\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    /**\n     * @dev Calldata version of {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProofCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 proofLen = proof.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proofLen - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            require(proofPos == proofLen, \"MerkleProof: invalid multiproof\");\n            unchecked {\n                return hashes[totalHashes - 1];\n            }\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {\n        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);\n    }\n\n    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            mstore(0x00, a)\n            mstore(0x20, b)\n            value := keccak256(0x00, 0x40)\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/IAccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IAccessControl {\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {AccessControl-_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) external;\n}\n"
    },
    "@openzeppelin/contracts/token/ERC721/IERC721.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../../utils/introspection/IERC165.sol\";\n\n/**\n * @dev Required interface of an ERC721 compliant contract.\n */\ninterface IERC721 is IERC165 {\n    /**\n     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.\n     */\n    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);\n\n    /**\n     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.\n     */\n    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);\n\n    /**\n     * @dev Returns the number of tokens in ``owner``'s account.\n     */\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    /**\n     * @dev Returns the owner of the `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;\n\n    /**\n     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients\n     * are aware of the ERC721 protocol to prevent tokens from being forever locked.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must exist and be owned by `from`.\n     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.\n     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.\n     *\n     * Emits a {Transfer} event.\n     */\n    function safeTransferFrom(address from, address to, uint256 tokenId) external;\n\n    /**\n     * @dev Transfers `tokenId` token from `from` to `to`.\n     *\n     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721\n     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must\n     * understand this adds an external call which potentially creates a reentrancy vulnerability.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `tokenId` token must be owned by `from`.\n     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 tokenId) external;\n\n    /**\n     * @dev Gives permission to `to` to transfer `tokenId` token to another account.\n     * The approval is cleared when the token is transferred.\n     *\n     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.\n     *\n     * Requirements:\n     *\n     * - The caller must own the token or be an approved operator.\n     * - `tokenId` must exist.\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address to, uint256 tokenId) external;\n\n    /**\n     * @dev Approve or remove `operator` as an operator for the caller.\n     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.\n     *\n     * Requirements:\n     *\n     * - The `operator` cannot be the caller.\n     *\n     * Emits an {ApprovalForAll} event.\n     */\n    function setApprovalForAll(address operator, bool approved) external;\n\n    /**\n     * @dev Returns the account approved for `tokenId` token.\n     *\n     * Requirements:\n     *\n     * - `tokenId` must exist.\n     */\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    /**\n     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.\n     *\n     * See {setApprovalForAll}\n     */\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
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
    "remappings": []
  }
}}