// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;

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

/// @title Struct used across various interfaces in IPOR Protocol.
library IporTypes {
    /// @notice enum describing Swap's state, ACTIVE - when the swap is opened, INACTIVE when it's closed
    enum SwapState {
        INACTIVE,
        ACTIVE
    }

    /// @notice enum describing Swap's duration, 28 days, 60 days or 90 days
    enum SwapTenor {
        DAYS_28,
        DAYS_60,
        DAYS_90
    }

    /// @notice The struct describing the IPOR and its params calculated for the time when it was most recently updated and the change that took place since the update.
    /// Namely, the interest that would be computed into IBT should the rebalance occur.
    struct  AccruedIpor {
        /// @notice IPOR Index Value
        /// @dev value represented in 18 decimals
        uint256 indexValue;
        /// @notice IBT Price (IBT - Interest Bearing Token). For more information refer to the documentation:
        /// https://ipor-labs.gitbook.io/ipor-labs/interest-rate-derivatives/ibt
        /// @dev value represented in 18 decimals
        uint256 ibtPrice;
    }

    /// @notice Struct representing balances used internally for asset calculations
    /// @dev all balances in 18 decimals
    struct AmmBalancesMemory {
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Fixed & Receive Floating leg.
        uint256 totalCollateralPayFixed;
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Floating & Receive Fixed leg.
        uint256 totalCollateralReceiveFixed;
        /// @notice Liquidity Pool Balance. This balance is where the liquidity from liquidity providers and the opening fee are accounted for,
        /// @dev Amount of opening fee accounted in this balance is defined by _OPENING_FEE_FOR_TREASURY_PORTION_RATE param.
        uint256 liquidityPool;
        /// @notice Vault's balance, describes how much asset has been transferred to Asset Management Vault (AssetManagement)
        uint256 vault;
    }

    struct AmmBalancesForOpenSwapMemory {
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Fixed & Receive Floating leg.
        uint256 totalCollateralPayFixed;
        /// @notice Total notional amount of all swaps on  Pay Fixed leg (denominated in 18 decimals).
        uint256 totalNotionalPayFixed;
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Floating & Receive Fixed leg.
        uint256 totalCollateralReceiveFixed;
        /// @notice Total notional amount of all swaps on  Receive Fixed leg (denominated in 18 decimals).
        uint256 totalNotionalReceiveFixed;
        /// @notice Liquidity Pool Balance.
        uint256 liquidityPool;
    }

    struct SpreadInputs {
        //// @notice Swap's assets DAI/USDC/USDT
        address asset;
        /// @notice Swap's notional value
        uint256 swapNotional;
        /// @notice demand spread factor used in demand spread calculation
        uint256 demandSpreadFactor;
        /// @notice Base spread
        int256 baseSpreadPerLeg;
        /// @notice Swap's balance for Pay Fixed leg
        uint256 totalCollateralPayFixed;
        /// @notice Swap's balance for Receive Fixed leg
        uint256 totalCollateralReceiveFixed;
        /// @notice Liquidity Pool's Balance
        uint256 liquidityPoolBalance;
        /// @notice Ipor index value at the time of swap creation
        uint256 iporIndexValue;
        // @notice fixed rate cap for given leg for offered rate without demandSpread in 18 decimals
        uint256 fixedRateCapPerLeg;
    }
}

/// @title Interface of the CloseSwap Lens.
interface IAmmCloseSwapLens {
    /// @notice Structure representing the configuration of the AmmCloseSwapService for a given pool (asset).
    struct AmmCloseSwapServicePoolConfiguration {
        /// @notice asset address
        address asset;
        /// @notice asset decimals
        uint256 decimals;
        /// @notice Amm Storage contract address
        address ammStorage;
        /// @notice Amm Treasury contract address
        address ammTreasury;
        /// @notice Asset Management contract address, for stETH is empty, because stETH doesn't have asset management module
        address assetManagement;
        /// @notice Spread address, for USDT, USDC, DAI is a spread router address, for stETH is a spread address
        address spread;
        /// @notice Unwinding Fee Rate for unwinding the swap, represented in 18 decimals, 1e18 = 100%
        uint256 unwindingFeeRate;
        /// @notice Unwinding Fee Rate for unwinding the swap, part earmarked for the treasury, represented in 18 decimals, 1e18 = 100%
        uint256 unwindingFeeTreasuryPortionRate;
        /// @notice Max number of swaps (per leg) that can be liquidated in one call, represented without decimals
        uint256 maxLengthOfLiquidatedSwapsPerLeg;
        /// @notice Time before maturity when the community is allowed to close the swap, represented in seconds
        uint256 timeBeforeMaturityAllowedToCloseSwapByCommunity;
        /// @notice Time before maturity then the swap owner can close it, represented in seconds
        uint256 timeBeforeMaturityAllowedToCloseSwapByBuyer;
        /// @notice Min liquidation threshold allowing community to close the swap ahead of maturity, represented in 18 decimals
        uint256 minLiquidationThresholdToCloseBeforeMaturityByCommunity;
        /// @notice Min liquidation threshold allowing the owner to close the swap ahead of maturity, represented in 18 decimals
        uint256 minLiquidationThresholdToCloseBeforeMaturityByBuyer;
        /// @notice Min leverage of the virtual swap used in unwinding, represented in 18 decimals
        uint256 minLeverage;
        /// @notice Time after open swap when it is allowed to close swap with unwinding, represented in seconds
        uint256 timeAfterOpenAllowedToCloseSwapWithUnwinding;
    }

    /// @notice Returns the configuration of the AmmCloseSwapService for a given pool (asset).
    /// @param asset asset address
    /// @return AmmCloseSwapServicePoolConfiguration struct representing the configuration of the AmmCloseSwapService for a given pool (asset).
    function getAmmCloseSwapServicePoolConfiguration(
        address asset
    ) external view returns (AmmCloseSwapServicePoolConfiguration memory);

    /// @notice Returns the closing swap details for a given swap and closing timestamp.
    /// @param asset asset address
    /// @param account account address for which are returned closing swap details, for example closableStatus depends on the account
    /// @param direction swap direction
    /// @param swapId swap id
    /// @param closeTimestamp closing timestamp
    /// @param riskIndicatorsInput risk indicators input
    /// @return closingSwapDetails struct representing the closing swap details for a given swap and closing timestamp.
    function getClosingSwapDetails(
        address asset,
        address account,
        AmmTypes.SwapDirection direction,
        uint256 swapId,
        uint256 closeTimestamp,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) external view returns (AmmTypes.ClosingSwapDetails memory closingSwapDetails);
}

/// @title Types used in interfaces strictly related to AMM (Automated Market Maker).
/// @dev Used by IAmmTreasury and IAmmStorage interfaces.
library AmmTypes {
    /// @notice Struct describing AMM Pool's core addresses.
    struct AmmPoolCoreModel {
        /// @notice asset address
        address asset;
        /// @notice asset decimals
        uint256 assetDecimals;
        /// @notice ipToken address associated to the asset
        address ipToken;
        /// @notice AMM Storage address
        address ammStorage;
        /// @notice AMM Treasury address
        address ammTreasury;
        /// @notice Asset Management address
        address assetManagement;
        /// @notice IPOR Oracle address
        address iporOracle;
    }

    /// @notice Structure which represents Swap's data that will be saved in the storage.
    /// Refer to the documentation https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/ipor-swaps for more information.
    struct NewSwap {
        /// @notice Account / trader who opens the Swap
        address buyer;
        /// @notice Epoch timestamp of when position was opened by the trader.
        uint256 openTimestamp;
        /// @notice Swap's collateral amount.
        /// @dev value represented in 18 decimals
        uint256 collateral;
        /// @notice Swap's notional amount.
        /// @dev value represented in 18 decimals
        uint256 notional;
        /// @notice Quantity of Interest Bearing Token (IBT) at moment when position was opened.
        /// @dev value represented in 18 decimals
        uint256 ibtQuantity;
        /// @notice Fixed interest rate at which the position has been opened.
        /// @dev value represented in 18 decimals
        uint256 fixedInterestRate;
        /// @notice Liquidation deposit is retained when the swap is opened. It is then paid back to agent who closes the derivative at maturity.
        /// It can be both trader or community member. Trader receives the deposit back when he chooses to close the derivative before maturity.
        /// @dev value represented WITHOUT 18 decimals for USDT, USDC, DAI pool. Notice! Value represented in 6 decimals for stETH pool.
        /// @dev Example value in 6 decimals: 25000000 (in 6 decimals) = 25 stETH = 25.000000
        uint256 liquidationDepositAmount;
        /// @notice Opening fee amount part which is allocated in Liquidity Pool Balance. This fee is calculated as a rate of the swap's collateral.
        /// @dev value represented in 18 decimals
        uint256 openingFeeLPAmount;
        /// @notice Opening fee amount part which is allocated in Treasury Balance. This fee is calculated as a rate of the swap's collateral.
        /// @dev value represented in 18 decimals
        uint256 openingFeeTreasuryAmount;
        /// @notice Swap's tenor, 0 - 28 days, 1 - 60 days or 2 - 90 days
        IporTypes.SwapTenor tenor;
    }

    /// @notice Struct representing swap item, used for listing and in internal calculations
    struct Swap {
        /// @notice Swap's unique ID
        uint256 id;
        /// @notice Swap's buyer
        address buyer;
        /// @notice Swap opening epoch timestamp
        uint256 openTimestamp;
        /// @notice Swap's tenor
        IporTypes.SwapTenor tenor;
        /// @notice Index position of this Swap in an array of swaps' identification associated to swap buyer
        /// @dev Field used for gas optimization purposes, it allows for quick removal by id in the array.
        /// During removal the last item in the array is switched with the one that just has been removed.
        uint256 idsIndex;
        /// @notice Swap's collateral
        /// @dev value represented in 18 decimals
        uint256 collateral;
        /// @notice Swap's notional amount
        /// @dev value represented in 18 decimals
        uint256 notional;
        /// @notice Swap's notional amount denominated in the Interest Bearing Token (IBT)
        /// @dev value represented in 18 decimals
        uint256 ibtQuantity;
        /// @notice Fixed interest rate at which the position has been opened
        /// @dev value represented in 18 decimals
        uint256 fixedInterestRate;
        /// @notice Liquidation deposit amount
        /// @dev value represented in 18 decimals
        uint256 liquidationDepositAmount;
        /// @notice State of the swap
        /// @dev 0 - INACTIVE, 1 - ACTIVE
        IporTypes.SwapState state;
    }

    /// @notice Struct representing amounts related to Swap that is presently being opened.
    /// @dev all values represented in 18 decimals
    struct OpenSwapAmount {
        /// @notice Total Amount of asset that is sent from buyer to AmmTreasury when opening swap.
        uint256 totalAmount;
        /// @notice Swap's collateral
        uint256 collateral;
        /// @notice Swap's notional
        uint256 notional;
        /// @notice Opening Fee - part allocated as a profit of the Liquidity Pool
        uint256 openingFeeLPAmount;
        /// @notice  Part of the fee set aside for subsidizing the oracle that publishes IPOR rate. Flat fee set by the DAO.
        /// @notice Opening Fee - part allocated in Treasury balance. Part of the fee set asside for subsidising the oracle that publishes IPOR rate. Flat fee set by the DAO.
        uint256 openingFeeTreasuryAmount;
        /// @notice Fee set aside for subsidizing the oracle that publishes IPOR rate. Flat fee set by the DAO.
        uint256 iporPublicationFee;
        /// @notice Liquidation deposit is retained when the swap is opened. Value represented in 18 decimals.
        uint256 liquidationDepositAmount;
    }

    /// @notice Structure describes one swap processed by closeSwaps method, information about swap ID and flag if this swap was closed during execution closeSwaps method.
    struct IporSwapClosingResult {
        /// @notice Swap ID
        uint256 swapId;
        /// @notice Flag describe if swap was closed during this execution
        bool closed;
    }

    /// @notice Technical structure used for storing information about amounts used during redeeming assets from liquidity pool.
    struct RedeemAmount {
        /// @notice Asset amount represented in 18 decimals
        /// @dev Asset amount is a sum of wadRedeemFee and wadRedeemAmount
        uint256 wadAssetAmount;
        /// @notice Redeemed amount represented in decimals of asset
        uint256 redeemAmount;
        /// @notice Redeem fee value represented in 18 decimals
        uint256 wadRedeemFee;
        /// @notice Redeem amount represented in 18 decimals
        uint256 wadRedeemAmount;
    }

    struct UnwindParams {
        /// @notice Risk Indicators Inputs signer
        address messageSigner;
        /// @notice Spread Router contract address
        address spreadRouter;
        address ammStorage;
        address ammTreasury;
        SwapDirection direction;
        uint256 closeTimestamp;
        int256 swapPnlValueToDate;
        uint256 indexValue;
        Swap swap;
        IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration poolCfg;
        CloseSwapRiskIndicatorsInput riskIndicatorsInputs;
    }

    /// @notice Swap direction (long = Pay Fixed and Receive a Floating or short = receive fixed and pay a floating)
    enum SwapDirection {
        /// @notice When taking the "long" position the trader will pay a fixed rate and receive a floating rate.
        /// for more information refer to the documentation https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/ipor-swaps
        PAY_FIXED_RECEIVE_FLOATING,
        /// @notice When taking the "short" position the trader will pay a floating rate and receive a fixed rate.
        PAY_FLOATING_RECEIVE_FIXED
    }
    /// @notice List of closable statuses for a given swap
    /// @dev Closable status is a one of the following values:
    /// 0 - Swap is closable
    /// 1 - Swap is already closed
    /// 2 - Swap state required Buyer or Liquidator to close. Sender is not Buyer nor Liquidator.
    /// 3 - Cannot close swap, closing is too early for Community
    /// 4 - Cannot close swap with unwind because action is too early from the moment when swap was opened, validation based on Close Service configuration
    enum SwapClosableStatus {
        SWAP_IS_CLOSABLE,
        SWAP_ALREADY_CLOSED,
        SWAP_REQUIRED_BUYER_OR_LIQUIDATOR_TO_CLOSE,
        SWAP_CANNOT_CLOSE_CLOSING_TOO_EARLY_FOR_COMMUNITY,
        SWAP_CANNOT_CLOSE_WITH_UNWIND_ACTION_IS_TOO_EARLY
    }

    /// @notice Collection of swap attributes connected with IPOR Index and swap itself.
    /// @dev all values are in 18 decimals
    struct IporSwapIndicator {
        /// @notice IPOR Index value at the time of swap opening
        uint256 iporIndexValue;
        /// @notice IPOR Interest Bearing Token (IBT) price at the time of swap opening
        uint256 ibtPrice;
        /// @notice Swap's notional denominated in IBT
        uint256 ibtQuantity;
        /// @notice Fixed interest rate at which the position has been opened,
        /// it is quote from spread documentation
        uint256 fixedInterestRate;
    }

    /// @notice Risk indicators calculated for swap opening
    struct OpenSwapRiskIndicators {
        /// @notice Maximum collateral ratio in general
        uint256 maxCollateralRatio;
        /// @notice Maximum collateral ratio for a given leg
        uint256 maxCollateralRatioPerLeg;
        /// @notice Maximum leverage for a given leg
        uint256 maxLeveragePerLeg;
        /// @notice Base Spread for a given leg (without demand part)
        int256 baseSpreadPerLeg;
        /// @notice Fixed rate cap
        uint256 fixedRateCapPerLeg;
        /// @notice Demand spread factor used to calculate demand spread
        uint256 demandSpreadFactor;
    }

    /// @notice Risk indicators calculated for swap opening
    struct RiskIndicatorsInputs {
        /// @notice Maximum collateral ratio in general
        uint256 maxCollateralRatio;
        /// @notice Maximum collateral ratio for a given leg
        uint256 maxCollateralRatioPerLeg;
        /// @notice Maximum leverage for a given leg
        uint256 maxLeveragePerLeg;
        /// @notice Base Spread for a given leg (without demand part)
        int256 baseSpreadPerLeg;
        /// @notice Fixed rate cap
        uint256 fixedRateCapPerLeg;
        /// @notice Demand spread factor used to calculate demand spread
        uint256 demandSpreadFactor;
        /// @notice expiration date in seconds
        uint256 expiration;
        /// @notice signature of data (maxCollateralRatio, maxCollateralRatioPerLeg,maxLeveragePerLeg,baseSpreadPerLeg,fixedRateCapPerLeg,demandSpreadFactor,expiration,asset,tenor,direction)
        /// asset - address
        /// tenor - uint256
        /// direction - uint256
        bytes signature;
    }

    struct CloseSwapRiskIndicatorsInput {
        RiskIndicatorsInputs payFixed;
        RiskIndicatorsInputs receiveFixed;
    }

    /// @notice Structure containing information about swap's closing status, unwind values and PnL for a given swap and time.
    struct ClosingSwapDetails {
        /// @notice Swap's closing status
        AmmTypes.SwapClosableStatus closableStatus;
        /// @notice Flag indicating if swap unwind is required
        bool swapUnwindRequired;
        /// @notice Swap's unwind PnL Value, part of PnL corresponded to virtual swap (unwinded swap), represented in 18 decimals
        int256 swapUnwindPnlValue;
        /// @notice Unwind opening fee amount it is a sum of `swapUnwindFeeLPAmount` and `swapUnwindFeeTreasuryAmount`
        uint256 swapUnwindOpeningFeeAmount;
        /// @notice Part of unwind opening fee allocated as a profit of the Liquidity Pool
        uint256 swapUnwindFeeLPAmount;
        /// @notice Part of unwind opening fee allocated in Treasury Balance
        uint256 swapUnwindFeeTreasuryAmount;
        /// @notice Final Profit and Loss which takes into account the swap unwind and limits the PnL to the collateral amount. Represented in 18 decimals.
        int256 pnlValue;
    }
}

/// @title Interface for interaction with IporOracle, smart contract responsible for managing IPOR Index.
interface IIporOracle {

    /// @notice Structure representing parameters required to update an IPOR index for a given asset.
    /// @dev This structure is used in the `updateIndexes` method to provide necessary details for updating IPOR indexes.
    ///      For assets other than '_stEth', the 'quasiIbtPrice' field is not utilized in the update process.
    /// @param asset The address of the underlying asset/stablecoin supported by the IPOR Protocol.
    /// @param indexValue The new value of the IPOR index to be set for the specified asset.
    /// @param updateTimestamp The timestamp at which the index value is updated, used to calculate accrued interest.
    /// @param quasiIbtPrice The quasi interest-bearing token (IBT) price, applicable only for the '_stEth' asset.
    ///                      Represents a specialized value used in calculations for staked Ethereum.
    struct UpdateIndexParams {
        address asset;
        uint256 indexValue;
        uint256 updateTimestamp;
        uint256 quasiIbtPrice;
    }

    /// @notice Returns current version of IporOracle's
    /// @dev Increase number when implementation inside source code is different that implementation deployed on Mainnet
    /// @return current IporOracle version
    function getVersion() external pure returns (uint256);

    /// @notice Gets IPOR Index indicators for a given asset
    /// @dev all returned values represented in 18 decimals
    /// @param asset underlying / stablecoin address supported in Ipor Protocol
    /// @return indexValue IPOR Index value for a given asset calculated for time lastUpdateTimestamp
    /// @return ibtPrice Interest Bearing Token Price for a given IPOR Index calculated for time lastUpdateTimestamp
    /// @return lastUpdateTimestamp Last IPOR Index update done by off-chain service
    /// @dev For calculation accrued IPOR Index indicators (indexValue and ibtPrice) for a specified timestamp use {getAccruedIndex} function.
    /// Method {getIndex} calculates IPOR Index indicators for a moment when last update was done by off-chain service,
    /// this timestamp is stored in lastUpdateTimestamp variable.
    function getIndex(
        address asset
    ) external view returns (uint256 indexValue, uint256 ibtPrice, uint256 lastUpdateTimestamp);

    /// @notice Gets accrued IPOR Index indicators for a given timestamp and asset.
    /// @param calculateTimestamp time of accrued IPOR Index calculation
    /// @param asset underlying / stablecoin address supported by IPOR Protocol.
    /// @return accruedIpor structure {IporTypes.AccruedIpor}
    /// @dev ibtPrice included in accruedIpor structure is calculated using continuous compounding interest formula
    function getAccruedIndex(
        uint256 calculateTimestamp,
        address asset
    ) external view returns (IporTypes.AccruedIpor memory accruedIpor);

    /// @notice Calculates accrued Interest Bearing Token price for a given asset and timestamp.
    /// @param asset underlying / stablecoin address supported by IPOR Protocol.
    /// @param calculateTimestamp time of accrued Interest Bearing Token price calculation
    /// @return accrued IBT price, represented in 18 decimals
    function calculateAccruedIbtPrice(address asset, uint256 calculateTimestamp) external view returns (uint256);

    /// @notice Updates IPOR indexes for specified assets, accessible only by authorized updaters.
    /// @dev Iterates through the 'indexesToUpdate' array, updating each asset's index and emitting {IporIndexUpdate} event.
    ///      Special handling is applied for the '_stEth' asset. Function execution is restricted during pause state and
    ///      requires the caller to be an authorized updater.
    /// @param indexesToUpdate Array of 'UpdateIndexParams' containing asset address, new index value, update timestamp,
    ///        and quasiIbtPrice (for '_stEth' asset).
    /// @dev INPUT_ARRAYS_LENGTH_MISMATCH if 'indexesToUpdate' array is empty.
    /// @dev ASSET_NOT_SUPPORTED if an asset in 'indexesToUpdate' is not supported.
    /// @dev WRONG_INDEX_TIMESTAMP if the provided timestamp is either older than the last update timestamp or greater
    ///         than the current block timestamp.
    function updateIndexes(UpdateIndexParams[] calldata indexesToUpdate) external;

    /// @notice Adds new Updater. Updater has right to update IPOR Index. Function available only for Owner.
    /// @param newUpdater new updater address
    function addUpdater(address newUpdater) external;

    /// @notice Removes Updater. Function available only for Owner.
    /// @param updater updater address
    function removeUpdater(address updater) external;

    /// @notice Checks if given account is an Updater.
    /// @param account account for checking
    /// @return 0 if account is not updater, 1 if account is updater.
    function isUpdater(address account) external view returns (uint256);

    /// @notice Adds new asset which IPOR Protocol will support. Function available only for Owner.
    /// @param newAsset new asset address
    /// @param updateTimestamp Time when start to accrue interest for Interest Bearing Token price.
    function addAsset(address newAsset, uint256 updateTimestamp) external;

    /// @notice Removes asset which IPOR Protocol will not support. Function available only for Owner.
    /// @param asset  underlying / stablecoin address which current is supported by IPOR Protocol.
    function removeAsset(address asset) external;

    /// @notice Checks if given asset is supported by IPOR Protocol.
    /// @param asset underlying / stablecoin address
    function isAssetSupported(address asset) external view returns (bool);

    /// @notice Emmited when Charlie update IPOR Index.
    /// @param asset underlying / stablecoin address
    /// @param indexValue IPOR Index value represented in 18 decimals
    /// @param quasiIbtPrice quasi Interest Bearing Token price represented in 18 decimals.
    /// @param updateTimestamp moment when IPOR Index was updated.
    event IporIndexUpdate(address asset, uint256 indexValue, uint256 quasiIbtPrice, uint256 updateTimestamp);

    /// @notice event emitted when IPOR Index Updater is added by Owner
    /// @param newUpdater new Updater address
    event IporIndexAddUpdater(address newUpdater);

    /// @notice event emitted when IPOR Index Updater is removed by Owner
    /// @param updater updater address
    event IporIndexRemoveUpdater(address updater);

    /// @notice event emitted when new asset is added by Owner to list of assets supported in IPOR Protocol.
    /// @param newAsset new asset address
    /// @param updateTimestamp update timestamp
    event IporIndexAddAsset(address newAsset, uint256 updateTimestamp);

    /// @notice event emitted when asset is removed by Owner from list of assets supported in IPOR Protocol.
    /// @param asset asset address
    event IporIndexRemoveAsset(address asset);
}

/// @title Interface of the service allowing to close swaps.
interface IAmmCloseSwapService {
    function getPoolConfiguration()
        external
        view
        returns (IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration memory);
}

library IporErrors {
    /// @notice Error when address is wrong
    error WrongAddress(string errorCode, address wrongAddress, string message);

    /// @notice Error when amount is wrong
    error WrongAmount(string errorCode, uint256 value);

    /// @notice Error when caller is not an ipor protocol router
    error CallerNotIporProtocolRouter(string errorCode, address caller);

    /// @notice Error when caller is not a pause guardian
    error CallerNotPauseGuardian(string errorCode, address caller);

    /// @notice Error when caller is not a AmmTreasury contract
    error CallerNotAmmTreasury(string errorCode, address caller);

    /// @notice Error when given direction is not supported
    error UnsupportedDirection(string errorCode, uint256 direction);

    /// @notice Error when given asset is not supported
    error UnsupportedAsset(string errorCode, address asset);

    /// @notice Error when given module is not supported
    error UnsupportedModule(string errorCode, address asset);

    /// @notice Error when Input Asset total amount is too low
    error InputAssetTotalAmountTooLow(string errorCode, uint256 value);

    /// @dev Error appears if user/account doesn't have enough balance to open a swap with a specific totalAmount
    error InputAssetBalanceTooLow(string errorCode, address inputAsset, uint256 inputAssetBalance, uint256 totalAmount);

    // 000-199 - general codes

    /// @notice General problem, address is wrong
    string public constant WRONG_ADDRESS = "IPOR_000";

    /// @notice General problem. Wrong decimals
    string public constant WRONG_DECIMALS = "IPOR_001";

    /// @notice General problem, addresses mismatch
    string public constant ADDRESSES_MISMATCH = "IPOR_002";

    /// @notice Sender's asset balance is too low to transfer and to open a swap
    string public constant SENDER_ASSET_BALANCE_TOO_LOW = "IPOR_003";

    /// @notice Value is not greater than zero
    string public constant VALUE_NOT_GREATER_THAN_ZERO = "IPOR_004";

    /// @notice Input arrays length mismatch
    string public constant INPUT_ARRAYS_LENGTH_MISMATCH = "IPOR_005";

    /// @notice Amount is too low to transfer
    string public constant NOT_ENOUGH_AMOUNT_TO_TRANSFER = "IPOR_006";

    /// @notice msg.sender is not an appointed owner, so cannot confirm his appointment to be an owner of a specific smart contract
    string public constant SENDER_NOT_APPOINTED_OWNER = "IPOR_007";

    /// @notice only Router can have access to function
    string public constant CALLER_NOT_IPOR_PROTOCOL_ROUTER = "IPOR_008";

    /// @notice Chunk size is equal to zero
    string public constant CHUNK_SIZE_EQUAL_ZERO = "IPOR_009";

    /// @notice Chunk size is too big
    string public constant CHUNK_SIZE_TOO_BIG = "IPOR_010";

    /// @notice Caller is not a pause guardian
    string public constant CALLER_NOT_PAUSE_GUARDIAN = "IPOR_011";

    /// @notice Request contains invalid method signature, which is not supported by the Ipor Protocol Router
    string public constant ROUTER_INVALID_SIGNATURE = "IPOR_012";

    /// @notice Only AMM Treasury can have access to function
    string public constant CALLER_NOT_AMM_TREASURY = "IPOR_013";

    /// @notice Caller is not an owner
    string public constant CALLER_NOT_OWNER = "IPOR_014";

    /// @notice Method is paused
    string public constant METHOD_PAUSED = "IPOR_015";

    /// @notice Reentrancy appears
    string public constant REENTRANCY = "IPOR_016";

    /// @notice Asset is not supported
    string public constant ASSET_NOT_SUPPORTED = "IPOR_017";

    /// @notice Return back ETH failed in Ipor Protocol Router
    string public constant ROUTER_RETURN_BACK_ETH_FAILED = "IPOR_018";

    /// @notice Risk indicators are expired
    string public constant RISK_INDICATORS_EXPIRED = "IPOR_019";

    /// @notice Signature is invalid for risk indicators
    string public constant RISK_INDICATORS_SIGNATURE_INVALID = "IPOR_020";

    /// @notice Input Asset used by user is not supported
    string public constant INPUT_ASSET_NOT_SUPPORTED = "IPOR_021";

    /// @notice Module Asset Management is not supported
    string public constant UNSUPPORTED_MODULE_ASSET_MANAGEMENT = "IPOR_022";
}

