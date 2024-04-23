/**
 *Submitted for verification at BscScan.com on 2023-05-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15; 

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(0x188Aaea282a5DDBb483d11EfBCd692E659a0514B);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract PoolERC is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 constant TOKEN = IERC20(0x55d398326f99059fF775485246999027B3197955); 
    bool public started;
    bool public depositPaused = false;
    bool public withdrawPaused = false;
    uint256 public totalInvestors = 0;
    uint256 public totalInvested = 0;
    uint256 public totalRewardsPaid = 0;

    uint256 constant EARLY_WITHDRAW_TIME = 45 days;
    uint256 constant EARLY_WITHDRAW_FEE = 500;
    uint256 constant CLAIM_COOLDOWN = 14 days;
    uint256 constant WITHDRAW_FEE = 100;
    uint256 constant REWARD_RATE = 8;
    uint256[5] public PERCENTAGES = [80, 60, 30, 20, 10];

    mapping(address => Stake) public stake;

    struct Stake {
        uint256 stake;
        uint256 unclaimedReward;
        uint256 timestamp;
        address partner;
        uint256 lockTimestamp;
        uint256 claimedRewards;
        uint256 claimLockTimestamp;
    }

    event PositionUpdate(address indexed user, address indexed partner, uint256 amount);

    modifier whenStarted {
        require(started, "Pool not started");
        _;
    }

    receive() external payable {}

    function start() external onlyOwner {
        started = true;
    }

    function deposit(address partner, uint256 amount) external whenStarted nonReentrant {
        require(!depositPaused, "Deposits are paused");
        require(amount > 0, "Deposit amount is 0");

        // Calculate deposit fee
        uint256 depositFee = (amount * 25) / 1000; // 2.5%

        // Transfer the adjusted amount (amount - depositFee) to the contract
        TOKEN.safeTransferFrom(_msgSender(), address(this), amount - depositFee);

        // Transfer the deposit fee to the owner
        TOKEN.safeTransfer(owner(), depositFee);

        // Update user's stake information
        _updateReward(_msgSender());
        stake[_msgSender()].stake += (amount - depositFee);
        totalInvested += (amount - depositFee);

        // Handle partner-related logic
        if (stake[_msgSender()].lockTimestamp == 0) {
            require(partner != _msgSender(), "Partner cannot be sender");
            stake[_msgSender()].partner = partner;
            totalInvestors += 1;
        }
        stake[_msgSender()].lockTimestamp = block.timestamp;

        emit PositionUpdate(_msgSender(), stake[_msgSender()].partner, stake[_msgSender()].stake);
    }

    function compoundRewards() external whenStarted nonReentrant {
        require(stake[_msgSender()].claimLockTimestamp + CLAIM_COOLDOWN < block.timestamp, "Claim cooldown");
        _updateReward(_msgSender());
        uint256 amount = stake[_msgSender()].unclaimedReward;
        require(amount > 0, "Rewards are 0");
        stake[_msgSender()].unclaimedReward = 0;
        stake[_msgSender()].stake += amount;
        stake[_msgSender()].claimedRewards += amount;
        stake[_msgSender()].claimLockTimestamp = block.timestamp;
        totalInvested += amount;
        emit PositionUpdate(_msgSender(), stake[_msgSender()].partner, stake[_msgSender()].stake);
    }

    function withdraw(uint256 amount) external whenStarted nonReentrant {
        require(!withdrawPaused, "Withdraw is paused");
        require(amount > 0, "Withdraw amount 0");
        _updateReward(_msgSender());
        require(amount <= stake[_msgSender()].stake, "Not enough balance");
        uint256 fee;
        if (stake[_msgSender()].lockTimestamp + EARLY_WITHDRAW_TIME >= block.timestamp) {
          fee = (amount * EARLY_WITHDRAW_FEE) / 1000;
        } else {
          fee = (amount * WITHDRAW_FEE) / 1000;
        }
        stake[_msgSender()].stake -= amount;
        totalInvested -= amount;
        TOKEN.safeTransfer(owner(), fee);
        TOKEN.safeTransfer(_msgSender(), amount - fee);
    }

    function pendingReward(address account) public view returns(uint256) {
        return ((stake[account].stake * ((block.timestamp - stake[account].timestamp) / 86400) * REWARD_RATE) / 1000);
    }

    function _updateReward(address account) private {
        uint256 pending = pendingReward(_msgSender());

        // Calculate performance fee
        uint256 performanceFee = (pending * 250) / 1000;

        stake[_msgSender()].timestamp = block.timestamp;
        stake[_msgSender()].unclaimedReward += pending - performanceFee;
        totalRewardsPaid += pending - performanceFee;
        _updatePartnerReward(stake[account].partner, pending);

        // Transfer the performance fee to the owner
        TOKEN.safeTransfer(owner(), performanceFee);

        emit PositionUpdate(_msgSender(), stake[_msgSender()].partner, stake[_msgSender()].stake);
    }


    function _updatePartnerReward(address account, uint256 value) private {
        if (value != 0) {
            for (uint8 i; i < 5; i++) {
                if (stake[account].stake == 0 || account == address(0)) {
                    break;
                }
                stake[account].unclaimedReward += ((value * PERCENTAGES[i]) / 1000);
                totalInvested += ((value * PERCENTAGES[i]) / 1000);
                totalRewardsPaid += ((value * PERCENTAGES[i]) / 1000);
                account = stake[account].partner;
            }
        }
    }


    function pauseDeposits() external onlyOwner {
        depositPaused = true;
    }

    function unpauseDeposits() external onlyOwner {
        depositPaused = false;
    }

    function pauseWithdraw() external onlyOwner {
        withdrawPaused = true;
    }

    function unpauseWithdraw() external onlyOwner {
        withdrawPaused = false;
    }

    function tradingTransfer(uint256 amount) external onlyOwner {
        uint256 contractBalance = TOKEN.balanceOf(address(this));
        amount = amount > contractBalance ? contractBalance : amount;
        TOKEN.safeTransfer(owner(), amount);
    }

    function getInvestmentData() external view returns (uint256,uint256,uint256) {
        return (totalInvested, totalInvestors, totalRewardsPaid);
    }
}