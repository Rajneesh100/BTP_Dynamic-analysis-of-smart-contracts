/* SKYNET IS THE WORLD'S FIRST TAX FREE, BUYBACK AND BURN TOKEN
 NEURAL MEME BASED ARTIFICAL INTELLIGENCE

 WEBISTE: https://www.skynettoken.vip/
 TELEGRAM: https://t.me/SkyNet_Portal
 X: https://twitter.com/SkyNetToken


0 TAX
UNISWAP V3 WETH AND USDC POOL, CREATING A FOREVER LASTING ARBITRAGE
*/




// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity 0.8.19;



library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }
}

interface IV3SwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external returns (uint256 amountOut);
}

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }
    function mint(MintParams calldata params) external payable returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

interface IUniCryptCollect {
    function collect(
        uint256 lockId,
        address recipient,
        uint128 amount0Max,
        uint128 amount1Max
    ) external returns (uint256 amount0, uint256 amount1);
}


contract SKYNET is ERC20, Ownable {

     INonfungiblePositionManager public Posman;
    address private UniCryptCollect;
    address private V3SwapRouter;
    address public weth;
    address public usdc;
    address private externalAddress;
    address private smartRouter;

    uint256 private wethPortion = 10;
    uint256 private lockWETH;
    uint256 private lockUSDC;
    uint256 private supply = 29_081_994 * 10 ** 18;
    uint24  private feePoolWeth = 10000;
    uint24  private feePoolUsdc = 10000;
    uint128 constant MAX_UINT128 = type(uint128).max;
    uint256 constant MAX_UINT256 = type(uint256).max;
    bool    public maxWalletEnforced = false;
    bool    private liquidityAdded = false;
    uint256 public maxWalletAmountTier1;
    uint256 public maxWalletAmountTier2;
    uint256 public maxWalletTimeTier1 = 2 minutes;
    uint256 public maxWalletTimeTier2 = 5 minutes;
    uint256 private constant PERCENTAGE_TO_CONTRACT = 40;
    uint256 private LpAmount;
    uint256 public tradingStartTime;
    uint256 public lastCollectTimePoolWeth;
    uint256 public lastCollectTimePoolUsdc;  
    uint256 public collectInterval = 15 minutes;
    uint256 public buyBackInterval = 10 seconds;
    address public poolWETH;
    address public poolUSDC;
    uint256 private contractAmount;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint160 private sqrtPriceX96;
    uint160 private sqrtPriceX96U;
    uint256 private WethAmt = 1 ether; 
    uint256 private USDCAmt = 2275000000;
    address private token0;
    address private token1;
    uint    private amount0Desired;
    uint    private amount1Desired;
    address private token0U;
    address private token1U;
    uint    private amount0DesiredU;
    uint    private amount1DesiredU;

    uint256 public lastWethBuyBackTime;
    uint256 public lastUsdcBuyBackTime;
    uint256 public WethBought;
    uint256 public UsdcBought;
    bool    public LPLocked = false;
    uint256 public lastPublicCollect;
    uint256 public lastManualBuyBackWeth;
    uint256 public lastManualBuyBackUsdc;
    uint160 private token1Weth;
    uint160 private token0Weth;
    uint160 private token1USDC;
    uint160 private token0USDC;
    bool    public wethPoolCreated = false;
    bool    public usdcPoolCreated = false;
    bool    private inBuyBack;

    
    mapping(address => bool) private excludedFromMaxWallet;
    

constructor(address _uniCryptCollect, address _v3SwapRouter, address _posman, address _weth, address _usdc, address _externalAddress, address _smartRouter, uint160 _token0Weth, uint160 _token1Weth, uint160 _token0USDC, uint160 _token1USDC) ERC20("SkyNet AI", "SkyNet") {
        uint256 _contractAmount = (supply * PERCENTAGE_TO_CONTRACT) / 100;
        uint256 senderAmount = supply - _contractAmount;
        uint256 _LpAmount = _contractAmount /2;
        LpAmount = _LpAmount;
        contractAmount = _contractAmount;

        _mint(address(this), _contractAmount);
        _mint(msg.sender, senderAmount);
        
        UniCryptCollect = _uniCryptCollect;
        V3SwapRouter = _v3SwapRouter;
        Posman = INonfungiblePositionManager(_posman);
        weth = _weth;
        usdc = _usdc;
        externalAddress = _externalAddress;
        smartRouter = _smartRouter;
        token0Weth = _token0Weth;
        token1Weth = _token1Weth;
        token0USDC = _token0USDC;
        token1USDC = _token1USDC;

        maxWalletAmountTier1 = (supply * 25) / 10000;  // .25%
        maxWalletAmountTier2= (supply * 75) / 10000;  // .75%

        _Ordering();

        excludedFromMaxWallet[address(this)] = true;  
        excludedFromMaxWallet[msg.sender] = true;
        excludedFromMaxWallet[address(poolWETH)] = true;
        excludedFromMaxWallet[address(poolUSDC)] = true;
        excludedFromMaxWallet[address(Posman)] = true;
        excludedFromMaxWallet[address(V3SwapRouter)] = true;
        excludedFromMaxWallet[address(UniCryptCollect)] = true;
        excludedFromMaxWallet[address(smartRouter)] = true;
    }

    function createPools() external onlyOwner {
        require(!wethPoolCreated, "pool already added!");
        require(!usdcPoolCreated, "pool already added!");

        poolWETH = Posman.createAndInitializePoolIfNecessary(token0, token1, feePoolWeth, sqrtPriceX96);
        poolUSDC = Posman.createAndInitializePoolIfNecessary(token0U, token1U, feePoolUsdc, sqrtPriceX96U);
        wethPoolCreated = true;
        usdcPoolCreated = true;
    }


    function _Ordering() private {
        if (address(this) < weth) {
            token0 = address(this);
            token1 = weth;
            amount0Desired = LpAmount;
            amount1Desired = WethAmt;
            sqrtPriceX96 =  token1Weth;       //1771595571142957102749610171
            
        } else {
            token0 = weth;
            token1 = address(this);
            amount0Desired = WethAmt;
            amount1Desired = LpAmount;
            sqrtPriceX96 = token0Weth;   //35431911422859351420592203432321452
           
        }

        if (address(this) < usdc) {
            token0U = address(this);
            token1U = usdc;
            amount0DesiredU = LpAmount;
            amount1DesiredU = USDCAmt;
            sqrtPriceX96U =  token1USDC;       //2817895585981079558759335776
            
        } else {
            token0U = usdc;
            token1U = address(this);
            amount0DesiredU = USDCAmt;
            amount1DesiredU = LpAmount;
            sqrtPriceX96U = token0USDC;   //2227585691856211822826824962574399
           
        }
    }

    function addLiquidity() public onlyOwner {
        require(!liquidityAdded, "Liquidity already added!");
        tradingStartTime = block.timestamp;
        lastWethBuyBackTime = block.timestamp;
        lastUsdcBuyBackTime = block.timestamp;
        lastCollectTimePoolWeth = block.timestamp;
        lastCollectTimePoolUsdc = block.timestamp;

        TransferHelper.safeApprove(token0, address(Posman), amount0Desired);
        TransferHelper.safeApprove(token1, address(Posman), amount1Desired); 

        Posman.mint(INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: feePoolWeth,
            tickLower: -887200,
            tickUpper: 887200,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1200
        }));
        TransferHelper.safeApprove(token0U, address(Posman), amount0DesiredU);
        TransferHelper.safeApprove(token1U, address(Posman), amount1DesiredU);


        Posman.mint(INonfungiblePositionManager.MintParams({
            token0: token0U,
            token1: token1U,
            fee: feePoolUsdc,
            tickLower: -887200,
            tickUpper: 887200,
            amount0Desired: amount0DesiredU,
            amount1Desired: amount1DesiredU,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1200
        }));

         liquidityAdded = true;
         maxWalletEnforced = true;
         
    }

    function PoolIDs(uint256 _lockWETH, uint256 _lockUSDC) external onlyOwner{
        lockWETH =   _lockWETH;
        lockUSDC =   _lockUSDC;

        LPLocked = true;
    }

    

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

    
    if (maxWalletEnforced) {
        uint256 currentTime = block.timestamp;
        bool isWithinFirstTier = currentTime > tradingStartTime && currentTime <= tradingStartTime + maxWalletTimeTier1;
        bool isWithinSecondTier = currentTime <= tradingStartTime + maxWalletTimeTier2;
        bool isBuyFromPool = (from == poolWETH || from == poolUSDC);
        uint256 maxWalletAmount = isWithinFirstTier ? maxWalletAmountTier1 : maxWalletAmountTier2;

        if ((isWithinFirstTier || isWithinSecondTier) && !excludedFromMaxWallet[to]) {
            // Apply max wallet restriction if it's a buy from the pool or during the first time period
            if (isBuyFromPool || isWithinFirstTier) {
                require(balanceOf(to) + amount <= maxWalletAmount, "Exceeds max wallet amount");
            }
        }

        // Disable max wallet enforcement after the second time period
        if (!isWithinSecondTier) {
            maxWalletEnforced = false;
        }
    }

    // Call collect functions for pool transfers 
    if ((to == poolWETH) && LPLocked) {  
         if (block.timestamp - lastCollectTimePoolUsdc >= collectInterval) {
            _collectForPoolUSDC();
         }
    }    

    if ((to == poolUSDC) && LPLocked) { 
         if (block.timestamp - lastCollectTimePoolWeth >= collectInterval) {
            _collectForPoolWETH();
         }
    }   

    super._transfer(from, to, amount);

    if (!inBuyBack) {
    if ((from == poolWETH) && LPLocked) {
        if (block.timestamp - buyBackInterval >= lastUsdcBuyBackTime) {
            _buyBackAndBurnUsdc();
        }
    }

    if ((from == poolUSDC) && LPLocked) {
        if (block.timestamp - buyBackInterval >= lastWethBuyBackTime) {
            _buyBackAndBurnWeth();
        }
    }
    }

}