library IporContractValidator {
    function checkAddress(address addr) internal pure returns (address) {
        require(addr != address(0), IporErrors.WRONG_ADDRESS);
        return addr;
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */
library ABDKMathQuad {
  /*
   * 0.
   */
  bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

  /*
   * -0.
   */
  bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

  /*
   * +Infinity.
   */
  bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

  /*
   * -Infinity.
   */
  bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

  /*
   * Canonical NaN value.
   */
  bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

  /**
   * Convert signed 256-bit integer number into quadruple precision number.
   *
   * @param x signed 256-bit integer number
   * @return quadruple precision number
   */
  function fromInt (int256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint256 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 256-bit integer number
   * rounding towards zero.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 256-bit integer number
   */
  function toInt (bytes16 x) internal pure returns (int256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16638); // Overflow
      if (exponent < 16383) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16495) result >>= 16495 - exponent;
      else if (exponent > 16495) result <<= exponent - 16495;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
        return -int256 (result); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int256 (result);
      }
    }
  }

  /**
   * Convert unsigned 256-bit integer number into quadruple precision number.
   *
   * @param x unsigned 256-bit integer number
   * @return quadruple precision number
   */
  function fromUInt (uint256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        uint256 result = x;

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into unsigned 256-bit integer number
   * rounding towards zero.  Revert on underflow.  Note, that negative floating
   * point numbers in range (-1.0 .. 0.0) may be converted to unsigned integer
   * without error, because they are rounded to zero.
   *
   * @param x quadruple precision number
   * @return unsigned 256-bit integer number
   */
  function toUInt (bytes16 x) internal pure returns (uint256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      if (exponent < 16383) return 0; // Underflow

      require (uint128 (x) < 0x80000000000000000000000000000000); // Negative

      require (exponent <= 16638); // Overflow
      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16495) result >>= 16495 - exponent;
      else if (exponent > 16495) result <<= exponent - 16495;

      return result;
    }
  }

  /**
   * Convert signed 128.128 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 128.128 bit fixed point number
   * @return quadruple precision number
   */
  function from128x128 (int256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint256 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 128.128 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 128.128 bit fixed point number
   */
  function to128x128 (bytes16 x) internal pure returns (int256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16510); // Overflow
      if (exponent < 16255) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16367) result >>= 16367 - exponent;
      else if (exponent > 16367) result <<= exponent - 16367;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
        return -int256 (result); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int256 (result);
      }
    }
  }

  /**
   * Convert signed 64.64 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 64.64 bit fixed point number
   * @return quadruple precision number
   */
  function from64x64 (int128 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint128 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 64.64 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 64.64 bit fixed point number
   */
  function to64x64 (bytes16 x) internal pure returns (int128) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16446); // Overflow
      if (exponent < 16319) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16431) result >>= 16431 - exponent;
      else if (exponent > 16431) result <<= exponent - 16431;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x80000000000000000000000000000000);
        return -int128 (int256 (result)); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (int256 (result));
      }
    }
  }

  /**
   * Convert octuple precision number into quadruple precision number.
   *
   * @param x octuple precision number
   * @return quadruple precision number
   */
  function fromOctuple (bytes32 x) internal pure returns (bytes16) {
    unchecked {
      bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

      uint256 exponent = uint256 (x) >> 236 & 0x7FFFF;
      uint256 significand = uint256 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFFF) {
        if (significand > 0) return NaN;
        else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
      }

      if (exponent > 278526)
        return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
      else if (exponent < 245649)
        return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
      else if (exponent < 245761) {
        significand = (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
        exponent = 0;
      } else {
        significand >>= 124;
        exponent -= 245760;
      }

      uint128 result = uint128 (significand | exponent << 112);
      if (negative) result |= 0x80000000000000000000000000000000;

      return bytes16 (result);
    }
  }

  /**
   * Convert quadruple precision number into octuple precision number.
   *
   * @param x quadruple precision number
   * @return octuple precision number
   */
  function toOctuple (bytes16 x) internal pure returns (bytes32) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      uint256 result = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFF) exponent = 0x7FFFF; // Infinity or NaN
      else if (exponent == 0) {
        if (result > 0) {
          uint256 msb = mostSignificantBit (result);
          result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          exponent = 245649 + msb;
        }
      } else {
        result <<= 124;
        exponent += 245760;
      }

      result |= exponent << 236;
      if (uint128 (x) >= 0x80000000000000000000000000000000)
        result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

      return bytes32 (result);
    }
  }

  /**
   * Convert double precision number into quadruple precision number.
   *
   * @param x double precision number
   * @return quadruple precision number
   */
  function fromDouble (bytes8 x) internal pure returns (bytes16) {
    unchecked {
      uint256 exponent = uint64 (x) >> 52 & 0x7FF;

      uint256 result = uint64 (x) & 0xFFFFFFFFFFFFF;

      if (exponent == 0x7FF) exponent = 0x7FFF; // Infinity or NaN
      else if (exponent == 0) {
        if (result > 0) {
          uint256 msb = mostSignificantBit (result);
          result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          exponent = 15309 + msb;
        }
      } else {
        result <<= 60;
        exponent += 15360;
      }

      result |= exponent << 112;
      if (x & 0x8000000000000000 > 0)
        result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into double precision number.
   *
   * @param x quadruple precision number
   * @return double precision number
   */
  function toDouble (bytes16 x) internal pure returns (bytes8) {
    unchecked {
      bool negative = uint128 (x) >= 0x80000000000000000000000000000000;

      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 significand = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFF) {
        if (significand > 0) return 0x7FF8000000000000; // NaN
        else return negative ?
            bytes8 (0xFFF0000000000000) : // -Infinity
            bytes8 (0x7FF0000000000000); // Infinity
      }

      if (exponent > 17406)
        return negative ?
            bytes8 (0xFFF0000000000000) : // -Infinity
            bytes8 (0x7FF0000000000000); // Infinity
      else if (exponent < 15309)
        return negative ?
            bytes8 (0x8000000000000000) : // -0
            bytes8 (0x0000000000000000); // 0
      else if (exponent < 15361) {
        significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
        exponent = 0;
      } else {
        significand >>= 60;
        exponent -= 15360;
      }

      uint64 result = uint64 (significand | exponent << 52);
      if (negative) result |= 0x8000000000000000;

      return bytes8 (result);
    }
  }

  /**
   * Test whether given quadruple precision number is NaN.
   *
   * @param x quadruple precision number
   * @return true if x is NaN, false otherwise
   */
  function isNaN (bytes16 x) internal pure returns (bool) {
    unchecked {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >
        0x7FFF0000000000000000000000000000;
    }
  }

  /**
   * Test whether given quadruple precision number is positive or negative
   * infinity.
   *
   * @param x quadruple precision number
   * @return true if x is positive or negative infinity, false otherwise
   */
  function isInfinity (bytes16 x) internal pure returns (bool) {
    unchecked {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ==
        0x7FFF0000000000000000000000000000;
    }
  }

  /**
   * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
   * is positive.  Note that sign (-0) is zero.  Revert if x is NaN. 
   *
   * @param x quadruple precision number
   * @return sign of x
   */
  function sign (bytes16 x) internal pure returns (int8) {
    unchecked {
      uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

      if (absoluteX == 0) return 0;
      else if (uint128 (x) >= 0x80000000000000000000000000000000) return -1;
      else return 1;
    }
  }

  /**
   * Calculate sign (x - y).  Revert if either argument is NaN, or both
   * arguments are infinities of the same sign. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return sign (x - y)
   */
  function cmp (bytes16 x, bytes16 y) internal pure returns (int8) {
    unchecked {
      uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

      uint128 absoluteY = uint128 (y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

      // Not infinities of the same sign
      require (x != y || absoluteX < 0x7FFF0000000000000000000000000000);

      if (x == y) return 0;
      else {
        bool negativeX = uint128 (x) >= 0x80000000000000000000000000000000;
        bool negativeY = uint128 (y) >= 0x80000000000000000000000000000000;

        if (negativeX) {
          if (negativeY) return absoluteX > absoluteY ? -1 : int8 (1);
          else return -1; 
        } else {
          if (negativeY) return 1;
          else return absoluteX > absoluteY ? int8 (1) : -1;
        }
      }
    }
  }

  /**
   * Test whether x equals y.  NaN, infinity, and -infinity are not equal to
   * anything. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return true if x equals to y, false otherwise
   */
  function eq (bytes16 x, bytes16 y) internal pure returns (bool) {
    unchecked {
      if (x == y) {
        return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF <
          0x7FFF0000000000000000000000000000;
      } else return false;
    }
  }

  /**
   * Calculate x + y.  Special values behave in the following way:
   *
   * NaN + x = NaN for any x.
   * Infinity + x = Infinity for any finite x.
   * -Infinity + x = -Infinity for any finite x.
   * Infinity + Infinity = Infinity.
   * -Infinity + -Infinity = -Infinity.
   * Infinity + -Infinity = -Infinity + Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function add (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) { 
          if (x == y) return x;
          else return NaN;
        } else return x; 
      } else if (yExponent == 0x7FFF) return y;
      else {
        bool xSign = uint128 (x) >= 0x80000000000000000000000000000000;
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        bool ySign = uint128 (y) >= 0x80000000000000000000000000000000;
        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
        else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
        else {
          int256 delta = int256 (xExponent) - int256 (yExponent);
  
          if (xSign == ySign) {
            if (delta > 112) return x;
            else if (delta > 0) ySignifier >>= uint256 (delta);
            else if (delta < -112) return y;
            else if (delta < 0) {
              xSignifier >>= uint256 (-delta);
              xExponent = yExponent;
            }
  
            xSignifier += ySignifier;
  
            if (xSignifier >= 0x20000000000000000000000000000) {
              xSignifier >>= 1;
              xExponent += 1;
            }
  
            if (xExponent == 0x7FFF)
              return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            else {
              if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
              else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  
              return bytes16 (uint128 (
                  (xSign ? 0x80000000000000000000000000000000 : 0) |
                  (xExponent << 112) |
                  xSignifier)); 
            }
          } else {
            if (delta > 0) {
              xSignifier <<= 1;
              xExponent -= 1;
            } else if (delta < 0) {
              ySignifier <<= 1;
              xExponent = yExponent - 1;
            }

            if (delta > 112) ySignifier = 1;
            else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256 (delta - 1)) + 1;
            else if (delta < -112) xSignifier = 1;
            else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256 (-delta - 1)) + 1;

            if (xSignifier >= ySignifier) xSignifier -= ySignifier;
            else {
              xSignifier = ySignifier - xSignifier;
              xSign = ySign;
            }

            if (xSignifier == 0)
              return POSITIVE_ZERO;

            uint256 msb = mostSignificantBit (xSignifier);

            if (msb == 113) {
              xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
              xExponent += 1;
            } else if (msb < 112) {
              uint256 shift = 112 - msb;
              if (xExponent > shift) {
                xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                xExponent -= shift;
              } else {
                xSignifier <<= xExponent - 1;
                xExponent = 0;
              }
            } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (xExponent == 0x7FFF)
              return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            else return bytes16 (uint128 (
                (xSign ? 0x80000000000000000000000000000000 : 0) |
                (xExponent << 112) |
                xSignifier));
          }
        }
      }
    }
  }

  /**
   * Calculate x - y.  Special values behave in the following way:
   *
   * NaN - x = NaN for any x.
   * Infinity - x = Infinity for any finite x.
   * -Infinity - x = -Infinity for any finite x.
   * Infinity - -Infinity = Infinity.
   * -Infinity - Infinity = -Infinity.
   * Infinity - Infinity = -Infinity - -Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function sub (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      return add (x, y ^ 0x80000000000000000000000000000000);
    }
  }

  /**
   * Calculate x * y.  Special values behave in the following way:
   *
   * NaN * x = NaN for any x.
   * Infinity * x = Infinity for any finite positive x.
   * Infinity * x = -Infinity for any finite negative x.
   * -Infinity * x = -Infinity for any finite positive x.
   * -Infinity * x = Infinity for any finite negative x.
   * Infinity * 0 = NaN.
   * -Infinity * 0 = NaN.
   * Infinity * Infinity = Infinity.
   * Infinity * -Infinity = -Infinity.
   * -Infinity * Infinity = -Infinity.
   * -Infinity * -Infinity = Infinity.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function mul (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) {
          if (x == y) return x ^ y & 0x80000000000000000000000000000000;
          else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
          else return NaN;
        } else {
          if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
          else return x ^ y & 0x80000000000000000000000000000000;
        }
      } else if (yExponent == 0x7FFF) {
          if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
          else return y ^ x & 0x80000000000000000000000000000000;
      } else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        xSignifier *= ySignifier;
        if (xSignifier == 0)
          return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
              NEGATIVE_ZERO : POSITIVE_ZERO;

        xExponent += yExponent;

        uint256 msb =
          xSignifier >= 0x200000000000000000000000000000000000000000000000000000000 ? 225 :
          xSignifier >= 0x100000000000000000000000000000000000000000000000000000000 ? 224 :
          mostSignificantBit (xSignifier);

        if (xExponent + msb < 16496) { // Underflow
          xExponent = 0;
          xSignifier = 0;
        } else if (xExponent + msb < 16608) { // Subnormal
          if (xExponent < 16496)
            xSignifier >>= 16496 - xExponent;
          else if (xExponent > 16496)
            xSignifier <<= xExponent - 16496;
          xExponent = 0;
        } else if (xExponent + msb > 49373) {
          xExponent = 0x7FFF;
          xSignifier = 0;
        } else {
          if (msb > 112)
            xSignifier >>= msb - 112;
          else if (msb < 112)
            xSignifier <<= 112 - msb;

          xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          xExponent = xExponent + msb - 16607;
        }

        return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
            xExponent << 112 | xSignifier));
      }
    }
  }

  /**
   * Calculate x / y.  Special values behave in the following way:
   *
   * NaN / x = NaN for any x.
   * x / NaN = NaN for any x.
   * Infinity / x = Infinity for any finite non-negative x.
   * Infinity / x = -Infinity for any finite negative x including -0.
   * -Infinity / x = -Infinity for any finite non-negative x.
   * -Infinity / x = Infinity for any finite negative x including -0.
   * x / Infinity = 0 for any finite non-negative x.
   * x / -Infinity = -0 for any finite non-negative x.
   * x / Infinity = -0 for any finite non-negative x including -0.
   * x / -Infinity = 0 for any finite non-negative x including -0.
   * 
   * Infinity / Infinity = NaN.
   * Infinity / -Infinity = -NaN.
   * -Infinity / Infinity = -NaN.
   * -Infinity / -Infinity = NaN.
   *
   * Division by zero behaves in the following way:
   *
   * x / 0 = Infinity for any finite positive x.
   * x / -0 = -Infinity for any finite positive x.
   * x / 0 = -Infinity for any finite negative x.
   * x / -0 = Infinity for any finite negative x.
   * 0 / 0 = NaN.
   * 0 / -0 = NaN.
   * -0 / 0 = NaN.
   * -0 / -0 = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function div (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) return NaN;
        else return x ^ y & 0x80000000000000000000000000000000;
      } else if (yExponent == 0x7FFF) {
        if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
        else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
      } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
        if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
      } else {
        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) {
          if (xSignifier != 0) {
            uint shift = 226 - mostSignificantBit (xSignifier);

            xSignifier <<= shift;

            xExponent = 1;
            yExponent += shift - 114;
          }
        }
        else {
          xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
        }

        xSignifier = xSignifier / ySignifier;
        if (xSignifier == 0)
          return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
              NEGATIVE_ZERO : POSITIVE_ZERO;

        assert (xSignifier >= 0x1000000000000000000000000000);

        uint256 msb =
          xSignifier >= 0x80000000000000000000000000000 ? mostSignificantBit (xSignifier) :
          xSignifier >= 0x40000000000000000000000000000 ? 114 :
          xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

        if (xExponent + msb > yExponent + 16497) { // Overflow
          xExponent = 0x7FFF;
          xSignifier = 0;
        } else if (xExponent + msb + 16380  < yExponent) { // Underflow
          xExponent = 0;
          xSignifier = 0;
        } else if (xExponent + msb + 16268  < yExponent) { // Subnormal
          if (xExponent + 16380 > yExponent)
            xSignifier <<= xExponent + 16380 - yExponent;
          else if (xExponent + 16380 < yExponent)
            xSignifier >>= yExponent - xExponent - 16380;

          xExponent = 0;
        } else { // Normal
          if (msb > 112)
            xSignifier >>= msb - 112;

          xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          xExponent = xExponent + msb + 16269 - yExponent;
        }

        return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
            xExponent << 112 | xSignifier));
      }
    }
  }

  /**
   * Calculate -x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function neg (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return x ^ 0x80000000000000000000000000000000;
    }
  }

  /**
   * Calculate |x|.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function abs (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }
  }

  /**
   * Calculate square root of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function sqrt (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      if (uint128 (x) >  0x80000000000000000000000000000000) return NaN;
      else {
        uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
        if (xExponent == 0x7FFF) return x;
        else {
          uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          if (xExponent == 0) xExponent = 1;
          else xSignifier |= 0x10000000000000000000000000000;

          if (xSignifier == 0) return POSITIVE_ZERO;

          bool oddExponent = xExponent & 0x1 == 0;
          xExponent = xExponent + 16383 >> 1;

          if (oddExponent) {
            if (xSignifier >= 0x10000000000000000000000000000)
              xSignifier <<= 113;
            else {
              uint256 msb = mostSignificantBit (xSignifier);
              uint256 shift = (226 - msb) & 0xFE;
              xSignifier <<= shift;
              xExponent -= shift - 112 >> 1;
            }
          } else {
            if (xSignifier >= 0x10000000000000000000000000000)
              xSignifier <<= 112;
            else {
              uint256 msb = mostSignificantBit (xSignifier);
              uint256 shift = (225 - msb) & 0xFE;
              xSignifier <<= shift;
              xExponent -= shift - 112 >> 1;
            }
          }

          uint256 r = 0x10000000000000000000000000000;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
          uint256 r1 = xSignifier / r;
          if (r1 < r) r = r1;

          return bytes16 (uint128 (xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
        }
      }
    }
  }

  /**
   * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function log_2 (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      if (uint128 (x) > 0x80000000000000000000000000000000) return NaN;
      else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO; 
      else {
        uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
        if (xExponent == 0x7FFF) return x;
        else {
          uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          if (xExponent == 0) xExponent = 1;
          else xSignifier |= 0x10000000000000000000000000000;

          if (xSignifier == 0) return NEGATIVE_INFINITY;

          bool resultNegative;
          uint256 resultExponent = 16495;
          uint256 resultSignifier;

          if (xExponent >= 0x3FFF) {
            resultNegative = false;
            resultSignifier = xExponent - 0x3FFF;
            xSignifier <<= 15;
          } else {
            resultNegative = true;
            if (xSignifier >= 0x10000000000000000000000000000) {
              resultSignifier = 0x3FFE - xExponent;
              xSignifier <<= 15;
            } else {
              uint256 msb = mostSignificantBit (xSignifier);
              resultSignifier = 16493 - msb;
              xSignifier <<= 127 - msb;
            }
          }

          if (xSignifier == 0x80000000000000000000000000000000) {
            if (resultNegative) resultSignifier += 1;
            uint256 shift = 112 - mostSignificantBit (resultSignifier);
            resultSignifier <<= shift;
            resultExponent -= shift;
          } else {
            uint256 bb = resultNegative ? 1 : 0;
            while (resultSignifier < 0x10000000000000000000000000000) {
              resultSignifier <<= 1;
              resultExponent -= 1;
  
              xSignifier *= xSignifier;
              uint256 b = xSignifier >> 255;
              resultSignifier += b ^ bb;
              xSignifier >>= 127 + b;
            }
          }

          return bytes16 (uint128 ((resultNegative ? 0x80000000000000000000000000000000 : 0) |
              resultExponent << 112 | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
        }
      }
    }
  }

  /**
   * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function ln (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return mul (log_2 (x), 0x3FFE62E42FEFA39EF35793C7673007E5);
    }
  }

  /**
   * Calculate 2^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function pow_2 (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      bool xNegative = uint128 (x) > 0x80000000000000000000000000000000;
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
      else if (xExponent > 16397)
        return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
      else if (xExponent < 16255)
        return 0x3FFF0000000000000000000000000000;
      else {
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xExponent > 16367)
          xSignifier <<= xExponent - 16367;
        else if (xExponent < 16367)
          xSignifier >>= 16367 - xExponent;

        if (xNegative && xSignifier > 0x406E00000000000000000000000000000000)
          return POSITIVE_ZERO;

        if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
          return POSITIVE_INFINITY;

        uint256 resultExponent = xSignifier >> 128;
        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xNegative && xSignifier != 0) {
          xSignifier = ~xSignifier;
          resultExponent += 1;
        }

        uint256 resultSignifier = 0x80000000000000000000000000000000;
        if (xSignifier & 0x80000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
        if (xSignifier & 0x40000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
        if (xSignifier & 0x20000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
        if (xSignifier & 0x10000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
        if (xSignifier & 0x8000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
        if (xSignifier & 0x4000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
        if (xSignifier & 0x2000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
        if (xSignifier & 0x1000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
        if (xSignifier & 0x800000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
        if (xSignifier & 0x400000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
        if (xSignifier & 0x200000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
        if (xSignifier & 0x100000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
        if (xSignifier & 0x80000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
        if (xSignifier & 0x40000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
        if (xSignifier & 0x20000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
        if (xSignifier & 0x10000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
        if (xSignifier & 0x8000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
        if (xSignifier & 0x4000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
        if (xSignifier & 0x2000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
        if (xSignifier & 0x1000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
        if (xSignifier & 0x800000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
        if (xSignifier & 0x400000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
        if (xSignifier & 0x200000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
        if (xSignifier & 0x100000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
        if (xSignifier & 0x80000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
        if (xSignifier & 0x40000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
        if (xSignifier & 0x20000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
        if (xSignifier & 0x10000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
        if (xSignifier & 0x8000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
        if (xSignifier & 0x4000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
        if (xSignifier & 0x2000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
        if (xSignifier & 0x1000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
        if (xSignifier & 0x800000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
        if (xSignifier & 0x400000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
        if (xSignifier & 0x200000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
        if (xSignifier & 0x100000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
        if (xSignifier & 0x80000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
        if (xSignifier & 0x40000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
        if (xSignifier & 0x20000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
        if (xSignifier & 0x10000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
        if (xSignifier & 0x8000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
        if (xSignifier & 0x4000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
        if (xSignifier & 0x2000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
        if (xSignifier & 0x1000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
        if (xSignifier & 0x800000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
        if (xSignifier & 0x400000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
        if (xSignifier & 0x200000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
        if (xSignifier & 0x100000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
        if (xSignifier & 0x80000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
        if (xSignifier & 0x40000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
        if (xSignifier & 0x20000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
        if (xSignifier & 0x10000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
        if (xSignifier & 0x8000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
        if (xSignifier & 0x4000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
        if (xSignifier & 0x2000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
        if (xSignifier & 0x1000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
        if (xSignifier & 0x800000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
        if (xSignifier & 0x400000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
        if (xSignifier & 0x200000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
        if (xSignifier & 0x100000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
        if (xSignifier & 0x80000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
        if (xSignifier & 0x40000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
        if (xSignifier & 0x20000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
        if (xSignifier & 0x10000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
        if (xSignifier & 0x8000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
        if (xSignifier & 0x4000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
        if (xSignifier & 0x2000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
        if (xSignifier & 0x1000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
        if (xSignifier & 0x800000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
        if (xSignifier & 0x400000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
        if (xSignifier & 0x200000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
        if (xSignifier & 0x100000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
        if (xSignifier & 0x80000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
        if (xSignifier & 0x40000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
        if (xSignifier & 0x20000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
        if (xSignifier & 0x10000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
        if (xSignifier & 0x8000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
        if (xSignifier & 0x4000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
        if (xSignifier & 0x2000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
        if (xSignifier & 0x1000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
        if (xSignifier & 0x800000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
        if (xSignifier & 0x400000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
        if (xSignifier & 0x200000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
        if (xSignifier & 0x100000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
        if (xSignifier & 0x80000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
        if (xSignifier & 0x40000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
        if (xSignifier & 0x20000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
        if (xSignifier & 0x10000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
        if (xSignifier & 0x8000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
        if (xSignifier & 0x4000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
        if (xSignifier & 0x2000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
        if (xSignifier & 0x1000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
        if (xSignifier & 0x800000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
        if (xSignifier & 0x400000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
        if (xSignifier & 0x200000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
        if (xSignifier & 0x100000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
        if (xSignifier & 0x80000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
        if (xSignifier & 0x40000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
        if (xSignifier & 0x20000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
        if (xSignifier & 0x10000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
        if (xSignifier & 0x8000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
        if (xSignifier & 0x4000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
        if (xSignifier & 0x2000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
        if (xSignifier & 0x1000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
        if (xSignifier & 0x800000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
        if (xSignifier & 0x400000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
        if (xSignifier & 0x200000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
        if (xSignifier & 0x100000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
        if (xSignifier & 0x80000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
        if (xSignifier & 0x40000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
        if (xSignifier & 0x20000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
        if (xSignifier & 0x10000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
        if (xSignifier & 0x8000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
        if (xSignifier & 0x4000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
        if (xSignifier & 0x2000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
        if (xSignifier & 0x1000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
        if (xSignifier & 0x800 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
        if (xSignifier & 0x400 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
        if (xSignifier & 0x200 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
        if (xSignifier & 0x100 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
        if (xSignifier & 0x80 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
        if (xSignifier & 0x40 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
        if (xSignifier & 0x20 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
        if (xSignifier & 0x10 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
        if (xSignifier & 0x8 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
        if (xSignifier & 0x4 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;

        if (!xNegative) {
          resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          resultExponent += 0x3FFF;
        } else if (resultExponent <= 0x3FFE) {
          resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          resultExponent = 0x3FFF - resultExponent;
        } else {
          resultSignifier = resultSignifier >> resultExponent - 16367;
          resultExponent = 0;
        }

        return bytes16 (uint128 (resultExponent << 112 | resultSignifier));
      }
    }
  }

  /**
   * Calculate e^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function exp (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return pow_2 (mul (x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
    }
  }

  /**
   * Get index of the most significant non-zero bit in binary representation of
   * x.  Reverts if x is zero.
   *
   * @return index of the most significant non-zero bit in binary representation
   *         of x
   */
  function mostSignificantBit (uint256 x) private pure returns (uint256) {
    unchecked {
      require (x > 0);

      uint256 result = 0;

      if (x >= 0x100000000000000000000000000000000) { x >>= 128; result += 128; }
      if (x >= 0x10000000000000000) { x >>= 64; result += 64; }
      if (x >= 0x100000000) { x >>= 32; result += 32; }
      if (x >= 0x10000) { x >>= 16; result += 16; }
      if (x >= 0x100) { x >>= 8; result += 8; }
      if (x >= 0x10) { x >>= 4; result += 4; }
      if (x >= 0x4) { x >>= 2; result += 2; }
      if (x >= 0x2) result += 1; // No need to shift x anymore

      return result;
    }
  }
}

library Constants {
    uint256 public constant MAX_VALUE = type(uint256).max;
    uint256 public constant WAD_LEVERAGE_1000 = 1_000e18;
    uint256 public constant YEAR_IN_SECONDS = 365 days;
    uint256 public constant MAX_CHUNK_SIZE = 50;
}

library IporMath {
    uint256 private constant RAY = 1e27;

    //@notice Division with rounding up on last position, x, and y is with MD
    function division(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = (x + (y / 2)) / y;
    }

    function divisionInt(int256 x, int256 y) internal pure returns (int256 z) {
        uint256 absX = uint256(x < 0 ? -x : x);
        uint256 absY = uint256(y < 0 ? -y : y);

        // Use bitwise XOR to get the sign on MBS bit then shift to LSB
        // sign == 0x0000...0000 ==  0 if the number is non-negative
        // sign == 0xFFFF...FFFF == -1 if the number is negative
        int256 sign = (x ^ y) >> 255;

        uint256 divAbs;
        uint256 remainder;

        unchecked {
            divAbs = absX / absY;
            remainder = absX % absY;
        }
        // Check if we need to round
        if (sign < 0) {
            // remainder << 1 left shift is equivalent to multiplying by 2
            if (remainder << 1 > absY) {
                ++divAbs;
            }
        } else {
            if (remainder << 1 >= absY) {
                ++divAbs;
            }
        }

        // (sign | 1) is cheaper than (sign < 0) ? -1 : 1;
        unchecked {
            z = int256(divAbs) * (sign | 1);
        }
    }

    function divisionWithoutRound(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x / y;
    }

    function convertWadToAssetDecimals(uint256 value, uint256 assetDecimals) internal pure returns (uint256) {
        if (assetDecimals == 18) {
            return value;
        } else if (assetDecimals > 18) {
            return value * 10 ** (assetDecimals - 18);
        } else {
            return division(value, 10 ** (18 - assetDecimals));
        }
    }

    function convertWadToAssetDecimalsWithoutRound(
        uint256 value,
        uint256 assetDecimals
    ) internal pure returns (uint256) {
        if (assetDecimals == 18) {
            return value;
        } else if (assetDecimals > 18) {
            return value * 10 ** (assetDecimals - 18);
        } else {
            return divisionWithoutRound(value, 10 ** (18 - assetDecimals));
        }
    }

    function convertToWad(uint256 value, uint256 assetDecimals) internal pure returns (uint256) {
        if (value > 0) {
            if (assetDecimals == 18) {
                return value;
            } else if (assetDecimals > 18) {
                return division(value, 10 ** (assetDecimals - 18));
            } else {
                return value * 10 ** (18 - assetDecimals);
            }
        } else {
            return value;
        }
    }

    function absoluteValue(int256 value) internal pure returns (uint256) {
        return (uint256)(value < 0 ? -value : value);
    }

    function percentOf(uint256 value, uint256 rate) internal pure returns (uint256) {
        return division(value * rate, 1e18);
    }

    /// @notice Calculates x^n where x and y are represented in RAY (27 decimals)
    /// @param x base, represented in 27 decimals
    /// @param n exponent, represented in 27 decimals
    /// @return z x^n represented in 27 decimals
    function rayPow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := RAY
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := RAY
                }
                default {
                    z := x
                }
                let half := div(RAY, 2) // for rounding.
                for {
                    n := div(n, 2)
                } n {
                    n := div(n, 2)
                } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) {
                        revert(0, 0)
                    }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    x := div(xxRound, RAY)
                    if mod(n, 2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                            revert(0, 0)
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, RAY)
                    }
                }
            }
        }
    }
}

library InterestRates {
    using SafeCast for uint256;

    /// @notice Adds interest to given value using continuous compounding formula: v2 = value * e^(interestRate * time)
    /// @param value value to which interest is added, value represented in 18 decimals
    /// @param interestRatePeriodMultiplication interest rate * time, interest rate in 18 decimals, time in seconds
    /// @return value with interest, value represented in 18 decimals
    function addContinuousCompoundInterestUsingRatePeriodMultiplication(
        uint256 value,
        uint256 interestRatePeriodMultiplication
    ) internal pure returns (uint256) {
        uint256 interestRateYearsMultiplication = IporMath.division(
            interestRatePeriodMultiplication,
            Constants.YEAR_IN_SECONDS
        );
        bytes16 floatValue = _toQuadruplePrecision(value, 1e18);
        bytes16 floatIpm = _toQuadruplePrecision(interestRateYearsMultiplication, 1e18);
        bytes16 valueWithInterest = ABDKMathQuad.mul(floatValue, ABDKMathQuad.exp(floatIpm));
        return _toUint256(valueWithInterest);
    }

    /// @notice Adds interest to given value using continuous compounding formula: v2 = value * e^(interestRate * time)
    /// @param value value to which interest is added, value represented in 18 decimals
    /// @param interestRatePeriodMultiplication interest rate * time, interest rate in 18 decimals, time in seconds
    /// @return value with interest, value represented in 18 decimals
    function addContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
        int256 value,
        int256 interestRatePeriodMultiplication
    ) internal pure returns (int256) {
        int256 interestRateYearsMultiplication = IporMath.divisionInt(
            interestRatePeriodMultiplication,
            Constants.YEAR_IN_SECONDS.toInt256()
        );
        bytes16 floatValue = _toQuadruplePrecisionInt(value, 1e18);
        bytes16 floatIpm = _toQuadruplePrecisionInt(interestRateYearsMultiplication, 1e18);
        bytes16 valueWithInterest = ABDKMathQuad.mul(floatValue, ABDKMathQuad.exp(floatIpm));
        return _toInt256(valueWithInterest);
    }

    /// @notice Calculates interest to given value using continuous compounding formula: v2 = value * e^(interestRate * time)
    /// @param value value to which interest is added, value represented in 18 decimals
    /// @param interestRatePeriodMultiplication interest rate * time, interest rate in 18 decimals, time in seconds
    /// @return interest, value represented in 18 decimals
    function calculateContinuousCompoundInterestUsingRatePeriodMultiplication(
        uint256 value,
        uint256 interestRatePeriodMultiplication
    ) internal pure returns (uint256) {
        return
            addContinuousCompoundInterestUsingRatePeriodMultiplication(value, interestRatePeriodMultiplication) - value;
    }

    /// @notice Calculates interest to given value using continuous compounding formula: v2 = value * e^(interestRate * time)
    /// @param value value to which interest is added, value represented in 18 decimals
    /// @param interestRatePeriodMultiplication interest rate * time, interest rate in 18 decimals, time in seconds
    /// @return interest, value represented in 18 decimals
    function calculateContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
        int256 value,
        int256 interestRatePeriodMultiplication
    ) internal pure returns (int256) {
        return
            addContinuousCompoundInterestUsingRatePeriodMultiplicationInt(value, interestRatePeriodMultiplication) -
            value;
    }

    /// @dev Quadruple precision, 128 bits
    function _toQuadruplePrecision(uint256 number, uint256 decimals) private pure returns (bytes16) {
        if (number % decimals > 0) {
            /// @dev during calculation this value is lost in the conversion
            number += 1;
        }
        bytes16 nominator = ABDKMathQuad.fromUInt(number);
        bytes16 denominator = ABDKMathQuad.fromUInt(decimals);
        bytes16 fraction = ABDKMathQuad.div(nominator, denominator);
        return fraction;
    }

    /// @dev Quadruple precision, 128 bits
    function _toQuadruplePrecisionInt(int256 number, int256 decimals) private pure returns (bytes16) {
        if (number % decimals > 0) {
            /// @dev during calculation this value is lost in the conversion
            number += 1;
        }
        bytes16 nominator = ABDKMathQuad.fromInt(number);
        bytes16 denominator = ABDKMathQuad.fromInt(decimals);
        bytes16 fraction = ABDKMathQuad.div(nominator, denominator);
        return fraction;
    }

    function _toUint256(bytes16 value) private pure returns (uint256) {
        bytes16 decimals = ABDKMathQuad.fromUInt(1e18);
        bytes16 resultD18 = ABDKMathQuad.mul(value, decimals);
        return ABDKMathQuad.toUInt(resultD18);
    }

    function _toInt256(bytes16 value) private pure returns (int256) {
        bytes16 decimals = ABDKMathQuad.fromUInt(1e18);
        bytes16 resultD18 = ABDKMathQuad.mul(value, decimals);
        return ABDKMathQuad.toInt(resultD18);
    }
}

/// @title Types used in AmmStorage smart contract
library AmmStorageTypes {
    /// @notice struct representing swap's ID and direction
    /// @dev direction = 0 - Pay Fixed - Receive Floating, direction = 1 - Receive Fixed - Pay Floating
    struct IporSwapId {
        /// @notice Swap's ID
        uint256 id;
        /// @notice Swap's direction, 0 - Pay Fixed Receive Floating, 1 - Receive Fixed Pay Floating
        uint8 direction;
    }

    /// @notice Struct containing extended balance information.
    /// @dev extended information includes: opening fee balance, liquidation deposit balance,
    /// IPOR publication fee balance, treasury balance, all values are with 18 decimals
    struct ExtendedBalancesMemory {
        /// @notice Swap's balance for Pay Fixed leg
        uint256 totalCollateralPayFixed;
        /// @notice Swap's balance for Receive Fixed leg
        uint256 totalCollateralReceiveFixed;
        /// @notice Liquidity Pool's Balance
        uint256 liquidityPool;
        /// @notice AssetManagement's (Asset Management) balance
        uint256 vault;
        /// @notice IPOR publication fee balance. This balance is used to subsidise the oracle operations
        uint256 iporPublicationFee;
        /// @notice Balance of the DAO's treasury. Fed by portion of the opening fee set by the DAO
        uint256 treasury;
    }

    /// @notice A struct with parameters required to calculate SOAP for pay fixed and receive fixed legs.
    /// @dev Committed to the memory.
    struct SoapIndicators {
        /// @notice Value of interest accrued on a fixed leg of all derivatives for this particular type of swap.
        /// @dev Represented in 18 decimals.
        uint256 hypotheticalInterestCumulative;
        /// @notice Sum of all swaps' notional amounts for a given leg.
        /// @dev Represented in 18 decimals.
        uint256 totalNotional;
        /// @notice Sum of all IBTs on a given leg.
        /// @dev Represented in 18 decimals.
        uint256 totalIbtQuantity;
        /// @notice The notional-weighted average interest rate of all swaps on a given leg combined.
        /// @dev Represented in 18 decimals.
        uint256 averageInterestRate;
        /// @notice EPOCH timestamp of when the most recent rebalancing took place
        uint256 rebalanceTimestamp;
    }
}

/// @notice The types used in the AmmTreasury's interface.
/// @dev All values, where applicable, are represented in 18 decimals.
library AmmInternalTypes {
    struct PnlValueStruct {
        /// @notice PnL Value of the swap.
        int256 pnlValue;
        /// @notice flag indicating if unwind is required when closing swap.
        bool swapUnwindRequired;
        /// @notice Unwind amount of the swap.
        int256 swapUnwindAmount;
        /// @notice Unwind fee of the swap that will be added to the AMM liquidity pool balance.
        uint256 swapUnwindFeeLPAmount;
        /// @notice Unwind fee of the swap that will be added to the AMM treasury balance.
        uint256 swapUnwindFeeTreasuryAmount;
    }

    struct BeforeOpenSwapStruct {
        /// @notice Sum of all asset transferred when opening swap. It includes the collateral, fees and deposits.
        /// @dev The amount is represented in 18 decimals regardless of the decimals of the asset.
        uint256 wadTotalAmount;
        /// @notice Swap's collateral.
        uint256 collateral;
        /// @notice Swap's notional amount.
        uint256 notional;
        /// @notice The part of the opening fee that will be added to the liquidity pool balance.
        uint256 openingFeeLPAmount;
        /// @notice Part of the opening fee that will be added to the treasury balance.
        uint256 openingFeeTreasuryAmount;
        /// @notice Amount of asset set aside for the oracle subsidization.
        uint256 iporPublicationFeeAmount;
        /// @notice Refundable deposit blocked for the entity that will close the swap.
        /// For more information on how the liquidations work refer to the documentation.
        /// https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/liquidations
        /// @dev value represented without decimals for USDT, USDC, DAI, with 6 decimals for stETH, as an integer.
        uint256 liquidationDepositAmount;
        /// @notice The struct describing the IPOR and its params calculated for the time when it was most recently updated and the change that took place since the update.
        /// Namely, the interest that would be computed into IBT should the rebalance occur.
        IporTypes.AccruedIpor accruedIpor;
    }

    /// @notice Risk indicators context data
    struct RiskIndicatorsContext {
        /// @notice Asset address for which the risk indicators are calculated.
        address asset;
        /// @notice Tenor of the swap.
        IporTypes.SwapTenor tenor;
        /// @notice AMM Liquidity Pool balance.
        uint256 liquidityPoolBalance;
        /// @notice AMM Min Leverage allowed for a swap.
        uint256 minLeverage;
    }

    /// @notice Spread context data
    struct SpreadContext {
        /// @notice Asset address for which the spread is calculated.
        address asset;
        /// @notice Signature of spread method used to calculate spread.
        bytes4 spreadFunctionSig;
        /// @notice Tenor of the swap.
        IporTypes.SwapTenor tenor;
        /// @notice Swap's notional
        uint256 notional;
        /// @notice Minimum leverage allowed for a swap.
        uint256 minLeverage;
        /// @notice Ipor Index Value
        uint256 indexValue;
        /// @notice Risk Indicators data for a opened swap used to calculate spread.
        AmmTypes.OpenSwapRiskIndicators riskIndicators;
        /// @notice AMM Balance for a opened swap used to calculate spread.
        IporTypes.AmmBalancesForOpenSwapMemory balance;
    }

    /// @notice Open swap item - element of linked list of swaps
    struct OpenSwapItem {
        /// @notice Swap ID
        uint32 swapId;
        /// @notcie Next swap ID in linked list
        uint32 nextSwapId;
        /// @notice Previous swap ID in linked list
        uint32 previousSwapId;
        /// @notice Timestamp of the swap opening
        uint32 openSwapTimestamp;
    }

    /// @notice Open swap list structure
    struct OpenSwapList {
        /// @notice Head swap ID
        uint32 headSwapId;
        /// @notice Swaps mapping, where key is swap ID
        mapping(uint32 => OpenSwapItem) swaps;
    }
}

