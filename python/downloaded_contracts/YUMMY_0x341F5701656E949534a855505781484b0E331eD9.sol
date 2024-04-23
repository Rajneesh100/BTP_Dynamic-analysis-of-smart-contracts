/*

  Website: http://www.yummycoin.vip/
  Telegram: https://t.me/YummyCoinPortal

*/

// SPDX-License-Identifier: unlicense

pragma solidity 0.8.21;

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

contract YUMMY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    IUniswapV2Router02 public uniswapV2Router;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isRemoveFromTransactionFee;
    address payable public _TeamMKTwalletAddress;
    address payable public _devWalletAddress;
    uint256 public _buyTaxfeeei=20;
    uint256 public _sellTaxfeeei=20;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCount=0;
    uint256 private _swapThreshold = _tTotal / 1000;
    uint256 private _maxTaxfeeeiwap = _tTotal * 2 / 100;
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** 18;
    uint256 public _maxWallet = _tTotal * 2 / 100;
    
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;
    string private constant _name = unicode"Yummy Coin";
    string private constant _symbol = unicode"YUMMY";
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    bool public tradeOpen;

    constructor () {
        _TeamMKTwalletAddress = payable(_msgSender());
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _isRemoveFromTransactionFee[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isRemoveFromTransactionFee[owner()] = true;
        _isRemoveFromTransactionFee[address(this)] = true;
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
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
        if (!_isRemoveFromTransactionFee[from] && !_isRemoveFromTransactionFee[to]) {
            require(tradeOpen, "Not open yet ");

            taxAmount = amount.mul(_buyTaxfeeei).div(100);

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet);
            }

            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet);
                _buyCount++;
            }

            if(to == uniswapV2Pair){
                taxAmount = amount.mul(_sellTaxfeeei).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_swapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxfeeeiwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToMKTadress(address(this).balance);
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

    function excludeFromTaxfeeei(address account, bool status) external onlyOwner {
        _isRemoveFromTransactionFee[account] = status;
    }

    function setSellTaxfeeei(uint newTaxValue) external onlyOwner {
        _sellTaxfeeei = newTaxValue;
        
    }

    function setBuyTaxfeeei(uint newTaxValue) external onlyOwner {
        _buyTaxfeeei = newTaxValue;
        require(newTaxValue < 6, "Not more 6%");
    }
   
    function removeLimits() external onlyOwner{
        _maxWallet=_tTotal;
    }

    function sendETHToMKTadress(uint256 amount) private {
        _TeamMKTwalletAddress.transfer(amount);
    }
 
    function setWalletMarketingTeam(address payable newWallet) external onlyOwner {
        _TeamMKTwalletAddress = newWallet;
    }

    function setWalletDEVMaster(address payable newWallet) external onlyOwner {
        _devWalletAddress = newWallet;
    }

    function openTrading() external onlyOwner() {
        require(!tradeOpen,"trading is already open");
        swapEnabled = true;
        tradeOpen = true;
    }

    receive() external payable {}
}