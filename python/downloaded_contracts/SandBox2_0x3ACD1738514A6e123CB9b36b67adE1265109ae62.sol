{{
  "language": "Solidity",
  "sources": {
    "SandBox2.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Sandboxd2 \npragma solidity 0.8.21;\n\nimport \"MarketConnector.sol\";\nimport \"IERC20Burn.sol\";\n\n/// @title SandBox2 \n/// @author UBD Team\n/// @notice This contract store UBD ecosystem reserves and team shares\n/// @dev  Check deploy params so they are immutable\ncontract SandBox2 is MarketConnector {\n\n    uint256 public constant TREASURY_TOPUP_PERIOD = 1 days;\n    uint256 public constant TREASURY_TOPUP_PERCENT = 10000; //   1% -   10000, 13% - 130000, etc \n    uint256 public constant PERCENT_DENOMINATOR = 10000; \n    uint256 public constant TEAM_PERCENT = 330000; //   1% -   10000, 13% - 130000, etc \n    \n    address public immutable SANDBOX_2_BASE_ASSET;\n\n    uint256 public lastTreasuryTopUp;\n    uint256 public MIN_TREASURY_TOPUP_AMOUNT = 1000; // Stable Coin Units (without decimals)\n\n    event TeamShareIncreased(uint256 Income, uint256 TeamLimit);\n\n\tconstructor(address _markets, address _baseAsset)\n        MarketConnector(_markets)\n    {\n        require(_markets != address(0), 'No zero markets');\n        require(_baseAsset != address(0),'No zero address assets');\n        SANDBOX_2_BASE_ASSET = _baseAsset;\n    }\n\n    /// @notice Check condition and topup Treasury\n    /// @dev Revert if no condition yet\n    function topupTreasury() external returns(bool) {\n        if (_getCollateralSystemLevelM10() >= 5 && _getCollateralSystemLevelM10() < 10) {\n            uint256 topupAmount = \n                IERC20(SANDBOX_2_BASE_ASSET).balanceOf(address(this)) * TREASURY_TOPUP_PERCENT / (100 * PERCENT_DENOMINATOR);\n            \n            require(\n                topupAmount \n                    >= MIN_TREASURY_TOPUP_AMOUNT \n                       * 10**IERC20Metadata(SANDBOX_2_BASE_ASSET).decimals(),\n                'Too small topup amount'\n            );\n            \n            require(\n                lastTreasuryTopUp + TREASURY_TOPUP_PERIOD < block.timestamp, \n                'Please wait untit TREASURY_TOPUP_PERIOD'\n            );\n\n            lastTreasuryTopUp = block.timestamp;\n            IERC20(SANDBOX_2_BASE_ASSET).approve(marketRegistry, topupAmount);\n            IMarketRegistry(marketRegistry).swapExactBASEInToTreasuryAssets(\n                topupAmount, \n                SANDBOX_2_BASE_ASSET\n            );\n            emit TreasuryTopup(SANDBOX_2_BASE_ASSET, topupAmount);\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /// @notice Check condition and topup SandBox2\n    /// @dev Revert if no condition yet\n    function topupSandBox2() external returns (bool){\n        uint256  topupAmount;\n        topupAmount = IMarketRegistry(marketRegistry).swapTreasuryAssetsPercentToSandboxAsset();\n        emit Sandbox2Topup(SANDBOX_2_BASE_ASSET, topupAmount);\n        _increaseApproveForTEAM(topupAmount * TEAM_PERCENT / (100 * PERCENT_DENOMINATOR));\n\n    }\n\n    /// @notice Approve 33% from DAI in to Team wallet\n    function _increaseApproveForTEAM(uint256 _incAmount) internal {\n        address team = IMarketRegistry(marketRegistry).getUBDNetworkTeamAddress();\n        uint256 newApprove = IERC20(SANDBOX_2_BASE_ASSET).allowance(address(this),team) + _incAmount;\n        IERC20(SANDBOX_2_BASE_ASSET).approve(team, newApprove);\n        emit TeamShareIncreased(_incAmount, newApprove);\n    }\n}"
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
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "SandBox2.sol": {}
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