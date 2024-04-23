{{
  "language": "Solidity",
  "sources": {
    "SandBox1.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// SandBox1 \npragma solidity 0.8.21;\n\nimport \"UBDExchange.sol\";\nimport \"MarketConnector.sol\";\nimport \"ReentrancyGuard.sol\";\n\n/// @title SandBox1 \n/// @author UBD Team\n/// @notice This contract is main user's entry point in UBD ecosystem\n/// @dev  Check deploy params so they are immutable\ncontract SandBox1 is UBDExchange, MarketConnector, ReentrancyGuard {\n\n    uint256 public constant TREASURY_TOPUP_PERIOD = 1 days;\n    uint256 public constant TREASURY_TOPUP_PERCENT = 10000; // 1% - 10000, 13% - 130000, etc \n\n    uint256 public lastTreasuryTopUp;\n    uint256 public MIN_TREASURY_TOPUP_AMOUNT = 1000; // Stable Coin Units (without decimals)\n\n    constructor(address _markets, address _baseAsset)\n        UBDExchange(_baseAsset, address(this))\n        MarketConnector(_markets)\n    {\n\n    }\n    \n    /// @notice Swap any asset (available at AMM) to UBD\n    /// @dev only called from Sandboxes\n    /// @param _inAsset - contract address of in asset\n    /// @param _inAmount - amount with decimcals\n    /// @param _deadline -acceptable time\n    /// @param _amountOutMin - min acceptable amount of base \n    function swapExactInput(\n        address _inAsset,\n        uint256 _inAmount, \n        uint256 _deadline, \n        uint256 _amountOutMin\n    ) \n        public\n        nonReentrant\n        returns (uint256 outAmount)\n    {\n        \n        // Check system balance and redeem sandbox_1 if  need\n        if (_inAsset == address(ubdToken) &&\n            IERC20(EXCHANGE_BASE_ASSET).balanceOf(address(this)) < _amountOutMin){\n            if (_redeemSandbox1() < _amountOutMin ) {\n                return 0;\n            }\n        }\n\n        if (_inAsset != EXCHANGE_BASE_ASSET && _inAsset != address(ubdToken)) {\n            address[] memory path = new address[](2);\n            \n            // Swap any to BASE asset\n            uint256 amountBASE = IMarketRegistry(marketRegistry).swapExactInToBASEOut(\n                _inAmount,\n                _amountOutMin,\n                _inAsset,\n                msg.sender,\n                _deadline\n            );\n            return super.swapExactInput(EXCHANGE_BASE_ASSET, amountBASE, _deadline, _amountOutMin, msg.sender);\n        }\n        return super.swapExactInput(_inAsset, _inAmount, _deadline, _amountOutMin, msg.sender);\n\n    }\n\n    /// @notice Check condition and topup Treasury\n    /// @dev Revert if no condition yet\n    function topupTreasury() external {\n        uint256 topupAmount = \n            IERC20(EXCHANGE_BASE_ASSET).balanceOf(address(this)) \n            * TREASURY_TOPUP_PERCENT \n            / (100 * PERCENT_DENOMINATOR);\n        require(\n            topupAmount \n                >= MIN_TREASURY_TOPUP_AMOUNT * 10**IERC20Metadata(EXCHANGE_BASE_ASSET).decimals(), \n            'Too small topup amount'\n        ); \n        require(\n            lastTreasuryTopUp + TREASURY_TOPUP_PERIOD < block.timestamp, \n            'Please wait untit TREASURY_TOPUP_PERIOD'\n        );\n        lastTreasuryTopUp = block.timestamp;\n        IERC20(EXCHANGE_BASE_ASSET).approve(marketRegistry, topupAmount);\n        IMarketRegistry(marketRegistry).swapExactBASEInToTreasuryAssets(topupAmount, EXCHANGE_BASE_ASSET);\n        emit TreasuryTopup(EXCHANGE_BASE_ASSET, topupAmount);\n    }\n    \n    /// @notice Emergency method for  case of Sandbox1 BASE asset.\n    /// Call it for  try sell old BASE asset\n    /// @dev Revert if use for current BASE asset\n    function topupTreasuryEmergency(address _token) external {\n        require(_token != EXCHANGE_BASE_ASSET && _token != address(ubdToken), 'Only for other assets');\n        uint256 topupAmount = IERC20(_token).balanceOf(address(this));\n        IERC20(_token).approve(marketRegistry, topupAmount);\n        IMarketRegistry(marketRegistry).swapExactBASEInToTreasuryAssets(topupAmount, _token);\n        emit TreasuryTopup(_token, topupAmount);\n\n    }\n\n\n    ///////////////////////////////////////////////////////////\n    ///////    Admin Functions        /////////////////////////\n    ///////////////////////////////////////////////////////////\n    function setMinTopUp(uint256 _amount) \n        external \n        onlyOwner \n    {\n        MIN_TREASURY_TOPUP_AMOUNT = _amount;\n    }\n    ///////////////////////////////////////////////////////////\n\n    function ubdTokenAddress() external view returns(address) {\n        return address(ubdToken);\n    }\n    \n    function _redeemSandbox1() internal returns(uint256 newBASEBalance) {\n        if (_getCollateralSystemLevelM10() >= 10) {\n            uint256 redeemAmount = IMarketRegistry(marketRegistry).swapTreasuryAssetsPercentToSandboxAsset(); \n            emit Sandbox1Redeem(EXCHANGE_BASE_ASSET,redeemAmount);\n        }\n        newBASEBalance = IERC20(EXCHANGE_BASE_ASSET).balanceOf(address(this));\n    }\n\n}"
    },
    "UBDExchange.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// UBDExchange \npragma solidity 0.8.21;\n\n\nimport \"TransferHelper.sol\";\nimport \"Ownable.sol\";\nimport \"IERC20Burn.sol\";\n\n\ncontract UBDExchange is Ownable {\n    \n    struct PaymentTokenInfo {\n        uint256 validAfter;\n        uint256 feePercent;  \n    }\n\n    uint256 constant public FEE_EXCHANGE_DEFAULT = 5000;      // 0.5 %\n    uint256 constant public FEE_EXCHANGE_MAX_PERCENT = 10000; // 1% - 10000, 13% - 130000, etc        \n    uint256 constant public PERCENT_DENOMINATOR = 10000;\n    uint256 constant public ADD_NEW_PAYMENT_TOKEN_TIMELOCK = 48 hours;\n    uint256 constant public EMERGENCY_PAYMENT_PAUSE = 1 hours;\n\n    \n    address immutable public SANDBOX_1;\n\n    address public FEE_BENEFICIARY;\n    address public EXCHANGE_BASE_ASSET;\n\n    IERC20Burn public ubdToken;\n    // mapping from token address to timestamp of start validity\n    mapping (address => PaymentTokenInfo) public paymentTokens;\n    mapping (address => bool) public isGuardian;\n    mapping (address => bool) public isStakingContract;\n\n   \n    event PaymentTokenStatus(address indexed Token, bool Status, uint256 FeePercent);\n    event PaymentTokenPaused(address indexed Token, uint256 Until);\n\n    error NoDirectSwap(string);\n\n    constructor (address _baseAsset, address _sandbox1) {\n        require(_baseAsset != address(0) && _sandbox1 != address(0),'No zero address');\n        // Add ETH USDT as default payment asset\n        EXCHANGE_BASE_ASSET = _baseAsset;\n        paymentTokens[_baseAsset] \n            = PaymentTokenInfo(block.timestamp, FEE_EXCHANGE_DEFAULT);\n        SANDBOX_1 = _sandbox1;    \n    }\n\n\n    /// @notice SWap exact amount of input token for output\n    /// @dev Don't forget approvement(s)\n    /// @param _inAsset  UBD or BASE_TOKEN_ADDRESS,\n    /// and  the last is the output token (UniswapV2 style)\n    /// @param _inAmount amount of stable to spent\n    /// @param _deadline Unix timestamp, Swap can't be executed after\n    /// @param _amountOutMin minimum amount of output tokens that \n    /// caller want receive. \n    /// received for the transaction not to revert\n    function swapExactInput(\n        address _inAsset,\n        uint256 _inAmount, \n        uint256 _deadline, \n        uint256 _amountOutMin, \n        address _receiver\n    ) \n        public\n        virtual \n        returns (uint256 outAmount)\n    {\n        require(address(ubdToken) != address(0), 'UBD address not Define');\n        require(_isValidForPayment(_inAsset), 'Token not enabled');\n\n        address receiver = _receiver;\n        \n        if (receiver == address(0)) {\n            receiver = msg.sender;\n        }\n\n        \n        // Charge fee in inTokenAsset token from sender if enable(FEE_BENEFICIARY != address(0))\n        uint256 feeAmount = _getFeeFromInAmount(_inAsset, _inAmount);\n\n        if (FEE_BENEFICIARY != address(0)) {\n            TransferHelper.safeTransferFrom(_inAsset, receiver, FEE_BENEFICIARY, feeAmount);\n        }\n\n        // Decrease in amount with charged fee(_inAmountPure)\n        uint256 inAmountPure = _inAmount - feeAmount;\n        address baseAsset = EXCHANGE_BASE_ASSET;\n        \n\n        if (_inAsset == address(ubdToken)) {\n            // Back swap from UBD to Excange Base Asset\n            // Burn UBD for sender\n            ubdToken.burn(receiver, inAmountPure);\n\n            // Return BASE ASSET  _inAmountPure to sender\n            outAmount = inAmountPure * 10**IERC20Metadata(baseAsset).decimals() / 10**ubdToken.decimals();\n            if (SANDBOX_1 == address(this)){\n                TransferHelper.safeTransfer(baseAsset,  receiver, outAmount);    \n            } else {\n                // This branch can be removed if sandbox always is exchange\n                TransferHelper.safeTransferFrom(baseAsset, SANDBOX_1, receiver, outAmount);\n            }\n            \n            \n\n        } else if (_inAsset == baseAsset) {\n            // Swap from BASE to UBD\n            // Take BAse Token _inAmountPure\n            TransferHelper.safeTransferFrom(baseAsset, receiver, SANDBOX_1,  inAmountPure);\n\n            // Mint  UBD _inAmountPure to sender\n            outAmount = inAmountPure * 10**ubdToken.decimals() / 10**IERC20Metadata(baseAsset).decimals();\n            // Below not used because GAS +2K\n            //outAmount = _calcOutForExactIn(EXCHANGE_BASE_ASSET, _inAmount);\n            ubdToken.mint(receiver, outAmount); \n        }  else {\n            revert NoDirectSwap(IERC20Metadata(baseAsset).symbol());\n        }\n        // Sanity Checks \n        require(outAmount >= _amountOutMin, \"Unexpected Out Amount\");\n        if (_deadline > 0) {\n            require(block.timestamp <= _deadline, \"Unexpected Transaction time\");\n        } \n    }\n\n    /// @notice Mint UBD for staking reward\n    /// @notice Available only for trusted addresses\n    /// @param _for address reward minting for\n    /// @param _amount reward amount\n    function mintReward(address _for, uint256 _amount) external {\n        require(isStakingContract[msg.sender], 'Only for staking reward');\n        ubdToken.mint(_for, _amount); \n    }\n\n\n    /// @notice Temprory disable payments with token\n    /// @param _paymentToken stable coin address\n    function emergencyPause(address _paymentToken) external {\n        require(isGuardian[msg.sender], \"Only for approved guardians\");\n        if (\n                paymentTokens[_paymentToken].validAfter > 0 // token enabled \n                && paymentTokens[_paymentToken].validAfter <= block.timestamp // no timelock now\n            ) \n        {\n            paymentTokens[_paymentToken].validAfter = block.timestamp + EMERGENCY_PAYMENT_PAUSE;\n            // TODO Check GAS with block.timestamp + EMERGENCY_PAYMENT_PAUSE below instead of get from mapping\n            emit PaymentTokenPaused(_paymentToken, paymentTokens[_paymentToken].validAfter);\n        }\n    }\n\n    ///////////////////////////////////////////////////////////\n    ///////    Admin Functions        /////////////////////////\n    ///////////////////////////////////////////////////////////\n    function setPaymentTokenStatus(address _token, bool _state, uint256 _feePercent) \n        external \n        onlyOwner \n    {\n        if (_state ) {\n            require(_feePercent <= FEE_EXCHANGE_MAX_PERCENT, 'Fee is too much');\n\n            // Timelock for all new tokens but exclude UBD \n            // and current EXCHANGE_BASE_ASSET\n            uint256 newValidAfter;\n            if (_token != address(ubdToken) && _token != EXCHANGE_BASE_ASSET) {\n                EXCHANGE_BASE_ASSET = _token;\n                newValidAfter = block.timestamp + ADD_NEW_PAYMENT_TOKEN_TIMELOCK;\n            } else {\n                newValidAfter = block.timestamp;\n            }\n\n            paymentTokens[_token] = PaymentTokenInfo(\n                newValidAfter,\n                _feePercent\n            );\n                \n        } else {\n            require (_token != address(ubdToken), \"Cant disable UBD\");\n            paymentTokens[_token] = PaymentTokenInfo(0, 0);\n        }\n        \n        emit PaymentTokenStatus(_token, _state, _feePercent);\n    }\n\n    function setUBDToken(address _token) \n        external \n        onlyOwner \n    {\n        require(address(ubdToken) == address(0), \"Can call only once\");\n        paymentTokens[_token] \n            = PaymentTokenInfo(block.timestamp, FEE_EXCHANGE_DEFAULT);\n        ubdToken = IERC20Burn(_token);\n    }\n\n    function setGuardianStatus(address _guardian, bool _state)\n        external\n        onlyOwner\n    {\n        isGuardian[_guardian] = _state;\n    }\n\n    function setBeneficiary(address _addr)\n        external\n        onlyOwner\n    {\n        FEE_BENEFICIARY = _addr;\n    }\n\n    function setStakingContract(address _contract, bool _isEnabled) external onlyOwner {\n        isStakingContract[_contract] = _isEnabled;\n    }\n\n    ///////////////////////////////////////////////////////////\n\n    /// @notice Returns amount of UBD tokens that will be\n    /// get by user if he(she) pay given stable coin amount\n    /// @dev _inAmount must be with given in wei (eg 1 USDT =1000000)\n    /// @param _inAmount stable coin amount that user want to spend\n    function calcOutUBDForExactInBASE(uint256 _inAmount) \n        external \n        view \n        returns(uint256) \n    {\n        return _calcOutForExactIn(EXCHANGE_BASE_ASSET, _inAmount);\n    }\n\n    /// @notice Returns amount of stable coins that must be spent\n    /// for user get given  amount of UBD token\n    /// @dev _outAmount must be in wei (eg 1 UBD =1e18)\n    /// @param _outAmount UBD token amount that user want to get\n    function calcInBASEForExactOutUBD(uint256 _outAmount) \n        external \n        view \n        returns(uint256) \n    {\n        return _calcInForExactOut(address(ubdToken), _outAmount);\n    }\n\n    /// @notice Returns amount of BASE stable that will be\n    /// get by user if he(she) pay given UBD amount\n    /// @dev _inAmount must be with given in wei (eg 1 USDT =1000000)\n    /// @param _inAmount UBD amount that user want to spend\n    function calcOutBASEForExactInUBD(uint256 _inAmount) \n        external \n        view \n        returns(uint256) \n    {\n        return _calcOutForExactIn(address(ubdToken), _inAmount);\n    }\n\n    /// @notice Returns amount of UBD that must be spent\n    /// for user get given  amount of BASE token\n    /// @dev _outAmount must be in wei (eg 1 UBD =1e18)\n    /// @param _outAmount BASE token amount that user want to get\n    function calcInUBDForExactOutBASE(uint256 _outAmount) \n        external \n        view \n        returns(uint256) \n    {\n        return _calcInForExactOut(EXCHANGE_BASE_ASSET, _outAmount);\n    }\n\n    function getFeeFromInAmount(address _inAsset, uint256 _inAmount)\n        public\n        view\n        returns(uint256)\n    {\n        return _getFeeFromInAmount(_inAsset, _inAmount);\n    }\n    /////////////////////////////////////////////////////////////////////\n\n    function _getFeeFromInAmount(address _inAsset, uint256 _inAmount)\n        internal\n        view\n        returns(uint256)\n    {\n        uint256 feeP = paymentTokens[_inAsset].feePercent;\n        return _inAmount * feeP / (100 * PERCENT_DENOMINATOR + feeP);\n    }\n\n    function _calcOutForExactIn(address _inToken, uint256 _inAmount) \n        internal\n        view \n        returns(uint256 outAmount) \n    {\n        uint256 inAmountPure = _inAmount - _getFeeFromInAmount(_inToken, _inAmount);\n        address outToken;\n        if (_inToken == address(ubdToken)){\n            outToken = EXCHANGE_BASE_ASSET;\n        } else {\n            outToken = address(ubdToken);\n        }\n        outAmount = inAmountPure * 10**IERC20Metadata(outToken).decimals() / 10**IERC20Metadata(_inToken).decimals();\n    }\n\n    function _calcInForExactOut(address _outToken, uint256 _outAmount) \n        internal\n        view \n        returns(uint256 inAmount) \n    {\n       \n        address inToken;\n        if (_outToken == address(ubdToken)){\n            inToken = EXCHANGE_BASE_ASSET;\n        } else {\n            inToken = address(ubdToken);\n        }\n\n         uint256 outAmountWithFee = \n            _outAmount + _outAmount * paymentTokens[inToken].feePercent  \n                / (100 * PERCENT_DENOMINATOR);\n\n        inAmount = outAmountWithFee \n            * (10**IERC20Metadata(inToken).decimals())\n            / (10**IERC20Metadata(_outToken).decimals()); \n            \n\n    }\n\n\n    function _isValidForPayment(address _paymentToken) internal view returns(bool){\n        uint256 validAfterTime = paymentTokens[_paymentToken].validAfter;\n        if ( validAfterTime == 0) {\n            return false;\n        }\n        require( validAfterTime < block.timestamp, \"Token paused or timelocked\");\n        return true; \n    }\n}"
    },
    "TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.6.0;\n\nimport \"IERC20.sol\";\n\nlibrary TransferHelper {\n    /// @notice Transfers tokens from the targeted address to the given destination\n    /// @notice Errors with 'STF' if transfer fails\n    /// @param token The contract address of the token to be transferred\n    /// @param from The originating address from which the tokens will be transferred\n    /// @param to The destination address of the transfer\n    /// @param value The amount to be transferred\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) =\n            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');\n    }\n\n    /// @notice Transfers tokens from msg.sender to a recipient\n    /// @dev Errors with ST if transfer fails\n    /// @param token The contract address of the token which will be transferred\n    /// @param to The recipient of the transfer\n    /// @param value The value of the transfer\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');\n    }\n\n    /// @notice Approves the stipulated contract to spend the given allowance in the given token\n    /// @dev Errors with 'SA' if transfer fails\n    /// @param token The contract address of the token to be approved\n    /// @param to The target of the approval\n    /// @param value The amount of the given token the target will be allowed to spend\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');\n    }\n\n    /// @notice Transfers ETH to the recipient address\n    /// @dev Fails with `STE`\n    /// @param to The destination of the transfer\n    /// @param value The value to be transferred\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, 'STE');\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "IERC20Burn.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\nimport \"IERC20Mint.sol\";\n\ninterface IERC20Burn is IERC20Mint {\n    function burn(address _burnFor, uint256 _amount) external;\n}"
    },
    "IERC20Mint.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\nimport \"IERC20Metadata.sol\";\n\ninterface IERC20Mint is IERC20Metadata {\n    function mint(address _for, uint256 _amount) external;\n}"
    },
    "IERC20Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"
    },
    "MarketConnector.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// MarketConnector \npragma solidity 0.8.21;\n\nimport \"IMarketRegistry.sol\";\n\nabstract contract MarketConnector {\n\n    address immutable public marketRegistry;\n\tconstructor(address _markets)\n    {\n        marketRegistry = _markets;\n\n    }\n\n    event TreasuryTopup(address Asset, uint256 TopupAmount);\n    event Sandbox2Topup(address Asset, uint256 TopupAmount);\n    event Sandbox1Redeem(address Asset, uint256 TopupAmount);\n\n\n    function _getCollateralSystemLevelM10() internal view returns(uint256) {\n        return  IMarketRegistry(marketRegistry).getCollateralLevelM10();\n    }\n    \n    function _getBalanceInStableUnits(address _holder, address[] memory _assets) \n        internal \n        view \n        returns(uint256)\n    {\n        return IMarketRegistry(marketRegistry).getBalanceInStableUnits(_holder, _assets);\n    }\n}"
    },
    "IMarketRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\n\n\ninterface IMarketRegistry  {\n\n    struct AsssetShare {\n        address asset;\n        uint8 percent;\n    }\n\n    struct UBDNetwork {\n        address sandbox1;\n        address treasury;\n        address sandbox2;\n        AsssetShare[] treasuryERC20Assets;\n\n    }\n\n    struct Market {\n        address marketAdapter;\n        address oracleAdapter;\n        uint256 slippage;\n    }\n\n    struct ActualShares{\n        address asset;\n        uint256 actualPercentPoint;\n        uint256 excessAmount;\n    } \n    \n    function swapExactInToBASEOut(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address assetIn,\n        address to,\n        uint deadline\n    ) external returns (uint256 amountOut);\n\n\n    function swapExactBASEInToTreasuryAssets(uint256 _amountIn, address _baseAsset) external;\n\n    function swapTreasuryAssetsPercentToSandboxAsset() \n        external \n        returns(uint256 totalStableAmount);\n\n    function getAmountOut(\n        uint amountIn, \n        address[] memory path\n    ) external view returns (uint256 amountOut);\n    function getCollateralLevelM10() external view returns(uint256);\n    function getBalanceInStableUnits(address _holder, address[] memory _assets) external view returns(uint256);\n    function treasuryERC20Assets() external view returns(address[] memory assets);\n    function getUBDNetworkTeamAddress() external view returns(address);\n    function getUBDNetworkInfo() external view returns(UBDNetwork memory);\n}"
    },
    "ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "SandBox1.sol": {}
    },
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
  }
}}