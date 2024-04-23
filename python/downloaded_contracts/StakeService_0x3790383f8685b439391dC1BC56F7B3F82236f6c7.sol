// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

/// @title Structures used in the LiquidityMining.
library LiquidityMiningTypes {
    /// @title Struct pair representing delegated pwToken balance
    struct DelegatedPwTokenBalance {
        /// @notice lpToken address
        address lpToken;
        /// @notice The amount of Power Token delegated to lpToken staking pool
        /// @dev value represented in 18 decimals
        uint256 pwTokenAmount;
    }

    /// @title Global indicators used in rewards calculation.
    struct GlobalRewardsIndicators {
        /// @notice powerUp indicator aggregated
        /// @dev It can be changed many times during transaction, represented with 18 decimals
        uint256 aggregatedPowerUp;
        /// @notice composite multiplier in a block described in field blockNumber
        /// @dev It can be changed many times during transaction, represented with 27 decimals
        uint128 compositeMultiplierInTheBlock;
        /// @notice Composite multiplier updated in block {blockNumber} but calculated for PREVIOUS (!) block.
        /// @dev It can be changed once per block, represented with 27 decimals
        uint128 compositeMultiplierCumulativePrevBlock;
        /// @dev It can be changed once per block. Block number in which all other params of this structure are updated
        uint32 blockNumber;
        /// @notice value describing amount of rewards issued per block,
        /// @dev It can be changed at most once per block, represented with 8 decimals
        uint32 rewardsPerBlock;
        /// @notice amount of accrued rewards since inception
        /// @dev It can be changed at most once per block, represented with 18 decimals
        uint88 accruedRewards;
    }

    /// @title Params recorded for a given account. These params are used by the algorithm responsible for rewards distribution.
    /// @dev The structure in storage is updated when account interacts with the LiquidityMining smart contract (stake, unstake, delegate, undelegate, claim)
    struct AccountRewardsIndicators {
        /// @notice `composite multiplier cumulative` is calculated for previous block
        /// @dev represented in 27 decimals
        uint128 compositeMultiplierCumulativePrevBlock;
        /// @notice lpToken account's balance
        uint128 lpTokenBalance;
        /// @notive PowerUp is a result of logarithmic equastion,
        /// @dev  powerUp < 100 *10^18
        uint72 powerUp;
        /// @notice balance of Power Tokens delegated to LiquidityMining
        /// @dev delegatedPwTokenBalance < 10^26 < 2^87
        uint96 delegatedPwTokenBalance;
    }

    struct UpdateLpToken {
        address beneficiary;
        address lpToken;
        uint256 lpTokenAmount;
    }

    struct UpdatePwToken {
        address beneficiary;
        address lpToken;
        uint256 pwTokenAmount;
    }

    struct AccruedRewardsResult {
        address lpToken;
        uint256 rewardsAmount;
    }

    struct AccountRewardResult {
        address lpToken;
        uint256 rewardsAmount;
        uint256 allocatedPwTokens;
    }

    struct AccountIndicatorsResult {
        address lpToken;
        LiquidityMiningTypes.AccountRewardsIndicators indicators;
    }

    struct GlobalIndicatorsResult {
        address lpToken;
        LiquidityMiningTypes.GlobalRewardsIndicators indicators;
    }
}

/// @title The interface for interaction with the LiquidityMining.
/// LiquidityMining is responsible for the distribution of the Power Token rewards to accounts
/// staking lpTokens and / or delegating Power Tokens to LiquidityMining. LpTokens can be staked directly to the LiquidityMining,
/// Power Tokens are a staked version of the [Staked] Tokens minted by the PowerToken smart contract.
interface ILiquidityMining {
    /// @notice Contract ID. The keccak-256 hash of "io.ipor.LiquidityMining" decreased by 1
    /// @return Returns an ID of the contract
    function getContractId() external pure returns (bytes32);

    /// @notice Returns the balance of staked lpTokens
    /// @param account the account's address
    /// @param lpToken the address of lpToken
    /// @return balance of the lpTokens staked by the sender
    function balanceOf(address account, address lpToken) external view returns (uint256);

    /// @notice It returns the balance of delegated Power Tokens for a given `account` and the list of lpToken addresses.
    /// @param account address for which to fetch the information about balance of delegated Power Tokens
    /// @param lpTokens list of lpTokens addresses(lpTokens)
    /// @return balances list of {LiquidityMiningTypes.DelegatedPwTokenBalance} structure, with information how much Power Token is delegated per lpToken address.
    function balanceOfDelegatedPwToken(
        address account,
        address[] memory lpTokens
    ) external view returns (LiquidityMiningTypes.DelegatedPwTokenBalance[] memory balances);

