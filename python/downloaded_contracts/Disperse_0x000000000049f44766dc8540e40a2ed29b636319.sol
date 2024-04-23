// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Disperse {

    fallback() payable external {
        assembly {
            function selector() -> s {
                calldatacopy(s, 0x00, 0x04)
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }
            switch selector()

            /*
              @notice disperseETH_1125D8(address[])
              @param `address[]` List of payees to transfer to.

              @notice Divides `msg.value` by the number payees then transfers the respective amount to each payee.
            */
            case 0x0000004a {
                if iszero(gt(callvalue(),0)) {revert(0,0)}

                let lengthOffset := add(calldataload(0x04),0x04)
                let lengthOfAddresses := calldataload(lengthOffset)
                if iszero(gt(lengthOfAddresses,0)) {revert(0,0)}

                let valueSplitUp := div(callvalue(), lengthOfAddresses)

                let addressIdx := add(0x20,lengthOffset)
                lengthOfAddresses := add(mul(lengthOfAddresses, 0x20), addressIdx)

                for {} 1 {}{
                    pop(call(21000, calldataload(addressIdx), valueSplitUp, 0, 0, 0, 0))
                    addressIdx := add(addressIdx, 0x20)
                    if iszero(lt(addressIdx, lengthOfAddresses)){break}
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }

            /*
              @notice disperseETHSpecific_4B1AB70(address[],uint256[])
              @param `address[]` List of payees to transfer to.
              @param `uint256[]` List of amounts to transfer.

              @notice Sends specified amount to payee at a given index.
            */
            case 0x000000c9 {
                if iszero(gt(callvalue(),0)) {revert(0,0)}

                let addressLengthOffset := add(calldataload(0x04),0x04)
                let amountLengthOffset := add(calldataload(0x24),0x04)

                let lengthOfAddresses := calldataload(addressLengthOffset)
                let lengthOfAmounts := calldataload(amountLengthOffset)

                if iszero(gt(lengthOfAddresses,0)) {revert(0,0)}
                if iszero(eq(lengthOfAddresses,lengthOfAmounts)) {revert(0,0)}

                let addressIdx := add(0x20,addressLengthOffset)

                lengthOfAddresses := add(mul(lengthOfAddresses, 0x20), addressIdx)
                let difference := sub(add(0x20,amountLengthOffset),addressIdx)

                for {} 1 {}{
                    pop(call(21000, calldataload(addressIdx), calldataload(add(addressIdx,difference)), 0, 0, 0, 0))
                    addressIdx := add(addressIdx, 0x20)
                    if iszero(lt(addressIdx, lengthOfAddresses)){break}
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }

            /*
              @notice disperseToken_1EDBF2(address,uint256,address[])
              @param `address` Token intended to transfer
              @param `uint256` Total quantity of tokens to transfer
              @param `address[]` list of addresses to transfer to

              @notice Divides `total quantity of tokens` by the number payees then transfers the respective amount to each payee.
              @notice Must approve contract first before calling this function.
            */
            case 0x000000df {
                let token := calldataload(0x04)
                let totalValue := calldataload(0x24)

                if iszero(gt(totalValue,0)) {revert(0,0)}

                mstore(0x00, hex"23b872dd")
                mstore(0x04, caller())
                mstore(0x24, address())
                mstore(0x44, totalValue)
                if iszero(call(gas(), token, 0, 0x00, 0x64, 0, 0)){
                    revert(0, 0)
                }

                let lengthOffset := add(calldataload(0x44),0x04)
                let lengthOfAddresses := calldataload(lengthOffset)
                let valueSplitUp := div(totalValue, lengthOfAddresses)

                if eq(lengthOfAddresses,0) {revert(0,0)}

                let addressIdx := add(0x20,lengthOffset)
                lengthOfAddresses := add(mul(lengthOfAddresses, 0x20), addressIdx)

                mstore(0x00,hex"a9059cbb")
                mstore(0x24,valueSplitUp)

                for {} 1 {}{
                    mstore(0x04,calldataload(addressIdx))

                    if iszero(call(gas(), token, 0, 0x00, 0x44, 0, 0)){revert(0,0)}

                    totalValue := sub(totalValue,valueSplitUp)
                    addressIdx := add(addressIdx, 0x20)

                    if iszero(lt(addressIdx, lengthOfAddresses)){break}
                }

                if gt(totalValue, 0){
                    mstore(0x04,caller())
                    mstore(0x24,totalValue)
                    if iszero(call(gas(), token, 0, 0x00, 0x44, 0, 0)){
                        revert(0,0)
                    }
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }

            /*
              @notice disperseTokenSpecific_109D78E(address,uint256,address[],uint256[])
              @param `address` Token intended to transfer.
              @param `uint256` Total quantity of tokens to transfer.
              @param `address[]` List of addresses to transfer to.
              @param `uint256[]` List of amounts to transfer.

              @notice Sends specified amount to payee at a given index.
              @notice Must approve contract first before calling this function.
            */
            case 0x00000088 {
                let token := calldataload(0x04)
                let totalValue := calldataload(0x24)

                if iszero(gt(totalValue,0)) {revert(0,0)}

                mstore(0x00, hex"23b872dd")
                mstore(0x04, caller())
                mstore(0x24, address())
                mstore(0x44, totalValue)
                if iszero(call(gas(), token, 0, 0x00, 0x64, 0, 0)){
                    revert(0, 0)
                }

                let addressLengthOffset := add(calldataload(0x44),0x04)
                let amountLengthOffset := add(calldataload(0x64),0x04)

                let lengthOfAddresses := calldataload(addressLengthOffset)
                let lengthOfAmounts := calldataload(amountLengthOffset)

                if iszero(eq(lengthOfAddresses,lengthOfAmounts)) {revert(0,0)}

                let addressIdx := add(0x20,addressLengthOffset)

                lengthOfAddresses := add(mul(lengthOfAddresses, 0x20), addressIdx)
                let difference := sub(add(0x20,amountLengthOffset),addressIdx)

                mstore(0x00,hex"a9059cbb")

                for {} 1 {}{
                    mstore(0x04,calldataload(addressIdx))

                    let amount := calldataload(add(addressIdx,difference))
                    mstore(0x24,amount)

                    if iszero(call(gas(), token, 0, 0x00, 0x44, 0, 0)){revert(0,0)}

                    totalValue := sub(totalValue,amount)
                    addressIdx := add(addressIdx, 0x20)

                    if iszero(lt(addressIdx, lengthOfAddresses)){break}
                }

                if gt(totalValue, 0){
                    mstore(0x04,caller())
                    mstore(0x24,totalValue)
                    if iszero(call(gas(), token, 0, 0x00, 0x44, 0, 0)){
                        revert(0,0)
                    }
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }

            /*
              @notice disperse721_57583EF(address,uint256,uint256,address[])
              @param `address` Token intended to transfer.
              @param `uint256` First tokenId to transfer.
              @param `uint256` Quantity of tokens to transfer.
              @param `address[]` List of addresses to transfer to.

              @notice Sends one token to each address starting at the first tokenId.
              @notice Must approve contract first before calling this function.
            */
            case 0x0000004b {
                let token := calldataload(0x04)
                let firstTokenId := calldataload(0x24)
                let quantity := calldataload(0x44)
                if iszero(gt(quantity,0)) {revert(0,0)}

                let addressLengthOffset := add(calldataload(0x64),0x04)
                let lengthOfAddresses := calldataload(addressLengthOffset)
                if iszero(eq(lengthOfAddresses,quantity)) {revert(0,0)}

                let addressIdx := add(0x20,addressLengthOffset)
                let lastTokenId := add(firstTokenId, quantity)

                mstore(0x00, hex"23b872dd")
                mstore(0x04, caller())

                for {} 1 {}{
                    mstore(0x24, calldataload(addressIdx))
                    mstore(0x44, firstTokenId)

                    if iszero(call(gas(), token, 0, 0x00, 0x64, 0, 0)){revert(0,0)}

                    addressIdx := add(addressIdx, 0x20)
                    firstTokenId := add(firstTokenId,1)

                    if iszero(lt(firstTokenId, lastTokenId)){break}
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }

            /*
              @notice disperse721Specific_4B57A99(address,address[],uint256[])
              @param `address` Token intended to transfer.
              @param `address[]` List of addresses to transfer to.
              @param `uint256[]` List of tokenIds to transfer.

              @notice Sends specific tokenId to an address at a given index.
              @notice Must approve contract first before calling this function.
            */
            case 0x00000092 {
                let token := calldataload(0x04)

                let addressLengthOffset := add(calldataload(0x24),0x04)
                let tokenIdLengthOffset := add(calldataload(0x44),0x04)

                let lengthOfAddresses := calldataload(addressLengthOffset)
                let lengthOfTokenIds := calldataload(tokenIdLengthOffset)
                if iszero(eq(lengthOfAddresses,lengthOfTokenIds)) {revert(0,0)}

                let addressIdx := add(0x20,addressLengthOffset)

                lengthOfAddresses := add(mul(lengthOfAddresses, 0x20), addressIdx)
                let difference := sub(add(0x20,tokenIdLengthOffset),addressIdx)

                mstore(0x00,hex"23b872dd")
                mstore(0x04, caller())

                for {} 1 {}{
                    mstore(0x24,calldataload(addressIdx))
                    mstore(0x44,calldataload(add(addressIdx,difference)))
                    if iszero(call(gas(), token, 0, 0x00, 0x64, 0, 0)){revert(0,0)}

                    addressIdx := add(addressIdx, 0x20)

                    if iszero(lt(addressIdx, lengthOfAddresses)){break}
                }

                if gt(selfbalance(), 0){
                    pop(call(21000, caller(), selfbalance(), 0, 0, 0, 0))
                }
            }
            default {
                revert(0,0)
            }
        }
    }
}