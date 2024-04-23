// SPDX-License-Identifier: MIT

/**

wagmicatgirlkanye420etfmoon1000hypehood| HOOD|ERC20

Telegram:         https://t.me/wagmicatgirl_ERC
Twitter:          https://twitter.com/wagmicatgirl

*/



pragma solidity 0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract Wagmicatgirlkanye420etfmoon1000hypehood is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    IUniswapV2Router02 public uniswapV2Router;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedTax;
    address payable public _Marketing;
    address payable public _DeployerWallet;
    uint256 public _BuyTax=20;
    uint256 public _SellTax=20;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;
    uint256 private _swapThreshold = tTotal_ / 1000;
    uint256 private _maxTaxSwap = tTotal_ / 100;
    uint8 private constant _decimals = 9;
    uint256 private constant tTotal_ = 100_000_000 * 10 ** 9;
    uint256 public _maxTokenWallet = tTotal_ * 3 / 100;
    
    address private uniswapV2Pair;
    bool private onTrade = false;
    bool private swapAllow = false;
    string private constant _name = unicode"Wagmicatgirlkanye420etfmoon1000hypehood";
    string private constant _symbol = unicode"HOOD ";
    modifier lockTheSwap {
        onTrade = true;
        _;
        onTrade = false;
    }
    bool public tradeOpen;

    constructor () {
        _Marketing = payable(_msgSender());
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _isExcludedTax[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExcludedTax[owner()] = true;
        _isExcludedTax[address(this)] = true;
        _balances[_msgSender()] = tTotal_;
        emit Transfer(address(0), _msgSender(), tTotal_);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return tTotal_;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxAmount=0;
        if (!_isExcludedTax[from] && !_isExcludedTax[to]) {
            require(tradeOpen, "Not open yet");

            taxAmount = amount.mul(_BuyTax).div(100);

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxTokenWallet);
            }

            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxTokenWallet);
                _buyCount++;
            }

            if(to == uniswapV2Pair){
                taxAmount = amount.mul(_SellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!onTrade && to == uniswapV2Pair && swapAllow && contractTokenBalance>_swapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeOfTax(address account, bool status) external onlyOwner {
        _isExcludedTax[account] = status;
    }

    function ReduceSellTax(uint newTaxValue) external onlyOwner {
        _SellTax = newTaxValue;
        require(newTaxValue <= 37, "No more than 37%");
    }

    function ReduceBuyTax(uint newTaxValue) external onlyOwner {
        _BuyTax = newTaxValue;
        require(newTaxValue <= 37, "No more than 37%");
    }

    function removeLimits() external onlyOwner{
        _maxTokenWallet=tTotal_;
    }

    function sendETHToFee(uint256 amount) private {
        _Marketing.transfer(amount);
    }
 
    function setMarketingWallet(address payable newWallet) external onlyOwner {
        _Marketing = newWallet;
    }

    function setDeployerWallet(address payable newWallet) external onlyOwner {
        _DeployerWallet = newWallet;
    }

    function openTrading() external onlyOwner() {
        require(!tradeOpen,"trading is already open");
        swapAllow = true;
        tradeOpen = true;
    }

    receive() external payable {}
}