    /// @notice Calculates the accrued rewards for multiple LP tokens.
    /// @param lpTokens An array of LP token addresses.
    /// @return An array of `AccruedRewardsResult` structures, containing the LP token address and the accrued rewards amount.
    function calculateAccruedRewards(
        address[] calldata lpTokens
    ) external view returns (LiquidityMiningTypes.AccruedRewardsResult[] memory);

    /// @notice Calculates the rewards earned by an account for multiple LP tokens.
    /// @param account The address of the account for which to calculate rewards.
    /// @param lpTokens An array of LP token addresses.
    /// @return An array of `AccountRewardResult` structures, containing the LP token address, rewards amount, and allocated Power Token balance for the account.
    function calculateAccountRewards(
        address account,
        address[] calldata lpTokens
    ) external view returns (LiquidityMiningTypes.AccountRewardResult[] memory);

    /// @notice method allowing to update the indicators per asset (lpToken).
    /// @param account of which we should update the indicators
    /// @param lpTokens of the staking pools to update the indicators
    function updateIndicators(address account, address[] calldata lpTokens) external;

    /// @notice Adds LP tokens to the liquidity mining for multiple accounts.
    /// @param updateLpToken An array of `UpdateLpToken` structures, each containing the account address,
    /// LP token address, and LP token amount to be added.
    function addLpTokensInternal(
        LiquidityMiningTypes.UpdateLpToken[] memory updateLpToken
    ) external;

    /// @notice Adds Power tokens to the liquidity mining for multiple accounts.
    /// @param updatePwToken An array of `UpdatePwToken` structures, each containing the account address,
    /// LP token address, and Power token amount to be added.
    function addPwTokensInternal(
        LiquidityMiningTypes.UpdatePwToken[] memory updatePwToken
    ) external;

    /// @notice Removes LP tokens from the liquidity mining for multiple accounts.
    /// @param updateLpToken An array of `UpdateLpToken` structures, each containing the account address,
    /// LP token address, and LP token amount to be removed.
    function removeLpTokensInternal(
        LiquidityMiningTypes.UpdateLpToken[] memory updateLpToken
    ) external;

    /// @notice Removes Power Tokens from the liquidity mining for multiple accounts.
    /// @param updatePwToken An array of `UpdatePwToken` structures, each containing the account address,
    /// LP token address, and Power Token amount to be removed.
    function removePwTokensInternal(
        LiquidityMiningTypes.UpdatePwToken[] memory updatePwToken
    ) external;

    /// @notice Claims accumulated rewards for multiple LP tokens and transfers them to the specified account.
    /// @param account The account address to claim rewards for.
    /// @param lpTokens An array of LP token addresses for which rewards will be claimed.
    /// @return rewardsAmountToTransfer The total amount of rewards transferred to the account.
    function claimInternal(
        address account,
        address[] calldata lpTokens
    ) external returns (uint256 rewardsAmountToTransfer);

    /// @notice Retrieves the global indicators for multiple LP tokens.
    /// @param lpTokens An array of LP token addresses for which to retrieve the global indicators.
    /// @return An array of LiquidityMiningTypes.GlobalIndicatorsResult containing the global indicators for each LP token.
    function getGlobalIndicators(
        address[] calldata lpTokens
    ) external view returns (LiquidityMiningTypes.GlobalIndicatorsResult[] memory);

    /// @notice Retrieves the account indicators for a specific account and multiple LP tokens.
    /// @param account The address of the account for which to retrieve the account indicators.
    /// @param lpTokens An array of LP token addresses for which to retrieve the account indicators.
    /// @return An array of LiquidityMiningTypes.AccountIndicatorsResult containing the account indicators for each LP token.
    function getAccountIndicators(
        address account,
        address[] calldata lpTokens
    ) external view returns (LiquidityMiningTypes.AccountIndicatorsResult[] memory);

    /// @notice Emitted when the account claims the rewards
    /// @param account Account's address in the context of which activities of claiming are performed
    /// @param lpTokens The addresses of the lpTokens for which the rewards are claimed
    /// @param rewardsAmount Reward amount denominated in pwToken, represented with 18 decimals
    event Claimed(address account, address[] lpTokens, uint256 rewardsAmount);

    /// @notice Emitted when update was triggered for the account on the lpToken
    /// @param account Account address to which the update was triggered
    /// @param lpToken lpToken address to which the update was triggered
    event IndicatorsUpdated(address account, address lpToken);

    /// @notice Emitted when the lpToken is added to the LiquidityMining
    /// @param beneficiary Account address on behalf of which the lpToken is added
    /// @param lpToken lpToken address which is added
    /// @param lpTokenAmount Amount of lpTokens added, represented with 18 decimals
    event LpTokenAdded(address beneficiary, address lpToken, uint256 lpTokenAmount);