/// @title Interface for interaction with the IPOR AMM Storage, contract responsible for managing AMM storage.
interface IAmmStorage {
    /// @notice Returns the current version of AmmTreasury Storage
    /// @dev Increase number when the implementation inside source code is different that the implementation deployed on the Mainnet
    /// @return current AmmTreasury Storage version, integer
    function getVersion() external pure returns (uint256);

    /// @notice Gets the configuration of the IPOR AMM Storage.
    /// @return ammTreasury address of the AmmTreasury contract
    /// @return router address of the IPOR Protocol Router contract
    function getConfiguration() external view returns (address ammTreasury, address router);

    /// @notice Gets last swap ID.
    /// @dev swap ID is incremented when new position is opened, last swap ID is used in Pay Fixed and Receive Fixed swaps.
    /// @dev ID is global for all swaps, regardless if they are Pay Fixed or Receive Fixed in tenor 28, 60 or 90 days.
    /// @return last swap ID, integer
    function getLastSwapId() external view returns (uint256);

    /// @notice Gets the last opened swap for a given tenor and direction.
    /// @param tenor tenor of the swap
    /// @param direction direction of the swap: 0 for Pay Fixed, 1 for Receive Fixed
    /// @return last opened swap {AmmInternalTypes.OpenSwapItem}
    function getLastOpenedSwap(
        IporTypes.SwapTenor tenor,
        uint256 direction
    ) external view returns (AmmInternalTypes.OpenSwapItem memory);

    /// @notice Gets the AMM balance struct
    /// @dev Balance contains:
    /// # Pay Fixed Total Collateral
    /// # Receive Fixed Total Collateral
    /// # Liquidity Pool and Vault balances.
    /// @return balance structure {IporTypes.AmmBalancesMemory}
    function getBalance() external view returns (IporTypes.AmmBalancesMemory memory);

    /// @notice Gets the balance for open swap
    /// @dev Balance contains:
    /// # Pay Fixed Total Collateral
    /// # Receive Fixed Total Collateral
    /// # Liquidity Pool balance
    /// # Total Notional Pay Fixed
    /// # Total Notional Receive Fixed
    /// @return balance structure {IporTypes.AmmBalancesForOpenSwapMemory}
    function getBalancesForOpenSwap() external view returns (IporTypes.AmmBalancesForOpenSwapMemory memory);

    /// @notice Gets the balance with the extended information: IPOR publication fee balance and Treasury balance.
    /// @return balance structure {AmmStorageTypes.ExtendedBalancesMemory}
    function getExtendedBalance() external view returns (AmmStorageTypes.ExtendedBalancesMemory memory);

    /// @notice gets the SOAP indicators.
    /// @dev SOAP is a Sum Of All Payouts, aka undealised PnL.
    /// @return indicatorsPayFixed structure {AmmStorageTypes.SoapIndicators} indicators for Pay Fixed swaps
    /// @return indicatorsReceiveFixed structure {AmmStorageTypes.SoapIndicators} indicators for Receive Fixed swaps
    function getSoapIndicators()
        external
        view
        returns (
            AmmStorageTypes.SoapIndicators memory indicatorsPayFixed,
            AmmStorageTypes.SoapIndicators memory indicatorsReceiveFixed
        );

    /// @notice Gets swap based on the direction and swap ID.
    /// @param direction direction of the swap: 0 for Pay Fixed, 1 for Receive Fixed
    /// @param swapId swap ID
    /// @return swap structure {AmmTypes.Swap}
    function getSwap(AmmTypes.SwapDirection direction, uint256 swapId) external view returns (AmmTypes.Swap memory);

    /// @notice Gets the active Pay-Fixed swaps for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Pay-Fixed swaps
    /// @return swaps array where each element has structure {AmmTypes.Swap}
    function getSwapsPayFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmTypes.Swap[] memory swaps);

    /// @notice Gets the active Receive-Fixed swaps for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Receive Fixed swaps
    /// @return swaps array where each element has structure {AmmTypes.Swap}
    function getSwapsReceiveFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmTypes.Swap[] memory swaps);

    /// @notice Gets the active Pay-Fixed and Receive-Fixed swaps IDs for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Pay-Fixed and Receive-Fixed IDs.
    /// @return ids array where each element has structure {AmmStorageTypes.IporSwapId}
    function getSwapIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmStorageTypes.IporSwapId[] memory ids);

    /// @notice adds liquidity to the Liquidity Pool. Function available only to Router.
    /// @param account account address executing request for redeem asset amount
    /// @param assetAmount amount of asset added to balance of Liquidity Pool, represented in 18 decimals
    /// @param cfgMaxLiquidityPoolBalance max liquidity pool balance taken from AmmPoolsService configuration, represented in 18 decimals.
    /// @dev Function is only available to AmmPoolsService, can be executed only by IPOR Protocol Router as internal interaction.
    function addLiquidityInternal(address account, uint256 assetAmount, uint256 cfgMaxLiquidityPoolBalance) external;

    /// @notice subtract liquidity from the Liquidity Pool. Function available only to Router.
    /// @param assetAmount amount of asset subtracted from Liquidity Pool, represented in 18 decimals
    /// @dev Function is only available to AmmPoolsService, it can be executed only by IPOR Protocol Router as internal interaction.
    function subtractLiquidityInternal(uint256 assetAmount) external;

    /// @notice Updates structures in storage: balance, swaps, SOAP indicators when new Pay-Fixed swap is opened.
    /// @dev Function is only available to AmmOpenSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param newSwap new swap structure {AmmTypes.NewSwap}
    /// @param cfgIporPublicationFee publication fee amount taken from AmmTreasury configuration, represented in 18 decimals.
    /// @return new swap ID
    function updateStorageWhenOpenSwapPayFixedInternal(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    /// @notice Updates structures in the storage: balance, swaps, SOAP indicators when new Receive-Fixed swap is opened.
    /// @dev Function is only available to AmmOpenSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param newSwap new swap structure {AmmTypes.NewSwap}
    /// @param cfgIporPublicationFee publication fee amount taken from AmmTreasury configuration, represented in 18 decimals.
    /// @return new swap ID
    function updateStorageWhenOpenSwapReceiveFixedInternal(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    /// @notice Updates structures in the storage: balance, swaps, SOAP indicators when closing Pay-Fixed swap.
    /// @dev Function is only available to AmmCloseSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param swap The swap structure containing IPOR swap information.
    /// @param pnlValue The amount that the trader has earned or lost on the swap, represented in 18 decimals.
    /// pnValue can be negative, pnlValue NOT INCLUDE potential unwind fee.
    /// @param swapUnwindFeeLPAmount unwind fee which is accounted on AMM Liquidity Pool balance.
    /// @param swapUnwindFeeTreasuryAmount unwind fee which is accounted on AMM Treasury balance.
    /// @param closingTimestamp The moment when the swap was closed.
    /// @return closedSwap A memory struct representing the closed swap.
    function updateStorageWhenCloseSwapPayFixedInternal(
        AmmTypes.Swap memory swap,
        int256 pnlValue,
        uint256 swapUnwindFeeLPAmount,
        uint256 swapUnwindFeeTreasuryAmount,
        uint256 closingTimestamp
    ) external returns (AmmInternalTypes.OpenSwapItem memory closedSwap);

    /// @notice Updates structures in the storage: swaps, balances, SOAP indicators when closing Receive-Fixed swap.
    /// @dev Function is only available to AmmCloseSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param swap The swap structure containing IPOR swap information.
    /// @param pnlValue The amount that the trader has earned or lost on the swap, represented in 18 decimals.
    /// pnValue can be negative, pnlValue NOT INCLUDE potential unwind fee.
    /// @param swapUnwindFeeLPAmount unwind fee which is accounted on AMM Liquidity Pool balance.
    /// @param swapUnwindFeeTreasuryAmount unwind fee which is accounted on AMM Treasury balance.
    /// @param closingTimestamp The moment when the swap was closed.
    /// @return closedSwap A memory struct representing the closed swap.
    function updateStorageWhenCloseSwapReceiveFixedInternal(
        AmmTypes.Swap memory swap,
        int256 pnlValue,
        uint256 swapUnwindFeeLPAmount,
        uint256 swapUnwindFeeTreasuryAmount,
        uint256 closingTimestamp
    ) external returns (AmmInternalTypes.OpenSwapItem memory closedSwap);

    /// @notice Updates the balance when the AmmPoolsService withdraws AmmTreasury's assets from the AssetManagement.
    /// @dev Function is only available to the AmmTreasury contract.
    /// @param withdrawnAmount asset amount that was withdrawn from AssetManagement to AmmTreasury by AmmPoolsService, represented in 18 decimals.
    /// @param vaultBalance Asset Management Vault (AssetManagement) balance, represented in 18 decimals
    function updateStorageWhenWithdrawFromAssetManagement(uint256 withdrawnAmount, uint256 vaultBalance) external;

    /// @notice Updates the balance when AmmPoolsService deposits AmmTreasury's assets to AssetManagement. Function is only available to AmmTreasury.
    /// @param depositAmount asset amount deposited from AmmTreasury to AssetManagement by AmmPoolsService, represented in 18 decimals.
    /// @param vaultBalance actual Asset Management Vault(AssetManagement) balance , represented in 18 decimals
    function updateStorageWhenDepositToAssetManagement(uint256 depositAmount, uint256 vaultBalance) external;

    /// @notice Updates the balance when AmmPoolsService transfers AmmTreasury's assets to Oracle Treasury's multisig wallet.
    /// @dev Function is only available to the AmmGovernanceService, can be executed only by IPOR Protocol Router as internal interaction.
    /// @param transferredAmount asset amount transferred to Charlie Treasury multisig wallet.
    function updateStorageWhenTransferToCharlieTreasuryInternal(uint256 transferredAmount) external;

    /// @notice Updates the balance when AmmPoolsService transfers AmmTreasury's assets to Treasury's multisig wallet.
    /// @dev Function is only available to the AmmGovernanceService, can be executed only by IPOR Protocol Router as internal interaction.
    /// @param transferredAmount asset amount transferred to Treasury's multisig wallet.
    function updateStorageWhenTransferToTreasuryInternal(uint256 transferredAmount) external;
}

/// @title Spread interface for tenor 28 days lens
interface ISpread28DaysLens {
    /// @notice Calculates the quote value for pay fixed 28-day period on the pay-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the pay-fixed side.
    function calculateOfferedRatePayFixed28Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external view returns (uint256 quoteValue);

    /// @notice Calculates the quote value for a fixed 28-day period on the receive-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the receive-fixed side.
    function calculateOfferedRateReceiveFixed28Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external view returns (uint256 quoteValue);

    /// @notice Returns the configuration values for the spread function used in the 28-day imbalance spread calculation.
    /// @return An array of configuration values for the spread function.
    function spreadFunction28DaysConfig() external pure returns (uint256[] memory);
}

/// @title Spread interface for tenor 60 days lens
interface ISpread60DaysLens {
    /// @notice Calculates the quote value for a fixed 60-day period on the pay-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the pay-fixed side.
    function calculateOfferedRatePayFixed60Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external returns (uint256 quoteValue);

    /// @notice Calculates the quote value for a fixed 60-day period on the receive-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the receive-fixed side.
    function calculateOfferedRateReceiveFixed60Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external returns (uint256 quoteValue);

    /// @notice Returns the configuration values for the spread function used in the 60-day imbalance spread calculation.
    /// @return An array of configuration values for the spread function.
    function spreadFunction60DaysConfig() external pure returns (uint256[] memory);
}

/// @title Spread interface for tenor 90 days lens
interface ISpread90DaysLens {
    /// @notice Calculates the quote value for a fixed 90-day period on the pay-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the pay-fixed side.
    function calculateOfferedRatePayFixed90Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external returns (uint256 quoteValue);

    /// @notice Calculates the quote value for a fixed 90-day period on the receive-fixed side based on the provided spread inputs.
    /// @param spreadInputs The spread inputs required for the calculation.
    /// @return quoteValue The calculated quote value for the receive-fixed side.
    function calculateOfferedRateReceiveFixed90Days(
        IporTypes.SpreadInputs calldata spreadInputs
    ) external returns (uint256 quoteValue);

    /// @notice Returns the configuration values for the spread function used in the 90-day imbalance spread calculation.
    /// @return An array of configuration values for the spread function.
    function spreadFunction90DaysConfig() external pure returns (uint256[] memory);
}

/// @title Errors which occur inside AmmTreasury's method execution.
library AmmErrors {
    // 300-399-AMM
    /// @notice Liquidity Pool balance is equal 0.
    string public constant LIQUIDITY_POOL_IS_EMPTY = "IPOR_300";

    /// @notice Liquidity Pool balance is too low, should be equal or higher than 0.
    string public constant LIQUIDITY_POOL_AMOUNT_TOO_LOW = "IPOR_301";

    /// @notice Liquidity Pool Collateral Ratio exceeded. Liquidity Pool Collateral Ratio is higher than configured in AmmTreasury maximum liquidity pool collateral ratio.
    string public constant LP_COLLATERAL_RATIO_EXCEEDED = "IPOR_302";

    /// @notice Liquidity Pool Collateral Ratio Per Leg exceeded. Liquidity Pool Collateral Ratio per leg is higher than configured in AmmTreasury maximum liquidity pool collateral ratio per leg.
    string public constant LP_COLLATERAL_RATIO_PER_LEG_EXCEEDED = "IPOR_303";

    /// @notice Liquidity Pool Balance is too high
    string public constant LIQUIDITY_POOL_BALANCE_IS_TOO_HIGH = "IPOR_304";

    /// @notice Swap cannot be closed because liquidity pool is too low for payid out cash. Situation should never happen where Liquidity Pool is insolvent.
    string public constant CANNOT_CLOSE_SWAP_LP_IS_TOO_LOW = "IPOR_305";

    /// @notice Swap id used in input has incorrect value (like 0) or not exists.
    string public constant INCORRECT_SWAP_ID = "IPOR_306";

    /// @notice Swap has incorrect status.
    string public constant INCORRECT_SWAP_STATUS = "IPOR_307";

    /// @notice Leverage given as a parameter when opening swap is lower than configured in AmmTreasury minimum leverage.
    string public constant LEVERAGE_TOO_LOW = "IPOR_308";

    /// @notice Leverage given as a parameter when opening swap is higher than configured in AmmTreasury maxumum leverage.
    string public constant LEVERAGE_TOO_HIGH = "IPOR_309";

    /// @notice Total amount given as a parameter when opening swap is too low. Cannot be equal zero.
    string public constant TOTAL_AMOUNT_TOO_LOW = "IPOR_310";

    /// @notice Total amount given as a parameter when opening swap is lower than sum of liquidation deposit amount and ipor publication fee.
    string public constant TOTAL_AMOUNT_LOWER_THAN_FEE = "IPOR_311";

    /// @notice Amount of collateral used to open swap is higher than configured in AmmTreasury max swap collateral amount
    string public constant COLLATERAL_AMOUNT_TOO_HIGH = "IPOR_312";

    /// @notice Acceptable fixed interest rate defined by traded exceeded.
    string public constant ACCEPTABLE_FIXED_INTEREST_RATE_EXCEEDED = "IPOR_313";

    /// @notice Swap Notional Amount is higher than Total Notional for specific leg.
    string public constant SWAP_NOTIONAL_HIGHER_THAN_TOTAL_NOTIONAL = "IPOR_314";

    /// @notice Number of swaps per leg which are going to be liquidated is too high, is higher than configured in AmmTreasury liquidation leg limit.
    string public constant MAX_LENGTH_LIQUIDATED_SWAPS_PER_LEG_EXCEEDED = "IPOR_315";

    /// @notice Sum of SOAP and Liquidity Pool Balance is lower than zero.
    /// @dev SOAP can be negative, Sum of SOAP and Liquidity Pool Balance can be negative, but this is undesirable.
    string public constant SOAP_AND_LP_BALANCE_SUM_IS_TOO_LOW = "IPOR_316";

    /// @notice Calculation timestamp is earlier than last SOAP rebalance timestamp.
    string public constant CALC_TIMESTAMP_LOWER_THAN_SOAP_REBALANCE_TIMESTAMP = "IPOR_317";

    /// @notice Calculation timestamp is lower than  Swap's open timestamp.
    string public constant CALC_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP = "IPOR_318";

    /// @notice Closing timestamp is lower than Swap's open timestamp.
    string public constant CLOSING_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP = "IPOR_319";

    /// @notice Swap cannot be closed because sender is not a buyer nor liquidator.
    string public constant CANNOT_CLOSE_SWAP_SENDER_IS_NOT_BUYER_NOR_LIQUIDATOR = "IPOR_320";

    /// @notice Interest from Strategy is below zero.
    string public constant INTEREST_FROM_STRATEGY_EXCEEDED_THRESHOLD = "IPOR_321";

    /// @notice IPOR publication fee balance is too low.
    string public constant PUBLICATION_FEE_BALANCE_IS_TOO_LOW = "IPOR_322";

    /// @notice The caller must be the Token Manager (Smart Contract responsible for managing token total supply).
    string public constant CALLER_NOT_TOKEN_MANAGER = "IPOR_323";

    /// @notice Deposit amount is too low.
    string public constant DEPOSIT_AMOUNT_IS_TOO_LOW = "IPOR_324";

    /// @notice Vault balance is lower than deposit value.
    string public constant VAULT_BALANCE_LOWER_THAN_DEPOSIT_VALUE = "IPOR_325";

    /// @notice Treasury balance is too low.
    string public constant TREASURY_BALANCE_IS_TOO_LOW = "IPOR_326";

    /// @notice Swap cannot be closed because closing timestamp is lower than swap's open timestamp in general.
    string public constant CANNOT_CLOSE_SWAP_CLOSING_IS_TOO_EARLY = "IPOR_327";

    /// @notice Swap cannot be closed because closing timestamp is lower than swap's open timestamp for buyer.
    string public constant CANNOT_CLOSE_SWAP_CLOSING_IS_TOO_EARLY_FOR_BUYER = "IPOR_328";

    /// @notice Swap cannot be closed and unwind because is too late
    string public constant CANNOT_UNWIND_CLOSING_TOO_LATE = "IPOR_329";

    /// @notice Unsupported swap tenor
    string public constant UNSUPPORTED_SWAP_TENOR = "IPOR_330";

    /// @notice Sender is not AMM (is not a IporProtocolRouter contract)
    string public constant SENDER_NOT_AMM = "IPOR_331";

    /// @notice Storage id is not time weighted notional group
    string public constant STORAGE_ID_IS_NOT_TIME_WEIGHTED_NOTIONAL = "IPOR_332";

    /// @notice Spread function is not supported
    string public constant FUNCTION_NOT_SUPPORTED = "IPOR_333";

    /// @notice Unsupported direction
    string public constant UNSUPPORTED_DIRECTION = "IPOR_334";

    /// @notice Invalid notional
    string public constant INVALID_NOTIONAL = "IPOR_335";

    /// @notice Average interest rate cannot be zero when open swap
    string public constant AVERAGE_INTEREST_RATE_WHEN_OPEN_SWAP_CANNOT_BE_ZERO = "IPOR_336";

    /// @notice Average interest rate cannot be zero when close swap
    string public constant AVERAGE_INTEREST_RATE_WHEN_CLOSE_SWAP_CANNOT_BE_ZERO = "IPOR_337";

    /// @notice Submit ETH to stETH contract failed.
    string public constant STETH_SUBMIT_FAILED = "IPOR_338";

    /// @notice Collateral is not sufficient to cover unwind swap
    string public constant COLLATERAL_IS_NOT_SUFFICIENT_TO_COVER_UNWIND_SWAP = "IPOR_339";

    /// @notice Error when withdraw from asset management is not enough to cover transfer amount to buyer and/or beneficiary
    string public constant ASSET_MANAGEMENT_WITHDRAW_NOT_ENOUGH = "IPOR_340";

    /// @notice Swap cannot be closed with unwind because action is too early, depends on value of configuration parameter `timeAfterOpenAllowedToCloseSwapWithUnwinding`
    string public constant CANNOT_CLOSE_SWAP_WITH_UNWIND_ACTION_IS_TOO_EARLY = "IPOR_341";
}

library RiskManagementLogic {
    using Address for address;

    /// @notice Stuct describing the context for calculating the offered rate
    /// @param asset Asset address
    /// @param ammStorage AMM storage address
    /// @param spreadRouter Spread router address
    /// @param minLeverage Minimum leverage
    /// @param indexValue IPOR Index value
    struct SpreadOfferedRateContext {
        address asset;
        address ammStorage;
        address spreadRouter;
        uint256 minLeverage;
        uint256 indexValue;
    }

    /// @notice Calculates the offered rate
    /// @param direction Swap direction
    /// @param tenor Swap tenor
    /// @param swapNotional Swap notional
    /// @param spreadOfferedRateCtx Context for calculating the offered rate
    /// @return Offered rate
    function calculateOfferedRate(
        uint256 direction,
        IporTypes.SwapTenor tenor,
        uint256 swapNotional,
        SpreadOfferedRateContext memory spreadOfferedRateCtx,
        AmmTypes.OpenSwapRiskIndicators memory riskIndicators
    ) internal view returns (uint256) {
        IporTypes.AmmBalancesForOpenSwapMemory memory balance = IAmmStorage(spreadOfferedRateCtx.ammStorage)
            .getBalancesForOpenSwap();

        return
            abi.decode(
                spreadOfferedRateCtx.spreadRouter.functionStaticCall(
                    abi.encodeWithSelector(
                        determineSpreadMethodSig(direction, tenor),
                        spreadOfferedRateCtx.asset,
                        swapNotional,
                        riskIndicators.demandSpreadFactor,
                        riskIndicators.baseSpreadPerLeg,
                        balance.totalCollateralPayFixed,
                        balance.totalCollateralReceiveFixed,
                        balance.liquidityPool,
                        spreadOfferedRateCtx.indexValue,
                        riskIndicators.fixedRateCapPerLeg
                    )
                ),
                (uint256)
            );
    }

    /// @notice Determines the spread method signature based on the swap direction and tenor
    /// @param direction Swap direction
    /// @param tenor Swap tenor
    /// @return Spread method signature
    function determineSpreadMethodSig(uint256 direction, IporTypes.SwapTenor tenor) internal pure returns (bytes4) {
        if (direction == 0) {
            if (tenor == IporTypes.SwapTenor.DAYS_28) {
                return ISpread28DaysLens.calculateOfferedRatePayFixed28Days.selector;
            } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
                return ISpread60DaysLens.calculateOfferedRatePayFixed60Days.selector;
            } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
                return ISpread90DaysLens.calculateOfferedRatePayFixed90Days.selector;
            } else {
                revert(AmmErrors.UNSUPPORTED_SWAP_TENOR);
            }
        } else if (direction == 1) {
            if (tenor == IporTypes.SwapTenor.DAYS_28) {
                return ISpread28DaysLens.calculateOfferedRateReceiveFixed28Days.selector;
            } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
                return ISpread60DaysLens.calculateOfferedRateReceiveFixed60Days.selector;
            } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
                return ISpread90DaysLens.calculateOfferedRateReceiveFixed90Days.selector;
            } else {
                revert(AmmErrors.UNSUPPORTED_SWAP_TENOR);
            }
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}

library RiskIndicatorsValidatorLib {
    using ECDSA for bytes32;
    
    function verify(
        AmmTypes.RiskIndicatorsInputs memory inputs,
        address asset,
        uint256 tenor,
        uint256 direction,
        address signerAddress
    ) internal view returns (AmmTypes.OpenSwapRiskIndicators memory riskIndicators) {
        bytes32 hash = hashRiskIndicatorsInputs(inputs, asset, tenor, direction);
        require(
            hash.recover(inputs.signature) == signerAddress,
            IporErrors.RISK_INDICATORS_SIGNATURE_INVALID
        );
        require(inputs.expiration > block.timestamp, IporErrors.RISK_INDICATORS_EXPIRED);
        return AmmTypes.OpenSwapRiskIndicators(
            inputs.maxCollateralRatio,
            inputs.maxCollateralRatioPerLeg,
            inputs.maxLeveragePerLeg,
            inputs.baseSpreadPerLeg,
            inputs.fixedRateCapPerLeg,
            inputs.demandSpreadFactor);
    }

    function hashRiskIndicatorsInputs(
        AmmTypes.RiskIndicatorsInputs memory inputs,
        address asset,
        uint256 tenor,
        uint256 direction
    ) private pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    inputs.maxCollateralRatio,
                    inputs.maxCollateralRatioPerLeg,
                    inputs.maxLeveragePerLeg,
                    inputs.baseSpreadPerLeg,
                    inputs.fixedRateCapPerLeg,
                    inputs.demandSpreadFactor,
                    inputs.expiration,
                    asset,
                    tenor,
                    direction
                )
            );
    }
}

/// @title Types used in interfaces strictly related to AMM (Automated Market Maker).
/// @dev Used by IAmmTreasury and IAmmStorage interfaces.
library AmmTypesBaseV1 {
    /// @notice Struct representing swap item, used for listing and in internal calculations
    struct Swap {
        /// @notice Swap's unique ID
        uint256 id;
        /// @notice Swap's buyer
        address buyer;
        /// @notice Swap opening epoch timestamp
        uint256 openTimestamp;
        /// @notice Swap's tenor
        IporTypes.SwapTenor tenor;
        /// @notice Swap's direction
        AmmTypes.SwapDirection direction;
        /// @notice Index position of this Swap in an array of swaps' identification associated to swap buyer
        /// @dev Field used for gas optimization purposes, it allows for quick removal by id in the array.
        /// During removal the last item in the array is switched with the one that just has been removed.
        uint256 idsIndex;
        /// @notice Swap's collateral
        /// @dev value represented in 18 decimals
        uint256 collateral;
        /// @notice Swap's notional amount
        /// @dev value represented in 18 decimals
        uint256 notional;
        /// @notice Swap's notional amount denominated in the Interest Bearing Token (IBT)
        /// @dev value represented in 18 decimals
        uint256 ibtQuantity;
        /// @notice Fixed interest rate at which the position has been opened
        /// @dev value represented in 18 decimals
        uint256 fixedInterestRate;
        /// @notice Liquidation deposit amount
        /// @dev value represented in 18 decimals
        uint256 wadLiquidationDepositAmount;
        /// @notice State of the swap
        /// @dev 0 - INACTIVE, 1 - ACTIVE
        IporTypes.SwapState state;
    }

    /// @notice Structure representing configuration of the AmmOpenSwapServicePool for specific asset (pool).
    struct AmmOpenSwapServicePoolConfiguration {
        /// @notice address of the asset
        address asset;
        /// @notice asset decimals
        uint256 decimals;
        /// @notice address of the AMM Storage
        address ammStorage;
        /// @notice address of the AMM Treasury
        address ammTreasury;
        /// @notice spread contract address
        address spread;
        /// @notice ipor publication fee, fee used when opening swap, represented in 18 decimals.
        uint256 iporPublicationFee;
        /// @notice maximum swap collateral amount, represented in 18 decimals.
        uint256 maxSwapCollateralAmount;
        /// @notice liquidation deposit amount, represented with 6 decimals. Example 25000000 = 25 units = 25.000000, 1000 = 0.001
        uint256 liquidationDepositAmount;
        /// @notice minimum leverage, represented in 18 decimals.
        uint256 minLeverage;
        /// @notice swap's opening fee rate, represented in 18 decimals. 1e18 = 100%
        uint256 openingFeeRate;
        /// @notice swap's opening fee rate, portion of the rate which is allocated to "treasury" balance
        /// @dev Value describes what percentage of opening fee amount is allocated to "treasury" balance. Value represented in 18 decimals. 1e18 = 100%
        uint256 openingFeeTreasuryPortionRate;
    }

    /// @notice Technical structure with unwinding parameters.
    struct UnwindParams {
        address asset;
        /// @notice Risk Indicators Inputs signer
        address messageSigner;
        address spread;
        address ammStorage;
        address ammTreasury;
        /// @notice Moment when the swap is closing
        uint256 closeTimestamp;
        /// @notice Swap's PnL value to moment when the swap is closing
        int256 swapPnlValueToDate;
        /// @notice Actual IPOR index value
        uint256 indexValue;
        /// @notice Swap data
        AmmTypesBaseV1.Swap swap;
        uint256 unwindingFeeRate;
        uint256 unwindingFeeTreasuryPortionRate;
        /// @notice Risk indicators for both legs pay fixed and receive fixed
        AmmTypes.CloseSwapRiskIndicatorsInput riskIndicatorsInputs;
    }

    struct BeforeOpenSwapStruct {
        /// @notice Amount of entered asset that is sent from buyer to AmmTreasury when opening swap.
        /// @dev Notice! Input Asset can be different than the asset that is used as a collateral. Value represented in decimals of input asset.
        uint256 inputAssetTotalAmount;
        /// @notice Amount of entered asset that is sent from buyer to AmmTreasury when opening swap.
        /// @dev Notice! Input Asset can be different than the asset that is used as a collateral. Value represented in 18 decimals.
        uint256 wadInputAssetTotalAmount;
        /// @notice Amount of underlying asset that is used as a collateral and other costs related to swap opening.
        /// @dev The amount is represented in decimals of the asset.
        uint256 assetTotalAmount;
        /// @notice Amount of underlying asset that is used as a collateral and other costs related to swap opening.
        /// @dev The amount is represented in 18 decimals regardless of the decimals of the asset.
        uint256 wadAssetTotalAmount;
        /// @notice Swap's collateral.
        uint256 collateral;
        /// @notice Swap's notional amount.
        uint256 notional;
        /// @notice The part of the opening fee that will be added to the liquidity pool balance.
        uint256 openingFeeLPAmount;
        /// @notice Part of the opening fee that will be added to the treasury balance.
        uint256 openingFeeTreasuryAmount;
        /// @notice Amount of asset set aside for the oracle subsidization.
        uint256 iporPublicationFeeAmount;
        /// @notice Refundable deposit blocked for the entity that will close the swap.
        /// For more information on how the liquidations work refer to the documentation.
        /// https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/liquidations
        /// @dev value represented without decimals for USDT, USDC, DAI, with 6 decimals for stETH, as an integer.
        uint256 liquidationDepositAmount;
        /// @notice The struct describing the IPOR and its params calculated for the time when it was most recently updated and the change that took place since the update.
        /// Namely, the interest that would be computed into IBT should the rebalance occur.
        IporTypes.AccruedIpor accruedIpor;
    }

    struct ClosableSwapInput {
        address account;
        address asset;
        uint256 closeTimestamp;
        address swapBuyer;
        uint256 swapOpenTimestamp;
        uint256 swapCollateral;
        IporTypes.SwapTenor swapTenor;
        IporTypes.SwapState swapState;
        int256 swapPnlValueToDate;
        uint256 minLiquidationThresholdToCloseBeforeMaturityByCommunity;
        uint256 minLiquidationThresholdToCloseBeforeMaturityByBuyer;
        uint256 timeBeforeMaturityAllowedToCloseSwapByCommunity;
        uint256 timeBeforeMaturityAllowedToCloseSwapByBuyer;
        uint256 timeAfterOpenAllowedToCloseSwapWithUnwinding;
    }

    /// @notice Struct representing amounts related to Swap that is presently being opened.
    /// @dev all values represented in 18 decimals
    struct OpenSwapAmount {
        /// @notice Amount of entered asset that is sent from buyer to AmmTreasury when opening swap.
        /// @dev Notice. Input Asset can be different than the asset that is used as a collateral. Represented in 18 decimals.
        uint256 inputAssetTotalAmount;
        /// @notice Total Amount of underlying asset that is used as a collateral.
        uint256 assetTotalAmount;
        /// @notice Swap's collateral, represented in underlying asset, represented in 18 decimals.
        uint256 collateral;
        /// @notice Swap's notional, represented in underlying asset, represented in 18 decimals.
        uint256 notional;
        /// @notice Opening Fee - part allocated as a profit of the Liquidity Pool, represented in underlying asset, represented in 18 decimals.
        uint256 openingFeeLPAmount;
        /// @notice  Part of the fee set aside for subsidizing the oracle that publishes IPOR rate. Flat fee set by the DAO. Represented in underlying asset, represented in 18 decimals.
        /// @notice Opening Fee - part allocated in Treasury balance. Part of the fee set asside for subsidising the oracle that publishes IPOR rate. Flat fee set by the DAO.
        uint256 openingFeeTreasuryAmount;
        /// @notice Fee set aside for subsidizing the oracle that publishes IPOR rate. Flat fee set by the DAO. Represented in underlying asset, represented in 18 decimals.
        uint256 iporPublicationFee;
        /// @notice Liquidation deposit is retained when the swap is opened. Notice! Value represented in 18 decimals. Represents in underlying asset, represented in 18 decimals.
        uint256 liquidationDepositAmount;
    }

    struct AmmBalanceForOpenSwap {
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Fixed & Receive Floating leg.
        uint256 totalCollateralPayFixed;
        /// @notice Total notional amount of all swaps on  Pay Fixed leg (denominated in 18 decimals).
        uint256 totalNotionalPayFixed;
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Floating & Receive Fixed leg.
        uint256 totalCollateralReceiveFixed;
        /// @notice Total notional amount of all swaps on  Receive Fixed leg (denominated in 18 decimals).
        uint256 totalNotionalReceiveFixed;
    }

    struct Balance {
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Fixed & Receive Floating leg.
        uint256 totalCollateralPayFixed;
        /// @notice Sum of all collateral put forward by the derivative buyer's on  Pay Floating & Receive Fixed leg.
        uint256 totalCollateralReceiveFixed;
        /// @notice This balance is used to track the funds accounted for IporOracle subsidization.
        uint256 iporPublicationFee;
        /// @notice Treasury is the balance that belongs to IPOR DAO and funds up to this amount can be transferred to the DAO-appointed multi-sig wallet.
        /// this ballance is fed by part of the opening fee appointed by the DAO. For more information refer to the documentation:
        /// https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/ipor-swaps#fees
        uint256 treasury;
        /// @notice Sum of all liquidation deposits for all opened swaps.
        /// @dev Value represented in 18 decimals.
        uint256 totalLiquidationDepositBalance;
    }
}

