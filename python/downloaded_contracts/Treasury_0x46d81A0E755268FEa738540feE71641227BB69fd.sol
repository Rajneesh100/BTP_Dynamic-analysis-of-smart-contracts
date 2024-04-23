{{
  "language": "Solidity",
  "sources": {
    "Treasury.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Treasury \npragma solidity 0.8.21;\n\nimport \"MarketConnector.sol\";\nimport \"IERC20Burn.sol\";\nimport \"TransferHelper.sol\";\n\n/// @title Treasury \n/// @author UBD Team\n/// @notice This contract store UBD ecosystem treasuruy assets\n/// @dev  Check deploy params so they are immutable\ncontract Treasury is MarketConnector {\n\n\tuint256 public constant SANDBOX2_TOPUP_PERCENT  = 330000; //   1% -   10000, 13% - 130000, etc \n    uint256 public constant SANDBOX1_REDEEM_PERCENT =  10000; //   1% -   10000, 13% - 130000, etc \n    uint256 public constant PERCENT_DENOMINATOR = 10000; \n\n    \n    modifier onlyMarketRegistry()\n    {\n        require(msg.sender == marketRegistry, 'Only for MarketRegistry');\n        _;\n    }\n\n    event ReceivedEther(address, uint);\n    \n    constructor(address _markets)\n        MarketConnector(_markets)\n    {\n        require(_markets != address(0), 'No zero markets');\n    }\n\n    receive() external payable {\n        emit ReceivedEther(msg.sender, msg.value);\n    }\n    \n    /// @notice Send one erc20 treasury asset for swap\n    /// @dev Can be called only from MarketRegistry\n    /// @param _marketAdapter  - address of AMM adapter contract\n    /// @param _erc20 - address of erc20 treasury tokens\n    /// @param _amount - amount of erc20 for  send\n    function sendOneERC20ForSwap(address _marketAdapter, address _erc20, uint256 _amount) \n        external\n        onlyMarketRegistry \n    {\n        \n        TransferHelper.safeTransfer(_erc20, _marketAdapter, _amount);\n    }\n\n    /// @notice Send all erc20 treasury asset for swap\n    /// @dev Can be called only from MarketRegistry\n    /// @param _marketAdapter  - address of AMM adapter contract\n    /// @param _percent - percent of Treasury balance\n    function sendERC20ForSwap(address _marketAdapter, uint256 _percent) \n        external\n        onlyMarketRegistry \n        returns(uint256[] memory)\n    {\n        \n        return _sendPercentOfTreasuryTokens(_marketAdapter, _percent);\n    }\n\n    /// @notice Send ether from  treasury asset for swap\n    /// @dev Can be called only from MarketRegistry\n    /// @param _percent - percent of Treasury balance\n    function sendEtherForRedeem(uint256 _percent) \n        external \n        onlyMarketRegistry \n        returns (uint256 amount)\n    {\n        amount = address(this).balance * _percent / (100 * PERCENT_DENOMINATOR); \n        TransferHelper.safeTransferETH(marketRegistry, amount);\n    }\n\n   \n    /// @notice Returns native token and erc20 balance of address in stableToken units\n    /// @dev Second param is array\n    /// @param _holder - address for get balance\n    /// @param _assets - array of erc20 address for get balance\n    function getBalanceInStableUnits(address _holder, address[] memory _assets) \n        external \n        view \n        returns(uint256)\n    {\n        return _getBalanceInStableUnits(_holder, _assets);\n    }\n\n    /// @notice Check conditions for Sandox2 topup\n    /// @dev Actualy check UBD ecosystem collateral Level\n    function isReadyForTopupSandBox2() public view returns(bool) {\n        if (_getCollateralSystemLevelM10() >= 30) {\n            return true;\n        }\n    }\n\n    /// @notice Returns array of erc20 Treasury assets\n    /// @dev Keep in mind that Native asset always exist\n    function treasuryERC20Assets() public view returns(address[] memory assets) {\n         return IMarketRegistry(marketRegistry).treasuryERC20Assets();\n    }\n\n    function _sendPercentOfTreasuryTokens(address _to, uint256 _percent) \n        internal \n        returns(uint256[] memory)\n    {\n        uint256 treasuryERC20AssetsCount = treasuryERC20Assets().length;\n        address[] memory _treasuryERC20Assets = new address[](treasuryERC20AssetsCount);\n        uint256[] memory _treasuryERC20sended = new uint256[](treasuryERC20AssetsCount);\n        _treasuryERC20Assets = treasuryERC20Assets();\n        for (uint8 i = 0; i < _treasuryERC20Assets.length; ++ i){\n            _treasuryERC20sended[i] = IERC20(_treasuryERC20Assets[i]).balanceOf(address(this)) \n                * _percent / (100 * PERCENT_DENOMINATOR); \n            TransferHelper.safeTransfer(\n                _treasuryERC20Assets[i],\n                _to, \n                _treasuryERC20sended[i]\n            );\n        }\n        return _treasuryERC20sended;\n\n    }\n}"
    },
    "MarketConnector.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// MarketConnector \npragma solidity 0.8.21;\n\nimport \"IMarketRegistry.sol\";\n\nabstract contract MarketConnector {\n\n    address immutable public marketRegistry;\n\tconstructor(address _markets)\n    {\n        marketRegistry = _markets;\n\n    }\n\n    event TreasuryTopup(address Asset, uint256 TopupAmount);\n    event Sandbox2Topup(address Asset, uint256 TopupAmount);\n    event Sandbox1Redeem(address Asset, uint256 TopupAmount);\n\n\n    function _getCollateralSystemLevelM10() internal view returns(uint256) {\n        return  IMarketRegistry(marketRegistry).getCollateralLevelM10();\n    }\n    \n    function _getBalanceInStableUnits(address _holder, address[] memory _assets) \n        internal \n        view \n        returns(uint256)\n    {\n        return IMarketRegistry(marketRegistry).getBalanceInStableUnits(_holder, _assets);\n    }\n}"
    },
    "IMarketRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\n\n\ninterface IMarketRegistry  {\n\n    struct AsssetShare {\n        address asset;\n        uint8 percent;\n    }\n\n    struct UBDNetwork {\n        address sandbox1;\n        address treasury;\n        address sandbox2;\n        AsssetShare[] treasuryERC20Assets;\n\n    }\n\n    struct Market {\n        address marketAdapter;\n        address oracleAdapter;\n        uint256 slippage;\n    }\n\n    struct ActualShares{\n        address asset;\n        uint256 actualPercentPoint;\n        uint256 excessAmount;\n    } \n    \n    function swapExactInToBASEOut(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address assetIn,\n        address to,\n        uint deadline\n    ) external returns (uint256 amountOut);\n\n\n    function swapExactBASEInToTreasuryAssets(uint256 _amountIn, address _baseAsset) external;\n\n    function swapTreasuryAssetsPercentToSandboxAsset() \n        external \n        returns(uint256 totalStableAmount);\n\n    function getAmountOut(\n        uint amountIn, \n        address[] memory path\n    ) external view returns (uint256 amountOut);\n    function getCollateralLevelM10() external view returns(uint256);\n    function getBalanceInStableUnits(address _holder, address[] memory _assets) external view returns(uint256);\n    function treasuryERC20Assets() external view returns(address[] memory assets);\n    function getUBDNetworkTeamAddress() external view returns(address);\n    function getUBDNetworkInfo() external view returns(UBDNetwork memory);\n}"
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
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.6.0;\n\nimport \"IERC20.sol\";\n\nlibrary TransferHelper {\n    /// @notice Transfers tokens from the targeted address to the given destination\n    /// @notice Errors with 'STF' if transfer fails\n    /// @param token The contract address of the token to be transferred\n    /// @param from The originating address from which the tokens will be transferred\n    /// @param to The destination address of the transfer\n    /// @param value The amount to be transferred\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) =\n            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');\n    }\n\n    /// @notice Transfers tokens from msg.sender to a recipient\n    /// @dev Errors with ST if transfer fails\n    /// @param token The contract address of the token which will be transferred\n    /// @param to The recipient of the transfer\n    /// @param value The value of the transfer\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');\n    }\n\n    /// @notice Approves the stipulated contract to spend the given allowance in the given token\n    /// @dev Errors with 'SA' if transfer fails\n    /// @param token The contract address of the token to be approved\n    /// @param to The target of the approval\n    /// @param value The amount of the given token the target will be allowed to spend\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');\n    }\n\n    /// @notice Transfers ETH to the recipient address\n    /// @dev Fails with `STE`\n    /// @param to The destination of the transfer\n    /// @param value The value to be transferred\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, 'STE');\n    }\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "Treasury.sol": {}
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