    /// @notice Emitted when the lpToken is removed from the LiquidityMining
    /// @param account address on behalf of which the lpToken is removed
    /// @param lpToken lpToken address which is removed
    /// @param lpTokenAmount Amount of lpTokens removed, represented with 18 decimals
    event LpTokensRemoved(address account, address lpToken, uint256 lpTokenAmount);

    /// @notice Emitted when the PwTokens is added to lpToken pool
    /// @param beneficiary Account address on behalf of which the PwToken is added
    /// @param lpToken lpToken address to which the PwToken is added
    /// @param pwTokenAmount Amount of PwTokens added, represented with 18 decimals
    event PwTokensAdded(address beneficiary, address lpToken, uint256 pwTokenAmount);

    /// @notice Emitted when the PwTokens is removed from lpToken pool
    /// @param account Account address on behalf of which the PwToken is removed
    /// @param lpToken lpToken address from which the PwToken is removed
    /// @param pwTokenAmount Amount of PwTokens removed, represented with 18 decimals
    event PwTokensRemoved(address account, address lpToken, uint256 pwTokenAmount);
}

/// @title Struct used across Liquidity Mining.
library PowerTokenTypes {
    struct PwTokenCooldown {
        // @dev The timestamp when the account can redeem Power Tokens
        uint256 endTimestamp;
        // @dev The amount of Power Tokens which can be redeemed without fee when the cooldown reaches `endTimestamp`
        uint256 pwTokenAmount;
    }

    struct UpdateGovernanceToken {
        address beneficiary;
        uint256 governanceTokenAmount;
    }
}

/// @title The Interface for the interaction with the PowerToken - smart contract responsible
/// for managing Power Token (pwToken), Swapping Staked Token for Power Tokens, and
/// delegating Power Tokens to other components.
interface IPowerToken {
    /// @notice Gets the name of the Power Token
    /// @return Returns the name of the Power Token.
    function name() external pure returns (string memory);

    /// @notice Contract ID. The keccak-256 hash of "io.ipor.PowerToken" decreased by 1
    /// @return Returns the ID of the contract
    function getContractId() external pure returns (bytes32);

    /// @notice Gets the symbol of the Power Token.
    /// @return Returns the symbol of the Power Token.
    function symbol() external pure returns (string memory);

    /// @notice Returns the number of the decimals used by Power Token. By default it's 18 decimals.
    /// @return Returns the number of decimals: 18.
    function decimals() external pure returns (uint8);

    /// @notice Gets the total supply of the Power Token.
    /// @dev Value is calculated in runtime using baseTotalSupply and internal exchange rate.
    /// @return Total supply of Power tokens, represented with 18 decimals
    function totalSupply() external view returns (uint256);

    /// @notice Gets the balance of Power Tokens for a given account
    /// @param account account address for which the balance of Power Tokens is fetched
    /// @return Returns the amount of the Power Tokens owned by the `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Gets the delegated balance of the Power Tokens for a given account.
    /// Tokens are delegated from PowerToken to LiquidityMining smart contract (reponsible for rewards distribution).
    /// @param account account address for which the balance of delegated Power Tokens is checked
    /// @return  Returns the amount of the Power Tokens owned by the `account` and delegated to the LiquidityMining contracts.
    function delegatedToLiquidityMiningBalanceOf(address account) external view returns (uint256);

    /// @notice Gets the rate of the fee from the configuration. This fee is applied when the owner of Power Tokens wants to unstake them immediately.
    /// @dev Fee value represented in as a percentage with 18 decimals
    /// @return value, a percentage represented with 18 decimal
    function getUnstakeWithoutCooldownFee() external view returns (uint256);

    /// @notice Gets the state of the active cooldown for the sender.
    /// @dev If PowerTokenTypes.PowerTokenCoolDown contains only zeros it represents no active cool down.
    /// Struct containing information on when the cooldown end and what is the quantity of the Power Tokens locked.
    /// @param account account address that owns Power Tokens in the cooldown
    /// @return Object PowerTokenTypes.PowerTokenCoolDown represents active cool down
    function getActiveCooldown(
        address account
    ) external view returns (PowerTokenTypes.PwTokenCooldown memory);

    /// @notice Initiates a cooldown for the specified account.
    /// @dev This function allows an account to initiate a cooldown period for a specified amount of Power Tokens.
    ///      During the cooldown period, the specified amount of Power Tokens cannot be redeemed or transferred.
    /// @param account The account address for which the cooldown is initiated.
    /// @param pwTokenAmount The amount of Power Tokens to be put on cooldown.
    function cooldownInternal(address account, uint256 pwTokenAmount) external;

