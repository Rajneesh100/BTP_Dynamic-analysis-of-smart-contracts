// SPDX-License-Identifier: MIT

/**  
Website: traderxcapital.io
Telegram : https://t.me/traderxportal
X: https://x.com/TraderXETH
**/

pragma solidity ^0.8.19;

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract TraderX is Context, IERC20, Ownable {

    using Address for address payable;

    IRouter public router;
    address public pair;
    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromMaxBalance;

    uint8 private constant _decimals = 9; 
    uint256 private _tTotal = 1_000_000 * (10**_decimals);
    uint256 public swapThreshold = 5_000 * (10**_decimals); 
    uint256 public maxWallet =  2_000 * (10**_decimals);
    
    uint8 public buyTax = 25;
    uint8 public sellTax = 25;

    string private constant _name = "TraderX"; 
    string private constant _symbol = "$TX";

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0xA467d20489f16732f8B8b938aabb82CE1a4F2F09;
    address public treasuryWallet = 0x31cF11064679080A45A61aE485700920C8fDc107;

    bool private swapping;
    uint8 private _txCountBeforeSwapEnabled = 20;
    uint8 private _txCount = 0;

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () {
        _tOwned[_msgSender()] = _tTotal * 90 / 100;
        _tOwned[address(this)] = _tTotal * 10 / 100;
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _approve(owner(), address(router), ~uint256(0));

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[treasuryWallet] = true;
        _isExcludedFromFee[DEAD] = true;

        _isExcludedFromMaxBalance[owner()] = true;
        _isExcludedFromMaxBalance[address(this)] = true;
        _isExcludedFromMaxBalance[pair] = true;
        _isExcludedFromMaxBalance[marketingWallet] = true;
        _isExcludedFromMaxBalance[treasuryWallet] = true;
        _isExcludedFromMaxBalance[DEAD] = true;

        emit Transfer(address(0), _msgSender(), _tTotal * 90 / 100);
        emit Transfer(address(0), address(this), _tTotal * 10 / 100);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _preTransferCheck(address from,address to,uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(to) + amount <= maxWallet || _isExcludedFromMaxBalance[to], "Transfer amount exceeds the maxWallet.");
        if (balanceOf(address(this)) >= swapThreshold && !swapping && _txCount >= _txCountBeforeSwapEnabled && from != pair && from != owner() && to != owner())
            swapAndLiquify();
    }

    function _getValues(address from,address to, uint256 amount) private returns(uint256){
        uint256 taxedTokens;
        if(to == pair){
            taxedTokens = amount * sellTax / 100;
        }else{
            if(from == pair)
                _txCount++;
            taxedTokens = amount * buyTax / 100;
        }
        if (taxedTokens > 0){
            _tOwned[address(this)] += taxedTokens;
            emit Transfer (from, address(this), taxedTokens);
        }
        return (amount - taxedTokens);
    }
    
    function _transfer(address from,address to,uint256 amount) private {
        _preTransferCheck(from, to, amount);
        _tOwned[from] -= amount;
        uint256 transferAmount = amount;
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
            transferAmount = _getValues(from, to, amount);
        _tOwned[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }

    function swapAndLiquify() private lockTheSwap{

        uint256 tokensForMarketing = swapThreshold * 40 / 100; 
        uint256 tokensForTreasury = swapThreshold * 55 / 100;
        uint256 tokensForLiquidity = swapThreshold * 5 / 100;
        
        if(tokensForMarketing > 0){
            uint256 ethSwapped = swapTokensForETH(tokensForMarketing);
            if(ethSwapped > 0)
                payable(marketingWallet).transfer(ethSwapped);
        }

        if(tokensForTreasury > 0){
            uint256 ethSwapped = swapTokensForETH(tokensForTreasury);
            if(ethSwapped > 0)
                payable(treasuryWallet).transfer(ethSwapped);
        }

        if(tokensForLiquidity > 0){
            uint half = tokensForLiquidity / 2;
            uint otherHalf = tokensForLiquidity - half;
            uint balAutoLP = swapTokensForETH(half);
            if (balAutoLP > 0)
                addLiquidity(otherHalf, balAutoLP);
        }

        if (address(this).balance > 0)
            payable(marketingWallet).sendValue(address(this).balance);

    }

    function swapTokensForETH(uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance - initialBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);

        (,uint256 ethFromLiquidity,) = router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            treasuryWallet,
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0)
            payable(marketingWallet).sendValue (ethAmount - ethFromLiquidity);
    }

    receive() external payable {}
    
    function setContractLimits(uint256 maxWalletEXACT_) external onlyOwner{
        uint256 minimumAmount = 5_000 * (10**_decimals);
        require(maxWalletEXACT_ * (10**_decimals) >= minimumAmount, "Invalid Settings!");
        maxWallet = maxWalletEXACT_ * (10**_decimals);
    }

    function setContractSettings(uint8 buyTax_ , uint8 sellTax_) external onlyOwner{
        require(buyTax_ <= 20 && sellTax_ <= 50, "Invalid Settings!");
        buyTax = buyTax_; 
        sellTax = sellTax_;
    }

    function setSwapThreshold(uint256 swapThresholdEXACT_) external onlyOwner{
        uint256 minimumAmount = 2_500 * (10**_decimals);
        require(swapThresholdEXACT_ * (10**_decimals) >= minimumAmount, "Invalid Settings!");
        swapThreshold = swapThresholdEXACT_ * (10**_decimals);
    }

    function manualSwap() external lockTheSwap{
        require(msg.sender == marketingWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){
            uint256 ethSwapped = swapTokensForETH(tokenBalance);
            if(ethSwapped > 0)
                payable(marketingWallet).transfer(ethSwapped);
        }
        if (address(this).balance > 0)
            payable(marketingWallet).sendValue(address(this).balance);
    }

}