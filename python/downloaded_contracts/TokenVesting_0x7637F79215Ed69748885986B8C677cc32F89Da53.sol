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

// File: ENOTOKEN/vesting.sol


pragma solidity 0.8.23;


interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenVesting is Ownable {
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 amountReleased;
        uint256 vestingStart;
        uint256 cliffDuration; 
        uint256 vestingDuration; 
        bool exists;
    }


    IERC20 public token;
    mapping(address => VestingSchedule) public vestingSchedules;
    address[] public beneficiaries;
    mapping(address => bool) public admins;
    bool public isPaused;
    uint256 public releaseInterval = 2592000; 

    event TokensClaimed(address indexed beneficiary, uint256 amount);
    event VestingAdded(address indexed beneficiary, uint256 totalAmount, uint256 vestingStart, uint256 cliffDuration, uint256 vestingDuration);

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not admin");
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor(address _tokenAddress, address[] memory _admins) {
        token = IERC20(_tokenAddress);
        for (uint256 i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    function setAdmin(address _admin, bool _status) external onlyOwner {
        admins[_admin] = _status;
    }

    function setVestingSchedule(address _beneficiary, uint256 _totalAmount, uint256 _vestingStart, uint256 _cliffDuration, uint256 _vestingDuration) external onlyOwner whenNotPaused {
        require(!vestingSchedules[_beneficiary].exists, "Vesting schedule already exists for this beneficiary");

        if (!vestingSchedules[_beneficiary].exists) {
            beneficiaries.push(_beneficiary);
        }

        vestingSchedules[_beneficiary] = VestingSchedule(_totalAmount, 0, _vestingStart, _cliffDuration, _vestingDuration, true);
        emit VestingAdded(_beneficiary, _totalAmount, _vestingStart, _cliffDuration, _vestingDuration);
    }

    function claimTokensForAllBeneficiaries() external onlyAdmin whenNotPaused {
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (vestingSchedules[beneficiaries[i]].exists) {
                _releaseTokens(beneficiaries[i]);
            }
        }
    }

    function _releaseTokens(address _beneficiary) internal {
        VestingSchedule storage schedule = vestingSchedules[_beneficiary];
        uint256 vestedAmount = _calculateVestedAmount(schedule);
        uint256 claimableAmount = vestedAmount - schedule.amountReleased;
        if (claimableAmount > 0) {
            schedule.amountReleased += claimableAmount;
            token.transfer(_beneficiary, claimableAmount);
            emit TokensClaimed(_beneficiary, claimableAmount);
        }
    }

    function _calculateVestedAmount(VestingSchedule memory schedule) private view returns (uint256) {
        if (block.timestamp < schedule.vestingStart + schedule.cliffDuration) {
            return 0;
        } else if (block.timestamp >= schedule.vestingStart + schedule.cliffDuration + schedule.vestingDuration) {
            return schedule.totalAmount;
        } else {
            uint256 timeElapsedSinceCliff = block.timestamp - (schedule.vestingStart + schedule.cliffDuration);
            uint256 completeIntervalsElapsed = timeElapsedSinceCliff / releaseInterval;
            uint256 totalIntervals = schedule.vestingDuration / releaseInterval;
            uint256 amountPerInterval = schedule.totalAmount / totalIntervals;
            return amountPerInterval * completeIntervalsElapsed;
        }
    }

    function pauseContract() external onlyOwner {
        isPaused = true;
    }

    function unpauseContract() external onlyOwner {
        isPaused = false;
    }

    function getAllBeneficiaries() public view returns (address[] memory) {
        return beneficiaries;
    }

    function getBeneficiaryDetails(address _beneficiary) public view returns (VestingSchedule memory) {
        require(vestingSchedules[_beneficiary].exists, "Beneficiary does not exist");
        return vestingSchedules[_beneficiary];
    }

}