    /// @notice Cancels the cooldown for the specified account.
    /// @dev This function allows an account to cancel the active cooldown period for their Power Tokens,
    ///      enabling them to freely redeem or transfer their Power Tokens.
    /// @param account The account address for which the cooldown is to be canceled.
    function cancelCooldownInternal(address account) external;

    /// @notice Redeems Power Tokens for the specified account.
    /// @dev This function allows an account to redeem their Power Tokens, transferring the specified
    ///      amount of Power Tokens back to the account's staked token balance.
    ///      The redemption is subject to the cooldown period, and the account must wait for the cooldown
    ///      period to finish before being able to redeem the Power Tokens.
    /// @param account The account address for which Power Tokens are to be redeemed.
    /// @return transferAmount The amount of Power Tokens that have been redeemed and transferred back to the staked token balance.
    function redeemInternal(address account) external returns (uint256 transferAmount);

    /// @notice Adds staked tokens to the specified account.
    /// @dev This function allows the specified account to add staked tokens to their Power Token balance.
    ///      The staked tokens are converted to Power Tokens based on the internal exchange rate.
    /// @param updateGovernanceToken An object of type PowerTokenTypes.UpdateGovernanceToken containing the details of the staked token update.
    function addGovernanceTokenInternal(
        PowerTokenTypes.UpdateGovernanceToken memory updateGovernanceToken
    ) external;

    /// @notice Removes staked tokens from the specified account, applying a fee.
    /// @dev This function allows the specified account to remove staked tokens from their Power Token balance,
    ///      while deducting a fee from the staked token amount. The fee is determined based on the cooldown period.
    /// @param updateGovernanceToken An object of type PowerTokenTypes.UpdateGovernanceToken containing the details of the staked token update.
    /// @return governanceTokenAmountToTransfer The amount of staked tokens to be transferred after applying the fee.
    function removeGovernanceTokenWithFeeInternal(
        PowerTokenTypes.UpdateGovernanceToken memory updateGovernanceToken
    ) external returns (uint256 governanceTokenAmountToTransfer);

    /// @notice Delegates a specified amount of Power Tokens from the caller's balance to the Liquidity Mining contract.
    /// @dev This function allows the caller to delegate a specified amount of Power Tokens to the Liquidity Mining contract,
    ///      enabling them to participate in liquidity mining and earn rewards.
    /// @param account The address of the account delegating the Power Tokens.
    /// @param pwTokenAmount The amount of Power Tokens to delegate.
    function delegateInternal(address account, uint256 pwTokenAmount) external;

    /// @notice Undelegated a specified amount of Power Tokens from the Liquidity Mining contract back to the caller's balance.
    /// @dev This function allows the caller to undelegate a specified amount of Power Tokens from the Liquidity Mining contract,
    ///      effectively removing them from participation in liquidity mining and stopping the earning of rewards.
    /// @param account The address of the account to undelegate the Power Tokens from.
    /// @param pwTokenAmount The amount of Power Tokens to undelegate.
    function undelegateInternal(address account, uint256 pwTokenAmount) external;

    /// @notice Emitted when the account stake/add [Staked] Tokens
    /// @param account account address that executed the staking
    /// @param governanceTokenAmount of Staked Token amount being staked into PowerToken contract
    /// @param internalExchangeRate internal exchange rate used to calculate the base amount
    /// @param baseAmount value calculated based on the governanceTokenAmount and the internalExchangeRate
    event GovernanceTokenAdded(
        address indexed account,
        uint256 governanceTokenAmount,
        uint256 internalExchangeRate,
        uint256 baseAmount
    );

    /// @notice Emitted when the account unstakes the Power Tokens
    /// @param account address that executed the unstaking
    /// @param pwTokenAmount amount of Power Tokens that were unstaked
    /// @param internalExchangeRate which was used to calculate the base amount
    /// @param fee amount subtracted from the pwTokenAmount
    event GovernanceTokenRemovedWithFee(
        address indexed account,
        uint256 pwTokenAmount,
        uint256 internalExchangeRate,
        uint256 fee
    );

    /// @notice Emitted when the sender delegates the Power Tokens to the LiquidityMining contract
    /// @param account address delegating the Power Tokens
    /// @param pwTokenAmounts amounts of Power Tokens delegated to respective lpTokens
    event Delegated(address indexed account, uint256 pwTokenAmounts);

    /// @notice Emitted when the sender undelegates Power Tokens from the LiquidityMining
    /// @param account address undelegating Power Tokens
    /// @param pwTokenAmounts amounts of Power Tokens undelegated form respective lpTokens
    event Undelegated(address indexed account, uint256 pwTokenAmounts);

