// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error WrongOrigin();

contract SingleOrigin {
    function checkOrigin(address requiredOrigin) public view {
        if (requiredOrigin != tx.origin) revert WrongOrigin();
    }
}