/// @title Core logic for IPOR Swap
library SwapLogicBaseV1 {
    using SafeCast for uint256;
    using SafeCast for int256;
    using InterestRates for uint256;
    using InterestRates for int256;
    using RiskIndicatorsValidatorLib for AmmTypes.RiskIndicatorsInputs;

    /// @notice Calculates core amounts related with swap
    /// @param tenor swap duration, 0 = 28 days, 1 = 60 days, 2 = 90 days
    /// @param wadTotalAmount total amount represented in 18 decimals
    /// @param leverage swap leverage, represented in 18 decimals
    /// @param wadLiquidationDepositAmount liquidation deposit amount, represented in 18 decimals
    /// @param iporPublicationFeeAmount IPOR publication fee amount, represented in 18 decimals
    /// @param openingFeeRate opening fee rate, represented in 18 decimals
    /// @return collateral collateral amount, represented in 18 decimals
    /// @return notional notional amount, represented in 18 decimals
    /// @return openingFee opening fee amount, represented in 18 decimals
    /// @dev wadTotalAmount = collateral + openingFee + wadLiquidationDepositAmount + iporPublicationFeeAmount
    /// @dev Opening Fee is a multiplication openingFeeRate and notional
    function calculateSwapAmount(
        IporTypes.SwapTenor tenor,
        uint256 wadTotalAmount,
        uint256 leverage,
        uint256 wadLiquidationDepositAmount,
        uint256 iporPublicationFeeAmount,
        uint256 openingFeeRate
    ) internal pure returns (uint256 collateral, uint256 notional, uint256 openingFee) {
        require(
            wadTotalAmount > wadLiquidationDepositAmount + iporPublicationFeeAmount,
            AmmErrors.TOTAL_AMOUNT_LOWER_THAN_FEE
        );

        uint256 availableAmount = wadTotalAmount - wadLiquidationDepositAmount - iporPublicationFeeAmount;

        collateral = IporMath.division(
            availableAmount * 1e18,
            1e18 + IporMath.division(leverage * openingFeeRate * getTenorInDays(tenor), 365 * 1e18)
        );
        notional = IporMath.division(leverage * collateral, 1e18);
        openingFee = availableAmount - collateral;
    }

    function calculatePnl(
        AmmTypesBaseV1.Swap memory swap,
        uint256 closingTimestamp,
        uint256 mdIbtPrice
    ) internal pure returns (int256 pnlValue) {
        if (swap.direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            pnlValue = calculatePnlPayFixed(
                swap.openTimestamp,
                swap.collateral,
                swap.notional,
                swap.fixedInterestRate,
                swap.ibtQuantity,
                closingTimestamp,
                mdIbtPrice
            );
        } else if (swap.direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            pnlValue = calculatePnlReceiveFixed(
                swap.openTimestamp,
                swap.collateral,
                swap.notional,
                swap.fixedInterestRate,
                swap.ibtQuantity,
                closingTimestamp,
                mdIbtPrice
            );
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }
    }

    /// @notice Calculates Profit and Loss (PnL) for a pay fixed swap for a given swap closing timestamp and IBT price from IporOracle.
    /// @param swapOpenTimestamp moment when swap is opened, represented in seconds
    /// @param swapCollateral collateral value, represented in 18 decimals
    /// @param swapNotional swap notional, represented in 18 decimals
    /// @param swapFixedInterestRate fixed interest rate on a swap, represented in 18 decimals
    /// @param swapIbtQuantity IBT quantity, represented in 18 decimals
    /// @param closingTimestamp moment when swap is closed, represented in seconds
    /// @param mdIbtPrice IBT price from IporOracle, represented in 18 decimals
    /// @return pnlValue swap PnL, represented in 18 decimals
    /// @dev Calculated PnL not taken into consideration potential unwinding of the swap.
    function calculatePnlPayFixed(
        uint256 swapOpenTimestamp,
        uint256 swapCollateral,
        uint256 swapNotional,
        uint256 swapFixedInterestRate,
        uint256 swapIbtQuantity,
        uint256 closingTimestamp,
        uint256 mdIbtPrice
    ) internal pure returns (int256 pnlValue) {
        (uint256 interestFixed, uint256 interestFloating) = calculateInterest(
            swapOpenTimestamp,
            swapNotional,
            swapFixedInterestRate,
            swapIbtQuantity,
            closingTimestamp,
            mdIbtPrice
        );

        pnlValue = normalizePnlValue(swapCollateral, interestFloating.toInt256() - interestFixed.toInt256());
    }

    /// @notice Calculates Profit and Loss (PnL) for a receive fixed swap for a given swap closing timestamp and IBT price from IporOracle.
    /// @param swapOpenTimestamp moment when swap is opened, represented in seconds
    /// @param swapCollateral collateral value, represented in 18 decimals
    /// @param swapNotional swap notional, represented in 18 decimals
    /// @param swapFixedInterestRate fixed interest rate on a swap, represented in 18 decimals
    /// @param swapIbtQuantity IBT quantity, represented in 18 decimals
    /// @param closingTimestamp moment when swap is closed, represented in seconds
    /// @param mdIbtPrice IBT price from IporOracle, represented in 18 decimals
    /// @return pnlValue swap PnL, represented in 18 decimals
    /// @dev Calculated PnL not taken into consideration potential unwinding of the swap.
    function calculatePnlReceiveFixed(
        uint256 swapOpenTimestamp,
        uint256 swapCollateral,
        uint256 swapNotional,
        uint256 swapFixedInterestRate,
        uint256 swapIbtQuantity,
        uint256 closingTimestamp,
        uint256 mdIbtPrice
    ) internal pure returns (int256 pnlValue) {
        (uint256 interestFixed, uint256 interestFloating) = calculateInterest(
            swapOpenTimestamp,
            swapNotional,
            swapFixedInterestRate,
            swapIbtQuantity,
            closingTimestamp,
            mdIbtPrice
        );

        pnlValue = normalizePnlValue(swapCollateral, interestFixed.toInt256() - interestFloating.toInt256());
    }

    /// @notice Calculates interest including continuous capitalization for a given swap, closing timestamp and IBT price from IporOracle.
    /// @param swapOpenTimestamp moment when swap is opened, represented in seconds without 18 decimals
    /// @param swapNotional swap notional, represented in 18 decimals
    /// @param swapFixedInterestRate fixed interest rate on a swap, represented in 18 decimals
    /// @param swapIbtQuantity IBT quantity, represented in 18 decimals
    /// @param closingTimestamp moment when swap is closed, represented in seconds without 18 decimals
    /// @param mdIbtPrice IBT price from IporOracle, represented in 18 decimals
    /// @return interestFixed fixed interest chunk, represented in 18 decimals
    /// @return interestFloating floating interest chunk, represented in 18 decimals
    function calculateInterest(
        uint256 swapOpenTimestamp,
        uint256 swapNotional,
        uint256 swapFixedInterestRate,
        uint256 swapIbtQuantity,
        uint256 closingTimestamp,
        uint256 mdIbtPrice
    ) internal pure returns (uint256 interestFixed, uint256 interestFloating) {
        require(closingTimestamp >= swapOpenTimestamp, AmmErrors.CLOSING_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP);

        interestFixed = calculateInterestFixed(
            swapNotional,
            swapFixedInterestRate,
            closingTimestamp - swapOpenTimestamp
        );

        interestFloating = calculateInterestFloating(swapIbtQuantity, mdIbtPrice);
    }

    /// @notice Calculates fixed interest chunk including continuous capitalization for a given swap, closing timestamp and IBT price from IporOracle.
    /// @param notional swap notional, represented in 18 decimals
    /// @param swapFixedInterestRate fixed interest rate on a swap, represented in 18 decimals
    /// @param swapPeriodInSeconds swap period in seconds
    /// @return interestFixed fixed interest chunk, represented in 18 decimals
    function calculateInterestFixed(
        uint256 notional,
        uint256 swapFixedInterestRate,
        uint256 swapPeriodInSeconds
    ) internal pure returns (uint256) {
        return
            notional.addContinuousCompoundInterestUsingRatePeriodMultiplication(
                swapFixedInterestRate * swapPeriodInSeconds
            );
    }

    /// @notice Calculates floating interest chunk for a given ibt quantity and IBT current price
    /// @param ibtQuantity IBT quantity, represented in 18 decimals
    /// @param ibtCurrentPrice IBT price from IporOracle, represented in 18 decimals
    /// @return interestFloating floating interest chunk, represented in 18 decimals
    function calculateInterestFloating(uint256 ibtQuantity, uint256 ibtCurrentPrice) internal pure returns (uint256) {
        //IBTQ * IBTPtc (IBTPtc - interest bearing token price in time when swap is closed)
        return IporMath.division(ibtQuantity * ibtCurrentPrice, 1e18);
    }

    /// @notice Splits opening fee amount into liquidity pool and treasury portions
    /// @param openingFeeAmount opening fee amount, represented in 18 decimals
    /// @param openingFeeForTreasurePortionRate opening fee for treasury portion rate taken from Protocol configuration, represented in 18 decimals
    /// @return feeForLiquidityPoolAmount liquidity pool portion of opening fee, represented in 18 decimals
    /// @return feeForTreasuryAmount treasury portion of opening fee, represented in 18 decimals
    function splitOpeningFeeAmount(
        uint256 openingFeeAmount,
        uint256 openingFeeForTreasurePortionRate
    ) internal pure returns (uint256 feeForLiquidityPoolAmount, uint256 feeForTreasuryAmount) {
        feeForTreasuryAmount = IporMath.division(openingFeeAmount * openingFeeForTreasurePortionRate, 1e18);
        feeForLiquidityPoolAmount = openingFeeAmount - feeForTreasuryAmount;
    }

    /// @notice Gets swap tenor in days
    /// @param tenor Swap tenor
    /// @return swap tenor in days
    function getTenorInDays(IporTypes.SwapTenor tenor) internal pure returns (uint256) {
        if (tenor == IporTypes.SwapTenor.DAYS_28) {
            return 28;
        } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
            return 60;
        } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
            return 90;
        } else {
            revert(AmmErrors.UNSUPPORTED_SWAP_TENOR);
        }
    }

    /// @notice Normalizes swap value to collateral value. Absolute value Swap PnL can't be higher than collateral.
    /// @param collateral collateral value, represented in 18 decimals
    /// @param pnlValue swap PnL, represented in 18 decimals
    function normalizePnlValue(uint256 collateral, int256 pnlValue) internal pure returns (int256) {
        int256 intCollateral = collateral.toInt256();

        if (pnlValue > 0) {
            if (pnlValue < intCollateral) {
                return pnlValue;
            } else {
                return intCollateral;
            }
        } else {
            if (pnlValue < -intCollateral) {
                return -intCollateral;
            } else {
                return pnlValue;
            }
        }
    }

    /// @notice Gets swap tenor in seconds
    /// @param tenor Swap tenor
    /// @return swap tenor in seconds
    function getTenorInSeconds(IporTypes.SwapTenor tenor) internal pure returns (uint256) {
        if (tenor == IporTypes.SwapTenor.DAYS_28) {
            return 28 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
            return 60 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
            return 90 days;
        }
        revert(AmmErrors.UNSUPPORTED_SWAP_TENOR);
    }
}

/// @title Interface for interaction with the IPOR AMM Storage, contract responsible for managing AMM storage.
interface IAmmStorageBaseV1 {
    /// @notice Returns the current version of AmmTreasury Storage
    /// @dev Increase number when the implementation inside source code is different that the implementation deployed on the Mainnet
    /// @return current AmmTreasury Storage version, integer
    function getVersion() external pure returns (uint256);

    /// @notice Gets last swap ID.
    /// @dev swap ID is incremented when new position is opened, last swap ID is used in Pay Fixed and Receive Fixed swaps.
    /// @dev ID is global for all swaps, regardless if they are Pay Fixed or Receive Fixed in tenor 28, 60 or 90 days.
    /// @return last swap ID, integer
    function getLastSwapId() external view returns (uint256);

    /// @notice Gets the last opened swap for a given tenor and direction.
    /// @param tenor tenor of the swap
    /// @param direction direction of the swap: 0 for Pay Fixed, 1 for Receive Fixed
    /// @return last opened swap {AmmInternalTypes.OpenSwapItem}
    function getLastOpenedSwap(
        IporTypes.SwapTenor tenor,
        uint256 direction
    ) external view returns (AmmInternalTypes.OpenSwapItem memory);

    /// @notice Gets the AMM balance struct
    /// @dev Balance contains:
    /// # Pay Fixed Total Collateral
    /// # Receive Fixed Total Collateral
    /// # Liquidity Pool and Vault balances.
    /// All balances are represented in 18 decimals.
    /// @return balance structure {AmmTypesBaseV1.Balance}
    function getBalance() external view returns (AmmTypesBaseV1.Balance memory);

    /// @notice Gets the balance for open swap
    /// @dev Balance contains:
    /// # Pay Fixed Total Collateral
    /// # Receive Fixed Total Collateral
    /// # Liquidity Pool balance
    /// # Total Notional Pay Fixed
    /// # Total Notional Receive Fixed
    /// @return balance structure {AmmTypesBaseV1.AmmBalanceForOpenSwap}
    function getBalancesForOpenSwap() external view returns (AmmTypesBaseV1.AmmBalanceForOpenSwap memory);

    /// @notice gets the SOAP indicators.
    /// @dev SOAP is a Sum Of All Payouts, aka undealised PnL.
    /// @return indicatorsPayFixed structure {AmmStorageTypes.SoapIndicators} indicators for Pay Fixed swaps
    /// @return indicatorsReceiveFixed structure {AmmStorageTypes.SoapIndicators} indicators for Receive Fixed swaps
    function getSoapIndicators()
        external
        view
        returns (
            AmmStorageTypes.SoapIndicators memory indicatorsPayFixed,
            AmmStorageTypes.SoapIndicators memory indicatorsReceiveFixed
        );

    /// @notice Gets swap based on the direction and swap ID.
    /// @param direction direction of the swap: 0 for Pay Fixed, 1 for Receive Fixed
    /// @param swapId swap ID
    /// @return swap structure {AmmTypesBaseV1.sol.Swap}
    function getSwap(
        AmmTypes.SwapDirection direction,
        uint256 swapId
    ) external view returns (AmmTypesBaseV1.Swap memory);

