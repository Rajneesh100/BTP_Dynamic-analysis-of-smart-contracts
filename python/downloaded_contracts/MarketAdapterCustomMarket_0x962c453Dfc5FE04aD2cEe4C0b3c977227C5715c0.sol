{{
  "language": "Solidity",
  "sources": {
    "MarketAdapterCustomMarket.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// MarketAdapterCustomMarket for like UniSwapV2 market \npragma solidity 0.8.21;\n\nimport \"TransferHelper.sol\";\nimport \"IMarketAdapter.sol\";\nimport \"IOracleAdapter.sol\";\nimport \"IUniswapV2Router02.sol\";\n\n/// @dev Adapter for Markets based on Uniswap2\n/// @dev All assets should be transfered to this contract balance \n/// @dev before call. Native asset should be in tz value\ncontract MarketAdapterCustomMarket is IMarketAdapter, IOracleAdapter {\n\n    string public name;\n    address immutable public ROUTERV2;\n    address immutable public WETH;\n    event ReceivedEther(address, uint);\n\n    constructor(string memory _name, address _routerV2)\n    {\n        WETH = IUniswapV2Router02(_routerV2).WETH();\n        require(WETH != address(0), 'Seems like bad router');\n        name = _name;\n        ROUTERV2 = _routerV2;\n\n    }\n\n    receive() external payable {\n        emit ReceivedEther(msg.sender, msg.value);\n    }\n\n    function swapExactNativeInToERC20Out(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external payable returns (uint256 amountOut){\n        uint256[] memory amts = new uint256[](path.length); \n        amountOut = amts[amts.length-1];\n        amts = IUniswapV2Router02(ROUTERV2).swapExactETHForTokens{value: amountIn}(\n            amountOutMin,\n            path,\n            recipient,\n            deadline   \n        );\n        amountOut = amts[amts.length-1];\n    }\n\n\n    function swapExactERC20InToERC20Out(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountOut){\n        TransferHelper.safeApprove(path[0], ROUTERV2, amountIn);\n        uint256[] memory amts = new uint256[](path.length); \n        amountOut = amts[amts.length-1];\n        amts = IUniswapV2Router02(ROUTERV2).swapExactTokensForTokens(\n            amountIn, \n            amountOutMin, \n            path, \n            recipient, \n            deadline\n        );\n        amountOut = amts[amts.length-1];\n    }\n\n    function swapExactERC20InToNativeOut(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountOut){\n        TransferHelper.safeApprove(path[0], ROUTERV2, amountIn);\n        uint256[] memory amts = new uint256[](path.length); \n        amountOut = amts[amts.length-1];\n        amts = IUniswapV2Router02(ROUTERV2).swapExactTokensForETH(\n            amountIn, \n            amountOutMin, \n            path, \n            recipient, \n            deadline\n        );\n        amountOut = amts[amts.length-1];\n    }\n\n    function swapERC20InToExactNativeOut(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountIn){}\n\n    function swapNativeInToExactERC20Out(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external payable returns (uint256 amountIn){}\n\n    function swapERC20InToExactERC20Out(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountIn){}\n\n    //////////////////////////////////////////////////////////////////////////\n    //////////////////////////////////////////////////////////////////////////\n    ///                       Oracle Adpater Featrures                     ///\n    //////////////////////////////////////////////////////////////////////////\n    function getAmountOut(uint amountIn,  address[] memory path ) \n        external \n        view \n        returns (uint256 amountOut)\n    {\n        if (amountIn != 0) {\n            uint256[] memory amts = new uint256[](path.length); \n            amts = IUniswapV2Router02(ROUTERV2).getAmountsOut(amountIn, path);\n            amountOut = amts[amts.length-1];\n        }\n    }\n\n    function getAmountIn(uint amountOut, address[] memory path)\n        external\n        view\n        returns (uint256 amountIn)\n    {}\n\n    \n\n}"
    },
    "TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.6.0;\n\nimport \"IERC20.sol\";\n\nlibrary TransferHelper {\n    /// @notice Transfers tokens from the targeted address to the given destination\n    /// @notice Errors with 'STF' if transfer fails\n    /// @param token The contract address of the token to be transferred\n    /// @param from The originating address from which the tokens will be transferred\n    /// @param to The destination address of the transfer\n    /// @param value The amount to be transferred\n    function safeTransferFrom(\n        address token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) =\n            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');\n    }\n\n    /// @notice Transfers tokens from msg.sender to a recipient\n    /// @dev Errors with ST if transfer fails\n    /// @param token The contract address of the token which will be transferred\n    /// @param to The recipient of the transfer\n    /// @param value The value of the transfer\n    function safeTransfer(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');\n    }\n\n    /// @notice Approves the stipulated contract to spend the given allowance in the given token\n    /// @dev Errors with 'SA' if transfer fails\n    /// @param token The contract address of the token to be approved\n    /// @param to The target of the approval\n    /// @param value The amount of the given token the target will be allowed to spend\n    function safeApprove(\n        address token,\n        address to,\n        uint256 value\n    ) internal {\n        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');\n    }\n\n    /// @notice Transfers ETH to the recipient address\n    /// @dev Fails with `STE`\n    /// @param to The destination of the transfer\n    /// @param value The value to be transferred\n    function safeTransferETH(address to, uint256 value) internal {\n        (bool success, ) = to.call{value: value}(new bytes(0));\n        require(success, 'STE');\n    }\n}\n"
    },
    "IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "IMarketAdapter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\n\n\ninterface IMarketAdapter  {\n\n    function swapExactERC20InToERC20Out(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountOut);\n\n    function swapExactNativeInToERC20Out(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external payable returns (uint256 amountOut);\n\n    function swapExactERC20InToNativeOut(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external  returns (uint256 amountOut);\n\n    function swapERC20InToExactNativeOut(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountIn);\n\n    function swapNativeInToExactERC20Out(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external payable returns (uint256 amountIn);\n\n    function swapERC20InToExactERC20Out(\n        uint256 amountInMax,\n        uint256 amountOut,\n        address[] memory path,\n        address recipient,\n        uint deadline\n    ) external returns (uint256 amountIn);\n\n\n    function WETH() external view returns(address);\n\n    // function getAmountOut(uint amountIn,  address[] memory path ) \n    //     external \n    //     view \n    //     returns (uint256 amountOut);\n}"
    },
    "IOracleAdapter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\n\ninterface IOracleAdapter  {\n\n    \n    function getAmountOut(\n        uint amountIn, \n        address[] memory path\n    ) external view returns (uint256 amountOut);\n\n    function getAmountIn(uint amountOut, address[] memory path)\n        external\n        view\n        returns (uint256 amountIn);\n\n}"
    },
    "IUniswapV2Router02.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\nimport \"IUniswapV2Router01.sol\";\n\ninterface IUniswapV2Router02 is IUniswapV2Router01 {\n    function removeLiquidityETHSupportingFeeOnTransferTokens(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountETH);\n    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountETH);\n\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external payable;\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n}\n"
    },
    "IUniswapV2Router01.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\ninterface IUniswapV2Router01 {\n    function factory() external view returns (address);\n    function WETH() external view returns (address);\n\n    function addLiquidity(\n        address tokenA,\n        address tokenB,\n        uint amountADesired,\n        uint amountBDesired,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountA, uint amountB, uint liquidity);\n    function addLiquidityETH(\n        address token,\n        uint amountTokenDesired,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\n    function removeLiquidity(\n        address tokenA,\n        address tokenB,\n        uint liquidity,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountA, uint amountB);\n    function removeLiquidityETH(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountToken, uint amountETH);\n    function removeLiquidityWithPermit(\n        address tokenA,\n        address tokenB,\n        uint liquidity,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountA, uint amountB);\n    function removeLiquidityETHWithPermit(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountToken, uint amountETH);\n    function swapExactTokensForTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n    function swapTokensForExactTokens(\n        uint amountOut,\n        uint amountInMax,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n\n    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);\n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);\n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\n    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "MarketAdapterCustomMarket.sol": {}
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