    /// @notice Emitted when the sender sets the cooldown on Power Tokens
    /// @param pwTokenAmount amount of pwToken in cooldown
    /// @param endTimestamp end time of the cooldown
    event CooldownChanged(uint256 pwTokenAmount, uint256 endTimestamp);

    /// @notice Emitted when the sender redeems the pwTokens after the cooldown
    /// @param account address that executed the redeem function
    /// @param pwTokenAmount amount of the pwTokens that was transferred to the Power Token owner's address
    event Redeem(address indexed account, uint256 pwTokenAmount);
}

interface IPowerTokenStakeService {
    /// @notice Stakes the specified amounts of LP tokens into the LiquidityMining contract.
    /// @dev This function allows the caller to stake their LP tokens on behalf of another address (`beneficiary`).
    /// @param beneficiary The address on behalf of which the LP tokens are being staked.
    /// @param lpTokens An array of LP token addresses to be staked.
    /// @param lpTokenMaxAmounts An array of corresponding LP token amounts to be staked which represent maximal amount
    /// to stake if balance of sender is lower this balance is transferred, represented with 18 decimals.
    /// @dev Both `lpTokens` and `lpTokenAmounts` arrays must have the same length.
    /// @dev The `beneficiary` address must not be the zero address.
    /// @dev The function ensures that the provided LP token addresses are valid and the amounts to be staked are greater than zero.
    /// @dev The function transfers the LP tokens from the caller's address to the LiquidityMining contract.
    /// @dev Finally, the function calls the `addLpTokens` function of the LiquidityMining contract to update the staked LP tokens.
    /// @dev Reverts if any of the requirements is not met or if the transfer of LP tokens fails.
    function stakeLpTokensToLiquidityMining(
        address beneficiary,
        address[] calldata lpTokens,
        uint256[] calldata lpTokenMaxAmounts
    ) external;

    /// @notice Unstakes the specified amounts of LP tokens from the LiquidityMining contract and transfers them to the specified address.
    /// @param transferTo The address to which the unstaked LP tokens will be transferred.
    /// @param lpTokens An array of LP token addresses to be unstaked.
    /// @param lpTokenAmounts An array of corresponding LP token amounts to be unstaked, represented with 18 decimals.
    /// @dev Both `lpTokens` and `lpTokenAmounts` arrays must have the same length.
    /// @dev The function ensures that the provided LP token addresses are valid and the amounts to be unstaked are greater than zero.
    /// @dev The function calls the `removeLpTokens` function of the LiquidityMining contract to update the unstaked LP tokens.
    /// @dev Finally, the function transfers the unstaked LP tokens from the LiquidityMining contract to the specified address.
    /// @dev Reverts if any of the requirements is not met or if the transfer of LP tokens fails.
    function unstakeLpTokensFromLiquidityMining(
        address transferTo,
        address[] calldata lpTokens,
        uint256[] calldata lpTokenAmounts
    ) external;

    /// @notice Stakes the specified amount of IPOR tokens on behalf of the specified address.
    /// @param beneficiary The address on whose behalf the IPOR tokens will be staked.
    /// @param iporTokenAmount The amount of IPOR tokens to be staked, represented with 18 decimals.
    /// @dev The function ensures that the provided `beneficiary` address is valid and the `iporTokenAmount` is greater than zero.
    /// @dev The function calls the `addGovernanceToken` function of the PowerToken contract to update the staked IPOR tokens.
    /// @dev Finally, the function transfers the IPOR tokens from the sender to the PowerToken contract for staking.
    /// @dev Reverts if any of the requirements is not met or if the transfer of IPOR tokens fails.
    function stakeGovernanceTokenToPowerToken(
        address beneficiary,
        uint256 iporTokenAmount
    ) external;

    /// @notice Stakes a specified amount of governance tokens and delegates power tokens to a specific beneficiary.
    /// @param beneficiary The address on whose behalf the governance tokens will be staked and power tokens will be delegated.
    /// @param governanceTokenAmount The amount of governance tokens to be staked, represented with 18 decimals.
    /// @param lpTokens An array of addresses representing the liquidity pool tokens.
    /// @param pwTokenAmounts An array of amounts of power tokens to be delegated corresponding to each liquidity pool token.
    /// @dev The function ensures that the `beneficiary` address is valid and the `governanceTokenAmount` is greater than zero.
    /// @dev The function also requires that the length of the `lpTokens` array is equal to the length of the `pwTokenAmounts` array.
    /// @dev For each liquidity pool token in `lpTokens`, the function creates an `UpdatePwToken` structure to be used for updating the power tokens in the Liquidity Mining contract.
    /// @dev The function checks if the total amount of power tokens to be delegated is less or equal to the amount of staked governance tokens.
    /// @dev The function calls the `addGovernanceTokenInternal` function of the PowerToken contract to update the staked governance tokens for the `beneficiary`.
    /// @dev The function transfers the governance tokens from the sender to the PowerToken contract for staking.
    /// @dev The function calls the `delegateInternal` function of the PowerToken contract to delegate power tokens to the `beneficiary`.
    /// @dev Finally, the function calls the `addPwTokensInternal` function of the Liquidity Mining contract to update the staked power tokens.
    /// @dev Reverts if any of the requirements is not met or if the transfer of governance tokens fails.
    function stakeGovernanceTokenToPowerTokenAndDelegate(
        address beneficiary,
        uint256 governanceTokenAmount,
        address[] calldata lpTokens,
        uint256[] calldata pwTokenAmounts
    ) external;

