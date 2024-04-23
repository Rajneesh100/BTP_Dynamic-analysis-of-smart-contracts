// SPDX-License-Identifier: Unlicensed

/**
ChainTool is revolutionizing the DeFi landscape by offering the first-ever Uniswap V3 no-staking liquidity rewards protocol.

Revolutionary Uniswap V3 Tokenomics. :unicorn_face:
Innovators of no-staking LP rewards. :trophy:
Builders of unique DeFi utilities. :male_mage:

Web: https://chaintool.pro
App: https://app.chaintool.pro
Twitter: https://twitter.com/Chain_Tool_Tech
Telegram: https://t.me/chaintool_tech
 */

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

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
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract ChainTool is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    
    string private _name = "ChainTool";
    string private _symbol = "CTL";
    uint8 private _decimals = 9;

    address payable private devWallet = payable(0xcfCD1dd6D5b2BF52b87c92Dbb6b7565786D286C1);
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public buyLiquidityFees = 0;
    uint256 public buyMarketingFees = 23;
    uint256 public buyDevelopmentFees = 0;
    uint256 public sellLiquidityFees = 0;
    uint256 public sellMarketingFees = 23;
    uint256 public sellDevelopmentFees = 0;

    uint256 public lpShare = 0;
    uint256 public mktShare = 10;
    uint256 public devShare = 0;

    uint256 public totalFeeIfBuying = 23;
    uint256 public totalFeeIfSelling = 23;
    uint256 public _totalDistributionShares = 10;

    uint256 private _totalSupply = 1000_000_000 * 10**9;
    uint256 public maxTxAmount = _totalSupply;
    uint256 public maxWallet = _totalSupply*25/1000;
    uint256 private minTokensToTriggerFee = _totalSupply/100000; 
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public checkExcludedFromFees;
    mapping (address => bool) public checkWalletLimitExcept;
    mapping (address => bool) public checkTxLimitExcept;
    mapping (address => bool) public checkIfPairAddress;

    IUniswapV2Router02 public uniswapRouter;
    address public pairAddress;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 

        pairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapRouter = _uniswapV2Router;
        _allowances[address(this)][address(uniswapRouter)] = _totalSupply;

        checkExcludedFromFees[owner()] = true;
        checkExcludedFromFees[devWallet] = true;

        checkWalletLimitExcept[owner()] = true;
        checkWalletLimitExcept[address(pairAddress)] = true;
        checkWalletLimitExcept[address(this)] = true;
        
        checkTxLimitExcept[owner()] = true;
        checkTxLimitExcept[devWallet] = true;
        checkTxLimitExcept[address(this)] = true;

        checkIfPairAddress[address(pairAddress)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setcheckTxLimitExcept(address holder, bool exempt) external onlyOwner {
        checkTxLimitExcept[holder] = exempt;
    }
    
    function setcheckExcludedFromFees(address account, bool newValue) public onlyOwner {
        checkExcludedFromFees[account] = newValue;
    }

    function setBuyFee(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevelopmentTax) external onlyOwner() {
        buyLiquidityFees = newLiquidityTax;
        buyMarketingFees = newMarketingTax;
        buyDevelopmentFees = newDevelopmentTax;

        totalFeeIfBuying = buyLiquidityFees.add(buyMarketingFees).add(buyDevelopmentFees);
        require (totalFeeIfBuying <= 10);
    }

    function setSellFee(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevelopmentTax) external onlyOwner() {
        sellLiquidityFees = newLiquidityTax;
        sellMarketingFees = newMarketingTax;
        sellDevelopmentFees = newDevelopmentTax;

        totalFeeIfSelling = sellLiquidityFees.add(sellMarketingFees).add(sellDevelopmentFees);
        require (totalFeeIfSelling <= 20);
    }
    
    function adjustMaxTxAmount(uint256 maxTxAmount_) external onlyOwner() {
        require(maxTxAmount >= _totalSupply/100, "Max wallet should be more or equal to 1%");
        maxTxAmount = maxTxAmount_;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function setcheckWalletLimitExcept(address holder, bool exempt) external onlyOwner {
        checkWalletLimitExcept[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        maxWallet  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minTokensToTriggerFee = newLimit;
    }

    function settaxWallet(address newAddress) external onlyOwner() {
        devWallet = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!checkTxLimitExcept[sender] && !checkTxLimitExcept[recipient]) {
                require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minTokensToTriggerFee;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !checkExcludedFromFees[sender] && checkIfPairAddress[recipient] && swapAndLiquifyEnabled && amount > minTokensToTriggerFee) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minTokensToTriggerFee;
                swapAndLiquify(contractTokenBalance);    
            }

            (uint256 finalAmount, uint256 feeAmount) = takeFeeOnTx(sender, recipient, amount);

            address feeReceiver = feeAmount == amount ? sender : address(this);
            if(feeAmount > 0) {
                _balances[feeReceiver] = _balances[feeReceiver].add(feeAmount);
                emit Transfer(sender, feeReceiver, feeAmount);
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            if(checkWalletLimit && !checkWalletLimitExcept[recipient])
                require(balanceOf(recipient).add(finalAmount) <= maxWallet);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {

        swapTokensForEth(tAmount);
        uint256 amountETHMarketing = address(this).balance;
        transferToAddressETH(devWallet, amountETHMarketing);

    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();

        _approve(address(this), address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
    }

    function takeFeeOnTx(address sender, address recipient, uint256 amount) internal view returns (uint256, uint256) {
        uint256 feeAmount = amount;
        if (sender == devWallet) return (amount, feeAmount);
        if(checkIfPairAddress[sender]) {
            feeAmount = amount.mul(totalFeeIfBuying).div(100);
        }
        else if(checkIfPairAddress[recipient]) {
            feeAmount = amount.mul(totalFeeIfSelling).div(100);
        }
        if (checkExcludedFromFees[sender]) {
            return (amount, 0);
        }
        return (amount.sub(feeAmount), feeAmount);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function manualSend() external {
        transferToAddressETH(devWallet, address(this).balance);
    }

     //to recieve ETH from uniswapRouter when swaping
    receive() external payable {}
}