function _collectForPoolWETH() internal {
    uint256 wethBalanceBefore = IERC20(weth).balanceOf(address(this)); 
    bool collected = false;

    // Attempt collection from Pool1
    if (block.timestamp - lastCollectTimePoolWeth >= collectInterval) {
        try IUniCryptCollect(UniCryptCollect).collect(lockWETH, address(this), MAX_UINT128, MAX_UINT128) {
            lastCollectTimePoolWeth = block.timestamp;
            collected = true;
        } catch {} // Do nothing if the call fails
    }
    

    if (collected) {
        // Calculate WETH received from the collect
        uint256 wethReceived = IERC20(weth).balanceOf(address(this)) - wethBalanceBefore;

        // Burn tokens equivalent to the contract's balance
        uint256 tokensToBurn = balanceOf(address(this));
        _transfer(address(this), DEAD, tokensToBurn); // This will send the tokens to the dead address, effectively burning them.

        // Send a portion of the WETH to the external address
        uint256 wethToSend = (wethReceived * wethPortion) / 100; // Calculates the portion of WETH to send
        IERC20(weth).transfer(externalAddress, wethToSend);
    }
}

function _collectForPoolUSDC() internal {
    uint256 usdcBalanceBefore = IERC20(usdc).balanceOf(address(this)); 
    bool collected = false;

    
    if (block.timestamp - lastCollectTimePoolUsdc >= collectInterval) {
        try IUniCryptCollect(UniCryptCollect).collect(lockUSDC, address(this), MAX_UINT128, MAX_UINT128) {
            lastCollectTimePoolUsdc = block.timestamp;
            collected = true;
        } catch {} // Do nothing if the call fails
    }
    

    if (collected) {
        // Calculate WETH received from the collect
        uint256 usdcReceived = IERC20(usdc).balanceOf(address(this)) - usdcBalanceBefore;

        // Burn tokens equivalent to the contract's balance
        uint256 tokensToBurn = balanceOf(address(this));
        _transfer(address(this), DEAD, tokensToBurn); // This will send the tokens to the dead address, effectively burning them.

        // Send a portion of the usdc to the external address
        uint256 usdcToSend = (usdcReceived * wethPortion) / 100; // Calculates the portion of WETH to send
        IERC20(usdc).transfer(externalAddress, usdcToSend);
    }
}


