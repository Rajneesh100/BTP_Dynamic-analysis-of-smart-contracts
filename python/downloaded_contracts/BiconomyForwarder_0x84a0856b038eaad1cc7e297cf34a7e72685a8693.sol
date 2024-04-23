{{
  "language": "Solidity",
  "sources": {
    "BiconomyForwarder.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.7.6;\r\npragma experimental ABIEncoderV2;\r\n\r\nimport \"openzeppelin-solidity/contracts/math/SafeMath.sol\";\r\nimport \"openzeppelin-solidity/contracts/cryptography/ECDSA.sol\";\r\nimport \"./ERC20ForwardRequestTypes.sol\";\r\nimport \"./libs/Ownable.sol\";\r\n\r\n/**\r\n *\r\n * @title BiconomyForwarder\r\n *\r\n * @notice A trusted forwarder for Biconomy relayed meta transactions\r\n * @notice You should verify your contracts on all chains they are deployed on\r\n *\r\n * @dev - Inherits the ERC20ForwarderRequest struct\r\n * @dev - Verifies EIP712 signatures\r\n * @dev - Verifies personalSign signatures\r\n * @dev - Implements 2D nonces... each Tx has a BatchId and a BatchNonce\r\n * @dev - Keeps track of highest BatchId used by a given address, to assist in encoding of transactions client-side\r\n * @dev - maintains a list of verified domain seperators\r\n *\r\n */\r\ncontract BiconomyForwarder is ERC20ForwardRequestTypes, Ownable {\r\n    using ECDSA for bytes32;\r\n\r\n    mapping(bytes32 => bool) public domains;\r\n\r\n    uint256 chainId;\r\n\r\n    string public constant EIP712_DOMAIN_TYPE =\r\n        \"EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)\";\r\n\r\n    bytes32 public constant REQUEST_TYPEHASH =\r\n        keccak256(\r\n            bytes(\r\n                \"ERC20ForwardRequest(address from,address to,address token,uint256 txGas,uint256 tokenGasPrice,uint256 batchId,uint256 batchNonce,uint256 deadline,bytes data)\"\r\n            )\r\n        );\r\n\r\n    mapping(address => mapping(uint256 => uint256)) nonces;\r\n\r\n    constructor(address _owner) public Ownable(_owner) {\r\n        uint256 id;\r\n        assembly {\r\n            id := chainid()\r\n        }\r\n        chainId = id;\r\n        require(_owner != address(0), \"Owner Address cannot be 0\");\r\n    }\r\n\r\n    /**\r\n     * @dev registers domain seperators, maintaining that all domain seperators used for EIP712 forward requests use...\r\n     * ... the address of this contract and the chainId of the chain this contract is deployed to\r\n     * @param name : name of dApp/dApp fee proxy\r\n     * @param version : version of dApp/dApp fee proxy\r\n     */\r\n    function registerDomainSeparator(\r\n        string calldata name,\r\n        string calldata version\r\n    ) external onlyOwner {\r\n        uint256 id;\r\n        /* solhint-disable-next-line no-inline-assembly */\r\n        assembly {\r\n            id := chainid()\r\n        }\r\n\r\n        bytes memory domainValue = abi.encode(\r\n            keccak256(bytes(EIP712_DOMAIN_TYPE)),\r\n            keccak256(bytes(name)),\r\n            keccak256(bytes(version)),\r\n            address(this),\r\n            bytes32(id)\r\n        );\r\n\r\n        bytes32 domainHash = keccak256(domainValue);\r\n\r\n        domains[domainHash] = true;\r\n        emit DomainRegistered(domainHash, domainValue);\r\n    }\r\n\r\n    event DomainRegistered(bytes32 indexed domainSeparator, bytes domainValue);\r\n\r\n    /**\r\n     * @dev returns a value from the nonces 2d mapping\r\n     * @param from : the user address\r\n     * @param batchId : the key of the user's batch being queried\r\n     * @return nonce : the number of transaction made within said batch\r\n     */\r\n    function getNonce(address from, uint256 batchId)\r\n        public\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return nonces[from][batchId];\r\n    }\r\n\r\n    /**\r\n     * @dev an external function which exposes the internal _verifySigEIP712 method\r\n     * @param req : request being verified\r\n     * @param domainSeparator : the domain separator presented to the user when signing\r\n     * @param sig : the signature generated by the user's wallet\r\n     */\r\n    function verifyEIP712(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes32 domainSeparator,\r\n        bytes calldata sig\r\n    ) external view {\r\n        _verifySigEIP712(req, domainSeparator, sig);\r\n    }\r\n\r\n    /**\r\n     * @dev verifies the call is valid by calling _verifySigEIP712\r\n     * @dev executes the forwarded call if valid\r\n     * @dev updates the nonce after\r\n     * @param req : request being executed\r\n     * @param domainSeparator : the domain separator presented to the user when signing\r\n     * @param sig : the signature generated by the user's wallet\r\n     * @return success : false if call fails. true otherwise\r\n     * @return ret : any return data from the call\r\n     */\r\n    function executeEIP712(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes32 domainSeparator,\r\n        bytes calldata sig\r\n    ) external returns (bool success, bytes memory ret) {\r\n        _verifySigEIP712(req, domainSeparator, sig);\r\n        _updateNonce(req);\r\n        /* solhint-disable-next-line avoid-low-level-calls */\r\n        (success, ret) = req.to.call{gas: req.txGas}(\r\n            abi.encodePacked(req.data, req.from)\r\n        );\r\n        // Validate that the relayer has sent enough gas for the call.\r\n        // See https://ronan.eth.link/blog/ethereum-gas-dangers/\r\n        assert(gasleft() > req.txGas / 63);\r\n        _verifyCallResult(\r\n            success,\r\n            ret,\r\n            \"Forwarded call to destination did not succeed\"\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev an external function which exposes the internal _verifySigPersonSign method\r\n     * @param req : request being verified\r\n     * @param sig : the signature generated by the user's wallet\r\n     */\r\n    function verifyPersonalSign(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes calldata sig\r\n    ) external view {\r\n        _verifySigPersonalSign(req, sig);\r\n    }\r\n\r\n    /**\r\n     * @dev verifies the call is valid by calling _verifySigPersonalSign\r\n     * @dev executes the forwarded call if valid\r\n     * @dev updates the nonce after\r\n     * @param req : request being executed\r\n     * @param sig : the signature generated by the user's wallet\r\n     * @return success : false if call fails. true otherwise\r\n     * @return ret : any return data from the call\r\n     */\r\n    function executePersonalSign(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes calldata sig\r\n    ) external returns (bool success, bytes memory ret) {\r\n        _verifySigPersonalSign(req, sig);\r\n        _updateNonce(req);\r\n        (success, ret) = req.to.call{gas: req.txGas}(\r\n            abi.encodePacked(req.data, req.from)\r\n        );\r\n        // Validate that the relayer has sent enough gas for the call.\r\n        // See https://ronan.eth.link/blog/ethereum-gas-dangers/\r\n        assert(gasleft() > req.txGas / 63);\r\n        _verifyCallResult(\r\n            success,\r\n            ret,\r\n            \"Forwarded call to destination did not succeed\"\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev Increments the nonce of given user/batch pair\r\n     * @dev Updates the highestBatchId of the given user if the request's batchId > current highest\r\n     * @dev only intended to be called post call execution\r\n     * @param req : request that was executed\r\n     */\r\n    function _updateNonce(ERC20ForwardRequest calldata req) internal {\r\n        nonces[req.from][req.batchId]++;\r\n    }\r\n\r\n    /**\r\n     * @dev verifies the domain separator used has been registered via registerDomainSeparator()\r\n     * @dev recreates the 32 byte hash signed by the user's wallet (as per EIP712 specifications)\r\n     * @dev verifies the signature using Open Zeppelin's ECDSA library\r\n     * @dev signature valid if call doesn't throw\r\n     *\r\n     * @param req : request being executed\r\n     * @param domainSeparator : the domain separator presented to the user when signing\r\n     * @param sig : the signature generated by the user's wallet\r\n     *\r\n     */\r\n    function _verifySigEIP712(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes32 domainSeparator,\r\n        bytes memory sig\r\n    ) internal view {\r\n        uint256 id;\r\n        /* solhint-disable-next-line no-inline-assembly */\r\n        assembly {\r\n            id := chainid()\r\n        }\r\n        require(\r\n            req.deadline == 0 || block.timestamp + 20 <= req.deadline,\r\n            \"request expired\"\r\n        );\r\n        require(domains[domainSeparator], \"unregistered domain separator\");\r\n        require(chainId == id, \"potential replay attack on the fork\");\r\n        bytes32 digest = keccak256(\r\n            abi.encodePacked(\r\n                \"\\x19\\x01\",\r\n                domainSeparator,\r\n                keccak256(\r\n                    abi.encode(\r\n                        REQUEST_TYPEHASH,\r\n                        req.from,\r\n                        req.to,\r\n                        req.token,\r\n                        req.txGas,\r\n                        req.tokenGasPrice,\r\n                        req.batchId,\r\n                        nonces[req.from][req.batchId],\r\n                        req.deadline,\r\n                        keccak256(req.data)\r\n                    )\r\n                )\r\n            )\r\n        );\r\n        require(digest.recover(sig) == req.from, \"signature mismatch\");\r\n    }\r\n\r\n    /**\r\n     * @dev encodes a 32 byte data string (presumably a hash of encoded data) as per eth_sign\r\n     *\r\n     * @param hash : hash of encoded data that signed by user's wallet using eth_sign\r\n     * @return input hash encoded to matched what is signed by the user's key when using eth_sign*/\r\n    function prefixed(bytes32 hash) internal pure returns (bytes32) {\r\n        return\r\n            keccak256(\r\n                abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", hash)\r\n            );\r\n    }\r\n\r\n    /**\r\n     * @dev recreates the 32 byte hash signed by the user's wallet\r\n     * @dev verifies the signature using Open Zeppelin's ECDSA library\r\n     * @dev signature valid if call doesn't throw\r\n     *\r\n     * @param req : request being executed\r\n     * @param sig : the signature generated by the user's wallet\r\n     *\r\n     */\r\n    function _verifySigPersonalSign(\r\n        ERC20ForwardRequest calldata req,\r\n        bytes memory sig\r\n    ) internal view {\r\n        require(\r\n            req.deadline == 0 || block.timestamp + 20 <= req.deadline,\r\n            \"request expired\"\r\n        );\r\n        bytes32 digest = prefixed(\r\n            keccak256(\r\n                abi.encodePacked(\r\n                    req.from,\r\n                    req.to,\r\n                    req.token,\r\n                    req.txGas,\r\n                    req.tokenGasPrice,\r\n                    req.batchId,\r\n                    nonces[req.from][req.batchId],\r\n                    req.deadline,\r\n                    keccak256(req.data)\r\n                )\r\n            )\r\n        );\r\n        require(digest.recover(sig) == req.from, \"signature mismatch\");\r\n    }\r\n\r\n    /**\r\n     * @dev verifies the call result and bubbles up revert reason for failed calls\r\n     *\r\n     * @param success : outcome of forwarded call\r\n     * @param returndata : returned data from the frowarded call\r\n     * @param errorMessage : fallback error message to show\r\n     */\r\n    function _verifyCallResult(\r\n        bool success,\r\n        bytes memory returndata,\r\n        string memory errorMessage\r\n    ) private pure {\r\n        if (!success) {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length > 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n\r\n                // solhint-disable-next-line no-inline-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}"
    },
    "openzeppelin-solidity/contracts/math/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n\r\npragma solidity >=0.6.0 <0.8.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it's recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity's `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c >= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity's `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity's `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b <= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity's `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\r\n        // benefit is lost if 'b' is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b > 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn't hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"
    },
    "openzeppelin-solidity/contracts/cryptography/ECDSA.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n\r\npragma solidity >=0.6.0 <0.8.0;\r\n\r\n/**\r\n * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.\r\n *\r\n * These functions can be used to verify that a message was signed by the holder\r\n * of the private keys of a given address.\r\n */\r\nlibrary ECDSA {\r\n    /**\r\n     * @dev Returns the address that signed a hashed message (`hash`) with\r\n     * `signature`. This address can then be used for verification purposes.\r\n     *\r\n     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:\r\n     * this function rejects them by requiring the `s` value to be in the lower\r\n     * half order, and the `v` value to be either 27 or 28.\r\n     *\r\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\r\n     * verification to be secure: it is possible to craft signatures that\r\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\r\n     * this is by receiving a hash of the original message (which may otherwise\r\n     * be too long), and then calling {toEthSignedMessageHash} on it.\r\n     */\r\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\r\n        // Check the signature length\r\n        if (signature.length != 65) {\r\n            revert(\"ECDSA: invalid signature length\");\r\n        }\r\n\r\n        // Divide the signature in r, s and v variables\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        // ecrecover takes the signature parameters, and the only way to get them\r\n        // currently is to use assembly.\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly {\r\n            r := mload(add(signature, 0x20))\r\n            s := mload(add(signature, 0x40))\r\n            v := byte(0, mload(add(signature, 0x60)))\r\n        }\r\n\r\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\r\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\r\n        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most\r\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\r\n        //\r\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\r\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\r\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\r\n        // these malleable signatures as well.\r\n        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, \"ECDSA: invalid signature 's' value\");\r\n        require(v == 27 || v == 28, \"ECDSA: invalid signature 'v' value\");\r\n\r\n        // If the signature is valid (and not malleable), return the signer address\r\n        address signer = ecrecover(hash, v, r, s);\r\n        require(signer != address(0), \"ECDSA: invalid signature\");\r\n\r\n        return signer;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns an Ethereum Signed Message, created from a `hash`. This\r\n     * replicates the behavior of the\r\n     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]\r\n     * JSON-RPC method.\r\n     *\r\n     * See {recover}.\r\n     */\r\n    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\r\n        // 32 is the length in bytes of hash,\r\n        // enforced by the type signature above\r\n        return keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", hash));\r\n    }\r\n}"
    },
    "libs/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n\r\npragma solidity 0.7.6;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \"user permissions\".\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(\r\n        address indexed previousOwner,\r\n        address indexed newOwner\r\n    );\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor(address owner) public {\r\n        _owner = owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(\r\n            isOwner(),\r\n            \"Only contract owner is allowed to perform this operation\"\r\n        );\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @return true if `msg.sender` is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the `onlyOwner`\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}"
    },
    "ERC20ForwardRequestTypes.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.7.6;\r\npragma experimental ABIEncoderV2;\r\n\r\n/* deadline can be removed : GSN reference https://github.com/opengsn/gsn/blob/master/contracts/forwarder/IForwarder.sol (Saves 250 more gas)*/\r\n/**\r\n * This contract defines a struct which both ERC20FeeProxy and BiconomyForwarder inherit. ERC20ForwardRequest specifies all the fields present in the GSN V2 ForwardRequest struct,\r\n * but adds the following :\r\n * address token\r\n * uint256 tokenGasPrice\r\n * uint256 txGas\r\n * uint256 batchNonce (can be removed)\r\n * uint256 deadline\r\n * Fields are placed in type order, to minimise storage used when executing transactions.\r\n */\r\ncontract ERC20ForwardRequestTypes {\r\n    /*allow the EVM to optimize for this, \r\nensure that you try to order your storage variables and struct members such that they can be packed tightly*/\r\n\r\n    struct ERC20ForwardRequest {\r\n        address from;\r\n        address to;\r\n        address token;\r\n        uint256 txGas;\r\n        uint256 tokenGasPrice;\r\n        uint256 batchId;\r\n        uint256 batchNonce;\r\n        uint256 deadline;\r\n        bytes data;\r\n    }\r\n\r\n    struct PermitRequest {\r\n        address holder;\r\n        address spender;\r\n        uint256 value;\r\n        uint256 nonce;\r\n        uint256 expiry;\r\n        bool allowed;\r\n        uint8 v;\r\n        bytes32 r;\r\n        bytes32 s;\r\n    }\r\n}"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "metadata": {
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
    "evmVersion": "istanbul",
    "libraries": {}
  }
}}