// SPDX-License-Identifier: MIT


/**
 * 🌐 Website: https://gamofi.io
 * 🐦 Twitter: https://twitter.com/gamofiio
 * 💬 Telegram: https://t.me/gamofi
 */

pragma solidity 0.8.21;

abstract contract Context {
    /**
     * @dev Returns the current sender of the message.
     * This function is internal view virtual, meaning that it can only be used within this contract or derived contracts.
     * @return The address of the account that initiated the transaction.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    /**
     * @dev Returns the total supply of tokens.
     * @return The total supply of tokens.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of a specific account.
     * @param account The address of the account to check the balance for.
     * @return The balance of the specified account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfers tokens to a recipient.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to be transferred.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining allowance for a spender.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     * @return The remaining allowance for the specified owner and spender.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Approves a spender to spend a certain amount of tokens on behalf of the owner.
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Transfers tokens from one account to another.
     * @param sender The address from which the tokens will be transferred.
     * @param recipient The address to which the tokens will be transferred.
     * @param amount The amount of tokens to be transferred.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when tokens are transferred from one address to another.
     * @param from The address from which the tokens are transferred.
     * @param to The address to which the tokens are transferred.
     * @param value The amount of tokens being transferred.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the approval of a spender is updated.
     * @param owner The address that approves the spender.
     * @param spender The address that is approved.
     * @param value The new approved amount.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a The first integer to add.
     * @param b The second integer to add.
     * @return The sum of the two integers.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow.
     * @param a The integer to subtract from (minuend).
     * @param b The integer to subtract (subtrahend).
     * @return The difference of the two integers.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Subtracts two unsigned integers, reverts with custom message on overflow.
     * @param a The integer to subtract from (minuend).
     * @param b The integer to subtract (subtrahend).
     * @param errorMessage The error message to revert with.
     * @return The difference of the two integers.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a The first integer to multiply.
     * @param b The second integer to multiply.
     * @return The product of the two integers.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a The dividend.
     * @param b The divisor.
     * @return The quotient of the division.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Divides two unsigned integers, reverts with custom message on division by zero.
     * @param a The dividend.
     * @param b The divisor.
     * @param errorMessage The error message to revert with.
     * @return The quotient of the division.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;

    /// @dev Emitted when ownership is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract, setting the original owner to the sender account.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     * @return The address of the current owner.
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
     * @dev Renounces ownership, leaving the contract without an owner.
     * @notice Renouncing ownership will leave the contract without an owner,
     * which means it will not be possible to call onlyOwner functions anymore.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    /**
     * @dev Creates a new UniswapV2 pair for the given tokens.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @return pair The address of the newly created UniswapV2 pair.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    /**
     * @dev Swaps an exact amount of input tokens for as much output as possible, along with additional functionality
     * to support fee-on-transfer tokens.
     * @param amountIn The amount of input tokens to swap.
     * @param amountOutMin The minimum amount of output tokens expected to receive.
     * @param path An array of token addresses representing the path of the swap.
     * @param to The recipient address to send the swapped ETH to.
     * @param deadline The timestamp for the deadline of the swap transaction.
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    /**
     * @dev Returns the address of the UniswapV2Factory contract.
     * @return The address of the UniswapV2Factory contract.
     */
    function factory() external pure returns (address);

    /**
     * @dev Returns the address of the WETH (Wrapped ETH) contract.
     * @return The address of the WETH contract.
     */
    function WETH() external pure returns (address);

    /**
    * @dev Adds liquidity to an ETH-based pool.
    * @param token The address of the ERC-20 token to add liquidity for.
    * @param amountTokenDesired The desired amount of tokens to add.
    * @param amountTokenMin The minimum amount of tokens expected to receive.
    * @param amountETHMin The minimum amount of ETH expected to receive.
    * @param to The recipient address to send the liquidity to.
    * @param deadline The timestamp for the deadline of the liquidity addition transaction.
    * @return amountToken The amount of token added.
    * @return amountETH The amount of ETH added.
    * @return liquidity The amount of liquidity added.
    */
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract GAMO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 private uniswapV2Router;

    string private constant _name = unicode"Gamofi Token";
    string private constant _symbol = unicode"GAMO";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 10000000 * 10**_decimals;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) private _holderLastTransferTimestamp;

    uint256 private _buyFee = 20;
    uint256 private _sellFee = 25;

    uint256 public _maxTxAmount = _totalSupply / 200;
    uint256 public _maxWalletSize = _totalSupply / 200;
    uint256 public _taxSwapThreshold = _totalSupply / 400;

    address payable private _taxWallet;

    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public transferDelayEnabled = true;

    event FeeUpdated(uint256 buyFee, uint256 sellFee);
    event MaxTxAmountUpdated(uint256 maxTxAmount);
    event MaxWalletSizeUpdated(uint256 maxWalletSize);
    event TaxSwapThresholdUpdated(uint256 newThreshold);
    event TransferDelayUpdated(bool transferDelayEnabled);
    event TradingOpened();
    event StuckETHCleared(uint256 amount);
    event StuckTokensCleared(address indexed tokenAddress, uint256 amount);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     * @dev Initializes the GAMO token contract.
     * @param taxWallet The address of the wallet to receive tax fees.
     */
    constructor (address taxWallet) {
        _taxWallet = payable(taxWallet);
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Gets the name of the GAMO token.
     * @return The name of the token.
     */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the symbol of the GAMO token.
     * @return The symbol of the token.
     */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Gets the number of decimals used for the GAMO token.
     * @return The number of decimals.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Gets the total supply of the GAMO token.
     * @return The total supply.
     */
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param account The address to query the balance of.
     * @return The balance of the specified address.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens from the sender to the recipient.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Gets the allowance granted by the owner to the spender for a specific amount.
     * @param owner The address granting the allowance.
     * @param spender The address receiving the allowance.
     * @return The remaining allowance for the spender.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves the spender to spend a certain amount of tokens on behalf of the owner.
     * @param spender The address to be approved.
     * @param amount The amount of tokens to approve.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Moves tokens from one address to another using the allowance mechanism.
     * @param sender The address to send tokens from.
     * @param recipient The address to receive tokens.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Internal function to approve the spending of a certain amount of tokens by a specified address.
     * @param owner The address granting the allowance.
     * @param spender The address receiving the allowance.
     * @param amount The amount of tokens to approve.
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Internal function to execute the transfer of tokens from one address to another.
     * @param from The address to send tokens from.
     * @param to The address to receive tokens.
     * @param amount The amount of tokens to transfer.
     */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "_transfer: Transfer amount must be greater than zero");

        uint256 taxAmount = 0;

        // Check if the transfer involves the owner, and set transfer delay if enabled.
        if (from != owner() && to != owner()) {
            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                    require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            // Check if the transfer is from the Uniswap pair and calculate buy fees.
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                taxAmount = amount.mul(_buyFee).div(100);
                require(amount <= _maxTxAmount, "_transfer: Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "_transfer: Exceeds the maxWalletSize.");
            }

            // Check if the transfer is to the Uniswap pair and calculate sell fees.
            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul(_sellFee).div(100);
            }

            // Check if a swap is needed and execute the swap.
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold) {
                if (amount >= _taxSwapThreshold) {
                    swapTokensForEth(_taxSwapThreshold);
                } else {
                    swapTokensForEth(amount);
                }
            }
        }

        // If there's a tax, transfer the tax amount to the contract.
        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        // Update balances after the transfer.
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    /**
     * @dev Internal function to swap tokens for ETH.
     * @param tokenAmount The amount of tokens to swap.
     */
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_taxWallet),
            block.timestamp
        );
    }

    /**
     * @dev Sets the buy fee percentage.
     * @param tax The new buy fee percentage (less than or equal to 25).
     */
    function setBuyfee(uint256 tax) external onlyOwner {
        require(tax <= 25, "setBuyfee: Tax should be less than or equal to 25");
        _buyFee = tax;
        emit FeeUpdated(_buyFee, _sellFee);
    }

    /**
     * @dev Sets the sell fee percentage.
     * @param tax The new sell fee percentage (less than or equal to 25).
     */
    function setSellFee(uint256 tax) external onlyOwner {
        require(tax <= 25, "setSellFee: Tax should be less than or equal to 25");
        _sellFee = tax;
        emit FeeUpdated(_buyFee, _sellFee);
    }

    /**
     * @dev Sets the maximum transfer amount as a percentage of the total supply.
     * @param percent The percentage of the total supply to set as the new maximum transfer amount (1 corresponds to 0.01%).
     */
    function setMaxTransferAmount(uint256 percent) external onlyOwner {
        require(percent <= 10000, "setMaxTransferAmount: Percentage should be less than or equal to 10000");
        _maxTxAmount = _totalSupply * percent / 10000;
        emit MaxTxAmountUpdated(_maxTxAmount);
    }

    /**
     * @dev Sets the maximum wallet size as a percentage of the total supply.
     * @param percent The percentage value to set the maximum wallet size (1 corresponds to 0.01%).
     * Only the owner can call this function.
     */
    function setMaxBalance(uint256 percent) external onlyOwner {
        require(percent <= 10000, "setMaxBalance: Percentage should be less than or equal to 10000");
        _maxWalletSize = _totalSupply * percent / 10000;
        emit MaxWalletSizeUpdated(_maxWalletSize);
    }

    /**
     * @dev Sets the threshold for swapping tokens to ETH.
     * @param percent The percentage of the total supply to set as the new threshold (1 corresponds to 0.01%).
     */
    function setTaxSwapThreshold(uint256 percent) external onlyOwner {
        require(percent <= 10000, "setTaxSwapThreshold: Percentage should be less than or equal to 10000");
        _taxSwapThreshold = _totalSupply * percent / 10000;
        emit TaxSwapThresholdUpdated(_taxSwapThreshold);
    }
    
    /**
     * @dev Removes transaction limits and disables transfer delay.
     * Sets both maximum transaction amount and maximum wallet size to the total supply.
     * Only the owner can call this function.
     */
    function removeLimits() external onlyOwner {
        _maxTxAmount = _totalSupply;
        _maxWalletSize = _totalSupply;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
        emit MaxWalletSizeUpdated(_totalSupply);
        emit TransferDelayUpdated(false);
    }

    /**
     * @dev Disables the transfer delay feature.
     * Only the owner can call this function.
     */
    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
        emit TransferDelayUpdated(false);
    }

    /**
    * @dev Clears all stuck ETH from the contract and transfers it to the owner.
    * Only the owner can call this function.
    */
    function clearStuckETH() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No stuck ETH to clear");

        payable(owner()).transfer(contractBalance);

        emit StuckETHCleared(contractBalance);
    }

    /**
    * @dev Clears all stuck tokens from the contract and transfers them to the owner.
    * Only the owner can call this function.
    * @param tokenAddress The address of the ERC-20 token to clear from the contract.
    */
    function clearStuckTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        require(contractTokenBalance > 0, "No stuck tokens to clear");

        token.transfer(owner(), contractTokenBalance);

        emit StuckTokensCleared(tokenAddress, contractTokenBalance);
    }

    /**
     * @dev Opens trading by initializing the Uniswap router, creating a pair,
     * adding liquidity, and enabling swapping on the contract.
     * Only the owner can call this function.
     */
    function openTrading() external onlyOwner() {
        require(!tradingOpen, "openTrading: Trading is already open");

        // Initialize the Uniswap router
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        // Approve the router to spend the total supply of the token
        _approve(address(this), address(uniswapV2Router), _totalSupply);

        // Create the Uniswap pair
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // Add liquidity to the Uniswap pair
        uniswapV2Router.addLiquidityETH{
            value: address(this).balance
        }(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        // Approve Uniswap router to spend the pair's tokens
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        // Enable swapping on the contract
        swapEnabled = true;

        // Set trading as open
        tradingOpen = true;
        emit TradingOpened();
    }

    /**
     * @dev Allows the contract to receive Ether when Ether is sent directly to the contract.
     */
    receive() external payable {}
}