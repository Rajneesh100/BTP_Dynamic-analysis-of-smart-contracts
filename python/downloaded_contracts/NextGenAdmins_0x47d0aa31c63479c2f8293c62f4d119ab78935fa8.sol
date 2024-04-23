{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}"},"NextGenAdmins.sol":{"content":"// SPDX-License-Identifier: MIT\n\n/**\n *\n *  @title: NextGen 6529 - Admin Contract\n *  @date: 20-December-2023\n *  @version: 1.1\n *  @author: 6529 team\n */\n\npragma solidity ^0.8.19;\n\nimport \"./Ownable.sol\";\n\ncontract NextGenAdmins is Ownable {\n\n    // sets global admins\n    mapping(address =\u003e bool) public adminPermissions;\n\n    // sets collection admins\n    mapping (address =\u003e mapping (uint256 =\u003e bool)) private collectionAdmin;\n\n    // sets permission on specific function\n    mapping (address =\u003e mapping (bytes4 =\u003e bool)) private functionAdmin;\n\n    constructor() {\n        adminPermissions[msg.sender] = true;\n    }\n\n    // certain functions can only be called by an admin\n    modifier AdminRequired {\n      require((adminPermissions[msg.sender] == true) || (_msgSender()== owner()), \"Not allowed\");\n      _;\n    }\n\n    // function to register a global admin\n\n    function registerAdmin(address _admin, bool _status) public onlyOwner {\n        adminPermissions[_admin] = _status;\n    }\n\n    // function to register function admin\n\n    function registerFunctionAdmin(address _address, bytes4 _selector, bool _status) public AdminRequired {\n        functionAdmin[_address][_selector] = _status;\n    }\n\n    // function to register batch functions admin\n\n    function registerBatchFunctionAdmin(address _address, bytes4[] memory _selector, bool _status) public AdminRequired {\n        for (uint256 i=0; i\u003c_selector.length; i++) {\n            functionAdmin[_address][_selector[i]] = _status;\n        }\n    }\n\n    // function to register a collection admin\n\n    function registerCollectionAdmin(uint256 _collectionID, address _address, bool _status) public AdminRequired {\n        require(_collectionID \u003e 0, \"Collection Id must be larger than 0\");\n        collectionAdmin[_address][_collectionID] = _status;\n    }\n\n    // function to retrieve global admin\n\n    function retrieveGlobalAdmin(address _address) public view returns(bool) {\n        return adminPermissions[_address];\n    }\n\n    // function to retrieve collection admin\n\n    function retrieveFunctionAdmin(address _address, bytes4 _selector) public view returns(bool) {\n        return functionAdmin[_address][_selector];\n    }\n\n    // function to retrieve collection admin\n\n    function retrieveCollectionAdmin(address _address, uint256 _collectionID) public view returns(bool) {\n        return collectionAdmin[_address][_collectionID];\n    }\n\n    // get admin contract status\n\n    function isAdminContract() external view returns (bool) {\n        return true;\n    }\n\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\n\nimport \"./Context.sol\";\n\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}"}}