    /// @notice Unstakes the specified amount of IPOR tokens and transfers them to the specified address.
    /// @param transferTo The address to which the unstaked IPOR tokens will be transferred.
    /// @param iporTokenAmount The amount of IPOR tokens to be unstaked, represented with 18 decimals.
    /// @dev The function ensures that the `iporTokenAmount` is greater than zero.
    /// @dev The function calls the `removeGovernanceTokenWithFee` function of the PowerToken contract to remove the staked IPOR tokens.
    /// @dev Finally, the function transfers the corresponding staked token amount to the `transferTo` address.
    /// @dev Reverts if the `iporTokenAmount` is not greater than zero, or if the transfer of staked tokens fails.
    function unstakeGovernanceTokenFromPowerToken(
        address transferTo,
        uint256 iporTokenAmount
    ) external;

    /// @notice Initiates a cooldown period for the specified amount of Power Tokens.
    /// @param pwTokenAmount The amount of Power Tokens to be put into cooldown, represented with 18 decimals.
    /// @dev The function ensures that the `pwTokenAmount` is greater than zero.
    /// @dev The function calls the `cooldown` function of the PowerToken contract to initiate the cooldown.
    /// @dev Reverts if the `pwTokenAmount` is not greater than zero.
    function pwTokenCooldown(uint256 pwTokenAmount) external;

    /// @notice Cancels the active cooldown for the sender.
    /// @dev The function calls the `cancelCooldown` function of the PowerToken contract to cancel the cooldown.
    function pwTokenCancelCooldown() external;

    /// @notice Redeems Power Tokens and transfers the corresponding Staked Tokens to the specified address.
    /// @dev The function calls the `redeem` function of the PowerToken contract to redeem Power Tokens.
    /// @param transferTo The address to which the Staked Tokens will be transferred.
    function redeemPwToken(address transferTo) external;
}

library Errors {
    /// @notice Error thrown when the lpToken address is not supported
    /// @dev List of supported LpTokens is defined in {LiquidityMining._lpTokens}
    string public constant LP_TOKEN_NOT_SUPPORTED = "PT_701";
    /// @notice Error thrown when the caller / msgSender is not a Pause Manager address.
    /// @dev Pause Manager can be defined by the smart contract's Onwer
    string public constant CALLER_NOT_PAUSE_MANAGER = "PT_704";
    /// @notice Error thrown when the account's base balance is too low
    string public constant ACCOUNT_BASE_BALANCE_IS_TOO_LOW = "PT_705";
    /// @notice Error thrown when the account's Lp Token balance is too low
    string public constant ACCOUNT_LP_TOKEN_BALANCE_IS_TOO_LOW = "PT_706";
    /// @notice Error thrown when the account's delegated balance is too low
    string public constant ACC_DELEGATED_TO_LIQUIDITY_MINING_BALANCE_IS_TOO_LOW = "PT_707";
    /// @notice Error thrown when the account's available Power Token balance is too low
    string public constant ACC_AVAILABLE_POWER_TOKEN_BALANCE_IS_TOO_LOW = "PT_708";
    /// @notice Error thrown when the account doesn't have the rewards (Staked Tokens / Power Tokens) to claim
    string public constant NO_REWARDS_TO_CLAIM = "PT_709";
    /// @notice Error thrown when the cooldown is not finished.
    string public constant COOL_DOWN_NOT_FINISH = "PT_710";
    /// @notice Error thrown when the aggregate power up indicator is going to be negative during the calculation.
    string public constant AGGREGATE_POWER_UP_COULD_NOT_BE_NEGATIVE = "PT_711";
    /// @notice Error thrown when the block number used in the function is lower than previous block number stored in the liquidity mining indicators.
    string public constant BLOCK_NUMBER_LOWER_THAN_PREVIOUS_BLOCK_NUMBER = "PT_712";
    /// @notice Account Composite Multiplier indicator is greater or equal to Composit Multiplier indicator, but it should be lower or equal
    string public constant ACCOUNT_COMPOSITE_MULTIPLIER_GT_COMPOSITE_MULTIPLIER = "PT_713";
    /// @notice The fee for unstacking of Power Tokens should be number between (0, 1e18)
    string public constant UNSTAKE_WITHOUT_COOLDOWN_FEE_IS_TO_HIGH = "PT_714";
    /// @notice General problem, address is wrong
    string public constant WRONG_ADDRESS = "PT_715";
    /// @notice General problem, contract is wrong
    string public constant WRONG_CONTRACT_ID = "PT_716";
    /// @notice Value not greater than zero
    string public constant VALUE_NOT_GREATER_THAN_ZERO = "PT_717";
    /// @notice Appeared when input of two arrays length mismatch
    string public constant INPUT_ARRAYS_LENGTH_MISMATCH = "PT_718";
    /// @notice msg.sender is not an appointed owner, it cannot confirm their ownership
    string public constant SENDER_NOT_APPOINTED_OWNER = "PT_719";
    /// @notice msg.sender is not an appointed owner, it cannot confirm their ownership
    string public constant ROUTER_INVALID_SIGNATURE = "PT_720";
    string public constant INPUT_ARRAYS_EMPTY = "PT_721";
    string public constant CALLER_NOT_ROUTER = "PT_722";
    string public constant CALLER_NOT_GUARDIAN = "PT_723";
    string public constant CONTRACT_PAUSED = "PT_724";
    string public constant REENTRANCY = "PT_725";
    string public constant CALLER_NOT_OWNER = "PT_726";
}