    /// @notice Gets the active Pay-Fixed swaps for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Pay-Fixed swaps
    /// @return swaps array where each element has structure {AmmTypesBaseV1.sol.Swap}
    function getSwapsPayFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmTypesBaseV1.Swap[] memory swaps);

    /// @notice Gets the active Receive-Fixed swaps for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Receive Fixed swaps
    /// @return swaps array where each element has structure {AmmTypesBaseV1.sol.Swap}
    function getSwapsReceiveFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmTypesBaseV1.Swap[] memory swaps);

    /// @notice Gets the active Pay-Fixed and Receive-Fixed swaps IDs for a given account address.
    /// @param account account address
    /// @param offset offset for paging
    /// @param chunkSize page size for paging
    /// @return totalCount total number of active Pay-Fixed and Receive-Fixed IDs.
    /// @return ids array where each element has structure {AmmStorageTypes.IporSwapId}
    function getSwapIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, AmmStorageTypes.IporSwapId[] memory ids);

    /// @notice Updates structures in storage: balance, swaps, SOAP indicators when new Pay-Fixed swap is opened.
    /// @dev Function is only available to AmmOpenSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param newSwap new swap structure {AmmTypesBaseV1.sol.NewSwap}
    /// @param cfgIporPublicationFee publication fee amount taken from AmmTreasury configuration, represented in 18 decimals.
    /// @return new swap ID
    function updateStorageWhenOpenSwapPayFixedInternal(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    /// @notice Updates structures in the storage: balance, swaps, SOAP indicators when new Receive-Fixed swap is opened.
    /// @dev Function is only available to AmmOpenSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param newSwap new swap structure {AmmTypesBaseV1.sol.NewSwap}
    /// @param cfgIporPublicationFee publication fee amount taken from AmmTreasury configuration, represented in 18 decimals.
    /// @return new swap ID
    function updateStorageWhenOpenSwapReceiveFixedInternal(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    /// @notice Updates structures in the storage: balance, swaps, SOAP indicators when closing Pay-Fixed swap.
    /// @dev Function is only available to AmmCloseSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param swap The swap structure containing IPOR swap information.
    /// @param pnlValue The amount that the trader has earned or lost on the swap, represented in 18 decimals.
    /// pnValue can be negative, pnlValue NOT INCLUDE potential unwind fee.
    /// @param swapUnwindFeeLPAmount unwind fee which is accounted on AMM Liquidity Pool balance.
    /// @param swapUnwindFeeTreasuryAmount unwind fee which is accounted on AMM Treasury balance.
    /// @param closingTimestamp The moment when the swap was closed.
    /// @return closedSwap A memory struct representing the closed swap.
    function updateStorageWhenCloseSwapPayFixedInternal(
        AmmTypesBaseV1.Swap memory swap,
        int256 pnlValue,
        uint256 swapUnwindFeeLPAmount,
        uint256 swapUnwindFeeTreasuryAmount,
        uint256 closingTimestamp
    ) external returns (AmmInternalTypes.OpenSwapItem memory closedSwap);

    /// @notice Updates structures in the storage: swaps, balances, SOAP indicators when closing Receive-Fixed swap.
    /// @dev Function is only available to AmmCloseSwapService, it can be executed only by IPOR Protocol Router as internal interaction.
    /// @param swap The swap structure containing IPOR swap information.
    /// @param pnlValue The amount that the trader has earned or lost on the swap, represented in 18 decimals.
    /// pnValue can be negative, pnlValue NOT INCLUDE potential unwind fee.
    /// @param swapUnwindFeeLPAmount unwind fee which is accounted on AMM Liquidity Pool balance.
    /// @param swapUnwindFeeTreasuryAmount unwind fee which is accounted on AMM Treasury balance.
    /// @param closingTimestamp The moment when the swap was closed.
    /// @return closedSwap A memory struct representing the closed swap.
    function updateStorageWhenCloseSwapReceiveFixedInternal(
        AmmTypesBaseV1.Swap memory swap,
        int256 pnlValue,
        uint256 swapUnwindFeeLPAmount,
        uint256 swapUnwindFeeTreasuryAmount,
        uint256 closingTimestamp
    ) external returns (AmmInternalTypes.OpenSwapItem memory closedSwap);

    /// @notice Updates the balance when AmmPoolsService transfers AmmTreasury's assets to Oracle Treasury's multisig wallet.
    /// @dev Function is only available to the AmmGovernanceService, can be executed only by IPOR Protocol Router as internal interaction.
    /// @param transferredAmount asset amount transferred to Charlie Treasury multisig wallet.
    function updateStorageWhenTransferToCharlieTreasuryInternal(uint256 transferredAmount) external;

    /// @notice Updates the balance when AmmPoolsService transfers AmmTreasury's assets to Treasury's multisig wallet.
    /// @dev Function is only available to the AmmGovernanceService, can be executed only by IPOR Protocol Router as internal interaction.
    /// @param transferredAmount asset amount transferred to Treasury's multisig wallet.
    function updateStorageWhenTransferToTreasuryInternal(uint256 transferredAmount) external;
}

/// @notice Interface of the AmmTreasury contract.
interface IAmmTreasuryBaseV1 {
    /// @notice Gets router address.
    function router() external view returns (address);

    /// @notice Retrieves the version number of the contract.
    /// @return The version number of the contract.
    /// @dev This function provides a way to access the version information of the contract.
    /// Currently, the version is set to 1.
    function getVersion() external pure returns (uint256);

    /// @notice Gets the balance of the liquidity pool.
    /// @dev Liquidity Pool balance not take into account following balances: collateral, ipor publication fee, treasury
    function getLiquidityPoolBalance() external view returns (uint256);

    /// @notice Pauses the contract and revokes the approval of stEth tokens for the router.
    /// @dev This function can only be called by the pause guardian.
    /// It revokes the approval of stEth tokens for the router and then pauses the contract.
    /// require Caller must be the pause guardian.
    function pause() external;

    /// @notice Unpauses the contract and forcefully approves the router to transfer an unlimited amount of stEth tokens.
    /// @dev This function can only be called by the contract owner.
    /// It unpauses the contract and then forcefully sets the approval of stEth tokens for the router to the maximum possible value.
    /// require Caller must be the contract owner.
    function unpause() external;

    /// @notice Checks if the given account is a pause guardian.
    /// @param account Address to be checked.
    /// @return A boolean indicating whether the provided account is a pause guardian.
    /// @dev This function queries the PauseManager to determine if the provided account is a pause guardian.
    function isPauseGuardian(address account) external view returns (bool);

    /// @notice Adds a new pause guardian to the contract.
    /// @param guardians List Addresses of the accounts to be added as a pause guardian.
    /// @dev This function can only be called by the contract owner.
    /// It delegates the addition of a new pause guardian to the PauseManager.
    /// require Caller must be the contract owner.
    function addPauseGuardians(address[] calldata guardians) external;

    /// @notice Removes an existing pause guardian from the contract.
    /// @param guardians List addresses of the accounts to be removed as a pause guardian.
    /// @dev This function can only be called by the contract owner.
    /// It delegates the removal of a pause guardian to the PauseManager.
    /// require Caller must be the contract owner.
    function removePauseGuardians(address[] calldata guardians) external;
}

/// @title Spread storage library
library SpreadStorageLibsBaseV1 {
    using SafeCast for uint256;
    uint256 private constant STORAGE_SLOT_BASE = 10_000;

    /// Only allowed to append new value to the end of the enum
    enum StorageId {
        // WeightedNotionalStorage
        TimeWeightedNotional28Days,
        TimeWeightedNotional60Days,
        TimeWeightedNotional90Days
    }

    /// @notice Saves time weighted notional for a specific asset and tenor
    /// @param timeWeightedNotionalStorageId The storage ID of the time weighted notional
    /// @param timeWeightedNotional The time weighted notional to save
    function saveTimeWeightedNotionalForAssetAndTenor(
        StorageId timeWeightedNotionalStorageId,
        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory timeWeightedNotional
    ) internal {
        checkTimeWeightedNotional(timeWeightedNotionalStorageId);

        uint256 timeWeightedNotionalPayFixedTemp;
        uint256 timeWeightedNotionalReceiveFixedTemp;

        unchecked {
            timeWeightedNotionalPayFixedTemp = timeWeightedNotional.timeWeightedNotionalPayFixed / 1e18;

            timeWeightedNotionalReceiveFixedTemp = timeWeightedNotional.timeWeightedNotionalReceiveFixed / 1e18;
        }

        uint96 timeWeightedNotionalPayFixed = timeWeightedNotionalPayFixedTemp.toUint96();
        uint32 lastUpdateTimePayFixed = timeWeightedNotional.lastUpdateTimePayFixed.toUint32();
        uint96 timeWeightedNotionalReceiveFixed = timeWeightedNotionalReceiveFixedTemp.toUint96();
        uint32 lastUpdateTimeReceiveFixed = timeWeightedNotional.lastUpdateTimeReceiveFixed.toUint32();
        uint256 slotAddress = _getStorageSlot(timeWeightedNotionalStorageId);

        assembly {
            let value := add(
                timeWeightedNotionalPayFixed,
                add(
                    shl(96, lastUpdateTimePayFixed),
                    add(shl(128, timeWeightedNotionalReceiveFixed), shl(224, lastUpdateTimeReceiveFixed))
                )
            )
            sstore(slotAddress, value)
        }
    }

    /// @notice Gets the time-weighted notional for a specific storage ID representing an asset and tenor
    /// @param timeWeightedNotionalStorageId The storage ID of the time weighted notional
    function getTimeWeightedNotionalForAssetAndTenor(
        StorageId timeWeightedNotionalStorageId
    ) internal view returns (SpreadTypesBaseV1.TimeWeightedNotionalMemory memory weightedNotional28Days) {
        checkTimeWeightedNotional(timeWeightedNotionalStorageId);

        uint256 timeWeightedNotionalPayFixed;
        uint256 lastUpdateTimePayFixed;
        uint256 timeWeightedNotionalReceiveFixed;
        uint256 lastUpdateTimeReceiveFixed;
        uint256 slotAddress = _getStorageSlot(timeWeightedNotionalStorageId);

        assembly {
            let slotValue := sload(slotAddress)
            timeWeightedNotionalPayFixed := mul(and(slotValue, 0xFFFFFFFFFFFFFFFFFFFFFFFF), 1000000000000000000)
            lastUpdateTimePayFixed := and(shr(96, slotValue), 0xFFFFFFFF)
            timeWeightedNotionalReceiveFixed := mul(
                and(shr(128, slotValue), 0xFFFFFFFFFFFFFFFFFFFFFFFF),
                1000000000000000000
            )
            lastUpdateTimeReceiveFixed := and(shr(224, slotValue), 0xFFFFFFFF)
        }

        return
            SpreadTypesBaseV1.TimeWeightedNotionalMemory({
                timeWeightedNotionalPayFixed: timeWeightedNotionalPayFixed,
                lastUpdateTimePayFixed: lastUpdateTimePayFixed,
                timeWeightedNotionalReceiveFixed: timeWeightedNotionalReceiveFixed,
                lastUpdateTimeReceiveFixed: lastUpdateTimeReceiveFixed,
                storageId: timeWeightedNotionalStorageId
            });
    }

    /// @notice Gets all time weighted notional storage IDs
    function getAllStorageId() internal pure returns (StorageId[] memory storageIds, string[] memory keys) {
        storageIds = new StorageId[](3);
        keys = new string[](3);
        storageIds[0] = StorageId.TimeWeightedNotional28Days;
        keys[0] = "TimeWeightedNotional28Days";
        storageIds[1] = StorageId.TimeWeightedNotional60Days;
        keys[1] = "TimeWeightedNotional60Days";
        storageIds[2] = StorageId.TimeWeightedNotional90Days;
        keys[2] = "TimeWeightedNotional90Days";
    }

    function checkTimeWeightedNotional(StorageId storageId) internal pure {
        require(
            storageId == StorageId.TimeWeightedNotional28Days ||
                storageId == StorageId.TimeWeightedNotional60Days ||
                storageId == StorageId.TimeWeightedNotional90Days,
            AmmErrors.STORAGE_ID_IS_NOT_TIME_WEIGHTED_NOTIONAL
        );
    }

    function _getStorageSlot(StorageId storageId) private pure returns (uint256 slot) {
        slot = uint256(storageId) + STORAGE_SLOT_BASE;
    }
}

library SpreadTypesBaseV1 {
    /// @notice structure used to save the weighted notional for the 28 days into storage
    /// timeWeightedNotionalPayFixed without decimals - uint96 - bytes 0-96
    /// lastUpdateTimePayFixed - uint32 - bytes 96-128
    /// timeWeightedNotionalReceiveFixed  without decimals - uint96 - bytes 128-224
    /// lastUpdateTimeReceiveFixed - uint32 - bytes 224-256
    struct WeightedNotionalStorage {
        bytes32 weightedNotional;
    }

    /// @notice Dto for the Weighted Notional
    struct TimeWeightedNotionalMemory {
        /// @notice timeWeightedNotionalPayFixed with 18 decimals
        uint256 timeWeightedNotionalPayFixed;
        /// @notice lastUpdateTimePayFixed timestamp in seconds
        uint256 lastUpdateTimePayFixed;
        /// @notice timeWeightedNotionalReceiveFixed with 18 decimals
        uint256 timeWeightedNotionalReceiveFixed;
        /// @notice lastUpdateTimeReceiveFixed timestamp in seconds
        uint256 lastUpdateTimeReceiveFixed;
        /// @notice storageId from SpreadStorageLibs
        SpreadStorageLibsBaseV1.StorageId storageId;
    }

    /// @notice Technical structure used in Lens for the Weighted Notional params
    struct TimeWeightedNotionalResponse {
        /// @notice timeWeightedNotionalPayFixed time weighted notional params
        TimeWeightedNotionalMemory timeWeightedNotional;
        string key;
    }
}

interface ISpreadBaseV1 {
    struct SpreadInputs {
        //// @notice Swap's assets DAI/USDC/USDT/stETH/etc.
        address asset;
        /// @notice Swap's notional value
        uint256 swapNotional;
        /// @notice demand spread factor used in demand spread calculation
        uint256 demandSpreadFactor;
        /// @notice Base spread
        int256 baseSpreadPerLeg;
        /// @notice Swap's balance for Pay Fixed leg
        uint256 totalCollateralPayFixed;
        /// @notice Swap's balance for Receive Fixed leg
        uint256 totalCollateralReceiveFixed;
        /// @notice Liquidity Pool's Balance
        uint256 liquidityPoolBalance;
        /// @notice Ipor index value at the time of swap creation
        uint256 iporIndexValue;
        /// @notice fixed rate cap for given leg for offered rate without demandSpread in 18 decimals
        uint256 fixedRateCapPerLeg;
        /// @notice Swap's tenor
        IporTypes.SwapTenor tenor;
    }

    /// @notice Calculates and updates the offered rate for Pay Fixed leg of a swap.
    /// @dev This function should be called only through the Router contract as per the 'onlyRouter' modifier.
    ///      It calculates the offered rate for Pay Fixed swaps by taking into account various factors like
    ///      IPOR index value, base spread, demand spread, and rate cap.
    ///      The demand spread is updated based on the current market conditions and the swap's specifics.
    /// @param spreadInputs A 'SpreadInputs' struct containing all necessary data for calculating the offered rate.
    ///                     This includes the asset's address, swap's notional value, demand spread factor, base spread,
    ///                     balances for Pay Fixed and Receive Fixed legs, liquidity pool balance, IPOR index value at swap creation,
    ///                     fixed rate cap per leg, and the swap's tenor.
    /// @return offeredRate The calculated offered rate for the Pay Fixed leg in the swap.
    function calculateAndUpdateOfferedRatePayFixed(
        SpreadInputs calldata spreadInputs
    ) external returns (uint256 offeredRate);

    /// @notice Calculates the offered rate for a swap based on the specified direction (Pay Fixed or Receive Fixed).
    /// @dev This function computes the offered rate for a swap, taking into account the swap's direction,
    ///      the current IPOR index value, base spread, demand spread, and the fixed rate cap.
    ///      It is a view function and does not modify the state of the contract.
    /// @param direction An enum value from 'AmmTypes' specifying the swap direction -
    ///                  either PAY_FIXED_RECEIVE_FLOATING or PAY_FLOATING_RECEIVE_FIXED.
    /// @param spreadInputs A 'SpreadInputs' struct containing necessary data for calculating the offered rate,
    ///                     such as the asset's address, swap's notional value, demand spread factor, base spread,
    ///                     balances for Pay Fixed and Receive Fixed legs, liquidity pool balance, IPOR index value at the time of swap creation,
    ///                     fixed rate cap per leg, and the swap's tenor.
    /// @return The calculated offered rate for the specified swap direction.
    ///         The rate is returned as a uint256.
    function calculateOfferedRate(
        AmmTypes.SwapDirection direction,
        SpreadInputs calldata spreadInputs
    ) external view returns (uint256);

    /// @notice Calculates the offered rate for a Pay Fixed swap.
    /// @dev This view function computes the offered rate specifically for swaps where the Pay Fixed leg is chosen.
    ///      It considers various inputs like the IPOR index value, base spread, demand spread, and the fixed rate cap
    ///      to determine the appropriate rate. As a view function, it does not alter the state of the contract.
    /// @param spreadInputs A 'SpreadInputs' struct containing data essential for calculating the offered rate.
    ///                     This includes information such as the asset's address, the notional value of the swap,
    ///                     the demand spread factor, the base spread, balances of Pay Fixed and Receive Fixed legs,
    ///                     the liquidity pool balance, the IPOR index value at the time of swap creation, the fixed rate cap per leg,
    ///                     and the swap's tenor.
    /// @return offeredRate The calculated offered rate for the Pay Fixed leg of the swap, returned as a uint256.
    function calculateOfferedRatePayFixed(
        SpreadInputs calldata spreadInputs
    ) external view returns (uint256 offeredRate);

    /// @notice Calculates and updates the offered rate for the Receive Fixed leg of a swap.
    /// @dev This function is accessible only through the Router contract, as enforced by the 'onlyRouter' modifier.
    ///      It calculates the offered rate for Receive Fixed swaps, considering various factors like the IPOR index value,
    ///      base spread, imbalance spread, and the fixed rate cap. This function also updates the time-weighted notional
    ///      based on the current market conditions and the specifics of the swap.
    /// @param spreadInputs A 'SpreadInputs' struct containing all necessary data for calculating the offered rate.
    ///                     This includes the asset's address, swap's notional value, demand spread factor, base spread,
    ///                     balances for Pay Fixed and Receive Fixed legs, liquidity pool balance, IPOR index value at swap creation,
    ///                     fixed rate cap per leg, and the swap's tenor.
    /// @return offeredRate The calculated offered rate for the Receive Fixed leg in the swap, returned as a uint256.
    function calculateAndUpdateOfferedRateReceiveFixed(
        SpreadInputs calldata spreadInputs
    ) external returns (uint256 offeredRate);

    /// @notice Calculates the offered rate for a Receive Fixed swap.
    /// @dev This view function computes the offered rate specifically for swaps where the Receive Fixed leg is chosen.
    ///      It evaluates various inputs such as the IPOR index value, base spread, demand spread, and the fixed rate cap
    ///      to determine the appropriate rate. Being a view function, it does not modify the state of the contract.
    /// @param spreadInputs A 'SpreadInputs' struct containing the necessary data for calculating the offered rate.
    ///                     This includes the asset's address, swap's notional value, demand spread factor, base spread,
    ///                     balances for Pay Fixed and Receive Fixed legs, liquidity pool balance, the IPOR index value at the time of swap creation,
    ///                     fixed rate cap per leg, and the swap's tenor.
    /// @return offeredRate The calculated offered rate for the Receive Fixed leg of the swap, returned as a uint256.
    function calculateOfferedRateReceiveFixed(
        SpreadInputs calldata spreadInputs
    ) external view returns (uint256 offeredRate);

    /// @notice Updates the time-weighted notional values when a swap is closed.
    /// @dev This function is called upon the closure of a swap to adjust the time-weighted notional values for Pay Fixed
    ///      or Receive Fixed legs, reflecting the change in the market conditions due to the closed swap.
    ///      It takes into account the swap's direction, tenor, notional, and the details of the closed swap to make the necessary adjustments.
    /// @param direction A uint256 indicating the direction of the swap: 0 for Pay Fixed, 1 for Receive Fixed.
    /// @param tenor The tenor of the swap, represented by an enum value from 'IporTypes'.
    /// @param swapNotional The notional value of the swap that is being closed.
    /// @param closedSwap An 'OpenSwapItem' struct from 'AmmInternalTypes' representing the details of the swap that was closed.
    /// @param ammStorageAddress The address of the AMM (Automated Market Maker) storage contract where the swap data is maintained.
    /// @dev This function should only be called by an authorized Router, as it can significantly impact the contract's state.
    function updateTimeWeightedNotionalOnClose(
        uint256 direction,
        IporTypes.SwapTenor tenor,
        uint256 swapNotional,
        AmmInternalTypes.OpenSwapItem memory closedSwap,
        address ammStorageAddress
    ) external;

    /// @notice Retrieves time-weighted notional values for various asset-tenor pairs.
    /// @dev Returns an array of `TimeWeightedNotionalResponse` containing time-weighted notional values and associated keys.
    /// @return timeWeightedNotionalResponse An array of `TimeWeightedNotionalResponse` structures, each including a time-weighted notional value and a corresponding key.
    function getTimeWeightedNotional()
        external
        view
        returns (SpreadTypesBaseV1.TimeWeightedNotionalResponse[] memory timeWeightedNotionalResponse);

    /// @notice Retrieves the configuration parameters for the spread function.
    /// @dev This function provides access to the current configuration of the spread function used in the contract.
    ///      It returns an array of uint256 values, each representing a specific parameter or threshold used in
    ///      the calculation of spreads for different swap legs or conditions.
    /// @return An array of uint256 values representing the configuration parameters of the spread function.
    ///      These parameters are critical in determining how spreads are calculated for Pay Fixed and Receive Fixed swaps.
    function spreadFunctionConfig() external returns (uint256[] memory);

    /// @notice Updates the time-weighted notional values for multiple assets and tenors.
    /// @dev This function can only be called by the contract owner and overrides any existing implementation.
    ///     It iterates through an array of `TimeWeightedNotionalMemory` structures, checks each one for validity,
    ///     and then saves the updated time-weighted notional values.
    /// @param timeWeightedNotionalMemories An array of `TimeWeightedNotionalMemory` structures, where each structure
    ///        contains information about the asset, tenor, and the new time-weighted notional value to be updated.
    ///        Each `TimeWeightedNotionalMemory` structure should have a `storageId` identifying the asset and tenor
    ///        combination, along with the notional values and other relevant information.
    /// @dev The function employs an `unchecked` block for the loop iteration to optimize gas usage, assuming that
    ///         the arithmetic operation will not overflow under normal operation conditions.
    function updateTimeWeightedNotional(
        SpreadTypesBaseV1.TimeWeightedNotionalMemory[] calldata timeWeightedNotionalMemories
    ) external;

    /// @notice Returns the version number of the contract.
    /// @dev This function provides a simple way to retrieve the version number of the current contract.
    ///      It's useful for compatibility checks, upgradeability assessments, and tracking contract iterations.
    ///      The version number is returned as a uint256.
    /// @return A uint256 value representing the version number of the contract.
    function getVersion() external pure returns (uint256);
}

/// @title Storage ID's associated with the IPOR Protocol Router.
library StorageLib {
    uint256 constant STORAGE_SLOT_BASE = 1_000_000;

    // append only
    enum StorageId {
        /// @dev The address of the contract owner.
        Owner,
        AppointedOwner,
        Paused,
        PauseGuardian,
        ReentrancyStatus,
        RouterFunctionPaused,
        AmmSwapsLiquidators,
        AmmPoolsAppointedToRebalance,
        AmmPoolsParams
    }

    /// @notice Struct which contains owner address of IPOR Protocol Router.
    struct OwnerStorage {
        address owner;
    }

    /// @notice Struct which contains appointed owner address of IPOR Protocol Router.
    struct AppointedOwnerStorage {
        address appointedOwner;
    }

    /// @notice Struct which contains reentrancy status of IPOR Protocol Router.
    struct ReentrancyStatusStorage {
        uint256 value;
    }

    /// @notice Struct which contains information about swap liquidators.
    /// @dev First key is an asset (pool), second key is an liquidator address in the asset pool,
    /// value is a flag to indicate whether account is a liquidator.
    /// True - account is a liquidator, False - account is not a liquidator.
    struct AmmSwapsLiquidatorsStorage {
        mapping(address => mapping(address => bool)) value;
    }

    /// @notice Struct which contains information about accounts appointed to rebalance.
    /// @dev first key - asset address, second key - account address which is allowed to rebalance in the asset pool,
    /// value - flag to indicate whether account is allowed to rebalance. True - allowed, False - not allowed.
    struct AmmPoolsAppointedToRebalanceStorage {
        mapping(address => mapping(address => bool)) value;
    }

    struct AmmPoolsParamsValue {
        /// @dev max liquidity pool balance in the asset pool, represented without 18 decimals
        uint32 maxLiquidityPoolBalance;
        /// @dev The threshold for auto-rebalancing the pool. Value represented without 18 decimals.
        /// Value represents multiplication of 1000.
        uint32 autoRebalanceThresholdInThousands;
        /// @dev asset management ratio, represented without 18 decimals, value represents percentage with 2 decimals
        /// 65% = 6500, 99,99% = 9999, this is a percentage which stay in Amm Treasury in opposite to Asset Management
        /// based on AMM Treasury balance (100%).
        uint16 ammTreasuryAndAssetManagementRatio;
    }

    /// @dev key - asset address, value - struct AmmOpenSwapParamsValue
    struct AmmPoolsParamsStorage {
        mapping(address => AmmPoolsParamsValue) value;
    }

    /// @dev key - function sig, value - 1 if function is paused, 0 if not
    struct RouterFunctionPausedStorage {
        mapping(bytes4 => uint256) value;
    }

    /// @notice Gets Ipor Protocol Router owner address.
    function getOwner() internal pure returns (OwnerStorage storage owner) {
        uint256 slot = _getStorageSlot(StorageId.Owner);
        assembly {
            owner.slot := slot
        }
    }

    /// @notice Gets Ipor Protocol Router appointed owner address.
    function getAppointedOwner() internal pure returns (AppointedOwnerStorage storage appointedOwner) {
        uint256 slot = _getStorageSlot(StorageId.AppointedOwner);
        assembly {
            appointedOwner.slot := slot
        }
    }

    /// @notice Gets Ipor Protocol Router reentrancy status.
    function getReentrancyStatus() internal pure returns (ReentrancyStatusStorage storage reentrancyStatus) {
        uint256 slot = _getStorageSlot(StorageId.ReentrancyStatus);
        assembly {
            reentrancyStatus.slot := slot
        }
    }

    /// @notice Gets information if function is paused in Ipor Protocol Router.
    function getRouterFunctionPaused() internal pure returns (RouterFunctionPausedStorage storage paused) {
        uint256 slot = _getStorageSlot(StorageId.RouterFunctionPaused);
        assembly {
            paused.slot := slot
        }
    }

    /// @notice Gets point to pause guardian storage.
    function getPauseGuardianStorage() internal pure returns (mapping(address => bool) storage store) {
        uint256 slot = _getStorageSlot(StorageId.PauseGuardian);
        assembly {
            store.slot := slot
        }
    }

    /// @notice Gets point to liquidators storage.
    /// @return store - point to liquidators storage.
    function getAmmSwapsLiquidatorsStorage() internal pure returns (AmmSwapsLiquidatorsStorage storage store) {
        uint256 slot = _getStorageSlot(StorageId.AmmSwapsLiquidators);
        assembly {
            store.slot := slot
        }
    }

    /// @notice Gets point to accounts appointed to rebalance storage.
    /// @return store - point to accounts appointed to rebalance storage.
    function getAmmPoolsAppointedToRebalanceStorage()
        internal
        pure
        returns (AmmPoolsAppointedToRebalanceStorage storage store)
    {
        uint256 slot = _getStorageSlot(StorageId.AmmPoolsAppointedToRebalance);
        assembly {
            store.slot := slot
        }
    }

    /// @notice Gets point to amm pools params storage.
    /// @return store - point to amm pools params storage.
    function getAmmPoolsParamsStorage() internal pure returns (AmmPoolsParamsStorage storage store) {
        uint256 slot = _getStorageSlot(StorageId.AmmPoolsParams);
        assembly {
            store.slot := slot
        }
    }

    function _getStorageSlot(StorageId storageId) private pure returns (uint256 slot) {
        return uint256(storageId) + STORAGE_SLOT_BASE;
    }
}

/// @title Ipor Protocol Router Owner Manager library
library OwnerManager {
    /// @notice Emitted when account is appointed to transfer ownership
    /// @param appointedOwner Address of appointed owner
    event AppointedToTransferOwnership(address indexed appointedOwner);

    /// @notice Emitted when ownership is transferred
    /// @param previousOwner Address of previous owner
    /// @param newOwner Address of new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Gets the current owner of Ipor Protocol Router
    function getOwner() internal view returns (address) {
        return StorageLib.getOwner().owner;
    }

    /// @notice Oppoint account to transfer ownership
    /// @param newAppointedOwner Address of appointed owner
    function appointToOwnership(address newAppointedOwner) internal {
        require(newAppointedOwner != address(0), IporErrors.WRONG_ADDRESS);
        StorageLib.AppointedOwnerStorage storage appointedOwnerStorage = StorageLib.getAppointedOwner();
        appointedOwnerStorage.appointedOwner = newAppointedOwner;
        emit AppointedToTransferOwnership(newAppointedOwner);
    }

    /// @notice Confirm appointment to ownership
    /// @dev This is real transfer ownership in second step by appointed account
    function confirmAppointmentToOwnership() internal {
        StorageLib.AppointedOwnerStorage storage appointedOwnerStorage = StorageLib.getAppointedOwner();
        appointedOwnerStorage.appointedOwner = address(0);
        transferOwnership(msg.sender);
    }

    /// @notice Renounce ownership
    function renounceOwnership() internal {
        transferOwnership(address(0));
        StorageLib.AppointedOwnerStorage storage appointedOwnerStorage = StorageLib.getAppointedOwner();
        appointedOwnerStorage.appointedOwner = address(0);
    }

    /// @notice Immediately transfers ownership
    function transferOwnership(address newOwner) internal {
        StorageLib.OwnerStorage storage ownerStorage = StorageLib.getOwner();
        address oldOwner = ownerStorage.owner;
        ownerStorage.owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library AmmPoolsErrors {
    // 400-499-Amm Pools
    /// @notice IP Token Value which should be minted is too low
    string public constant IP_TOKEN_MINT_AMOUNT_TOO_LOW = "IPOR_400";

    /// @notice Amount which should be burned is too low
    string public constant IP_TOKEN_BURN_AMOUNT_TOO_LOW = "IPOR_401";

    /// @notice Liquidity Pool Collateral Ration is exceeded when redeeming
    string public constant REDEEM_LP_COLLATERAL_RATIO_EXCEEDED = "IPOR_402";

    /// @notice User cannot redeem underlying tokens because ipToken on his balance is too low
    string public constant CANNOT_REDEEM_IP_TOKEN_TOO_LOW = "IPOR_403";

    /// @notice Caller is not a treasury manager, not match address defined in IPOR Protocol configuration
    string public constant CALLER_NOT_TREASURY_MANAGER = "IPOR_404";

    /// @notice Account cannot redeem ip tokens because amount of underlying tokens for transfer to beneficiary is too low.
    string public constant CANNOT_REDEEM_ASSET_AMOUNT_TOO_LOW = "IPOR_405";

    /// @notice Sender is not a publication fee transferer, not match address defined in IporConfiguration in key AMM_TREASURY_PUBLICATION_FEE_TRANSFERER
    string public constant CALLER_NOT_PUBLICATION_FEE_TRANSFERER = "IPOR_406";

    /// @notice Asset Management Balance is empty
    string public constant ASSET_MANAGEMENT_BALANCE_IS_EMPTY = "IPOR_407";

    /// @notice Incorrect AMM Treasury and Asset Management Ratio
    string public constant AMM_TREASURY_ASSET_MANAGEMENT_RATIO = "IPOR_408";

    /// @notice Insufficient ERC20 balance
    string public constant INSUFFICIENT_ERC20_BALANCE = "IPOR_409";

    /// @notice Caller is not appointed to rebalance
    string public constant CALLER_NOT_APPOINTED_TO_REBALANCE = "IPOR_410";

    /// @notice Invalid redeem fee rate
    string public constant CFG_INVALID_REDEEM_FEE_RATE = "IPOR_411";

    /// @notice Invalid redeem lp max collateral ratio
    string public constant CFG_INVALID_REDEEM_LP_MAX_COLLATERAL_RATIO = "IPOR_412";
}

/// @title Configuration manager for AMM
library AmmConfigurationManager {
    /// @notice Emitted when new liquidator is added to the list of SwapLiquidators.
    /// @param asset address of the asset (pool)
    /// @param liquidator address of the new liquidator
    event AmmSwapsLiquidatorChanged(address indexed asset, address indexed liquidator, bool status);

    /// @notice Emitted when new account is added to the list of AppointedToRebalance.
    /// @param asset address of the asset (pool)
    /// @param account address of account appointed to rebalance
    /// @param status true if account is appointed to rebalance, false otherwise
    event AmmAppointedToRebalanceChanged(address indexed asset, address indexed account, bool status);

    /// @notice Emitted when AMM Pools Params are changed.
    /// @param asset address of the asset (pool)
    /// @param maxLiquidityPoolBalance maximum liquidity pool balance
    /// @param autoRebalanceThresholdInThousands auto rebalance threshold in thousands
    /// @param ammTreasuryAndAssetManagementRatio AMM treasury and asset management ratio
    /// @dev Params autoRebalanceThresholdInThousands and ammTreasuryAndAssetManagementRatio are not supported in stETH pool. Because stETH pool doesn't have asset management.
    event AmmPoolsParamsChanged(
        address indexed asset,
        uint32 maxLiquidityPoolBalance,
        uint32 autoRebalanceThresholdInThousands,
        uint16 ammTreasuryAndAssetManagementRatio
    );

    /// @notice Adds new liquidator to the list of SwapLiquidators.
    /// @param asset address of the asset (pool)
    /// @param account address of the new liquidator
    /// @dev Allowed only for the owner of the Ipor Protocol Router
    function addSwapLiquidator(address asset, address account) internal {
        require(account != address(0), IporErrors.WRONG_ADDRESS);
        require(asset != address(0), IporErrors.WRONG_ADDRESS);

        mapping(address => mapping(address => bool)) storage swapLiquidators = StorageLib
            .getAmmSwapsLiquidatorsStorage()
            .value;
        swapLiquidators[asset][account] = true;

        emit AmmSwapsLiquidatorChanged(asset, account, true);
    }

    /// @notice Removes liquidator from the list of SwapLiquidators.
    /// @param asset address of the asset (pool)
    /// @param account address of the liquidator
    /// @dev Allowed only for the owner of the Ipor Protocol Router
    function removeSwapLiquidator(address asset, address account) internal {
        require(account != address(0), IporErrors.WRONG_ADDRESS);
        require(asset != address(0), IporErrors.WRONG_ADDRESS);

        mapping(address => mapping(address => bool)) storage swapLiquidators = StorageLib
            .getAmmSwapsLiquidatorsStorage()
            .value;
        swapLiquidators[asset][account] = false;

        emit AmmSwapsLiquidatorChanged(asset, account, false);
    }

    /// @notice Checks if account is a SwapLiquidator.
    /// @param asset address of the asset (pool)
    /// @param account address of the account
    /// @return true if account is a SwapLiquidator, false otherwise
    function isSwapLiquidator(address asset, address account) internal view returns (bool) {
        mapping(address => mapping(address => bool)) storage swapLiquidators = StorageLib
            .getAmmSwapsLiquidatorsStorage()
            .value;
        return swapLiquidators[asset][account];
    }

    /// @notice Adds new account to the list of AppointedToRebalance in AMM.
    /// @param asset address of the asset (pool)
    /// @param account address added to appointed to rebalance
    /// @dev Allowed only for the owner of the Ipor Protocol Router
    function addAppointedToRebalanceInAmm(address asset, address account) internal {
        require(asset != address(0), IporErrors.WRONG_ADDRESS);
        require(account != address(0), IporErrors.WRONG_ADDRESS);

        mapping(address => mapping(address => bool)) storage appointedToRebalance = StorageLib
            .getAmmPoolsAppointedToRebalanceStorage()
            .value;
        appointedToRebalance[asset][account] = true;

        emit AmmAppointedToRebalanceChanged(asset, account, true);
    }

    /// @notice Removes account from the list of AppointedToRebalance in AMM.
    /// @param asset address of the asset (pool)
    /// @param account address removed from appointed to rebalance
    /// @dev Allowed only for the owner of the Ipor Protocol Router
    function removeAppointedToRebalanceInAmm(address asset, address account) internal {
        require(asset != address(0), IporErrors.WRONG_ADDRESS);
        require(account != address(0), IporErrors.WRONG_ADDRESS);

        mapping(address => mapping(address => bool)) storage appointedToRebalance = StorageLib
            .getAmmPoolsAppointedToRebalanceStorage()
            .value;
        appointedToRebalance[asset][account] = false;

        emit AmmAppointedToRebalanceChanged(asset, account, false);
    }

    /// @notice Checks if account is appointed to rebalance in AMM.
    /// @param asset address of the asset (pool)
    /// @param account address of the account
    /// @return true if account is appointed to rebalance, false otherwise
    function isAppointedToRebalanceInAmm(address asset, address account) internal view returns (bool) {
        mapping(address => mapping(address => bool)) storage appointedToRebalance = StorageLib
            .getAmmPoolsAppointedToRebalanceStorage()
            .value;
        return appointedToRebalance[asset][account];
    }

    /// @notice Sets AMM Pools Params.
    /// @param asset address of the asset (pool)
    /// @param newMaxLiquidityPoolBalance maximum liquidity pool balance
    /// @param newAutoRebalanceThresholdInThousands auto rebalance threshold (for USDT, USDC, DAI in thousands)
    /// @param newAmmTreasuryAndAssetManagementRatio AMM treasury and asset management ratio
    /// @dev Allowed only for the owner of the Ipor Protocol Router
    function setAmmPoolsParams(
        address asset,
        uint32 newMaxLiquidityPoolBalance,
        uint32 newAutoRebalanceThresholdInThousands,
        uint16 newAmmTreasuryAndAssetManagementRatio
    ) internal {
        require(asset != address(0), IporErrors.WRONG_ADDRESS);
        /// @dev newAmmTreasuryAndAssetManagementRatio is percentage with 2 decimals, example: 65% = 6500, (see description in StorageLib.AmmPoolsParamsValue)
        /// value cannot be greater than 10000 which is 100%
        require(newAmmTreasuryAndAssetManagementRatio < 1e4, AmmPoolsErrors.AMM_TREASURY_ASSET_MANAGEMENT_RATIO);

        StorageLib.getAmmPoolsParamsStorage().value[asset] = StorageLib.AmmPoolsParamsValue({
            maxLiquidityPoolBalance: newMaxLiquidityPoolBalance,
            autoRebalanceThresholdInThousands: newAutoRebalanceThresholdInThousands,
            ammTreasuryAndAssetManagementRatio: newAmmTreasuryAndAssetManagementRatio
        });

        emit AmmPoolsParamsChanged(
            asset,
            newMaxLiquidityPoolBalance,
            newAutoRebalanceThresholdInThousands,
            newAmmTreasuryAndAssetManagementRatio
        );
    }

    /// @notice Gets AMM Pools Params.
    /// @param asset address of the asset (pool)
    /// @return AMM Pools Params struct
    function getAmmPoolsParams(address asset) internal view returns (StorageLib.AmmPoolsParamsValue memory) {
        return StorageLib.getAmmPoolsParamsStorage().value[asset];
    }
}

library SwapCloseLogicLibBaseV1 {
    using SafeCast for uint256;
    using SafeCast for int256;
    using InterestRates for uint256;
    using InterestRates for int256;
    using RiskIndicatorsValidatorLib for AmmTypes.RiskIndicatorsInputs;

    function calculateSwapUnwindPnlValueNormalized(
        AmmTypesBaseV1.UnwindParams memory unwindParams,
        AmmTypes.SwapDirection oppositeDirection,
        AmmTypes.OpenSwapRiskIndicators memory oppositeRiskIndicators
    ) internal view returns (int256) {
        AmmTypesBaseV1.AmmBalanceForOpenSwap memory balance = IAmmStorageBaseV1(unwindParams.ammStorage)
            .getBalancesForOpenSwap();
        uint256 liquidityPoolBalance = IAmmTreasuryBaseV1(unwindParams.ammTreasury).getLiquidityPoolBalance();

        return
            SwapLogicBaseV1.normalizePnlValue(
                unwindParams.swap.collateral,
                calculateSwapUnwindPnlValue(
                    unwindParams.swap,
                    unwindParams.closeTimestamp,
                    ISpreadBaseV1(unwindParams.spread).calculateOfferedRate(
                        oppositeDirection,
                        ISpreadBaseV1.SpreadInputs({
                            asset: unwindParams.asset,
                            swapNotional: unwindParams.swap.notional,
                            demandSpreadFactor: oppositeRiskIndicators.demandSpreadFactor,
                            baseSpreadPerLeg: oppositeRiskIndicators.baseSpreadPerLeg,
                            totalCollateralPayFixed: balance.totalCollateralPayFixed,
                            totalCollateralReceiveFixed: balance.totalCollateralReceiveFixed,
                            liquidityPoolBalance: liquidityPoolBalance,
                            iporIndexValue: unwindParams.indexValue,
                            fixedRateCapPerLeg: oppositeRiskIndicators.fixedRateCapPerLeg,
                            tenor: unwindParams.swap.tenor
                        })
                    )
                )
            );
    }

    /// @notice Calculate swap unwind when unwind is required.
    /// @param unwindParams unwind parameters required to calculate swap unwind pnl value.
    /// @return swapUnwindPnlValue swap unwind PnL value
    /// @return swapUnwindFeeAmount swap unwind opening fee amount, sum of swapUnwindFeeLPAmount and swapUnwindFeeTreasuryAmount
    /// @return swapUnwindFeeLPAmount swap unwind opening fee LP amount
    /// @return swapUnwindFeeTreasuryAmount swap unwind opening fee treasury amount
    /// @return swapPnlValue swap PnL value includes swap PnL to date, swap unwind PnL value, this value NOT INCLUDE swap unwind fee amount.
    function calculateSwapUnwindWhenUnwindRequired(
        AmmTypesBaseV1.UnwindParams memory unwindParams
    )
        internal
        view
        returns (
            int256 swapUnwindPnlValue,
            uint256 swapUnwindFeeAmount,
            uint256 swapUnwindFeeLPAmount,
            uint256 swapUnwindFeeTreasuryAmount,
            int256 swapPnlValue
        )
    {
        AmmTypes.OpenSwapRiskIndicators memory oppositeRiskIndicators;

        if (unwindParams.swap.direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            oppositeRiskIndicators = unwindParams.riskIndicatorsInputs.receiveFixed.verify(
                unwindParams.asset,
                uint256(unwindParams.swap.tenor),
                uint256(AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED),
                unwindParams.messageSigner
            );
            /// @dev Not allow to have swap unwind pnl absolute value larger than swap collateral.
            swapUnwindPnlValue = calculateSwapUnwindPnlValueNormalized(
                unwindParams,
                AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED,
                oppositeRiskIndicators
            );
        } else if (unwindParams.swap.direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            oppositeRiskIndicators = unwindParams.riskIndicatorsInputs.payFixed.verify(
                unwindParams.asset,
                uint256(unwindParams.swap.tenor),
                uint256(AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING),
                unwindParams.messageSigner
            );
            /// @dev Not allow to have swap unwind pnl absolute value larger than swap collateral.
            swapUnwindPnlValue = calculateSwapUnwindPnlValueNormalized(
                unwindParams,
                AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING,
                oppositeRiskIndicators
            );
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }

        swapPnlValue = SwapLogicBaseV1.normalizePnlValue(
            unwindParams.swap.collateral,
            unwindParams.swapPnlValueToDate + swapUnwindPnlValue
        );

        /// @dev swap unwind fee amount is independent of the swap unwind pnl value, takes into consideration notional.
        swapUnwindFeeAmount = calculateSwapUnwindOpeningFeeAmount(
            unwindParams.swap,
            unwindParams.closeTimestamp,
            unwindParams.unwindingFeeRate
        );

        require(
            unwindParams.swap.collateral.toInt256() + swapPnlValue > swapUnwindFeeAmount.toInt256(),
            AmmErrors.COLLATERAL_IS_NOT_SUFFICIENT_TO_COVER_UNWIND_SWAP
        );

        (swapUnwindFeeLPAmount, swapUnwindFeeTreasuryAmount) = SwapLogicBaseV1.splitOpeningFeeAmount(
            swapUnwindFeeAmount,
            unwindParams.unwindingFeeTreasuryPortionRate
        );

        swapPnlValue = unwindParams.swapPnlValueToDate + swapUnwindPnlValue;
    }

    function getClosableStatusForSwap(
        AmmTypesBaseV1.ClosableSwapInput memory closableSwapInput
    ) internal view returns (AmmTypes.SwapClosableStatus, bool) {
        if (closableSwapInput.swapState != IporTypes.SwapState.ACTIVE) {
            return (AmmTypes.SwapClosableStatus.SWAP_ALREADY_CLOSED, false);
        }

        if (closableSwapInput.account != OwnerManager.getOwner()) {
            uint256 absPnlValue = IporMath.absoluteValue(closableSwapInput.swapPnlValueToDate);

            uint256 minPnlValueToCloseBeforeMaturityByCommunity = IporMath.percentOf(
                closableSwapInput.swapCollateral,
                closableSwapInput.minLiquidationThresholdToCloseBeforeMaturityByCommunity
            );

            uint256 swapEndTimestamp = getSwapEndTimestamp(
                closableSwapInput.swapOpenTimestamp,
                closableSwapInput.swapTenor
            );

            if (closableSwapInput.closeTimestamp >= swapEndTimestamp) {
                if (
                    absPnlValue < minPnlValueToCloseBeforeMaturityByCommunity ||
                    absPnlValue == closableSwapInput.swapCollateral
                ) {
                    if (
                        AmmConfigurationManager.isSwapLiquidator(closableSwapInput.asset, closableSwapInput.account) !=
                        true &&
                        closableSwapInput.account != closableSwapInput.swapBuyer
                    ) {
                        return (AmmTypes.SwapClosableStatus.SWAP_REQUIRED_BUYER_OR_LIQUIDATOR_TO_CLOSE, false);
                    }
                }
            } else {
                uint256 minPnlValueToCloseBeforeMaturityByBuyer = IporMath.percentOf(
                    closableSwapInput.swapCollateral,
                    closableSwapInput.minLiquidationThresholdToCloseBeforeMaturityByBuyer
                );

                if (
                    (absPnlValue >= minPnlValueToCloseBeforeMaturityByBuyer &&
                        absPnlValue < minPnlValueToCloseBeforeMaturityByCommunity) ||
                    absPnlValue == closableSwapInput.swapCollateral
                ) {
                    if (
                        AmmConfigurationManager.isSwapLiquidator(closableSwapInput.asset, closableSwapInput.account) !=
                        true &&
                        closableSwapInput.account != closableSwapInput.swapBuyer
                    ) {
                        return (AmmTypes.SwapClosableStatus.SWAP_REQUIRED_BUYER_OR_LIQUIDATOR_TO_CLOSE, false);
                    }
                }

                if (absPnlValue < minPnlValueToCloseBeforeMaturityByBuyer) {
                    if (closableSwapInput.account == closableSwapInput.swapBuyer) {
                        if (
                            swapEndTimestamp - closableSwapInput.timeBeforeMaturityAllowedToCloseSwapByBuyer >
                            closableSwapInput.closeTimestamp
                        ) {
                            if (
                                block.timestamp - closableSwapInput.swapOpenTimestamp <=
                                closableSwapInput.timeAfterOpenAllowedToCloseSwapWithUnwinding
                            ) {
                                return (
                                    AmmTypes.SwapClosableStatus.SWAP_CANNOT_CLOSE_WITH_UNWIND_ACTION_IS_TOO_EARLY,
                                    true
                                );
                            }

                            return (AmmTypes.SwapClosableStatus.SWAP_IS_CLOSABLE, true);
                        }
                    } else {
                        if (
                            swapEndTimestamp - closableSwapInput.timeBeforeMaturityAllowedToCloseSwapByCommunity >
                            closableSwapInput.closeTimestamp
                        ) {
                            return (
                                AmmTypes.SwapClosableStatus.SWAP_CANNOT_CLOSE_CLOSING_TOO_EARLY_FOR_COMMUNITY,
                                false
                            );
                        }
                    }
                }
            }
        }

        return (AmmTypes.SwapClosableStatus.SWAP_IS_CLOSABLE, false);
    }

    /// @notice Calculates the swap unwind PnL value.
    /// @param swap Swap structure
    /// @param closingTimestamp moment when user/account/client wants to close the swap, represented in seconds without 18 decimals
    /// for particular swap at time when swap will be closed by the trader.
    /// @dev Equation for this calculation is:
    /// time - number of seconds left to swap until maturity divided by number of seconds in year
    /// Opposite Leg Fixed Rate - calculated fixed rate of opposite leg used for the virtual swap
    /// @dev If Swap is Pay Fixed Receive Floating then UnwindValue  = Current Swap PnL + Notional * (e^(Opposite Leg Fixed Rate * time) - e^(Swap Fixed Rate * time))
    /// @dev If Swap is Receive Fixed Pay Floating then UnwindValue  = Current Swap PnL + Notional * (e^(Swap Fixed Rate * time) - e^(Opposite Leg Fixed Rate * time))
    function calculateSwapUnwindPnlValue(
        AmmTypesBaseV1.Swap memory swap,
        uint256 closingTimestamp,
        uint256 oppositeLegFixedRate
    ) internal pure returns (int256 swapUnwindPnlValue) {
        uint256 endTimestamp = getSwapEndTimestamp(swap.openTimestamp, swap.tenor);

        require(closingTimestamp <= endTimestamp, AmmErrors.CANNOT_UNWIND_CLOSING_TOO_LATE);

        uint256 time = endTimestamp - closingTimestamp;

        if (swap.direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            swapUnwindPnlValue =
                swap.notional.toInt256().calculateContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
                    (oppositeLegFixedRate * time).toInt256()
                ) -
                swap.notional.toInt256().calculateContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
                    (swap.fixedInterestRate * time).toInt256()
                );
        } else if (swap.direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            swapUnwindPnlValue =
                swap.notional.toInt256().calculateContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
                    (swap.fixedInterestRate * time).toInt256()
                ) -
                swap.notional.toInt256().calculateContinuousCompoundInterestUsingRatePeriodMultiplicationInt(
                    (oppositeLegFixedRate * time).toInt256()
                );
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }
    }

    /// @notice Calculates the swap unwind opening fee amount for a given swap, closing timestamp and IBT price from IporOracle.
    /// @param swapOpenTimestamp moment when swap is opened, represented in seconds without 18 decimals
    /// @param swapNotional swap notional, represented in 18 decimals
    /// @param swapTenor swap tenor
    /// @param closingTimestamp moment when swap is closed, represented in seconds without 18 decimals
    /// @param openingFeeRateCfg opening fee rate taken from Protocol configuration, represented in 18 decimals
    /// @return swapOpeningFeeAmount swap opening fee amount, represented in 18 decimals
    function calculateSwapUnwindOpeningFeeAmount(
        uint256 swapOpenTimestamp,
        uint256 swapNotional,
        IporTypes.SwapTenor swapTenor,
        uint256 closingTimestamp,
        uint256 openingFeeRateCfg
    ) internal pure returns (uint256 swapOpeningFeeAmount) {
        require(closingTimestamp >= swapOpenTimestamp, AmmErrors.CLOSING_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP);

        /// @dev 1e36 = 1e18 * 1e18, To achieve result in 18 decimals when there is multiplication of 3 numbers in 18 decimals, we need to divide by 1e36.
        swapOpeningFeeAmount = IporMath.division(
            swapNotional *
                openingFeeRateCfg *
                IporMath.division(
                    (getSwapEndTimestamp(swapOpenTimestamp, swapTenor) - closingTimestamp) * 1e18,
                    365 days
                ),
            1e36
        );
    }

    /// @notice Calculates the swap unwind opening fee amount for a given swap, closing timestamp and IBT price from IporOracle.
    /// @param swap Swap structure
    /// @param closingTimestamp moment when swap is closed, represented in seconds without 18 decimals
    /// @param openingFeeRateCfg opening fee rate taken from Protocol configuration, represented in 18 decimals
    /// @return swapOpeningFeeAmount swap opening fee amount, represented in 18 decimals
    function calculateSwapUnwindOpeningFeeAmount(
        AmmTypesBaseV1.Swap memory swap,
        uint256 closingTimestamp,
        uint256 openingFeeRateCfg
    ) internal pure returns (uint256 swapOpeningFeeAmount) {
        require(closingTimestamp >= swap.openTimestamp, AmmErrors.CLOSING_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP);

        /// @dev 1e36 = 1e18 * 1e18, To achieve result in 18 decimals when there is multiplication of 3 numbers in 18 decimals, we need to divide by 1e36.
        swapOpeningFeeAmount = IporMath.division(
            swap.notional *
                openingFeeRateCfg *
                IporMath.division(
                    (getSwapEndTimestamp(swap.openTimestamp, swap.tenor) - closingTimestamp) * 1e18,
                    365 days
                ),
            1e36
        );
    }

    /// @notice Gets swap end timestamp based on swap tenor
    /// @return swap end timestamp in seconds without 18 decimals
    function getSwapEndTimestamp(uint256 openTimestamp, IporTypes.SwapTenor tenor) internal pure returns (uint256) {
        if (tenor == IporTypes.SwapTenor.DAYS_28) {
            return openTimestamp + 28 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
            return openTimestamp + 60 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
            return openTimestamp + 90 days;
        } else {
            revert(AmmErrors.UNSUPPORTED_SWAP_TENOR);
        }
    }

    function validateAllowanceToCloseSwap(AmmTypes.SwapClosableStatus closableStatus) internal pure {
        if (closableStatus == AmmTypes.SwapClosableStatus.SWAP_ALREADY_CLOSED) {
            revert(AmmErrors.INCORRECT_SWAP_STATUS);
        }
        if (closableStatus == AmmTypes.SwapClosableStatus.SWAP_REQUIRED_BUYER_OR_LIQUIDATOR_TO_CLOSE) {
            revert(AmmErrors.CANNOT_CLOSE_SWAP_SENDER_IS_NOT_BUYER_NOR_LIQUIDATOR);
        }
        if (closableStatus == AmmTypes.SwapClosableStatus.SWAP_CANNOT_CLOSE_CLOSING_TOO_EARLY_FOR_COMMUNITY) {
            revert(AmmErrors.CANNOT_CLOSE_SWAP_CLOSING_IS_TOO_EARLY);
        }
        if (closableStatus == AmmTypes.SwapClosableStatus.SWAP_CANNOT_CLOSE_WITH_UNWIND_ACTION_IS_TOO_EARLY) {
            revert(AmmErrors.CANNOT_CLOSE_SWAP_WITH_UNWIND_ACTION_IS_TOO_EARLY);
        }
    }
}

