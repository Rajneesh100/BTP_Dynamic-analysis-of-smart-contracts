// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: ENOTOKEN/staking.sol


pragma solidity 0.8.23;




contract ENOStaking is Ownable, ReentrancyGuard {
    IERC20 public stakingToken;

    struct StakingInfo {
        uint amount;
        uint endTime;
        uint32 multiplier;
    }

    struct Multipliers {
        uint32 oneMonth;
        uint32 threeMonths;
        uint32 sixMonths;
        uint32 twelveMonths;
        uint32 twentyFourMonths;
        uint32 fortyEightMonths;
    }

    Multipliers public multipliers;
    uint public totalCommitted;
    bool public isPaused;

    mapping(address => StakingInfo[]) public stakings;
    mapping(uint => uint32) public multiplierMapping;

    event Staked(address indexed user, uint amount, uint months, uint32 multiplier);
    event Withdrawn(address indexed user, uint amount);

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor(address _stakingTokenAddress) {
        stakingToken = IERC20(_stakingTokenAddress);
    }

    function setMultipliers(uint32 _oneMonth, uint32 _threeMonths, uint32 _sixMonths, uint32 _twelveMonths, uint32 _twentyFourMonths, uint32 _fortyEightMonths) public onlyOwner {
        multipliers = Multipliers(_oneMonth, _threeMonths, _sixMonths, _twelveMonths, _twentyFourMonths, _fortyEightMonths);
        multiplierMapping[1] = _oneMonth;
        multiplierMapping[3] = _threeMonths;
        multiplierMapping[6] = _sixMonths;
        multiplierMapping[12] = _twelveMonths;
        multiplierMapping[24] = _twentyFourMonths;
        multiplierMapping[48] = _fortyEightMonths;
    }

    function updateOneMonthMultiplier(uint32 _oneMonth) public onlyOwner {
        multipliers.oneMonth = _oneMonth;
        multiplierMapping[1] = _oneMonth;
    }

    function updateThreeMonthsMultiplier(uint32 _threeMonths) public onlyOwner {
        multipliers.threeMonths = _threeMonths;
        multiplierMapping[3] = _threeMonths;
    }

    function updateSixMonthsMultiplier(uint32 _sixMonths) public onlyOwner {
        multipliers.sixMonths = _sixMonths;
        multiplierMapping[6] = _sixMonths;
    }

    function updateTwelveMonthsMultiplier(uint32 _twelveMonths) public onlyOwner {
        multipliers.twelveMonths = _twelveMonths;
        multiplierMapping[12] = _twelveMonths;
    }

    function updateTwentyFourMonthsMultiplier(uint32 _twentyFourMonths) public onlyOwner {
        multipliers.twentyFourMonths = _twentyFourMonths;
        multiplierMapping[24] = _twentyFourMonths;
    }

    function updateFortyEightMonthsMultiplier(uint32 _fortyEightMonths) public onlyOwner {
        multipliers.fortyEightMonths = _fortyEightMonths;
        multiplierMapping[48] = _fortyEightMonths;
    }

    function pauseContract() external onlyOwner {
        isPaused = true;
    }

    function unpauseContract() external onlyOwner {
        isPaused = false;
    }

    function stake(uint _amount, uint _months) public whenNotPaused{
        require(_months == 1 || _months == 3 || _months == 6 || _months == 12 || _months == 24 || _months == 48, "Invalid staking duration");
        require(_amount > 0, "Invalid staking amount");

        uint32 multiplier = getMultiplier(_months);
        uint finalAmount = _amount * multiplier / 10000;
        require(stakingToken.balanceOf(address(this)) >= totalCommitted + finalAmount, "Insufficient funds in contract");

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        stakings[msg.sender].push(StakingInfo(_amount, block.timestamp + _months * 30 days, multiplier));
        totalCommitted += finalAmount;
	
	    emit Staked(msg.sender, _amount, _months, multiplier);
    }

    function withdraw(uint _index) public nonReentrant whenNotPaused{
        require(_index < stakings[msg.sender].length, "Invalid stake index");

        StakingInfo storage info = stakings[msg.sender][_index];
        require(block.timestamp >= info.endTime, "Staking period not yet completed");

        uint finalAmount = info.amount * info.multiplier / 10000;
        stakingToken.transfer(msg.sender, finalAmount);

        totalCommitted -= finalAmount;

        stakings[msg.sender][_index] = stakings[msg.sender][stakings[msg.sender].length - 1];
        stakings[msg.sender].pop();
	
	    emit Withdrawn(msg.sender, finalAmount);
    }

    function getStakes(address _owner) public view returns (StakingInfo[] memory) {
        return stakings[_owner];
    }

    function getMultiplier(uint _months) internal view returns (uint32) {
        require(multiplierMapping[_months] > 0, "Invalid staking duration");
        return multiplierMapping[_months];
    }

    function getContractBalance() public view returns (uint) {
        return stakingToken.balanceOf(address(this));
    }
    
    function getTotalStakedByUser(address _user) public view returns (uint) {
        uint totalStaked = 0;
        for (uint i = 0; i < stakings[_user].length; i++) {
            totalStaked += stakings[_user][i].amount;
        }
        return totalStaked;
    }

    function getActiveStakingsCount(address _user) public view returns (uint) {
        return stakings[_user].length;
    }

}