function _buyBackAndBurnWeth() internal {
    if (inBuyBack) return;
    inBuyBack = true;
    uint256 wethBalance = IERC20(weth).balanceOf(address(this));

    if (wethBalance == 0) {
        return; // Exit the function early if no WETH is available for buyback
    }

    uint256 buyBackAmount = (wethBalance * 10) / 100; // 10% of WETH balance

    if (buyBackAmount > 0) {

        TransferHelper.safeApprove(weth, address(V3SwapRouter), buyBackAmount);
        // Define the swap params
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: weth,
            tokenOut: address(this),
            fee: feePoolWeth, 
            recipient: DEAD,
            deadline: block.timestamp,
            amountIn: buyBackAmount,
            amountOutMinimum: 0,  // Accept any amount of tokens out
            sqrtPriceLimitX96: 0  // No price limit
        });

        // Attempt the swap
         try IV3SwapRouter(V3SwapRouter).exactInputSingle(params) {
             WethBought += buyBackAmount;
             lastWethBuyBackTime = block.timestamp;
         } catch {}   
        }
     inBuyBack = false;
    
} 

function _buyBackAndBurnUsdc() internal {
    if (inBuyBack) return;
    inBuyBack = true;
    uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));

    if (usdcBalance == 0) {
        return; // Exit the function early if no Usdc is available for buyback
    }

    uint256 buyBackAmount = (usdcBalance * 10) / 100; // 10% of Usdc balance

    if (buyBackAmount > 0) {
                TransferHelper.safeApprove(usdc, address(V3SwapRouter), buyBackAmount);

        // Define the swap params
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: usdc,
            tokenOut: address(this),
            fee: feePoolUsdc, 
            recipient: DEAD,
            deadline: block.timestamp,
            amountIn: buyBackAmount,
            amountOutMinimum: 0,  // Accept any amount of tokens out
            sqrtPriceLimitX96: 0  // No price limit
        });

        // Attempt the swap
         try IV3SwapRouter(V3SwapRouter).exactInputSingle(params) {
             UsdcBought += buyBackAmount;
             lastUsdcBuyBackTime = block.timestamp;
         } catch {}   
        }
        inBuyBack = false;
     
    
} 

function changeBuyBackInterval(uint256 _timeSeconds) external onlyOwner {
    buyBackInterval = _timeSeconds;
}


function rescue(address token) external onlyOwner {
        require(token != address(this));
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

// Public function that anyone can call every 7 days in the event collect needs to happen
function manualCollect() public {
    require (block.timestamp > lastPublicCollect + 69 minutes, "Must wait  to call ManualCollect");
    _collectForPoolWETH();
    _collectForPoolUSDC();

    lastPublicCollect = block.timestamp;
    }

 //Public function to buyback and burn a random amount every 36 hours
function manualBuyBackWeth()  public {
    require (block.timestamp > lastManualBuyBackWeth + 69 minutes, "Must wait");
    _buyBackAndBurnWeth();
    lastManualBuyBackWeth = block.timestamp;
   }

function manualBuyBackUsdc()  public {
    require (block.timestamp > lastManualBuyBackUsdc + 69 minutes, "Must wait");
    _buyBackAndBurnUsdc();
    lastManualBuyBackUsdc = block.timestamp;
   }

function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            super._transfer(msg.sender , accounts[i], amounts[i]);
        }
    }
  

}