library SwapCloseLogicLib {
    using SafeCast for uint256;
    using SafeCast for int256;
    using InterestRates for uint256;
    using InterestRates for int256;
    using RiskIndicatorsValidatorLib for AmmTypes.RiskIndicatorsInputs;

    /// @notice Calculate swap unwind when unwind is required.
    /// @param unwindParams unwind parameters required to calculate swap unwind pnl value.
    /// @return swapUnwindPnlValue swap unwind PnL value
    /// @return swapUnwindFeeAmount swap unwind opening fee amount, sum of swapUnwindFeeLPAmount and swapUnwindFeeTreasuryAmount
    /// @return swapUnwindFeeLPAmount swap unwind opening fee LP amount
    /// @return swapUnwindFeeTreasuryAmount swap unwind opening fee treasury amount
    /// @return swapPnlValue swap PnL value includes swap PnL to date, swap unwind PnL value, this value NOT INCLUDE swap unwind fee amount.
    function calculateSwapUnwindWhenUnwindRequired(
        AmmTypes.UnwindParams memory unwindParams
    )
        internal
        view
        returns (
            int256 swapUnwindPnlValue,
            uint256 swapUnwindFeeAmount,
            uint256 swapUnwindFeeLPAmount,
            uint256 swapUnwindFeeTreasuryAmount,
            int256 swapPnlValue
        )
    {
        AmmTypes.OpenSwapRiskIndicators memory oppositeRiskIndicators;

        if (unwindParams.direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            oppositeRiskIndicators = unwindParams.riskIndicatorsInputs.receiveFixed.verify(
                unwindParams.poolCfg.asset,
                uint256(unwindParams.swap.tenor),
                uint256(AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED),
                unwindParams.messageSigner
            );
            /// @dev Not allow to have swap unwind pnl absolute value larger than swap collateral.
            swapUnwindPnlValue = calculateSwapUnwindPnlValueNormalized(unwindParams, 1, oppositeRiskIndicators);
        } else if (unwindParams.direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            oppositeRiskIndicators = unwindParams.riskIndicatorsInputs.payFixed.verify(
                unwindParams.poolCfg.asset,
                uint256(unwindParams.swap.tenor),
                uint256(AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING),
                unwindParams.messageSigner
            );
            /// @dev Not allow to have swap unwind pnl absolute value larger than swap collateral.
            swapUnwindPnlValue = calculateSwapUnwindPnlValueNormalized(unwindParams, 0, oppositeRiskIndicators);
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }

        swapPnlValue = SwapLogicBaseV1.normalizePnlValue(
            unwindParams.swap.collateral,
            unwindParams.swapPnlValueToDate + swapUnwindPnlValue
        );

        /// @dev swap unwind fee amount is independent of the swap unwind pnl value, takes into consideration notional.
        swapUnwindFeeAmount = SwapCloseLogicLibBaseV1.calculateSwapUnwindOpeningFeeAmount(
            unwindParams.swap.openTimestamp,
            unwindParams.swap.notional,
            unwindParams.swap.tenor,
            unwindParams.closeTimestamp,
            unwindParams.poolCfg.unwindingFeeRate
        );

        require(
            unwindParams.swap.collateral.toInt256() + swapPnlValue > swapUnwindFeeAmount.toInt256(),
            AmmErrors.COLLATERAL_IS_NOT_SUFFICIENT_TO_COVER_UNWIND_SWAP
        );

        (swapUnwindFeeLPAmount, swapUnwindFeeTreasuryAmount) = SwapLogicBaseV1.splitOpeningFeeAmount(
            swapUnwindFeeAmount,
            unwindParams.poolCfg.unwindingFeeTreasuryPortionRate
        );

        swapPnlValue = unwindParams.swapPnlValueToDate + swapUnwindPnlValue;
    }

    function calculateSwapUnwindPnlValueNormalized(
        AmmTypes.UnwindParams memory unwindParams,
        uint256 direction,
        AmmTypes.OpenSwapRiskIndicators memory oppositeRiskIndicators
    ) internal view returns (int256) {
        return
            SwapLogicBaseV1.normalizePnlValue(
                unwindParams.swap.collateral,
                calculateSwapUnwindPnlValue(
                    unwindParams.swap,
                    unwindParams.direction,
                    unwindParams.closeTimestamp,
                    RiskManagementLogic.calculateOfferedRate(
                        direction,
                        unwindParams.swap.tenor,
                        unwindParams.swap.notional,
                        RiskManagementLogic.SpreadOfferedRateContext({
                            asset: unwindParams.poolCfg.asset,
                            ammStorage: unwindParams.poolCfg.ammStorage,
                            spreadRouter: unwindParams.spreadRouter,
                            minLeverage: unwindParams.poolCfg.minLeverage,
                            indexValue: unwindParams.indexValue
                        }),
                        oppositeRiskIndicators
                    )
                )
            );
    }

    /// @notice Calculates the swap unwind PnL value.
    /// @param swap Swap structure
    /// @param direction swap direction
    /// @param closingTimestamp moment when user wants to close the swap, represented in seconds without 18 decimals
    /// for particular swap at time when swap will be closed by the trader.
    /// @dev Equation for this calculation is:
    /// time - number of seconds left to swap until maturity divided by number of seconds in year
    /// Opposite Leg Fixed Rate - calculated fixed rate of opposite leg used for the virtual swap
    /// @dev If Swap is Pay Fixed Receive Floating then UnwindValue  = Current Swap PnL + Notional * (e^(Opposite Leg Fixed Rate * time) - e^(Swap Fixed Rate * time))
    /// @dev If Swap is Receive Fixed Pay Floating then UnwindValue  = Current Swap PnL + Notional * (e^(Swap Fixed Rate * time) - e^(Opposite Leg Fixed Rate * time))
    function calculateSwapUnwindPnlValue(
        AmmTypes.Swap memory swap,
        AmmTypes.SwapDirection direction,
        uint256 closingTimestamp,
        uint256 oppositeLegFixedRate
    ) internal pure returns (int256 swapUnwindPnlValue) {
        AmmTypesBaseV1.Swap memory swapBaseV1;

        swapBaseV1.openTimestamp = swap.openTimestamp;
        swapBaseV1.tenor = swap.tenor;
        swapBaseV1.direction = direction;
        swapBaseV1.collateral = swap.collateral;
        swapBaseV1.notional = swap.notional;
        swapBaseV1.fixedInterestRate = swap.fixedInterestRate;

        return SwapCloseLogicLibBaseV1.calculateSwapUnwindPnlValue(swapBaseV1, closingTimestamp, oppositeLegFixedRate);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
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
library AddressUpgradeable {
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
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
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
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
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
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
        IERC20PermitUpgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
    }
}

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

/// @title Interface of ipToken - Liquidity Pool Token managed by Router in IPOR Protocol for a given asset.
/// For more information refer to the documentation https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/liquidity-provisioning#liquidity-tokens
interface IIpToken is IERC20 {
    /// @notice Gets the asset / stablecoin address which is associated with particular ipToken smart contract instance
    /// @return asset / stablecoin address
    function getAsset() external view returns (address);

    /// @notice Gets the Token Manager's address.
    function getTokenManager() external view returns (address);

    /// @notice Sets token manager's address. IpToken contract Owner only
    /// @dev only Token Manager can mint or burn ipTokens. Function emits `TokenManagerChanged` event.
    /// @param newTokenManager Token Managers's address
    function setTokenManager(address newTokenManager) external;

    /// @notice Creates the ipTokens in the `amount` given and assigns them to the `account`
    /// @dev Emits {Transfer} from ERC20 asset and {Mint} event from ipToken
    /// @param account to which the created ipTokens were assigned
    /// @param amount volume of ipTokens created
    function mint(address account, uint256 amount) external;

    /// @notice Burns the `amount` of ipTokens from `account`, reducing the total supply
    /// @dev Emits {Transfer} from ERC20 asset and {Burn} event from ipToken
    /// @param account from which burned ipTokens are taken
    /// @param amount volume of ipTokens that will be burned, represented in 18 decimals
    function burn(address account, uint256 amount) external;

    /// @notice Emitted after the `amount` ipTokens were mint and transferred to `account`.
    /// @param account address where ipTokens are transferred after minting
    /// @param amount of ipTokens minted, represented in 18 decimals
    event Mint(address indexed account, uint256 amount);

    /// @notice Emitted after `amount` ipTokens were transferred from `account` and burnt.
    /// @param account address from which ipTokens are transferred to be burned
    /// @param amount volume of ipTokens burned
    event Burn(address indexed account, uint256 amount);

    /// @notice Emitted when Token Manager address is changed by its owner.
    /// @param newTokenManager new address of Token Manager
    event TokenManagerChanged(address indexed newTokenManager);
}

/// @title Interface for interaction with Asset Management DSR smart contract.
/// @notice Asset Management is responsible for delegating assets stored in AmmTreasury to Asset Management and forward to money market where they can earn interest.
interface IAssetManagement {
    /// @notice Gets total balance of AmmTreasury, transferred assets to Asset Management.
    /// @return Total balance for specific account given as a parameter, represented in 18 decimals.
    function totalBalance() external view returns (uint256);

    /// @notice Deposits ERC20 underlying assets to AssetManagement. Function available only for AmmTreasury.
    /// @dev Emits {Deposit} event from AssetManagement, emits {Transfer} event from ERC20 asset.
    /// Input and output values are represented in 18 decimals.
    /// @param amount amount deposited by AmmTreasury to AssetManagement.
    /// @return vaultBalance current balance including amount deposited on AssteManagement.
    /// @return depositedAmount final deposited amount.
    function deposit(uint256 amount) external returns (uint256 vaultBalance, uint256 depositedAmount);

    /// @notice Withdraws declared amount of asset from AssetManagement to AmmTreasury. Function available only for AmmTreasury.
    /// @dev Emits {Withdraw} event from AssetManagement, emits {Transfer} event from ERC20 asset.
    /// All input and output values are represented in 18 decimals.
    /// @param amount deposited amount of underlying asset represented in 18 decimals.
    /// @return withdrawnAmount final withdrawn amount of asset from AssetManagement, can be different than input amount due to passing time.
    /// @return vaultBalance current asset balance on AssetManagement
    function withdraw(uint256 amount) external returns (uint256 withdrawnAmount, uint256 vaultBalance);

    /// @notice Withdraws all of the asset from AssetManagement to AmmTreasury. Function available only for AmmTreasury.
    /// @dev Emits {Withdraw} event from AssetManagement, emits {Transfer} event from ERC20 asset.
    /// Output values are represented in 18 decimals.
    /// @return withdrawnAmount final withdrawn amount of the asset.
    /// @return vaultBalance current asset's balance on AssetManagement
    function withdrawAll() external returns (uint256 withdrawnAmount, uint256 vaultBalance);

    /// @notice Emitted after AmmTreasury has executed deposit function.
    /// @param from account address from which assets are transferred
    /// @param to account address where assets are transferred to
    /// @param amount of asset transferred from AmmTreasury to AssetManagement, represented in 18 decimals
    event Deposit(address from, address to, uint256 amount);

    /// @notice Emitted when AmmTreasury executes withdraw function.
    /// @param to account address where assets are transferred to
    /// @param amount of asset transferred from AmmTreasury to AssetManagement, represented in 18 decimals
    event Withdraw(address to, uint256 amount);
}

/// @title Basic logic related with SOAP indicators
library SoapIndicatorLogic {
    using SafeCast for uint256;
    using InterestRates for uint256;

    /// @notice Calculate the SOAP for pay fixed leg
    /// @param si SOAP indicators
    /// @param calculateTimestamp timestamp to calculate the SOAP
    /// @param ibtPrice IBT price
    /// @return SOAP for pay fixed leg
    function calculateSoapPayFixed(
        AmmStorageTypes.SoapIndicators memory si,
        uint256 calculateTimestamp,
        uint256 ibtPrice
    ) internal pure returns (int256) {
        return
            IporMath.division(si.totalIbtQuantity * ibtPrice, 1e18).toInt256() -
            (si.totalNotional + calculateHyphoteticalInterestTotal(si, calculateTimestamp)).toInt256();
    }

    /// @notice Calculate the SOAP for receive fixed leg
    /// @param si SOAP indicators
    /// @param calculateTimestamp timestamp to calculate the SOAP
    /// @param ibtPrice IBT price
    /// @return SOAP for receive fixed leg
    function calculateSoapReceiveFixed(
        AmmStorageTypes.SoapIndicators memory si,
        uint256 calculateTimestamp,
        uint256 ibtPrice
    ) internal pure returns (int256) {
        return
            (si.totalNotional + calculateHyphoteticalInterestTotal(si, calculateTimestamp)).toInt256() -
            IporMath.division(si.totalIbtQuantity * ibtPrice, 1e18).toInt256();
    }

    /// @notice Calculate hypothetical interest total, value that is used to calculate the SOAP
    /// @param si SOAP indicators
    /// @param calculateTimestamp timestamp to calculate the value
    /// @return hypothetical interest total
    function calculateHyphoteticalInterestTotal(
        AmmStorageTypes.SoapIndicators memory si,
        uint256 calculateTimestamp
    ) internal pure returns (uint256) {
        return
            si.hypotheticalInterestCumulative +
            calculateHypotheticalInterestDelta(
                calculateTimestamp,
                si.rebalanceTimestamp,
                si.totalNotional + si.hypotheticalInterestCumulative,
                si.averageInterestRate
            );
    }

    /// @notice Calculate hypothetical interest delta, value that is used to calculate the SOAP
    /// @param calculateTimestamp timestamp to calculate the value
    /// @param lastRebalanceTimestamp last rebalance timestamp
    /// @param totalNotional total notional
    /// @param averageInterestRate average interest rate
    /// @return hypothetical interest delta
    function calculateHypotheticalInterestDelta(
        uint256 calculateTimestamp,
        uint256 lastRebalanceTimestamp,
        uint256 totalNotional,
        uint256 averageInterestRate
    ) internal pure returns (uint256) {
        require(
            calculateTimestamp >= lastRebalanceTimestamp,
            AmmErrors.CALC_TIMESTAMP_LOWER_THAN_SOAP_REBALANCE_TIMESTAMP
        );
        return
            totalNotional.calculateContinuousCompoundInterestUsingRatePeriodMultiplication(
                averageInterestRate * (calculateTimestamp - lastRebalanceTimestamp)
            );
    }
}

/// @title AMM basic logic library
library AmmLib {
    using SafeCast for uint256;
    using SafeCast for int256;
    using SoapIndicatorLogic for AmmStorageTypes.SoapIndicators;

    /// @notice Gets AMM exchange rate
    /// @param model AMM model skeleton of the pool
    /// @return AMM exchange rate
    function getExchangeRate(AmmTypes.AmmPoolCoreModel memory model) internal view returns (uint256) {
        return getExchangeRate(model, getAccruedBalance(model).liquidityPool);
    }

    /// @notice Gets AMM exchange rate
    /// @param model AMM model skeleton of the pool
    /// @param liquidityPoolBalance liquidity pool balance
    /// @return AMM exchange rate
    /// @dev For gas optimization with additional param liquidityPoolBalance with already calculated value
    function getExchangeRate(
        AmmTypes.AmmPoolCoreModel memory model,
        uint256 liquidityPoolBalance
    ) internal view returns (uint256) {
        (, , int256 soap) = getSoap(model);

        int256 balance = liquidityPoolBalance.toInt256() - soap;
        require(balance >= 0, AmmErrors.SOAP_AND_LP_BALANCE_SUM_IS_TOO_LOW);

        uint256 ipTokenTotalSupply = IIpToken(model.ipToken).totalSupply();

        if (ipTokenTotalSupply > 0) {
            return IporMath.division(balance.toUint256() * 1e18, ipTokenTotalSupply);
        } else {
            return 1e18;
        }
    }

    /// @notice Gets AMM SOAP Sum Of All Payouts
    /// @param model AMM model skeleton of the pool
    /// @return soapPayFixed SOAP Pay Fixed
    /// @return soapReceiveFixed SOAP Receive Fixed
    /// @return soap SOAP Sum Of All Payouts
    function getSoap(
        AmmTypes.AmmPoolCoreModel memory model
    ) internal view returns (int256 soapPayFixed, int256 soapReceiveFixed, int256 soap) {
        uint256 timestamp = block.timestamp;
        (
            AmmStorageTypes.SoapIndicators memory indicatorsPayFixed,
            AmmStorageTypes.SoapIndicators memory indicatorsReceiveFixed
        ) = IAmmStorage(model.ammStorage).getSoapIndicators();

        uint256 ibtPrice = IIporOracle(model.iporOracle).calculateAccruedIbtPrice(model.asset, timestamp);
        soapPayFixed = indicatorsPayFixed.calculateSoapPayFixed(timestamp, ibtPrice);
        soapReceiveFixed = indicatorsReceiveFixed.calculateSoapReceiveFixed(timestamp, ibtPrice);
        soap = soapPayFixed + soapReceiveFixed;
    }

    /// @notice Gets accrued balance of the pool
    /// @param model AMM model skeleton of the pool
    /// @return accrued balance of the pool
    /// @dev balance takes into consideration asset management vault balance and their accrued interest
    function getAccruedBalance(
        AmmTypes.AmmPoolCoreModel memory model
    ) internal view returns (IporTypes.AmmBalancesMemory memory) {
        require(model.ammTreasury != address(0), string.concat(IporErrors.WRONG_ADDRESS, " ammTreasury"));
        IporTypes.AmmBalancesMemory memory accruedBalance = IAmmStorage(model.ammStorage).getBalance();

        uint256 actualVaultBalance = IAssetManagement(model.assetManagement).totalBalance();
        int256 liquidityPool = accruedBalance.liquidityPool.toInt256() +
            actualVaultBalance.toInt256() -
            accruedBalance.vault.toInt256();

        require(liquidityPool >= 0, AmmErrors.LIQUIDITY_POOL_AMOUNT_TOO_LOW);
        accruedBalance.liquidityPool = liquidityPool.toUint256();
        accruedBalance.vault = actualVaultBalance;
        return accruedBalance;
    }
}

library AmmEventsBaseV1 {
    /// @notice Emitted when the trader closes the swap.
    event CloseSwap(
        /// @notice swap ID.
        uint256 indexed swapId,
        /// @notice underlying asset
        address asset,
        /// @notice the moment when swap was closed
        uint256 closeTimestamp,
        /// @notice account that liquidated the swap
        address liquidator,
        /// @notice asset amount after closing swap that has been transferred from AmmTreasury to the Buyer. Value represented in 18 decimals.
        uint256 transferredToBuyer,
        /// @notice asset amount after closing swap that has been transferred from AmmTreasury to the Liquidator. Value represented in 18 decimals.
        uint256 transferredToLiquidator
    );

    /// @notice Emitted when unwind is performed during closing swap.
    event SwapUnwind(
        /// @notice underlying asset
        address asset,
        /// @notice swap ID.
        uint256 indexed swapId,
        /// @notice Profit and Loss to date without unwind value, represented in 18 decimals
        int256 swapPnlValueToDate,
        /// @notice swap unwind amount, represented in 18 decimals
        int256 swapUnwindAmount,
        /// @notice unwind fee amount, part earmarked for the liquidity pool, represented in 18 decimals
        uint256 unwindFeeLPAmount,
        /// @notice unwind fee amount, part earmarked for the treasury, represented in 18 decimals
        uint256 unwindFeeTreasuryAmount
    );

    event SpreadTimeWeightedNotionalChanged(
        /// @notice timeWeightedNotionalPayFixed with 18 decimals
        uint256 timeWeightedNotionalPayFixed,
        /// @notice lastUpdateTimePayFixed timestamp in seconds
        uint256 lastUpdateTimePayFixed,
        /// @notice timeWeightedNotionalReceiveFixed with 18 decimals
        uint256 timeWeightedNotionalReceiveFixed,
        /// @notice lastUpdateTimeReceiveFixed timestamp in seconds
        uint256 lastUpdateTimeReceiveFixed,
        /// @notice storageId from SpreadStorageLibsBaseV1.StorageId or from SpreadStorageLibs.StorageId depends on asset
        /// @dev If asset is USDT, USDC, DAI then sender is a IporProtocolRouter, if asset is stETH sender is a SpreadStEth contract
        uint256 storageId
    );
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

/// @title Extended version of OpenZeppelin Ownable contract with appointed owner
abstract contract IporOwnable is Ownable {
    address private _appointedOwner;

    /// @notice Emitted when account is appointed to transfer ownership
    /// @param appointedOwner Address of appointed owner
    event AppointedToTransferOwnership(address indexed appointedOwner);

    modifier onlyAppointedOwner() {
        require(_appointedOwner == msg.sender, IporErrors.SENDER_NOT_APPOINTED_OWNER);
        _;
    }

    /// @notice Oppoint account to transfer ownership
    /// @param appointedOwner Address of appointed owner
    function transferOwnership(address appointedOwner) public override onlyOwner {
        require(appointedOwner != address(0), IporErrors.WRONG_ADDRESS);
        _appointedOwner = appointedOwner;
        emit AppointedToTransferOwnership(appointedOwner);
    }

    /// @notice Confirm transfer ownership
    /// @dev This is real transfer ownership in second step by appointed account
    function confirmTransferOwnership() external onlyAppointedOwner {
        _appointedOwner = address(0);
        _transferOwnership(msg.sender);
    }

    /// @notice Renounce ownership
    function renounceOwnership() public virtual override onlyOwner {
        _transferOwnership(address(0));
        _appointedOwner = address(0);
    }
}

library SpreadTypes {
    /// @notice structure used to save the weighted notional for the 28 days into storage
    /// timeWeightedNotionalPayFixed without decimals - uint96 - bytes 0-96
    /// lastUpdateTimePayFixed - uint32 - bytes 96-128
    /// timeWeightedNotionalReceiveFixed  without decimals - uint96 - bytes 128-224
    /// lastUpdateTimeReceiveFixed - uint32 - bytes 224-256
    struct WeightedNotionalStorage {
        bytes32 weightedNotional;
    }

    /// @notice Dto for the Weighted Notional
    struct TimeWeightedNotionalMemory {
        /// @notice timeWeightedNotionalPayFixed with 18 decimals
        uint256 timeWeightedNotionalPayFixed;
        /// @notice lastUpdateTimePayFixed timestamp in seconds
        uint256 lastUpdateTimePayFixed;
        /// @notice timeWeightedNotionalReceiveFixed with 18 decimals
        uint256 timeWeightedNotionalReceiveFixed;
        /// @notice lastUpdateTimeReceiveFixed timestamp in seconds
        uint256 lastUpdateTimeReceiveFixed;
        /// @notice storageId from SpreadStorageLibs
        SpreadStorageLibs.StorageId storageId;
    }

    /// @notice Technical structure used in Lens for the Weighted Notional params
    struct TimeWeightedNotionalResponse {
        /// @notice timeWeightedNotionalPayFixed time weighted notional params
        TimeWeightedNotionalMemory timeWeightedNotional;
        string key;
    }
}

/// @title Spread storage library
library SpreadStorageLibs {
    using SafeCast for uint256;
    uint256 private constant STORAGE_SLOT_BASE = 10_000;

    /// Only allowed to append new value to the end of the enum
    enum StorageId {
        // address
        Owner,
        // address
        AppointedOwner,
        // uint256
        Paused,
        // WeightedNotionalStorage
        TimeWeightedNotional28DaysDai,
        TimeWeightedNotional28DaysUsdc,
        TimeWeightedNotional28DaysUsdt,
        TimeWeightedNotional60DaysDai,
        TimeWeightedNotional60DaysUsdc,
        TimeWeightedNotional60DaysUsdt,
        TimeWeightedNotional90DaysDai,
        TimeWeightedNotional90DaysUsdc,
        TimeWeightedNotional90DaysUsdt
    }

    /// @notice Struct which contains owner address of Spread Router
    struct OwnerStorage {
        address owner;
    }

    /// @notice Struct which contains pause flag on Spread Router
    struct PausedStorage {
        uint256 value;
    }

    /// @notice Struct which contains address of appointed owner of Spread Router
    struct AppointedOwnerStorage {
        address appointedOwner;
    }

    /// @notice Saves time weighted notional for a specific asset and tenor
    /// @param timeWeightedNotionalStorageId The storage ID of the time weighted notional
    /// @param timeWeightedNotional The time weighted notional to save
    function saveTimeWeightedNotionalForAssetAndTenor(
        StorageId timeWeightedNotionalStorageId,
        SpreadTypes.TimeWeightedNotionalMemory memory timeWeightedNotional
    ) internal {
        checkTimeWeightedNotional(timeWeightedNotionalStorageId);
        uint256 timeWeightedNotionalPayFixedTemp;
        uint256 timeWeightedNotionalReceiveFixedTemp;
        unchecked {
            timeWeightedNotionalPayFixedTemp = timeWeightedNotional.timeWeightedNotionalPayFixed / 1e18;

            timeWeightedNotionalReceiveFixedTemp = timeWeightedNotional.timeWeightedNotionalReceiveFixed / 1e18;
        }

        uint96 timeWeightedNotionalPayFixed = timeWeightedNotionalPayFixedTemp.toUint96();
        uint32 lastUpdateTimePayFixed = timeWeightedNotional.lastUpdateTimePayFixed.toUint32();
        uint96 timeWeightedNotionalReceiveFixed = timeWeightedNotionalReceiveFixedTemp.toUint96();
        uint32 lastUpdateTimeReceiveFixed = timeWeightedNotional.lastUpdateTimeReceiveFixed.toUint32();
        uint256 slotAddress = _getStorageSlot(timeWeightedNotionalStorageId);
        assembly {
            let value := add(
                timeWeightedNotionalPayFixed,
                add(
                    shl(96, lastUpdateTimePayFixed),
                    add(shl(128, timeWeightedNotionalReceiveFixed), shl(224, lastUpdateTimeReceiveFixed))
                )
            )
            sstore(slotAddress, value)
        }
    }

    /// @notice Gets the time-weighted notional for a specific storage ID representing an asset and tenor
    /// @param timeWeightedNotionalStorageId The storage ID of the time weighted notional
    function getTimeWeightedNotionalForAssetAndTenor(
        StorageId timeWeightedNotionalStorageId
    ) internal view returns (SpreadTypes.TimeWeightedNotionalMemory memory weightedNotional28Days) {
        checkTimeWeightedNotional(timeWeightedNotionalStorageId);
        uint256 timeWeightedNotionalPayFixed;
        uint256 lastUpdateTimePayFixed;
        uint256 timeWeightedNotionalReceiveFixed;
        uint256 lastUpdateTimeReceiveFixed;
        uint256 slotAddress = _getStorageSlot(timeWeightedNotionalStorageId);
        assembly {
            let slotValue := sload(slotAddress)
            timeWeightedNotionalPayFixed := mul(and(slotValue, 0xFFFFFFFFFFFFFFFFFFFFFFFF), 1000000000000000000)
            lastUpdateTimePayFixed := and(shr(96, slotValue), 0xFFFFFFFF)
            timeWeightedNotionalReceiveFixed := mul(
                and(shr(128, slotValue), 0xFFFFFFFFFFFFFFFFFFFFFFFF),
                1000000000000000000
            )
            lastUpdateTimeReceiveFixed := and(shr(224, slotValue), 0xFFFFFFFF)
        }

        return
            SpreadTypes.TimeWeightedNotionalMemory({
                timeWeightedNotionalPayFixed: timeWeightedNotionalPayFixed,
                lastUpdateTimePayFixed: lastUpdateTimePayFixed,
                timeWeightedNotionalReceiveFixed: timeWeightedNotionalReceiveFixed,
                lastUpdateTimeReceiveFixed: lastUpdateTimeReceiveFixed,
                storageId: timeWeightedNotionalStorageId
            });
    }

    /// @notice Gets all time weighted notional storage IDs
    function getAllStorageId() internal pure returns (StorageId[] memory storageIds, string[] memory keys) {
        storageIds = new StorageId[](9);
        keys = new string[](9);
        storageIds[0] = StorageId.TimeWeightedNotional28DaysDai;
        keys[0] = "TimeWeightedNotional28DaysDai";
        storageIds[1] = StorageId.TimeWeightedNotional28DaysUsdc;
        keys[1] = "TimeWeightedNotional28DaysUsdc";
        storageIds[2] = StorageId.TimeWeightedNotional28DaysUsdt;
        keys[2] = "TimeWeightedNotional28DaysUsdt";
        storageIds[3] = StorageId.TimeWeightedNotional60DaysDai;
        keys[3] = "TimeWeightedNotional60DaysDai";
        storageIds[4] = StorageId.TimeWeightedNotional60DaysUsdc;
        keys[4] = "TimeWeightedNotional60DaysUsdc";
        storageIds[5] = StorageId.TimeWeightedNotional60DaysUsdt;
        keys[5] = "TimeWeightedNotional60DaysUsdt";
        storageIds[6] = StorageId.TimeWeightedNotional90DaysDai;
        keys[6] = "TimeWeightedNotional90DaysDai";
        storageIds[7] = StorageId.TimeWeightedNotional90DaysUsdc;
        keys[7] = "TimeWeightedNotional90DaysUsdc";
        storageIds[8] = StorageId.TimeWeightedNotional90DaysUsdt;
        keys[8] = "TimeWeightedNotional90DaysUsdt";
    }

    /// @notice Gets the owner of the Spread Router
    /// @return owner The owner of the Spread Router
    function getOwner() internal pure returns (OwnerStorage storage owner) {
        uint256 slotAddress = _getStorageSlot(StorageId.Owner);
        assembly {
            owner.slot := slotAddress
        }
    }

    /// @notice Gets the appointed owner of the Spread Router
    /// @return appointedOwner The appointed owner of the Spread Router
    function getAppointedOwner() internal pure returns (AppointedOwnerStorage storage appointedOwner) {
        uint256 slotAddress = _getStorageSlot(StorageId.AppointedOwner);
        assembly {
            appointedOwner.slot := slotAddress
        }
    }

    /// @notice Gets the paused state of the Spread Router
    /// @return paused The paused state of the Spread Router
    function getPaused() internal pure returns (PausedStorage storage paused) {
        uint256 slotAddress = _getStorageSlot(StorageId.Paused);
        assembly {
            paused.slot := slotAddress
        }
    }

    function checkTimeWeightedNotional(StorageId storageId) internal pure {
        require(
            storageId == StorageId.TimeWeightedNotional28DaysDai ||
                storageId == StorageId.TimeWeightedNotional28DaysUsdc ||
                storageId == StorageId.TimeWeightedNotional28DaysUsdt ||
                storageId == StorageId.TimeWeightedNotional60DaysDai ||
                storageId == StorageId.TimeWeightedNotional60DaysUsdc ||
                storageId == StorageId.TimeWeightedNotional60DaysUsdt ||
                storageId == StorageId.TimeWeightedNotional90DaysDai ||
                storageId == StorageId.TimeWeightedNotional90DaysUsdc ||
                storageId == StorageId.TimeWeightedNotional90DaysUsdt,
            AmmErrors.STORAGE_ID_IS_NOT_TIME_WEIGHTED_NOTIONAL
        );
    }

    function _getStorageSlot(StorageId storageId) private pure returns (uint256 slot) {
        slot = uint256(storageId) + STORAGE_SLOT_BASE;
    }

}

library CalculateTimeWeightedNotionalLibs {
    /// @notice calculate amm lp depth
    /// @param liquidityPoolBalance liquidity pool balance
    /// @param totalCollateralPayFixed total collateral pay fixed
    /// @param totalCollateralReceiveFixed total collateral receive fixed
    function calculateLpDepth(
        uint256 liquidityPoolBalance,
        uint256 totalCollateralPayFixed,
        uint256 totalCollateralReceiveFixed
    ) internal pure returns (uint256 lpDepth) {
        if (totalCollateralPayFixed >= totalCollateralReceiveFixed) {
            lpDepth = liquidityPoolBalance + totalCollateralReceiveFixed - totalCollateralPayFixed;
        } else {
            lpDepth = liquidityPoolBalance + totalCollateralPayFixed - totalCollateralReceiveFixed;
        }
    }

    /// @notice calculate weighted notional
    /// @param timeWeightedNotional weighted notional value
    /// @param timeFromLastUpdate time from last update in seconds
    /// @param tenorInSeconds tenor in seconds
    function calculateTimeWeightedNotional(
        uint256 timeWeightedNotional,
        uint256 timeFromLastUpdate,
        uint256 tenorInSeconds
    ) internal pure returns (uint256) {
        if (timeFromLastUpdate >= tenorInSeconds) {
            return 0;
        }
        uint256 newTimeWeightedNotional = IporMath.divisionWithoutRound(
            timeWeightedNotional * (tenorInSeconds - timeFromLastUpdate),
            tenorInSeconds
        );
        return newTimeWeightedNotional;
    }

    /// @notice Updates the time-weighted notional value for the receive fixed leg.
    /// @param timeWeightedNotional The memory struct containing the time-weighted notional information.
    /// @param newSwapNotional The new swap notional value.
    /// @param tenorInSeconds Tenor in seconds.
    /// @dev This function is internal and used to update the time-weighted notional value for the receive fixed leg.
    function updateTimeWeightedNotionalReceiveFixed(
        SpreadTypes.TimeWeightedNotionalMemory memory timeWeightedNotional,
        uint256 newSwapNotional,
        uint256 tenorInSeconds
    ) internal {
        if (timeWeightedNotional.timeWeightedNotionalReceiveFixed == 0) {
            timeWeightedNotional.timeWeightedNotionalReceiveFixed = calculateTimeWeightedNotional(
                newSwapNotional,
                0,
                tenorInSeconds
            );
        } else {
            uint256 oldWeightedNotionalReceiveFixed = calculateTimeWeightedNotional(
                timeWeightedNotional.timeWeightedNotionalReceiveFixed,
                block.timestamp - timeWeightedNotional.lastUpdateTimeReceiveFixed,
                tenorInSeconds
            );
            timeWeightedNotional.timeWeightedNotionalReceiveFixed = newSwapNotional + oldWeightedNotionalReceiveFixed;
        }
        timeWeightedNotional.lastUpdateTimeReceiveFixed = block.timestamp;
        SpreadStorageLibs.saveTimeWeightedNotionalForAssetAndTenor(timeWeightedNotional.storageId, timeWeightedNotional);
    }

    /// @notice Updates the time-weighted notional value for the pay fixed leg.
    /// @param timeWeightedNotional The memory struct containing the time-weighted notional information.
    /// @param newSwapNotional The new swap notional value.
    /// @param tenorInSeconds Tenor in seconds.
    /// @dev This function is internal and used to update the time-weighted notional value for the pay fixed leg.
    function updateTimeWeightedNotionalPayFixed(
        SpreadTypes.TimeWeightedNotionalMemory memory timeWeightedNotional,
        uint256 newSwapNotional,
        uint256 tenorInSeconds
    ) internal {
        if (timeWeightedNotional.timeWeightedNotionalPayFixed == 0) {
            timeWeightedNotional.timeWeightedNotionalPayFixed = calculateTimeWeightedNotional(
                newSwapNotional,
                0,
                tenorInSeconds
            );
        } else {
            uint256 oldWeightedNotionalPayFixed = calculateTimeWeightedNotional(
                timeWeightedNotional.timeWeightedNotionalPayFixed,
                block.timestamp - timeWeightedNotional.lastUpdateTimePayFixed,
                tenorInSeconds
            );
            timeWeightedNotional.timeWeightedNotionalPayFixed = newSwapNotional + oldWeightedNotionalPayFixed;
        }
        timeWeightedNotional.lastUpdateTimePayFixed = block.timestamp;
        SpreadStorageLibs.saveTimeWeightedNotionalForAssetAndTenor(timeWeightedNotional.storageId, timeWeightedNotional);
    }

    /// @notice Calculates the time-weighted notional values for the pay fixed and receive fixed legs.
    /// @param timeWeightedNotionalStorageIds The array of storage IDs representing the time-weighted notional storage locations.
    /// @param tenorsInSeconds The array of maturities corresponding to each storage ID.
    /// @param selectedTenorInSeconds The tenor in seconds used to calculate the time-weighted notional values.
    /// @return timeWeightedNotionalPayFixed The aggregated time-weighted notional value for the pay fixed leg.
    /// @return timeWeightedNotionalReceiveFixed The aggregated time-weighted notional value for the receive fixed leg.
    /// @dev This function is internal and used to calculate the aggregated time-weighted notional values for multiple storage IDs and maturities.
    function getTimeWeightedNotional(
        SpreadStorageLibs.StorageId[] memory timeWeightedNotionalStorageIds,
        uint256[] memory tenorsInSeconds,
        uint256 selectedTenorInSeconds
    ) internal view returns (uint256 timeWeightedNotionalPayFixed, uint256 timeWeightedNotionalReceiveFixed) {
        uint256 length = timeWeightedNotionalStorageIds.length;

        SpreadTypes.TimeWeightedNotionalMemory memory timeWeightedNotional;
        uint256 timeWeightedNotionalPayFixedIteration;
        uint256 timeWeightedNotionalReceiveFixedIteration;

        for (uint256 i; i != length; ) {
            timeWeightedNotional = SpreadStorageLibs.getTimeWeightedNotionalForAssetAndTenor(timeWeightedNotionalStorageIds[i]);
            timeWeightedNotionalPayFixedIteration = _isTimeWeightedNotionalRecalculationRequired(
                timeWeightedNotional.lastUpdateTimePayFixed,
                tenorsInSeconds[i],
                selectedTenorInSeconds
            )
                ? calculateTimeWeightedNotional(
                    timeWeightedNotional.timeWeightedNotionalPayFixed,
                    block.timestamp - timeWeightedNotional.lastUpdateTimePayFixed,
                    tenorsInSeconds[i]
                )
                : timeWeightedNotional.timeWeightedNotionalPayFixed;
            timeWeightedNotionalPayFixed = timeWeightedNotionalPayFixed + timeWeightedNotionalPayFixedIteration;

            timeWeightedNotionalReceiveFixedIteration = _isTimeWeightedNotionalRecalculationRequired(
                timeWeightedNotional.lastUpdateTimeReceiveFixed,
                tenorsInSeconds[i],
                selectedTenorInSeconds
            )
                ? calculateTimeWeightedNotional(
                    timeWeightedNotional.timeWeightedNotionalReceiveFixed,
                    block.timestamp - timeWeightedNotional.lastUpdateTimeReceiveFixed,
                    tenorsInSeconds[i]
                )
                : timeWeightedNotional.timeWeightedNotionalReceiveFixed;
            timeWeightedNotionalReceiveFixed = timeWeightedNotionalReceiveFixedIteration + timeWeightedNotionalReceiveFixed;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Determines if the time-weighted notional should be recalculated based on the last update time and tenors.
    /// @param lastUpdateTime The last time the notional was updated.
    /// @param iterationTenorInSeconds The tenor duration in seconds.
    /// @param selectedTenorInSeconds The duration in seconds for which the spread should be calculated for a given tenor.
    /// @dev This function is internal and used to decide if a recalculation of the time-weighted notional is necessary.
    function _isTimeWeightedNotionalRecalculationRequired(
        uint256 lastUpdateTime,
        uint256 iterationTenorInSeconds,
        uint256 selectedTenorInSeconds
    ) internal view returns (bool) {
        return iterationTenorInSeconds + lastUpdateTime < block.timestamp + selectedTenorInSeconds;
    }
}

library CalculateTimeWeightedNotionalLibsBaseV1 {
    /// @notice calculate amm lp depth
    /// @param liquidityPoolBalance liquidity pool balance
    /// @param totalCollateralPayFixed total collateral pay fixed
    /// @param totalCollateralReceiveFixed total collateral receive fixed
    function calculateLpDepth(
        uint256 liquidityPoolBalance,
        uint256 totalCollateralPayFixed,
        uint256 totalCollateralReceiveFixed
    ) internal pure returns (uint256 lpDepth) {
        if (totalCollateralPayFixed >= totalCollateralReceiveFixed) {
            lpDepth = liquidityPoolBalance + totalCollateralReceiveFixed - totalCollateralPayFixed;
        } else {
            lpDepth = liquidityPoolBalance + totalCollateralPayFixed - totalCollateralReceiveFixed;
        }
    }

    /// @notice calculate weighted notional
    /// @param timeWeightedNotional weighted notional value
    /// @param timeFromLastUpdate time from last update in seconds
    /// @param tenorInSeconds tenor in seconds
    function calculateTimeWeightedNotional(
        uint256 timeWeightedNotional,
        uint256 timeFromLastUpdate,
        uint256 tenorInSeconds
    ) internal pure returns (uint256) {
        if (timeFromLastUpdate >= tenorInSeconds) {
            return 0;
        }
        uint256 newTimeWeightedNotional = IporMath.divisionWithoutRound(
            timeWeightedNotional * (tenorInSeconds - timeFromLastUpdate),
            tenorInSeconds
        );
        return newTimeWeightedNotional;
    }

    /// @notice Updates the time-weighted notional value for the receive fixed leg.
    /// @param timeWeightedNotional The memory struct containing the time-weighted notional information.
    /// @param newSwapNotional The new swap notional value.
    /// @param tenorInSeconds Tenor in seconds.
    /// @dev This function is internal and used to update the time-weighted notional value for the receive fixed leg.
    function updateTimeWeightedNotionalReceiveFixed(
        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory timeWeightedNotional,
        uint256 newSwapNotional,
        uint256 tenorInSeconds
    ) internal {
        if (timeWeightedNotional.timeWeightedNotionalReceiveFixed == 0) {
            timeWeightedNotional.timeWeightedNotionalReceiveFixed = calculateTimeWeightedNotional(
                newSwapNotional,
                0,
                tenorInSeconds
            );
        } else {
            uint256 oldWeightedNotionalReceiveFixed = calculateTimeWeightedNotional(
                timeWeightedNotional.timeWeightedNotionalReceiveFixed,
                block.timestamp - timeWeightedNotional.lastUpdateTimeReceiveFixed,
                tenorInSeconds
            );
            timeWeightedNotional.timeWeightedNotionalReceiveFixed = newSwapNotional + oldWeightedNotionalReceiveFixed;
        }
        timeWeightedNotional.lastUpdateTimeReceiveFixed = block.timestamp;
        SpreadStorageLibsBaseV1.saveTimeWeightedNotionalForAssetAndTenor(
            timeWeightedNotional.storageId,
            timeWeightedNotional
        );
    }

    /// @notice Updates the time-weighted notional value for the pay fixed leg.
    /// @param timeWeightedNotional The memory struct containing the time-weighted notional information.
    /// @param newSwapNotional The new swap notional value.
    /// @param tenorInSeconds Tenor in seconds.
    /// @dev This function is internal and used to update the time-weighted notional value for the pay fixed leg.
    function updateTimeWeightedNotionalPayFixed(
        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory timeWeightedNotional,
        uint256 newSwapNotional,
        uint256 tenorInSeconds
    ) internal {
        if (timeWeightedNotional.timeWeightedNotionalPayFixed == 0) {
            timeWeightedNotional.timeWeightedNotionalPayFixed = calculateTimeWeightedNotional(
                newSwapNotional,
                0,
                tenorInSeconds
            );
        } else {
            uint256 oldWeightedNotionalPayFixed = calculateTimeWeightedNotional(
                timeWeightedNotional.timeWeightedNotionalPayFixed,
                block.timestamp - timeWeightedNotional.lastUpdateTimePayFixed,
                tenorInSeconds
            );
            timeWeightedNotional.timeWeightedNotionalPayFixed = newSwapNotional + oldWeightedNotionalPayFixed;
        }
        timeWeightedNotional.lastUpdateTimePayFixed = block.timestamp;
        SpreadStorageLibsBaseV1.saveTimeWeightedNotionalForAssetAndTenor(
            timeWeightedNotional.storageId,
            timeWeightedNotional
        );
    }

    /// @notice Calculates the time-weighted notional values for the pay fixed and receive fixed legs.
    /// @param timeWeightedNotionalStorageIds The array of storage IDs representing the time-weighted notional storage locations.
    /// @param tenorsInSeconds The array of maturities corresponding to each storage ID.
    /// @param selectedTenorInSeconds The tenor in seconds used to calculate the time-weighted notional values.
    /// @return timeWeightedNotionalPayFixed The aggregated time-weighted notional value for the pay fixed leg.
    /// @return timeWeightedNotionalReceiveFixed The aggregated time-weighted notional value for the receive fixed leg.
    /// @dev This function is internal and used to calculate the aggregated time-weighted notional values for multiple storage IDs and maturities.
    function getTimeWeightedNotional(
        SpreadStorageLibsBaseV1.StorageId[] memory timeWeightedNotionalStorageIds,
        uint256[] memory tenorsInSeconds,
        uint256 selectedTenorInSeconds
    ) internal view returns (uint256 timeWeightedNotionalPayFixed, uint256 timeWeightedNotionalReceiveFixed) {
        uint256 length = timeWeightedNotionalStorageIds.length;

        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory timeWeightedNotional;
        uint256 timeWeightedNotionalPayFixedIteration;
        uint256 timeWeightedNotionalReceiveFixedIteration;

        for (uint256 i; i != length; ) {
            timeWeightedNotional = SpreadStorageLibsBaseV1.getTimeWeightedNotionalForAssetAndTenor(
                timeWeightedNotionalStorageIds[i]
            );
            timeWeightedNotionalPayFixedIteration = _isTimeWeightedNotionalRecalculationRequired(
                timeWeightedNotional.lastUpdateTimePayFixed,
                tenorsInSeconds[i],
                selectedTenorInSeconds
            )
                ? calculateTimeWeightedNotional(
                    timeWeightedNotional.timeWeightedNotionalPayFixed,
                    block.timestamp - timeWeightedNotional.lastUpdateTimePayFixed,
                    tenorsInSeconds[i]
                )
                : timeWeightedNotional.timeWeightedNotionalPayFixed;
            timeWeightedNotionalPayFixed = timeWeightedNotionalPayFixed + timeWeightedNotionalPayFixedIteration;

            timeWeightedNotionalReceiveFixedIteration = _isTimeWeightedNotionalRecalculationRequired(
                timeWeightedNotional.lastUpdateTimeReceiveFixed,
                tenorsInSeconds[i],
                selectedTenorInSeconds
            )
                ? calculateTimeWeightedNotional(
                    timeWeightedNotional.timeWeightedNotionalReceiveFixed,
                    block.timestamp - timeWeightedNotional.lastUpdateTimeReceiveFixed,
                    tenorsInSeconds[i]
                )
                : timeWeightedNotional.timeWeightedNotionalReceiveFixed;
            timeWeightedNotionalReceiveFixed =
                timeWeightedNotionalReceiveFixedIteration +
                timeWeightedNotionalReceiveFixed;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Determines if the time-weighted notional should be recalculated based on the last update time and tenors.
    /// @param lastUpdateTime The last time the notional was updated.
    /// @param iterationTenorInSeconds The tenor duration in seconds.
    /// @param selectedTenorInSeconds The duration in seconds for which the spread should be calculated for a given tenor.
    /// @dev This function is internal and used to decide if a recalculation of the time-weighted notional is necessary.
    function _isTimeWeightedNotionalRecalculationRequired(
        uint256 lastUpdateTime,
        uint256 iterationTenorInSeconds,
        uint256 selectedTenorInSeconds
    ) internal view returns (bool) {
        return iterationTenorInSeconds + lastUpdateTime < block.timestamp + selectedTenorInSeconds;
    }
}

library DemandSpreadStEthLibsBaseV1 {
    uint256 internal constant INTERVAL_ONE = 2e17;
    uint256 internal constant INTERVAL_TWO = 5e17;
    uint256 internal constant INTERVAL_THREE = 1e18;

    uint256 internal constant SLOPE_ONE = 8333333333333333;
    uint256 internal constant BASE_ONE = 0;

    uint256 internal constant SLOPE_TWO = 22222222222222222;
    uint256 internal constant BASE_TWO = 2777777777777778;

    uint256 internal constant SLOPE_THREE = 83333333333333333;
    uint256 internal constant BASE_THREE = 33333333333333333;

    /// @notice DTO for the Weighted Notional
    struct SpreadInputData {
        /// @notice Swap's balance for Pay Fixed leg
        uint256 totalCollateralPayFixed;
        /// @notice Swap's balance for Receive Fixed leg
        uint256 totalCollateralReceiveFixed;
        /// @notice Liquidity Pool's Balance
        uint256 liquidityPoolBalance;
        /// @notice Swap's notional
        uint256 swapNotional;
        /// @notice demand spread factor used in demand spread calculation, value without decimals
        uint256 demandSpreadFactor;
        /// @notice List of supported tenors in seconds
        uint256[] tenorsInSeconds;
        /// @notice List of storage ids for a TimeWeightedNotional for all tenors for a given asset
        SpreadStorageLibsBaseV1.StorageId[] timeWeightedNotionalStorageIds;
        /// @notice Storage id for a TimeWeightedNotional for a specific tenor and asset.
        SpreadStorageLibsBaseV1.StorageId timeWeightedNotionalStorageId;
        // @notice Calculation for tenor in seconds
        uint256 selectedTenorInSeconds;
    }

    /// @notice Gets the spread function configuration.
    function spreadFunctionConfig() internal pure returns (uint256[] memory) {
        uint256[] memory config = new uint256[](21);
        config[0] = INTERVAL_ONE;
        config[1] = INTERVAL_TWO;
        config[2] = INTERVAL_THREE;
        config[3] = SLOPE_ONE;
        config[4] = BASE_ONE;
        config[5] = SLOPE_TWO;
        config[6] = BASE_TWO;
        config[7] = SLOPE_THREE;
        config[8] = BASE_THREE;
        return config;
    }

    /// @notice Calculates the spread value for the pay-fixed side based on the provided input data.
    /// @param inputData The input data required for the calculation, including liquidity pool information and collateral amounts.
    /// @return spreadValue The calculated spread value for the pay-fixed side.
    function calculatePayFixedSpread(SpreadInputData memory inputData) internal view returns (uint256 spreadValue) {
        uint256 lpDepth = CalculateTimeWeightedNotionalLibsBaseV1.calculateLpDepth(
            inputData.liquidityPoolBalance,
            inputData.totalCollateralPayFixed,
            inputData.totalCollateralReceiveFixed
        );

        /// @dev demandSpreadFactor is without decimals.
        uint256 notionalDepth = lpDepth * inputData.demandSpreadFactor;

        (
            uint256 oldWeightedNotionalPayFixed,
            uint256 timeWeightedNotionalReceiveFixed
        ) = CalculateTimeWeightedNotionalLibsBaseV1.getTimeWeightedNotional(
                inputData.timeWeightedNotionalStorageIds,
                inputData.tenorsInSeconds,
                inputData.selectedTenorInSeconds
            );

        uint256 newWeightedNotionalPayFixed = oldWeightedNotionalPayFixed + inputData.swapNotional;

        if (newWeightedNotionalPayFixed > timeWeightedNotionalReceiveFixed) {
            uint256 oldSpread;

            if (oldWeightedNotionalPayFixed > timeWeightedNotionalReceiveFixed) {
                oldSpread = calculateSpreadFunction(
                    notionalDepth,
                    oldWeightedNotionalPayFixed - timeWeightedNotionalReceiveFixed
                );
            }

            uint256 newSpread = calculateSpreadFunction(
                notionalDepth,
                newWeightedNotionalPayFixed - timeWeightedNotionalReceiveFixed
            );

            spreadValue = IporMath.division(oldSpread + newSpread, 2);
        } else {
            spreadValue = 0;
        }
    }

    /// @notice Calculates the spread value for the receive-fixed side based on the provided input data.
    /// @param inputData The input data required for the calculation, including liquidity pool information and collateral amounts.
    /// @return spreadValue The calculated spread value for the receive-fixed side.
    function calculateReceiveFixedSpread(SpreadInputData memory inputData) internal view returns (uint256 spreadValue) {
        uint256 lpDepth = CalculateTimeWeightedNotionalLibsBaseV1.calculateLpDepth(
            inputData.liquidityPoolBalance,
            inputData.totalCollateralPayFixed,
            inputData.totalCollateralReceiveFixed
        );

        /// @dev demandSpreadFactor is without decimals.
        uint256 notionalDepth = lpDepth * inputData.demandSpreadFactor;

        (
            uint256 timeWeightedNotionalPayFixed,
            uint256 oldWeightedNotionalReceiveFixed
        ) = CalculateTimeWeightedNotionalLibsBaseV1.getTimeWeightedNotional(
                inputData.timeWeightedNotionalStorageIds,
                inputData.tenorsInSeconds,
                inputData.selectedTenorInSeconds
            );

        uint256 newWeightedNotionalReceiveFixed = oldWeightedNotionalReceiveFixed + inputData.swapNotional;

        if (newWeightedNotionalReceiveFixed > timeWeightedNotionalPayFixed) {
            uint256 oldSpread;

            if (oldWeightedNotionalReceiveFixed > timeWeightedNotionalPayFixed) {
                oldSpread = calculateSpreadFunction(
                    notionalDepth,
                    oldWeightedNotionalReceiveFixed - timeWeightedNotionalPayFixed
                );
            }

            uint256 newSpread = calculateSpreadFunction(
                notionalDepth,
                newWeightedNotionalReceiveFixed - timeWeightedNotionalPayFixed
            );

            spreadValue = IporMath.division(oldSpread + newSpread, 2);
        } else {
            spreadValue = 0;
        }
    }

    /// @notice Calculates the spread value based on the given maximum notional and weighted notional.
    /// @param maxNotional The maximum notional value determined by lpDepth and demandSpreadFactor from Risk Oracle
    /// @param weightedNotional The weighted notional value used in the spread calculation.
    /// @return spreadValue The calculated spread value based on the given inputs.
    /// @dev maxNotional = lpDepth * demandSpreadFactor
    function calculateSpreadFunction(
        uint256 maxNotional,
        uint256 weightedNotional
    ) internal pure returns (uint256 spreadValue) {
        uint256 ratio = IporMath.division(weightedNotional * 1e18, maxNotional);
        if (ratio < INTERVAL_ONE) {
            spreadValue = IporMath.division(SLOPE_ONE * ratio, 1e18) - BASE_ONE;
            /// @dev spreadValue in range < 0%, 1% )
        } else if (ratio < INTERVAL_TWO) {
            spreadValue = IporMath.division(SLOPE_TWO * ratio, 1e18) - BASE_TWO;
            /// @dev spreadValue in range < 1%, 5% )
        } else if (ratio < INTERVAL_THREE) {
            spreadValue = IporMath.division(SLOPE_THREE * ratio, 1e18) - BASE_THREE;
            /// @dev spreadValue in range < 5%, 30% )
        } else {
            spreadValue = 5 * 1e16;
            /// @dev spreadValue is equal to 30%
        }
    }
}

/// @title Offered rate calculation library
library OfferedRateCalculationLibsBaseV1 {
    using SafeCast for uint256;
    using SafeCast for int256;

    /// @notice Calculates the offered rate for the pay-fixed side based on the provided spread and risk inputs.
    /// @param iporIndexValue The IPOR index value.
    /// @param baseSpreadPerLeg The base spread per leg.
    /// @param demandSpread The demand spread.
    /// @param payFixedMinCap The pay-fixed minimum cap.
    /// @return offeredRate The calculated offered rate for pay-fixed side.
    function calculatePayFixedOfferedRate(
        uint256 iporIndexValue,
        int256 baseSpreadPerLeg,
        uint256 demandSpread,
        uint256 payFixedMinCap
    ) internal pure returns (uint256 offeredRate) {
        int256 baseOfferedRate = iporIndexValue.toInt256() + baseSpreadPerLeg;

        if (baseOfferedRate > payFixedMinCap.toInt256()) {
            offeredRate = baseOfferedRate.toUint256() + demandSpread;
        } else {
            offeredRate = payFixedMinCap + demandSpread;
        }
    }

    /// @notice Calculates the offered rate for the receive-fixed side based on the provided spread and risk inputs.
    /// @param iporIndexValue The IPOR index value.
    /// @param baseSpreadPerLeg The base spread per leg.
    /// @param demandSpread The demand spread.
    /// @param receiveFixedMaxCap The receive-fixed maximum cap.
    /// @return offeredRate The calculated offered rate for receive-fixed side.
    function calculateReceiveFixedOfferedRate(
        uint256 iporIndexValue,
        int256 baseSpreadPerLeg,
        uint256 demandSpread,
        uint256 receiveFixedMaxCap
    ) internal pure returns (uint256 offeredRate) {
        int256 baseOfferedRate = iporIndexValue.toInt256() + baseSpreadPerLeg;

        int256 temp;
        if (baseOfferedRate < receiveFixedMaxCap.toInt256()) {
            temp = baseOfferedRate - demandSpread.toInt256();
        } else {
            temp = receiveFixedMaxCap.toInt256() - demandSpread.toInt256();
        }
        offeredRate = temp < 0 ? 0 : temp.toUint256();
    }
}

// @dev This contract should calculate the spread for one asset and for all tenors.
contract SpreadBaseV1 is IporOwnable, ISpreadBaseV1 {
    error UnknownTenor(IporTypes.SwapTenor tenor, string errorCode, string methodName);
    using IporContractValidator for address;
    using SafeCast for uint256;
    using SafeCast for int256;

    address public immutable asset;
    address public immutable iporProtocolRouter;

    modifier onlyRouter() {
        require(msg.sender == iporProtocolRouter, IporErrors.CALLER_NOT_IPOR_PROTOCOL_ROUTER);
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address iporProtocolRouterInput,
        address assetInput,
        SpreadTypesBaseV1.TimeWeightedNotionalMemory[] memory timeWeightedNotional
    ) {
        iporProtocolRouter = iporProtocolRouterInput.checkAddress();
        asset = assetInput.checkAddress();
        uint256 length = timeWeightedNotional.length;
        for (uint256 i; i < length; ) {
            SpreadStorageLibsBaseV1.saveTimeWeightedNotionalForAssetAndTenor(
                timeWeightedNotional[i].storageId,
                timeWeightedNotional[i]
            );
            unchecked {
                ++i;
            }
        }
    }

    function getVersion() external pure virtual override returns (uint256) {
        return 2_001;
    }

    function spreadFunctionConfig() external pure override returns (uint256[] memory) {
        return DemandSpreadStEthLibsBaseV1.spreadFunctionConfig();
    }

    function getTimeWeightedNotional()
        external
        view
        override
        returns (SpreadTypesBaseV1.TimeWeightedNotionalResponse[] memory timeWeightedNotionalResponse)
    {
        (SpreadStorageLibsBaseV1.StorageId[] memory storageIds, string[] memory keys) = SpreadStorageLibsBaseV1
            .getAllStorageId();
        uint256 storageIdLength = storageIds.length;
        timeWeightedNotionalResponse = new SpreadTypesBaseV1.TimeWeightedNotionalResponse[](storageIdLength);

        for (uint256 i; i != storageIdLength; ) {
            timeWeightedNotionalResponse[i].timeWeightedNotional = SpreadStorageLibsBaseV1
                .getTimeWeightedNotionalForAssetAndTenor(storageIds[i]);
            timeWeightedNotionalResponse[i].key = keys[i];
            unchecked {
                ++i;
            }
        }
    }

    function calculateOfferedRate(
        AmmTypes.SwapDirection direction,
        SpreadInputs calldata spreadInputs
    ) external view override returns (uint256) {
        if (direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            return
                OfferedRateCalculationLibsBaseV1.calculatePayFixedOfferedRate(
                    spreadInputs.iporIndexValue,
                    spreadInputs.baseSpreadPerLeg,
                    _calculateDemandPayFixed(spreadInputs),
                    spreadInputs.fixedRateCapPerLeg
                );
        } else if (direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            return
                OfferedRateCalculationLibsBaseV1.calculateReceiveFixedOfferedRate(
                    spreadInputs.iporIndexValue,
                    spreadInputs.baseSpreadPerLeg,
                    _calculateDemandReceiveFixed(spreadInputs),
                    spreadInputs.fixedRateCapPerLeg
                );
        } else {
            revert IporErrors.UnsupportedDirection(AmmErrors.UNSUPPORTED_DIRECTION, uint256(direction));
        }
    }

    function calculateOfferedRatePayFixed(
        SpreadInputs calldata spreadInputs
    ) external view override returns (uint256 offeredRate) {
        offeredRate = OfferedRateCalculationLibsBaseV1.calculatePayFixedOfferedRate(
            spreadInputs.iporIndexValue,
            spreadInputs.baseSpreadPerLeg,
            _calculateDemandPayFixed(spreadInputs),
            spreadInputs.fixedRateCapPerLeg
        );
    }

    function calculateOfferedRateReceiveFixed(
        SpreadInputs calldata spreadInputs
    ) external view override returns (uint256 offeredRate) {
        offeredRate = OfferedRateCalculationLibsBaseV1.calculateReceiveFixedOfferedRate(
            spreadInputs.iporIndexValue,
            spreadInputs.baseSpreadPerLeg,
            _calculateDemandReceiveFixed(spreadInputs),
            spreadInputs.fixedRateCapPerLeg
        );
    }

    function calculateAndUpdateOfferedRatePayFixed(
        SpreadInputs calldata spreadInputs
    ) external override onlyRouter returns (uint256 offeredRate) {
        offeredRate = OfferedRateCalculationLibsBaseV1.calculatePayFixedOfferedRate(
            spreadInputs.iporIndexValue,
            spreadInputs.baseSpreadPerLeg,
            _calculateDemandPayFixedAndUpdateTimeWeightedNotional(spreadInputs),
            spreadInputs.fixedRateCapPerLeg
        );
    }

    function calculateAndUpdateOfferedRateReceiveFixed(
        SpreadInputs calldata spreadInputs
    ) external override onlyRouter returns (uint256 offeredRate) {
        offeredRate = OfferedRateCalculationLibsBaseV1.calculateReceiveFixedOfferedRate(
            spreadInputs.iporIndexValue,
            spreadInputs.baseSpreadPerLeg,
            _calculateImbalanceReceiveFixedAndUpdateTimeWeightedNotional(spreadInputs),
            spreadInputs.fixedRateCapPerLeg
        );
    }

    function updateTimeWeightedNotionalOnClose(
        uint256 direction,
        IporTypes.SwapTenor tenor,
        uint256 swapNotional,
        AmmInternalTypes.OpenSwapItem memory closedSwap,
        address ammStorageAddress
    ) external override onlyRouter {
        // @dev when timestamp is 0, it means that the swap was open in ipor-protocol v1 .
        if (closedSwap.openSwapTimestamp == 0) {
            return;
        }
        uint256 tenorInSeconds = SwapLogicBaseV1.getTenorInSeconds(tenor);
        SpreadStorageLibsBaseV1.StorageId storageId = _calculateStorageId(tenor);
        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory timeWeightedNotional = SpreadStorageLibsBaseV1
            .getTimeWeightedNotionalForAssetAndTenor(storageId);

        uint256 timeWeightedNotionalAmount = direction == 0
            ? timeWeightedNotional.timeWeightedNotionalPayFixed
            : timeWeightedNotional.timeWeightedNotionalReceiveFixed;
        uint256 timeOfLastUpdate = direction == 0
            ? timeWeightedNotional.lastUpdateTimePayFixed
            : timeWeightedNotional.lastUpdateTimeReceiveFixed;

        uint256 timeWeightedNotionalToRemove = CalculateTimeWeightedNotionalLibs.calculateTimeWeightedNotional(
            swapNotional,
            // @dev timeOfLastUpdate should be greater than closedSwap.openSwapTimestamp
            timeOfLastUpdate - closedSwap.openSwapTimestamp,
            tenorInSeconds
        );

        uint256 actualTimeWeightedNotionalToSave;
        if (timeWeightedNotionalAmount > timeWeightedNotionalToRemove) {
            actualTimeWeightedNotionalToSave = timeWeightedNotionalAmount - timeWeightedNotionalToRemove;
        }

        if (closedSwap.nextSwapId == 0) {
            AmmInternalTypes.OpenSwapItem memory lastOpenSwap = IAmmStorageBaseV1(ammStorageAddress).getLastOpenedSwap(
                tenor,
                direction
            );
            uint256 swapTimePast = block.timestamp - uint256(lastOpenSwap.openSwapTimestamp);
            if (tenorInSeconds <= swapTimePast) {
                actualTimeWeightedNotionalToSave = 0;
                swapTimePast = 0;
            }
            if (direction == 0) {
                timeWeightedNotional.lastUpdateTimePayFixed = lastOpenSwap.openSwapTimestamp;
                timeWeightedNotional.timeWeightedNotionalPayFixed =
                    (actualTimeWeightedNotionalToSave * tenorInSeconds) /
                    (tenorInSeconds - swapTimePast);
            } else {
                timeWeightedNotional.lastUpdateTimeReceiveFixed = lastOpenSwap.openSwapTimestamp;
                timeWeightedNotional.timeWeightedNotionalReceiveFixed =
                    (actualTimeWeightedNotionalToSave * tenorInSeconds) /
                    (tenorInSeconds - swapTimePast);
            }
        } else {
            if (direction == 0) {
                timeWeightedNotional.timeWeightedNotionalPayFixed = actualTimeWeightedNotionalToSave;
            } else {
                timeWeightedNotional.timeWeightedNotionalReceiveFixed = actualTimeWeightedNotionalToSave;
            }
        }

        SpreadStorageLibsBaseV1.saveTimeWeightedNotionalForAssetAndTenor(storageId, timeWeightedNotional);
    }

    function updateTimeWeightedNotional(
        SpreadTypesBaseV1.TimeWeightedNotionalMemory[] calldata timeWeightedNotionalMemories
    ) external override onlyOwner {
        uint256 length = timeWeightedNotionalMemories.length;
        for (uint256 i; i < length; ) {
            SpreadStorageLibsBaseV1.checkTimeWeightedNotional(timeWeightedNotionalMemories[i].storageId);
            SpreadStorageLibsBaseV1.saveTimeWeightedNotionalForAssetAndTenor(
                timeWeightedNotionalMemories[i].storageId,
                timeWeightedNotionalMemories[i]
            );

            emit AmmEventsBaseV1.SpreadTimeWeightedNotionalChanged({
                timeWeightedNotionalPayFixed: timeWeightedNotionalMemories[i].timeWeightedNotionalPayFixed,
                lastUpdateTimePayFixed: timeWeightedNotionalMemories[i].lastUpdateTimePayFixed,
                timeWeightedNotionalReceiveFixed: timeWeightedNotionalMemories[i].timeWeightedNotionalReceiveFixed,
                lastUpdateTimeReceiveFixed: timeWeightedNotionalMemories[i].lastUpdateTimeReceiveFixed,
                storageId: uint256(timeWeightedNotionalMemories[i].storageId)
            });

            unchecked {
                ++i;
            }
        }
    }

    function _calculateDemandPayFixed(SpreadInputs memory spreadInputs) internal view returns (uint256 spreadValue) {
        DemandSpreadStEthLibsBaseV1.SpreadInputData memory inputData = _getSpreadConfigForDemand(spreadInputs);

        spreadValue = DemandSpreadStEthLibsBaseV1.calculatePayFixedSpread(inputData);
    }

    function _calculateDemandPayFixedAndUpdateTimeWeightedNotional(
        SpreadInputs memory spreadInputs
    ) internal returns (uint256 spreadValue) {
        DemandSpreadStEthLibsBaseV1.SpreadInputData memory inputData = _getSpreadConfigForDemand(spreadInputs);
        spreadValue = DemandSpreadStEthLibsBaseV1.calculatePayFixedSpread(inputData);

        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory weightedNotional = SpreadStorageLibsBaseV1
            .getTimeWeightedNotionalForAssetAndTenor(inputData.timeWeightedNotionalStorageId);

        CalculateTimeWeightedNotionalLibsBaseV1.updateTimeWeightedNotionalPayFixed(
            weightedNotional,
            inputData.swapNotional,
            _calculateTenorInSeconds(spreadInputs.tenor)
        );
    }

    function _calculateDemandReceiveFixed(
        SpreadInputs calldata spreadInputs
    ) internal view returns (uint256 spreadValue) {
        DemandSpreadStEthLibsBaseV1.SpreadInputData memory inputData = _getSpreadConfigForDemand(spreadInputs);

        spreadValue = DemandSpreadStEthLibsBaseV1.calculateReceiveFixedSpread(inputData);
    }

    function _calculateImbalanceReceiveFixedAndUpdateTimeWeightedNotional(
        SpreadInputs calldata spreadInputs
    ) internal returns (uint256 spreadValue) {
        DemandSpreadStEthLibsBaseV1.SpreadInputData memory inputData = _getSpreadConfigForDemand(spreadInputs);

        spreadValue = DemandSpreadStEthLibsBaseV1.calculateReceiveFixedSpread(inputData);
        SpreadTypesBaseV1.TimeWeightedNotionalMemory memory weightedNotional = SpreadStorageLibsBaseV1
            .getTimeWeightedNotionalForAssetAndTenor(inputData.timeWeightedNotionalStorageId);

        CalculateTimeWeightedNotionalLibsBaseV1.updateTimeWeightedNotionalReceiveFixed(
            weightedNotional,
            inputData.swapNotional,
            _calculateTenorInSeconds(spreadInputs.tenor)
        );
    }

    function _getSpreadConfigForDemand(
        SpreadInputs memory spreadInputs
    ) internal pure returns (DemandSpreadStEthLibsBaseV1.SpreadInputData memory inputData) {
        inputData = DemandSpreadStEthLibsBaseV1.SpreadInputData({
            totalCollateralPayFixed: spreadInputs.totalCollateralPayFixed,
            totalCollateralReceiveFixed: spreadInputs.totalCollateralReceiveFixed,
            liquidityPoolBalance: spreadInputs.liquidityPoolBalance,
            swapNotional: spreadInputs.swapNotional,
            demandSpreadFactor: spreadInputs.demandSpreadFactor,
            tenorsInSeconds: new uint256[](3),
            timeWeightedNotionalStorageIds: new SpreadStorageLibsBaseV1.StorageId[](3),
            timeWeightedNotionalStorageId: _calculateStorageId(spreadInputs.tenor),
            selectedTenorInSeconds: _calculateTenorInSeconds(spreadInputs.tenor)
        });

        inputData.tenorsInSeconds[0] = 28 days;
        inputData.tenorsInSeconds[1] = 60 days;
        inputData.tenorsInSeconds[2] = 90 days;

        inputData.timeWeightedNotionalStorageIds[0] = SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional28Days;
        inputData.timeWeightedNotionalStorageIds[1] = SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional60Days;
        inputData.timeWeightedNotionalStorageIds[2] = SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional90Days;
        return inputData;
    }

    function _calculateTenorInSeconds(IporTypes.SwapTenor tenor) private pure returns (uint256 tenorInSeconds) {
        if (tenor == IporTypes.SwapTenor.DAYS_28) {
            return 28 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
            return 60 days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
            return 90 days;
        }
        revert UnknownTenor({
            tenor: tenor,
            errorCode: AmmErrors.UNSUPPORTED_SWAP_TENOR,
            methodName: "_calculateTenorInSeconds"
        });
    }

    function _calculateStorageId(
        IporTypes.SwapTenor tenor
    ) private pure returns (SpreadStorageLibsBaseV1.StorageId storageId) {
        if (tenor == IporTypes.SwapTenor.DAYS_28) {
            return SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional28Days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_60) {
            return SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional60Days;
        } else if (tenor == IporTypes.SwapTenor.DAYS_90) {
            return SpreadStorageLibsBaseV1.StorageId.TimeWeightedNotional90Days;
        }
        revert UnknownTenor({
            tenor: tenor,
            errorCode: AmmErrors.UNSUPPORTED_SWAP_TENOR,
            methodName: "_calculateStorageId"
        });
    }
}

/// @title Abstract contract for closing swap, generation one, characterized by:
/// - no asset management, so also no auto rebalance
abstract contract AmmCloseSwapServiceBaseV1 is IAmmCloseSwapService {
    using Address for address;
    using IporContractValidator for address;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SwapLogicBaseV1 for AmmTypesBaseV1.Swap;
    using AmmLib for AmmTypes.AmmPoolCoreModel;
    using RiskIndicatorsValidatorLib for AmmTypes.RiskIndicatorsInputs;

    uint256 public immutable version = 2001;

    address public immutable asset;
    uint256 public immutable decimals;

    address public immutable messageSigner;
    address public immutable iporOracle;
    address public immutable spread;
    address public immutable ammStorage;
    address public immutable ammTreasury;

    /// @dev Unwinding fee rate, value represented in 18 decimals. Represents percentage of swap notional.
    uint256 public immutable unwindingFeeRate;
    /// @dev Unwinding fee treasury portion rate, value represented in 18 decimals. Represents percentage of unwinding fee, which is transferred to treasury.
    uint256 public immutable unwindingFeeTreasuryPortionRate;
    /// @dev Maximum length of liquidated swaps per leg, value represented WITHOUT 18 decimals.
    uint256 public immutable liquidationLegLimit;
    /// @dev Time in seconds before maturity allowed to close swap by community.
    uint256 public immutable timeBeforeMaturityAllowedToCloseSwapByCommunity;
    /// @dev Time in seconds before maturity allowed to close swap by buyer.
    uint256 public immutable timeBeforeMaturityAllowedToCloseSwapByBuyer;
    /// @dev Minimum liquidation threshold to close swap before maturity by community, value represented in 18 decimals.
    uint256 public immutable minLiquidationThresholdToCloseBeforeMaturityByCommunity;
    /// @dev Minimum liquidation threshold to close swap before maturity by buyer, value represented in 18 decimals.
    uint256 public immutable minLiquidationThresholdToCloseBeforeMaturityByBuyer;
    /// @dev Minimum leverage, value represented in 18 decimals.
    uint256 public immutable minLeverage;
    /// @dev Time after open swap when it is allowed to close swap with unwinding, represented in seconds
    uint256 public immutable timeAfterOpenAllowedToCloseSwapWithUnwinding;

    constructor(
        IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration memory poolCfg,
        address iporOracleInput,
        address messageSignerInput
    ) {
        asset = poolCfg.asset.checkAddress();
        decimals = poolCfg.decimals;

        messageSigner = messageSignerInput.checkAddress();
        iporOracle = iporOracleInput.checkAddress();
        spread = poolCfg.spread.checkAddress();
        ammStorage = poolCfg.ammStorage.checkAddress();
        ammTreasury = poolCfg.ammTreasury.checkAddress();

        unwindingFeeRate = poolCfg.unwindingFeeRate;
        unwindingFeeTreasuryPortionRate = poolCfg.unwindingFeeTreasuryPortionRate;
        liquidationLegLimit = poolCfg.maxLengthOfLiquidatedSwapsPerLeg;
        timeBeforeMaturityAllowedToCloseSwapByCommunity = poolCfg.timeBeforeMaturityAllowedToCloseSwapByCommunity;
        timeBeforeMaturityAllowedToCloseSwapByBuyer = poolCfg.timeBeforeMaturityAllowedToCloseSwapByBuyer;
        minLiquidationThresholdToCloseBeforeMaturityByCommunity = poolCfg
            .minLiquidationThresholdToCloseBeforeMaturityByCommunity;
        minLiquidationThresholdToCloseBeforeMaturityByBuyer = poolCfg
            .minLiquidationThresholdToCloseBeforeMaturityByBuyer;
        minLeverage = poolCfg.minLeverage;
        timeAfterOpenAllowedToCloseSwapWithUnwinding = poolCfg.timeAfterOpenAllowedToCloseSwapWithUnwinding;
    }

    function getPoolConfiguration()
        external
        view
        override
        returns (IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration memory)
    {
        return _getPoolConfiguration();
    }

    function _emergencyCloseSwaps(
        uint256[] memory payFixedSwapIds,
        uint256[] memory receiveFixedSwapIds,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    )
        internal
        returns (
            AmmTypes.IporSwapClosingResult[] memory closedPayFixedSwaps,
            AmmTypes.IporSwapClosingResult[] memory closedReceiveFixedSwaps
        )
    {
        (closedPayFixedSwaps, closedReceiveFixedSwaps) = _closeSwaps(
            msg.sender,
            payFixedSwapIds,
            receiveFixedSwapIds,
            riskIndicatorsInput
        );
    }

    function _closeSwaps(
        address beneficiary,
        uint256[] memory payFixedSwapIds,
        uint256[] memory receiveFixedSwapIds,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    )
        internal
        returns (
            AmmTypes.IporSwapClosingResult[] memory closedPayFixedSwaps,
            AmmTypes.IporSwapClosingResult[] memory closedReceiveFixedSwaps
        )
    {
        require(
            payFixedSwapIds.length <= liquidationLegLimit && receiveFixedSwapIds.length <= liquidationLegLimit,
            AmmErrors.MAX_LENGTH_LIQUIDATED_SWAPS_PER_LEG_EXCEEDED
        );

        uint256 payoutForLiquidatorPayFixed;
        uint256 payoutForLiquidatorReceiveFixed;

        (payoutForLiquidatorPayFixed, closedPayFixedSwaps) = _closeSwapsPerLeg(
            beneficiary,
            AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING,
            payFixedSwapIds,
            riskIndicatorsInput
        );

        (payoutForLiquidatorReceiveFixed, closedReceiveFixedSwaps) = _closeSwapsPerLeg(
            beneficiary,
            AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED,
            receiveFixedSwapIds,
            riskIndicatorsInput
        );

        _transferLiquidationDepositAmount(beneficiary, payoutForLiquidatorPayFixed + payoutForLiquidatorReceiveFixed);
    }

    function _closeSwapPayFixed(
        address beneficiary,
        uint256 indexValue,
        uint256 ibtPrice,
        AmmTypesBaseV1.Swap memory swap,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal returns (uint256 payoutForLiquidator) {
        uint256 timestamp = block.timestamp;
        int256 swapPnlValueToDate = SwapLogicBaseV1.calculatePnlPayFixed(
            swap.openTimestamp,
            swap.collateral,
            swap.notional,
            swap.fixedInterestRate,
            swap.ibtQuantity,
            timestamp,
            ibtPrice
        );

        AmmInternalTypes.PnlValueStruct memory pnlValueStruct = _preparePnlValueStructForClose(
            timestamp,
            swapPnlValueToDate,
            indexValue,
            swap,
            riskIndicatorsInput
        );

        ISpreadBaseV1(spread).updateTimeWeightedNotionalOnClose(
            uint256(swap.direction),
            swap.tenor,
            swap.notional,
            IAmmStorageBaseV1(ammStorage).updateStorageWhenCloseSwapPayFixedInternal(
                swap,
                pnlValueStruct.pnlValue,
                pnlValueStruct.swapUnwindFeeLPAmount,
                pnlValueStruct.swapUnwindFeeTreasuryAmount,
                timestamp
            ),
            ammStorage
        );

        uint256 transferredToBuyer;

        (transferredToBuyer, payoutForLiquidator) = _transferTokensBasedOnPnlValue(
            beneficiary,
            pnlValueStruct.pnlValue -
                pnlValueStruct.swapUnwindFeeLPAmount.toInt256() -
                pnlValueStruct.swapUnwindFeeTreasuryAmount.toInt256(),
            swap
        );

        if (pnlValueStruct.swapUnwindRequired) {
            emit AmmEventsBaseV1.SwapUnwind(
                asset,
                swap.id,
                swapPnlValueToDate,
                pnlValueStruct.swapUnwindAmount,
                pnlValueStruct.swapUnwindFeeLPAmount,
                pnlValueStruct.swapUnwindFeeTreasuryAmount
            );
        }

        emit AmmEventsBaseV1.CloseSwap(swap.id, asset, timestamp, beneficiary, transferredToBuyer, payoutForLiquidator);
    }

    function _closeSwapReceiveFixed(
        address beneficiary,
        uint256 indexValue,
        uint256 ibtPrice,
        AmmTypesBaseV1.Swap memory swap,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal returns (uint256 payoutForLiquidator) {
        uint256 timestamp = block.timestamp;
        int256 swapPnlValueToDate = SwapLogicBaseV1.calculatePnlReceiveFixed(
            swap.openTimestamp,
            swap.collateral,
            swap.notional,
            swap.fixedInterestRate,
            swap.ibtQuantity,
            timestamp,
            ibtPrice
        );

        AmmInternalTypes.PnlValueStruct memory pnlValueStruct = _preparePnlValueStructForClose(
            timestamp,
            swapPnlValueToDate,
            indexValue,
            swap,
            riskIndicatorsInput
        );

        SpreadBaseV1(spread).updateTimeWeightedNotionalOnClose(
            uint256(swap.direction),
            swap.tenor,
            swap.notional,
            IAmmStorageBaseV1(ammStorage).updateStorageWhenCloseSwapReceiveFixedInternal(
                swap,
                pnlValueStruct.pnlValue,
                pnlValueStruct.swapUnwindFeeLPAmount,
                pnlValueStruct.swapUnwindFeeTreasuryAmount,
                timestamp
            ),
            ammStorage
        );

        uint256 transferredToBuyer;

        (transferredToBuyer, payoutForLiquidator) = _transferTokensBasedOnPnlValue(
            beneficiary,
            pnlValueStruct.pnlValue -
                pnlValueStruct.swapUnwindFeeLPAmount.toInt256() -
                pnlValueStruct.swapUnwindFeeTreasuryAmount.toInt256(),
            swap
        );

        if (pnlValueStruct.swapUnwindRequired) {
            emit AmmEventsBaseV1.SwapUnwind(
                asset,
                swap.id,
                swapPnlValueToDate,
                pnlValueStruct.swapUnwindAmount,
                pnlValueStruct.swapUnwindFeeLPAmount,
                pnlValueStruct.swapUnwindFeeTreasuryAmount
            );
        }

        emit AmmEventsBaseV1.CloseSwap(swap.id, asset, timestamp, beneficiary, transferredToBuyer, payoutForLiquidator);
    }

    function _closeSwapsPerLeg(
        address beneficiary,
        AmmTypes.SwapDirection direction,
        uint256[] memory swapIds,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal returns (uint256 payoutForLiquidator, AmmTypes.IporSwapClosingResult[] memory closedSwaps) {
        uint256 swapIdsLength = swapIds.length;
        require(swapIdsLength <= liquidationLegLimit, AmmErrors.MAX_LENGTH_LIQUIDATED_SWAPS_PER_LEG_EXCEEDED);

        closedSwaps = new AmmTypes.IporSwapClosingResult[](swapIdsLength);
        AmmTypesBaseV1.Swap memory swap;

        IporTypes.AccruedIpor memory accruedIpor = IIporOracle(iporOracle).getAccruedIndex(block.timestamp, asset);
        uint256 swapId;

        for (uint256 i; i != swapIdsLength; ) {
            swapId = swapIds[i];
            require(swapId > 0, AmmErrors.INCORRECT_SWAP_ID);

            swap = IAmmStorageBaseV1(ammStorage).getSwap(direction, swapId);

            if (swap.state == IporTypes.SwapState.ACTIVE) {
                if (direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
                    payoutForLiquidator += _closeSwapPayFixed(
                        beneficiary,
                        accruedIpor.indexValue,
                        accruedIpor.ibtPrice,
                        swap,
                        riskIndicatorsInput
                    );
                } else if (direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
                    payoutForLiquidator += _closeSwapReceiveFixed(
                        beneficiary,
                        accruedIpor.indexValue,
                        accruedIpor.ibtPrice,
                        swap,
                        riskIndicatorsInput
                    );
                } else {
                    revert(AmmErrors.UNSUPPORTED_DIRECTION);
                }
                closedSwaps[i] = AmmTypes.IporSwapClosingResult(swapId, true);
            } else {
                closedSwaps[i] = AmmTypes.IporSwapClosingResult(swapId, false);
            }

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Transfer sum of all liquidation deposits to liquidator
    /// @param liquidator address of liquidator
    /// @param liquidationDepositAmount liquidation deposit amount, value represented in 18 decimals
    function _transferLiquidationDepositAmount(address liquidator, uint256 liquidationDepositAmount) internal {
        if (liquidationDepositAmount > 0) {
            IERC20Upgradeable(asset).safeTransferFrom(
                ammTreasury,
                liquidator,
                IporMath.convertWadToAssetDecimals(liquidationDepositAmount, decimals)
            );
        }
    }

    function _preparePnlValueStructForClose(
        uint256 closeTimestamp,
        int256 swapPnlValueToDate,
        uint256 indexValue,
        AmmTypesBaseV1.Swap memory swap,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal view returns (AmmInternalTypes.PnlValueStruct memory pnlValueStruct) {
        AmmTypes.SwapClosableStatus closableStatus;

        (closableStatus, pnlValueStruct.swapUnwindRequired) = SwapCloseLogicLibBaseV1.getClosableStatusForSwap(
            AmmTypesBaseV1.ClosableSwapInput({
                account: msg.sender,
                asset: asset,
                closeTimestamp: closeTimestamp,
                swapBuyer: swap.buyer,
                swapOpenTimestamp: swap.openTimestamp,
                swapCollateral: swap.collateral,
                swapTenor: swap.tenor,
                swapState: swap.state,
                swapPnlValueToDate: swapPnlValueToDate,
                minLiquidationThresholdToCloseBeforeMaturityByCommunity: minLiquidationThresholdToCloseBeforeMaturityByCommunity,
                minLiquidationThresholdToCloseBeforeMaturityByBuyer: minLiquidationThresholdToCloseBeforeMaturityByBuyer,
                timeBeforeMaturityAllowedToCloseSwapByCommunity: timeBeforeMaturityAllowedToCloseSwapByCommunity,
                timeBeforeMaturityAllowedToCloseSwapByBuyer: timeBeforeMaturityAllowedToCloseSwapByBuyer,
                timeAfterOpenAllowedToCloseSwapWithUnwinding: timeAfterOpenAllowedToCloseSwapWithUnwinding
            })
        );

        SwapCloseLogicLibBaseV1.validateAllowanceToCloseSwap(closableStatus);

        if (pnlValueStruct.swapUnwindRequired == true) {
            (
                pnlValueStruct.swapUnwindAmount,
                ,
                pnlValueStruct.swapUnwindFeeLPAmount,
                pnlValueStruct.swapUnwindFeeTreasuryAmount,
                pnlValueStruct.pnlValue
            ) = SwapCloseLogicLibBaseV1.calculateSwapUnwindWhenUnwindRequired(
                AmmTypesBaseV1.UnwindParams({
                    asset: asset,
                    messageSigner: messageSigner,
                    spread: spread,
                    ammStorage: ammStorage,
                    ammTreasury: ammTreasury,
                    closeTimestamp: closeTimestamp,
                    swapPnlValueToDate: swapPnlValueToDate,
                    indexValue: indexValue,
                    swap: swap,
                    unwindingFeeRate: unwindingFeeRate,
                    unwindingFeeTreasuryPortionRate: unwindingFeeTreasuryPortionRate,
                    riskIndicatorsInputs: riskIndicatorsInput
                })
            );
        } else {
            pnlValueStruct.pnlValue = swapPnlValueToDate;
        }
    }

    /**
     * @notice Function that transfers payout of the swap to the owner.
     * @dev Function:
     * # checks if swap profit, loss or achieve maturity allows for liquidation
     * # checks if swap's payout is larger than the collateral used to open it
     * # should the payout be larger than the collateral then it transfers payout to the buyer
     * @param swap - Derivative struct
     * @param pnlValue - Net earnings of the derivative. Can be positive (swap has a positive earnings) or negative (swap looses), value represented in 18 decimals, value include potential unwind fee.
     **/
    function _transferTokensBasedOnPnlValue(
        address beneficiary,
        int256 pnlValue,
        AmmTypesBaseV1.Swap memory swap
    ) internal returns (uint256 transferredToBuyer, uint256 payoutForLiquidator) {
        uint256 absPnlValue = IporMath.absoluteValue(pnlValue);

        if (pnlValue > 0) {
            //Buyer earns, AmmTreasury looses
            (transferredToBuyer, payoutForLiquidator) = _transferDerivativeAmount(
                beneficiary,
                swap.buyer,
                swap.wadLiquidationDepositAmount,
                swap.collateral + absPnlValue
            );
        } else {
            //AmmTreasury earns, Buyer looses
            (transferredToBuyer, payoutForLiquidator) = _transferDerivativeAmount(
                beneficiary,
                swap.buyer,
                swap.wadLiquidationDepositAmount,
                swap.collateral - absPnlValue
            );
        }
    }

    /// @notice Transfer derivative amount to buyer or liquidator.
    /// @param beneficiary Account which will receive the liquidation deposit amount
    /// @param buyer Account which will receive the collateral amount including pnl value (transferAmount)
    /// @param wadLiquidationDepositAmount Amount of liquidation deposit
    /// @param wadTransferAmount Amount of collateral including pnl value
    /// @return wadTransferredToBuyer Final value transferred to buyer, containing collateral and pnl value and if buyer is beneficiary, liquidation deposit amount
    /// @return wadPayoutForLiquidator Final value transferred to liquidator, if liquidator is beneficiary then value is zero
    /// @dev If beneficiary is buyer, then liquidation deposit amount is added to transfer amount.
    /// @dev Input amounts and returned values are represented in 18 decimals.
    function _transferDerivativeAmount(
        address beneficiary,
        address buyer,
        uint256 wadLiquidationDepositAmount,
        uint256 wadTransferAmount
    ) internal returns (uint256 wadTransferredToBuyer, uint256 wadPayoutForLiquidator) {
        if (beneficiary == buyer) {
            wadTransferAmount = wadTransferAmount + wadLiquidationDepositAmount;
        } else {
            /// @dev transfer liquidation deposit amount from AmmTreasury to Liquidator address (beneficiary),
            /// transfer to be made outside this function, to avoid multiple transfers
            wadPayoutForLiquidator = wadLiquidationDepositAmount;
        }

        if (wadTransferAmount > 0) {
            uint256 transferAmountAssetDecimals = IporMath.convertWadToAssetDecimals(wadTransferAmount, decimals);
            IERC20Upgradeable(asset).safeTransferFrom(ammTreasury, buyer, transferAmountAssetDecimals);
            wadTransferredToBuyer = IporMath.convertToWad(transferAmountAssetDecimals, decimals);
        }
    }

    function _getPoolConfiguration()
        internal
        view
        returns (IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration memory)
    {
        return
            IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration({
                asset: asset,
                decimals: decimals,
                ammStorage: ammStorage,
                ammTreasury: ammTreasury,
                assetManagement: address(0),
                spread: spread,
                unwindingFeeRate: unwindingFeeRate,
                unwindingFeeTreasuryPortionRate: unwindingFeeTreasuryPortionRate,
                maxLengthOfLiquidatedSwapsPerLeg: liquidationLegLimit,
                timeBeforeMaturityAllowedToCloseSwapByCommunity: timeBeforeMaturityAllowedToCloseSwapByCommunity,
                timeBeforeMaturityAllowedToCloseSwapByBuyer: timeBeforeMaturityAllowedToCloseSwapByBuyer,
                minLiquidationThresholdToCloseBeforeMaturityByCommunity: minLiquidationThresholdToCloseBeforeMaturityByCommunity,
                minLiquidationThresholdToCloseBeforeMaturityByBuyer: minLiquidationThresholdToCloseBeforeMaturityByBuyer,
                minLeverage: minLeverage,
                timeAfterOpenAllowedToCloseSwapWithUnwinding: timeAfterOpenAllowedToCloseSwapWithUnwinding
            });
    }
}

/// @dev It is not recommended to use service contract directly, should be used only through IporProtocolRouter.
contract AmmCloseSwapLens is IAmmCloseSwapLens {
    using Address for address;
    using IporContractValidator for address;
    using SwapLogicBaseV1 for AmmTypesBaseV1.Swap;

    address public immutable usdt;
    address public immutable usdc;
    address public immutable dai;
    address public immutable stETH;

    address public immutable iporOracle;
    address public immutable messageSigner;
    address public immutable spreadRouter;

    /// @dev Notice! Don't use following service to get data from storage, use only to get configuration stored in immutable fields.
    address public immutable closeSwapServiceUsdt;
    /// @dev Notice! Don't use following service to get data from storage, use only to get configuration stored in immutable fields.
    address public immutable closeSwapServiceUsdc;
    /// @dev Notice! Don't use following service to get data from storage, use only to get configuration stored in immutable fields.
    address public immutable closeSwapServiceDai;
    /// @dev Notice! Don't use following service to get data from storage, use only to get configuration stored in immutable fields.
    address public immutable closeSwapServiceStEth;

    constructor(
        address usdtInput,
        address usdcInput,
        address daiInput,
        address stETHInput,
        address iporOracleInput,
        address messageSignerInput,
        address spreadRouterInput,
        address closeSwapServiceUsdtInput,
        address closeSwapServiceUsdcInput,
        address closeSwapServiceDaiInput,
        address closeSwapServiceStEthInput
    ) {
        usdt = usdtInput.checkAddress();
        usdc = usdcInput.checkAddress();
        dai = daiInput.checkAddress();
        stETH = stETHInput.checkAddress();

        iporOracle = iporOracleInput.checkAddress();
        messageSigner = messageSignerInput.checkAddress();
        spreadRouter = spreadRouterInput.checkAddress();

        closeSwapServiceUsdt = closeSwapServiceUsdtInput.checkAddress();
        closeSwapServiceUsdc = closeSwapServiceUsdcInput.checkAddress();
        closeSwapServiceDai = closeSwapServiceDaiInput.checkAddress();
        closeSwapServiceStEth = closeSwapServiceStEthInput.checkAddress();
    }

    function getAmmCloseSwapServicePoolConfiguration(
        address asset
    ) external view override returns (AmmCloseSwapServicePoolConfiguration memory) {
        return _getPoolConfiguration(asset);
    }

    function _getPoolConfiguration(address asset) internal view returns (AmmCloseSwapServicePoolConfiguration memory) {
        if (asset == usdt) {
            return IAmmCloseSwapService(closeSwapServiceUsdt).getPoolConfiguration();
        } else if (asset == usdc) {
            return IAmmCloseSwapService(closeSwapServiceUsdc).getPoolConfiguration();
        } else if (asset == dai) {
            return IAmmCloseSwapService(closeSwapServiceDai).getPoolConfiguration();
        } else if (asset == stETH) {
            return IAmmCloseSwapService(closeSwapServiceStEth).getPoolConfiguration();
        } else {
            revert IporErrors.UnsupportedAsset(IporErrors.ASSET_NOT_SUPPORTED, asset);
        }
    }

    function getClosingSwapDetails(
        address asset,
        address account,
        AmmTypes.SwapDirection direction,
        uint256 swapId,
        uint256 closeTimestamp,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) external view override returns (AmmTypes.ClosingSwapDetails memory closingSwapDetails) {
        if (asset == usdt || asset == usdc || asset == dai) {
            closingSwapDetails = _getClosingSwapDetailsForStable(
                asset,
                account,
                direction,
                swapId,
                closeTimestamp,
                riskIndicatorsInput
            );
        } else if (asset == stETH) {
            closingSwapDetails = _getClosingSwapDetailsForStEth(
                account,
                direction,
                swapId,
                closeTimestamp,
                riskIndicatorsInput
            );
        } else {
            revert IporErrors.UnsupportedAsset(IporErrors.ASSET_NOT_SUPPORTED, asset);
        }
    }

    function _getClosingSwapDetailsForStable(
        address asset,
        address account,
        AmmTypes.SwapDirection direction,
        uint256 swapId,
        uint256 closeTimestamp,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal view returns (AmmTypes.ClosingSwapDetails memory closingSwapDetails) {
        AmmCloseSwapServicePoolConfiguration memory poolCfg = _getPoolConfiguration(asset);

        IporTypes.AccruedIpor memory accruedIpor = IIporOracle(iporOracle).getAccruedIndex(
            block.timestamp,
            poolCfg.asset
        );

        AmmTypes.Swap memory swap = IAmmStorage(poolCfg.ammStorage).getSwap(direction, swapId);

        require(swap.id > 0, AmmErrors.INCORRECT_SWAP_ID);

        int256 swapPnlValueToDate;

        if (direction == AmmTypes.SwapDirection.PAY_FIXED_RECEIVE_FLOATING) {
            swapPnlValueToDate = SwapLogicBaseV1.calculatePnlPayFixed(
                swap.openTimestamp,
                swap.collateral,
                swap.notional,
                swap.fixedInterestRate,
                swap.ibtQuantity,
                block.timestamp,
                accruedIpor.ibtPrice
            );
        } else if (direction == AmmTypes.SwapDirection.PAY_FLOATING_RECEIVE_FIXED) {
            swapPnlValueToDate = SwapLogicBaseV1.calculatePnlReceiveFixed(
                swap.openTimestamp,
                swap.collateral,
                swap.notional,
                swap.fixedInterestRate,
                swap.ibtQuantity,
                block.timestamp,
                accruedIpor.ibtPrice
            );
        } else {
            revert(AmmErrors.UNSUPPORTED_DIRECTION);
        }

        (closingSwapDetails.closableStatus, closingSwapDetails.swapUnwindRequired) = SwapCloseLogicLibBaseV1
            .getClosableStatusForSwap(
                AmmTypesBaseV1.ClosableSwapInput({
                    account: account,
                    asset: poolCfg.asset,
                    closeTimestamp: closeTimestamp,
                    swapBuyer: swap.buyer,
                    swapOpenTimestamp: swap.openTimestamp,
                    swapCollateral: swap.collateral,
                    swapTenor: swap.tenor,
                    swapState: swap.state,
                    swapPnlValueToDate: swapPnlValueToDate,
                    minLiquidationThresholdToCloseBeforeMaturityByCommunity: poolCfg
                        .minLiquidationThresholdToCloseBeforeMaturityByCommunity,
                    minLiquidationThresholdToCloseBeforeMaturityByBuyer: poolCfg
                        .minLiquidationThresholdToCloseBeforeMaturityByBuyer,
                    timeBeforeMaturityAllowedToCloseSwapByCommunity: poolCfg
                        .timeBeforeMaturityAllowedToCloseSwapByCommunity,
                    timeBeforeMaturityAllowedToCloseSwapByBuyer: poolCfg.timeBeforeMaturityAllowedToCloseSwapByBuyer,
                    timeAfterOpenAllowedToCloseSwapWithUnwinding: poolCfg.timeAfterOpenAllowedToCloseSwapWithUnwinding
                })
            );

        if (closingSwapDetails.swapUnwindRequired == true) {
            (
                closingSwapDetails.swapUnwindPnlValue,
                closingSwapDetails.swapUnwindOpeningFeeAmount,
                closingSwapDetails.swapUnwindFeeLPAmount,
                closingSwapDetails.swapUnwindFeeTreasuryAmount,
                closingSwapDetails.pnlValue
            ) = SwapCloseLogicLib.calculateSwapUnwindWhenUnwindRequired(
                AmmTypes.UnwindParams({
                    messageSigner: messageSigner,
                    spreadRouter: spreadRouter,
                    ammStorage: poolCfg.ammStorage,
                    ammTreasury: poolCfg.ammTreasury,
                    direction: direction,
                    closeTimestamp: closeTimestamp,
                    swapPnlValueToDate: swapPnlValueToDate,
                    indexValue: accruedIpor.indexValue,
                    swap: swap,
                    poolCfg: poolCfg,
                    riskIndicatorsInputs: riskIndicatorsInput
                })
            );
        } else {
            closingSwapDetails.pnlValue = swapPnlValueToDate;
        }
    }

    function _getClosingSwapDetailsForStEth(
        address account,
        AmmTypes.SwapDirection direction,
        uint256 swapId,
        uint256 closeTimestamp,
        AmmTypes.CloseSwapRiskIndicatorsInput calldata riskIndicatorsInput
    ) internal view returns (AmmTypes.ClosingSwapDetails memory closingSwapDetails) {
        IAmmCloseSwapLens.AmmCloseSwapServicePoolConfiguration memory poolCfg = AmmCloseSwapServiceBaseV1(
            closeSwapServiceStEth
        ).getPoolConfiguration();

        IporTypes.AccruedIpor memory accruedIpor = IIporOracle(iporOracle).getAccruedIndex(
            block.timestamp,
            poolCfg.asset
        );

        AmmTypesBaseV1.Swap memory swap = IAmmStorageBaseV1(poolCfg.ammStorage).getSwap(direction, swapId);

        require(swap.id > 0, AmmErrors.INCORRECT_SWAP_ID);

        int256 swapPnlValueToDate = swap.calculatePnl(block.timestamp, accruedIpor.ibtPrice);

        (closingSwapDetails.closableStatus, closingSwapDetails.swapUnwindRequired) = SwapCloseLogicLibBaseV1
            .getClosableStatusForSwap(
                AmmTypesBaseV1.ClosableSwapInput({
                    account: account,
                    asset: poolCfg.asset,
                    closeTimestamp: closeTimestamp,
                    swapBuyer: swap.buyer,
                    swapOpenTimestamp: swap.openTimestamp,
                    swapCollateral: swap.collateral,
                    swapTenor: swap.tenor,
                    swapState: swap.state,
                    swapPnlValueToDate: swapPnlValueToDate,
                    minLiquidationThresholdToCloseBeforeMaturityByCommunity: poolCfg
                        .minLiquidationThresholdToCloseBeforeMaturityByCommunity,
                    minLiquidationThresholdToCloseBeforeMaturityByBuyer: poolCfg
                        .minLiquidationThresholdToCloseBeforeMaturityByBuyer,
                    timeBeforeMaturityAllowedToCloseSwapByCommunity: poolCfg
                        .timeBeforeMaturityAllowedToCloseSwapByCommunity,
                    timeBeforeMaturityAllowedToCloseSwapByBuyer: poolCfg.timeBeforeMaturityAllowedToCloseSwapByBuyer,
                    timeAfterOpenAllowedToCloseSwapWithUnwinding: poolCfg.timeAfterOpenAllowedToCloseSwapWithUnwinding
                })
            );

        if (closingSwapDetails.swapUnwindRequired == true) {
            (
                closingSwapDetails.swapUnwindPnlValue,
                closingSwapDetails.swapUnwindOpeningFeeAmount,
                closingSwapDetails.swapUnwindFeeLPAmount,
                closingSwapDetails.swapUnwindFeeTreasuryAmount,
                closingSwapDetails.pnlValue
            ) = SwapCloseLogicLibBaseV1.calculateSwapUnwindWhenUnwindRequired(
                AmmTypesBaseV1.UnwindParams({
                    asset: poolCfg.asset,
                    messageSigner: messageSigner,
                    spread: poolCfg.spread,
                    ammStorage: poolCfg.ammStorage,
                    ammTreasury: poolCfg.ammTreasury,
                    closeTimestamp: closeTimestamp,
                    swapPnlValueToDate: swapPnlValueToDate,
                    indexValue: accruedIpor.indexValue,
                    swap: swap,
                    unwindingFeeRate: poolCfg.unwindingFeeRate,
                    unwindingFeeTreasuryPortionRate: poolCfg.unwindingFeeTreasuryPortionRate,
                    riskIndicatorsInputs: riskIndicatorsInput
                })
            );
        } else {
            closingSwapDetails.pnlValue = swapPnlValueToDate;
        }
    }
}
