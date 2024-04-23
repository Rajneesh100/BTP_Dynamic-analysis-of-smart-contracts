// SPDX-License-Identifier: UNLICENSED


//Website: AiOL.live
//Slogan: YOU'RE ONLINE


pragma solidity 0.8.18;

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

interface ERC20 {
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
 
    constructor() {
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract AiOL is ERC20, Ownable {
    using SafeMath for uint256;

     //events
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetMaxWalletExempt(address _address, bool _bool);
    event SellFeeChanged(uint256 _marketingFee);
    event BuyFeeChanged(uint256 _marketingFee);
    event TransferFeeChanged(uint256 _transferFee);
    event SetFeeReceiver(address _marketingReceiver);
    event ChangedSwapBack(bool _enabled, uint256 _amount);
    event SetFeeExempt(address _addr, bool _value);
    event InitialDistributionFinished(bool _value);
    event ChangedMaxWallet(uint256 _maxWallet);

    address private WETH;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    string constant private _name = "AiOL";
    string constant private _symbol = "AiOL";
    uint8 constant private _decimals = 18;

    uint256 private _totalSupply = 100000000* 10**_decimals;

    uint256 public _maxWalletAmount = _totalSupply *1 / 100;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isMaxWalletExempt;

    //Snipers
    uint256 private deadblocks = 32; 
    uint256 public launchBlock;
    uint256 private latestSniperBlock;


    //transfer fee
    uint256 private transferFee = 0;
    uint256 constant public maxFee = 10;

    //totalFees
    uint256 private totalBuyFee = 5;
    uint256 private totalSellFee = 5;

    uint256 constant private feeDenominator  = 100;

    address private marketingFeeReceiver = 0x9e3954a9D5a0524b8D1DF86A223502fa712a8410 ;


    IDEXRouter public router;
    address public pair;

    bool public tradingEnabled = false;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 5000;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));

        setAutomatedMarketMakerPair(pair, true);
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isMaxWalletExempt[msg.sender] = true;
        
        isFeeExempt[address(this)] = true; 
        isMaxWalletExempt[address(this)] = true;

        isFeeExempt[marketingFeeReceiver] = true;
        isMaxWalletExempt[marketingFeeReceiver] = true;

        isMaxWalletExempt[pair] = true; 

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(tradingEnabled,"Trading not open, yet");
        }

        if(shouldSwapBack()){ swapBack(); }


        uint256 amountReceived = amount; 

        if(automatedMarketMakerPairs[sender]) { //buy
            if(!isFeeExempt[recipient]) {
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                amountReceived = takeBuyFee(sender, amount);
            }

        } else if(automatedMarketMakerPairs[recipient]) { //sell
            if(!isFeeExempt[sender]) {
                amountReceived = takeSellFee(sender, amount);
            }
        } else {	
            if (!isFeeExempt[sender]) {	
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                amountReceived = takeTransferFee(sender, amount);	
            }
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getSniperFee() internal view returns(uint256) {
        uint256 blocksAfterLaunch = block.number.sub(launchBlock);
        uint256 sniperTax;
        if(blocksAfterLaunch < 8){
            sniperTax = 44;
        }
        else if(blocksAfterLaunch >= 8 && blocksAfterLaunch < 16) {
            sniperTax = 33;
        }
        else if(blocksAfterLaunch >= 16 && blocksAfterLaunch < 24) {
            sniperTax = 22;
        }
        else {
            sniperTax = 11;
        }
        return sniperTax;
    }

    // Fees
    function takeBuyFee(address sender, uint256 amount) internal returns (uint256){
        uint256 _realFee = totalBuyFee;
        if (block.number < latestSniperBlock) {
                _realFee = getSniperFee();
            }

        uint256 feeAmount = amount.mul(_realFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256){
        uint256 _realFee = totalSellFee;
        if (block.number < latestSniperBlock) {
                _realFee = getSniperFee();
            }
        
        uint256 feeAmount = amount.mul(_realFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
            
    }

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256){
        uint256 feeAmount = amount.mul(transferFee).div(feeDenominator);
            
        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);	
            emit Transfer(sender, address(this), feeAmount); 
        }
            	
        return amount.sub(feeAmount);	
    }    

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender]
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueERC20(address tokenAddress, uint256 amount) external onlyOwner returns (bool) {
        return ERC20(tokenAddress).transfer(msg.sender, amount);
    }

    // switch Trading
    function enableTrading() external onlyOwner {
        require(tradingEnabled == false, "Can only enable once");
        tradingEnabled = true;
        launchBlock = block.number;
        latestSniperBlock = block.number.add(deadblocks);

        emit InitialDistributionFinished(true);
    }

    function swapBack() internal swapping {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _balances[address(this)],
            0,
            path,
            marketingFeeReceiver,
            block.timestamp
        );
    
    }

    // Admin Functions
    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount > _totalSupply / 10000, "Can't limit trading");
        _maxWalletAmount = amount;

        emit ChangedMaxWallet(amount);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;

        emit SetFeeExempt(holder, exempt);
    }

    function setIsMaxWalletExempt(address holder, bool exempt) external onlyOwner {
        isMaxWalletExempt[holder] = exempt;

        emit SetMaxWalletExempt(holder, exempt);
    }

    function setBuyFee(uint256 _totalBuyFee) external onlyOwner {
        totalBuyFee = _totalBuyFee;
        require(totalBuyFee <= maxFee, "Fees cannot be more than 10%");

        emit BuyFeeChanged(totalBuyFee);
    }

    function setSellFee(uint256 _totalSellFee) external onlyOwner {
        totalSellFee = _totalSellFee;
        require(totalSellFee <= maxFee, "Fees cannot be more than 10%");

        emit SellFeeChanged(totalSellFee);
    }

    function setTransferFee(uint256 _transferFee) external onlyOwner {	
        transferFee = _transferFee;	
        require(transferFee <= maxFee, "Fees cannot be higher than 10%");	

	    emit TransferFeeChanged(_transferFee);	
    }


    function setMarketingFeeReceivers(address _marketingFeeReceiver) external onlyOwner {
        require(_marketingFeeReceiver != address(0), "Zero Address validation" );
        marketingFeeReceiver = _marketingFeeReceiver;

        emit SetFeeReceiver(_marketingFeeReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit ChangedSwapBack(_enabled, _amount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
            require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

            automatedMarketMakerPairs[_pair] = _value;

            if(_value){
                _markerPairs.push(_pair);
            }else{
                require(_markerPairs.length > 1, "Required 1 pair");
                for (uint256 i = 0; i < _markerPairs.length; i++) {
                    if (_markerPairs[i] == _pair) {
                        _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                        _markerPairs.pop();
                        break;
                    }
                }
            }

            emit SetAutomatedMarketMakerPair(_pair, _value);
        }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


}