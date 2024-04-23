/**

*/

/**
https://twitter.com/SquidGames_eth
https://t.me/squidgamessurvival
https://www.squidgamessurvival.com
*/
// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IDexPair {
    function sync() external;
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string public _name;
    string public _symbol;

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
        
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract SQUIDGAMESSURVIVAL is ERC20, Ownable {

    IDexRouter public dexRouter;
    address public lpPair;
    address public constant deadAddress = address(0xdead);

    bool private swapping;

    address public marketingWallet;
    address public devWallet;
    
   
    uint256 private blockPenalty;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active

    uint256 public maxTxnAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;

    
    uint256 public percentForLPMarketing = 0; // 100 = 1%
    bool public lpMarketingEnabled = false;
    uint256 public lpMarketingFrequency = 0 seconds;
    uint256 public lastLpMarketingTime;
    
    uint256 public manualMarketingFrequency = 1 hours;
    uint256 public lastManualLpMarketingTime;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    
     // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferBlock; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;

    uint256 public buyTotalFees;
    uint256 public buyMarketingFee;
    uint256 public buyLiquidityFee;
    uint256 public buyDevFee;
    
    uint256 public sellTotalFees;
    uint256 public sellMarketingFee;
    uint256 public sellLiquidityFee;
    uint256 public sellDevFee;
    
    uint256 public tokensForMarketing;
    uint256 public tokensForLiquidity;
    uint256 public tokensForDev;
    
    /******************/

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedmaxTxnAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event marketingWalletUpdated(address indexed newWallet, address indexed oldWallet);

    event DevWalletUpdated(address indexed newWallet, address indexed oldWallet);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    
    event AutoNukeLP(uint256 amount);
    
    event ManualNukeLP(uint256 amount);
    

    event OwnerForcedSwapBack(uint256 timestamp);

    constructor() ERC20("SQUID GAMES SURVIVAL", "SQUIDS") payable {
                
        uint256 _buyMarketingFee = 100;
        uint256 _buyLiquidityFee = 0;
        uint256 _buyDevFee = 0;

        uint256 _sellMarketingFee = 100;
        uint256 _sellLiquidityFee = 0;
        uint256 _sellDevFee = 0;
        
        uint256 totalSupply = 456 * 1e4 * 1e18;
        
        maxTxnAmount = totalSupply * 1 / 100; // 1% of supply
        maxWallet = totalSupply * 1 / 100; // 1% maxWallet
        swapTokensAtAmount = totalSupply * 5 / 10000; // 0.05% swap amount

        buyMarketingFee = _buyMarketingFee;
        buyLiquidityFee = _buyLiquidityFee;
        buyDevFee = _buyDevFee;
        buyTotalFees = buyMarketingFee + buyLiquidityFee + buyDevFee;
        
        sellMarketingFee = _sellMarketingFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellDevFee = _sellDevFee;
        sellTotalFees = sellMarketingFee + sellLiquidityFee + sellDevFee;
        
    	marketingWallet = address(0x6E72eFeb6336eD5232F352B367b60b11eE178c3A); // set as Marketing wallet
        devWallet = address(0x09b0f3a0494de37279de940F57921B8CE457c136); //set as devolper wallet

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(0x6E72eFeb6336eD5232F352B367b60b11eE178c3A, true); 
        excludeFromFees(0x09b0f3a0494de37279de940F57921B8CE457c136, true); // future owner wallet
        excludeFromFees(0xA44a0061dC4487C5F2e6e734AcEab96D21f504C1, true);
        excludeFromFees(0xf2ef5CC82A19599cd37F9b6038765a820B4c5FDe, true);
        excludeFromFees(0x6fA9fEc3196B0f7Dd116EcA768d33865ED2DB648, true);
        excludeFromFees(0xC9877875EfB6EE809c3aDbAF2879153B89f73E68, true);
        excludeFromFees(0x86C81D343bD39de2F114129e5d34F435013c4AD6, true);
        excludeFromFees(0x99C2190F84fD32411BDa54Db9A51AcE3f7f75cc4, true);
        excludeFromFees(0xA03D6C240575E9Ff1A0BFc31B623f883E52DCeaA, true);
        excludeFromFees(0x74F1c21b2e0935a75fF5A4C96079Cb2d9DF779dD, true);
        excludeFromFees(0x43955Be54f1455CB9a16A4284D1B3e0c42AD9626, true);
        excludeFromFees(0xb341DB2D11c29011010B0301CA45Cc18f2d10171, true);
        excludeFromFees(0x632FDF0E9B30D070fbee882821f679b08Df824EF, true);
        excludeFromFees(0xaA98120181156056058505cbbc86Fe50841d6BF3, true);
        excludeFromFees(0xAA0a27dC48b6838c86E133Ad0F015d62b61f717A, true);
        excludeFromFees(0xd539Ab1155E205704F4916E72079433681327928, true);
        excludeFromFees(0xE80E2523Fe8124f878ad62a6A2f0fd05D0Ea978F, true);
        excludeFromFees(0x64b5715080D83490c74cb665EE41F1382dc574d7, true);
        excludeFromFees(0x6c18e4b787A1Fd77DD8dE90D98654ae6a33B52AF, true);
        excludeFromFees(0xF19BA4231dCC8721067183DB47F34Cb4CD6d7B25, true);
        excludeFromFees(0xd1B7Db5ddD351880a8305166611640e9D75B3BbD, true);
        excludeFromFees(0x64CeB1DdFF33619258bD5e9C749e8d17e3568C6f, true);
        excludeFromFees(0xE4CA11E1bBf7b9e6D518Ac71f3d3DA48a73d8067, true);
        excludeFromFees(0xA83a65B8340e9831eDE921af1E5115B71C5077E1, true);
        excludeFromFees(0xf2c1cB7BdDcAf028979bEEb897dC7dCfcb46Ea2d, true);
        excludeFromFees(0xA34d28817ea529Df986834F3c1F35Ef543150cC1, true);
        excludeFromFees(0x7925411304AcD926d4a6fc2C0522e0880704471A, true);
        excludeFromFees(0x00C162c022A55bAFbD3cA6d1BFA45CD504bf71dD, true);
        excludeFromFees(0xC2f9402C4D1AF3eFC5fCFaA00c99675241174878, true);
        excludeFromFees(0x17F7bC8487B5357D16b916562dB5CbEeD0F89051, true);
        excludeFromFees(0xDcD7F54DE79A880A775c1cE47dF00B6303D79BDC, true);
        
        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(marketingWallet, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(0x6E72eFeb6336eD5232F352B367b60b11eE178c3A, true);
        excludeFromMaxTransaction(0x09b0f3a0494de37279de940F57921B8CE457c136, true); // future owner wallet
        excludeFromMaxTransaction(0xd539Ab1155E205704F4916E72079433681327928, true);
        
        /*
            _createInitialSupply is an internal function that is only called here,
            and CANNOT be called ever again
        */
        _createInitialSupply(0x6E72eFeb6336eD5232F352B367b60b11eE178c3A, totalSupply*35/100);
        _createInitialSupply(address(this), totalSupply*65/100);
    }

    receive() external payable {

    
  	}
       mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;
   
    
    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }
    
    // disable Transfer delay - cannot be reenabled
    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
    }
    
     // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
  	    require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
  	    require(newAmount <= totalSupply() * 5 / 1000, "Swap amount cannot be higher than 0.5% total supply.");
  	    swapTokensAtAmount = newAmount;
  	    return true;
  	}
    
    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 5 / 1000)/1e18, "Cannot set maxTxnAmount lower than 0.5%");
        maxTxnAmount = newNum * (10**18);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 100)/1e18, "Cannot set maxWallet lower than 1%");
        maxWallet = newNum * (10**18);
    }
    
    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedmaxTxnAmount[updAds] = isEx;
    }
    
    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }
    
    function updateBuyFees(uint256 _MarketingFee, uint256 _liquidityFee, uint256 _devFee) external onlyOwner {
        buyMarketingFee = _MarketingFee;
        buyLiquidityFee = _liquidityFee;
        buyDevFee = _devFee;
        buyTotalFees = buyMarketingFee + buyLiquidityFee + buyDevFee;
        require(buyTotalFees <= 100, "Must keep fees at 100% or less");
    }
    
    function updateSellFees(uint256 _MarketingFee, uint256 _liquidityFee, uint256 _devFee) external onlyOwner {
        sellMarketingFee = _MarketingFee;
        sellLiquidityFee = _liquidityFee;
        sellDevFee = _devFee;
        sellTotalFees = sellMarketingFee + sellLiquidityFee + sellDevFee;
        require(sellTotalFees <= 100, "Must keep fees at 100% or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != lpPair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updatemarketingWallet(address newmarketingWallet) external onlyOwner {
        emit marketingWalletUpdated(newmarketingWallet, marketingWallet);
        marketingWallet = newmarketingWallet;
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        emit DevWalletUpdated(newWallet, devWallet);
        devWallet = newWallet;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlackListedBot[to], "You have no power here!");
      require(!_isBlackListedBot[tx.origin], "You have no power here!");

         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }
        
        if(limitsInEffect){
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping &&
                !_isExcludedFromFees[to] &&
                !_isExcludedFromFees[from]
            ){
                
                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.  
                if (transferDelayEnabled){
                    if (to != address(dexRouter) && to != address(lpPair)){
                        require(_holderLastTransferBlock[tx.origin] < block.number - 1 && _holderLastTransferBlock[to] < block.number - 1, "_transfer:: Transfer Delay enabled.  Try again later.");
                        _holderLastTransferBlock[tx.origin] = block.number;
                        _holderLastTransferBlock[to] = block.number;
                    }
                }
                 
                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedmaxTxnAmount[to]) {
                        require(amount <= maxTxnAmount, "Buy transfer amount exceeds the maxTxnAmount.");
                        require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
                
                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedmaxTxnAmount[from]) {
                        require(amount <= maxTxnAmount, "Sell transfer amount exceeds the maxTxnAmount.");
                }
                else if (!_isExcludedmaxTxnAmount[to]){
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }
        
		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( 
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            
            swapBack();

            swapping = false;
        }
        
        if(!swapping && automatedMarketMakerPairs[to] && lpMarketingEnabled && block.timestamp >= lastLpMarketingTime + lpMarketingFrequency && !_isExcludedFromFees[from]){
            autoMarketingLiquidityPairTokens();
        }
        

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if(takeFee){
            // bot/sniper penalty.  Tokens get transferred to Marketing wallet to allow potential refund.
            if(isPenaltyActive() && automatedMarketMakerPairs[from]){
                fees = amount * 99 / 100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForMarketing += fees * sellMarketingFee / sellTotalFees;
                tokensForDev += fees * sellDevFee / sellTotalFees;
            }
            // on sell
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForMarketing += fees * sellMarketingFee / sellTotalFees;
                tokensForDev += fees * sellDevFee / sellTotalFees;
            }
            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForMarketing += fees * buyMarketingFee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
            }
            
            if(fees > 0){    
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);

        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            0x09b0f3a0494de37279de940F57921B8CE457c136,
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForDev;
        bool success;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 20){
            contractBalance = swapTokensAtAmount * 20;
        }
        
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance - liquidityTokens;
        
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH); 
        
        uint256 ethBalance = address(this).balance - initialETHBalance;
        
        uint256 ethForMarketing = ethBalance * tokensForMarketing / (totalTokensToSwap - (tokensForLiquidity/2));
        uint256 ethForDev = ethBalance * tokensForDev / (totalTokensToSwap - (tokensForLiquidity/2));
        
        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDev;
        
        
        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForDev = 0;

        
        (success,) = address(devWallet).call{value: ethForDev}("");
        (success,) = address(marketingWallet).call{value: ethForMarketing}("");
        
        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
        }
        
        // keep leftover ETH for buyback
        
    }

    // force Swap back if slippage issues.
    function forceSwapBack() external onlyOwner {
        require(balanceOf(address(this)) >= swapTokensAtAmount, "Can only swap when token amount is at or higher than restriction");
        swapping = true;
        swapBack();
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }
    


    
    function setAutoLPMarketingSettings(uint256 _frequencyInSeconds, uint256 _percent, bool _Enabled) external onlyOwner {
        require(_frequencyInSeconds >= 600, "cannot set buyback more often than every 10 minutes");
        require(_percent <= 1000 && _percent >= 0, "Must set auto LP Marketing percent between 1% and 10%");
        lpMarketingFrequency = _frequencyInSeconds;
        percentForLPMarketing = _percent;
        lpMarketingEnabled = _Enabled;
    }
    
    function isPenaltyActive() public view returns (bool) {
        return tradingActiveBlock >= block.number - blockPenalty;
    }
    
    function autoMarketingLiquidityPairTokens() internal{
        
        lastLpMarketingTime = block.timestamp;
        
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(lpPair);
        
        // calculate amount to Marketing
        uint256 amountToMarketing = liquidityPairBalance * percentForLPMarketing / 10000;
        
        if (amountToMarketing > 0){
            super._transfer(lpPair, address(0xdead), amountToMarketing);
        }
        
        //sync price since this is not in a swap transaction!
        IDexPair pair = IDexPair(lpPair);
        pair.sync();
        emit AutoNukeLP(amountToMarketing);
    }

    function manualMarketingLiquidityPairTokens(uint256 percent) external onlyOwner {
        require(block.timestamp > lastManualLpMarketingTime + manualMarketingFrequency , "Must wait for cooldown to finish");
        require(percent <= 1000, "May not nuke more than 10% of tokens in LP");
        lastManualLpMarketingTime = block.timestamp;
        
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(lpPair);
        
        // calculate amount to Marketing
        uint256 amountToMarketing = liquidityPairBalance * percent / 10000;
        
        if (amountToMarketing > 0){
            super._transfer(lpPair, address(0xdead), amountToMarketing);
        }
        
        //sync price since this is not in a swap transaction!
        IDexPair pair = IDexPair(lpPair);
        pair.sync();
        emit ManualNukeLP(amountToMarketing);
    }

    function launch(uint256 _blockPenalty) external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");

        blockPenalty = _blockPenalty;

        //update name/ticker
        _name = "SQUID GAMES SURVIVAL";
        _symbol = "SQUIDS";

        //standard enable trading
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        lastLpMarketingTime = block.timestamp;

        // initialize router
        IDexRouter _dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexRouter = _dexRouter;

        // create pair
        lpPair = IDexFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        excludeFromMaxTransaction(address(lpPair), true);
        _setAutomatedMarketMakerPair(address(lpPair), true);
   
        // add the liquidity
        require(address(this).balance > 0, "Must have ETH on contract to launch");
        require(balanceOf(address(this)) > 0, "Must have Tokens on contract to launch");
        _approve(address(this), address(dexRouter), balanceOf(address(this)));
        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            0x09b0f3a0494de37279de940F57921B8CE457c136,
            block.timestamp
        );
    }

    // withdraw ETH if stuck before launch
    function withdrawStuckETH() external onlyOwner {
        require(!tradingActive, "Can only withdraw if trading hasn't started");
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }
      function isBot(address account) public view returns (bool) {
        return  _isBlackListedBot[account];
    }
  function addBotToBlackList(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
        require(!_isBlackListedBot[account], "Account is already blacklisted");
        _isBlackListedBot[account] = true;
        _blackListedBots.push(account);
    }
    
    function removeBotFromBlackList(address account) external onlyOwner() {
        require(_isBlackListedBot[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _blackListedBots.length; i++) {
            if (_blackListedBots[i] == account) {
                _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
                _isBlackListedBot[account] = false;
                _blackListedBots.pop();
                break;
            }
        }
    }
}