library ContractValidator {
    function checkAddress(address addr) internal pure returns (address) {
        require(addr != address(0), Errors.WRONG_ADDRESS);
        return addr;
    }
}

/// @dev It is not recommended to use service contract directly, should be used only through router (like IporProtocolRouter or PowerTokenRouter)
contract StakeService is IPowerTokenStakeService {
    using ContractValidator for address;
    using SafeERC20 for IERC20;

    address public immutable liquidityMining;
    address public immutable powerToken;
    address public immutable governanceToken;

    constructor(
        address liquidityMiningInput,
        address powerTokenInput,
        address governanceTokenInput
    ) {
        liquidityMining = liquidityMiningInput.checkAddress();
        powerToken = powerTokenInput.checkAddress();
        governanceToken = governanceTokenInput.checkAddress();
    }

    function getConfiguration()
        external
        view
        returns (
            address liquidityMiningAddress,
            address powerTokenAddress,
            address governanceTokenAddress
        )
    {
        return (liquidityMining, powerToken, governanceToken);
    }

    function stakeLpTokensToLiquidityMining(
        address beneficiary,
        address[] calldata lpTokens,
        uint256[] calldata lpTokenMaxAmounts
    ) external {
        uint256 lpTokensLength = lpTokens.length;
        require(lpTokensLength == lpTokenMaxAmounts.length, Errors.INPUT_ARRAYS_LENGTH_MISMATCH);
        require(lpTokensLength > 0, Errors.INPUT_ARRAYS_EMPTY);
        require(beneficiary != address(0), Errors.WRONG_ADDRESS);
        LiquidityMiningTypes.UpdateLpToken[]
            memory updateLpTokens = new LiquidityMiningTypes.UpdateLpToken[](lpTokensLength);

        uint256 senderBalance;
        uint256 transferAmount;
        for (uint256 i; i != lpTokensLength; ) {
            require(lpTokens[i] != address(0), Errors.WRONG_ADDRESS);
            senderBalance = IERC20(lpTokens[i]).balanceOf(msg.sender);
            transferAmount = senderBalance < lpTokenMaxAmounts[i]
                ? senderBalance
                : lpTokenMaxAmounts[i];
            require(transferAmount > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);

            IERC20(lpTokens[i]).safeTransferFrom(msg.sender, liquidityMining, transferAmount);
            updateLpTokens[i] = LiquidityMiningTypes.UpdateLpToken(
                beneficiary,
                lpTokens[i],
                transferAmount
            );

            unchecked {
                ++i;
            }
        }

        ILiquidityMining(liquidityMining).addLpTokensInternal(updateLpTokens);
    }

    function unstakeLpTokensFromLiquidityMining(
        address transferTo,
        address[] calldata lpTokens,
        uint256[] calldata lpTokenAmounts
    ) external {
        uint256 lpTokensLength = lpTokens.length;
        require(lpTokensLength == lpTokenAmounts.length, Errors.INPUT_ARRAYS_LENGTH_MISMATCH);
        require(lpTokensLength > 0, Errors.INPUT_ARRAYS_EMPTY);
        LiquidityMiningTypes.UpdateLpToken[]
            memory updateLpTokens = new LiquidityMiningTypes.UpdateLpToken[](lpTokensLength);

        for (uint256 i; i != lpTokensLength; ) {
            require(lpTokens[i] != address(0), Errors.WRONG_ADDRESS);
            require(lpTokenAmounts[i] > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);

            updateLpTokens[i] = LiquidityMiningTypes.UpdateLpToken(
                msg.sender,
                lpTokens[i],
                lpTokenAmounts[i]
            );

            unchecked {
                ++i;
            }
        }

        ILiquidityMining(liquidityMining).removeLpTokensInternal(updateLpTokens);

        for (uint256 i; i != lpTokensLength; ) {
            IERC20(lpTokens[i]).safeTransferFrom(liquidityMining, transferTo, lpTokenAmounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function stakeGovernanceTokenToPowerToken(
        address beneficiary,
        uint256 governanceTokenAmount
    ) external {
        require(beneficiary != address(0), Errors.WRONG_ADDRESS);
        require(governanceTokenAmount > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);

        IPowerToken(powerToken).addGovernanceTokenInternal(
            PowerTokenTypes.UpdateGovernanceToken(beneficiary, governanceTokenAmount)
        );

        IERC20(governanceToken).safeTransferFrom(msg.sender, powerToken, governanceTokenAmount);
    }

    function stakeGovernanceTokenToPowerTokenAndDelegate(
        address beneficiary,
        uint256 governanceTokenAmount,
        address[] calldata lpTokens,
        uint256[] calldata pwTokenAmounts
    ) external {
        require(beneficiary != address(0), Errors.WRONG_ADDRESS);
        require(governanceTokenAmount > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);

        uint256 lpTokensLength = lpTokens.length;
        require(lpTokensLength == pwTokenAmounts.length, Errors.INPUT_ARRAYS_LENGTH_MISMATCH);
        require(lpTokensLength > 0, Errors.INPUT_ARRAYS_EMPTY);
        uint256 totalGovernanceTokenAmount;

        LiquidityMiningTypes.UpdatePwToken[]
            memory updatePwTokens = new LiquidityMiningTypes.UpdatePwToken[](lpTokensLength);

        for (uint256 i; i != lpTokensLength; ) {
            totalGovernanceTokenAmount += pwTokenAmounts[i];
            updatePwTokens[i] = LiquidityMiningTypes.UpdatePwToken(
                beneficiary,
                lpTokens[i],
                pwTokenAmounts[i]
            );
            unchecked {
                ++i;
            }
        }

        require(
            totalGovernanceTokenAmount <= governanceTokenAmount,
            Errors.ACC_DELEGATED_TO_LIQUIDITY_MINING_BALANCE_IS_TOO_LOW
        );
        IPowerToken(powerToken).addGovernanceTokenInternal(
            PowerTokenTypes.UpdateGovernanceToken(beneficiary, governanceTokenAmount)
        );
        IERC20(governanceToken).safeTransferFrom(msg.sender, powerToken, governanceTokenAmount);
        IPowerToken(powerToken).delegateInternal(beneficiary, totalGovernanceTokenAmount);
        ILiquidityMining(liquidityMining).addPwTokensInternal(updatePwTokens);
    }

    function unstakeGovernanceTokenFromPowerToken(
        address transferTo,
        uint256 governanceTokenAmount
    ) external {
        require(governanceTokenAmount > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);

        uint256 governanceTokenAmountToTransfer = IPowerToken(powerToken)
            .removeGovernanceTokenWithFeeInternal(
                PowerTokenTypes.UpdateGovernanceToken(msg.sender, governanceTokenAmount)
            );

        IERC20(governanceToken).safeTransferFrom(
            powerToken,
            transferTo,
            governanceTokenAmountToTransfer
        );
    }

    function pwTokenCooldown(uint256 pwTokenAmount) external {
        require(pwTokenAmount > 0, Errors.VALUE_NOT_GREATER_THAN_ZERO);
        IPowerToken(powerToken).cooldownInternal(msg.sender, pwTokenAmount);
    }

    function pwTokenCancelCooldown() external {
        IPowerToken(powerToken).cancelCooldownInternal(msg.sender);
    }

    function redeemPwToken(address transferTo) external {
        uint256 transferAmount = IPowerToken(powerToken).redeemInternal(msg.sender);
        ///@dev pwTokenAmount can be transfered because it is in relation 1:1 to Governace Token
        IERC20(governanceToken).safeTransferFrom(powerToken, transferTo, transferAmount);
    }
}
