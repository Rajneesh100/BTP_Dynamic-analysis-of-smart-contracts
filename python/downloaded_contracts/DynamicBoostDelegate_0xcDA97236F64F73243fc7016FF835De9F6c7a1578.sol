{{
  "language": "Solidity",
  "sources": {
    "DynamicBoostDelegate.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.23;\n\nimport \"IBoostCalculator.sol\";\n\ncontract DynamicBoostDelegate {\n    address public boostDelegate;\n    IBoostCalculator public immutable boostCalculator;\n\n    constructor(IBoostCalculator _boostCalculator) {\n        boostDelegate = msg.sender;\n        boostCalculator = _boostCalculator;\n    }\n\n    function getFeePct(\n        address,\n        address,\n        uint amount,\n        uint previousAmount,\n        uint totalWeeklyEmissions\n    ) external view returns (uint256 feePct) {\n        (uint256 maxBoostable, ) = boostCalculator.getClaimableWithBoost(boostDelegate, 0, totalWeeklyEmissions);\n\n        // claim does not deplete 2x boost\n        if (amount + previousAmount <= maxBoostable) {\n            // if claim consumes >25% of boost, dynamic fee from 14-14.9%\n            if (amount > maxBoostable / 4) {\n                uint256 boostPct = (amount * 10000) / maxBoostable;\n                return 1400 + ((90 * boostPct) / 10000);\n            }\n            // otherwise fee at 13.99%\n            return 1399;\n        }\n\n        uint256 adjustedAmount = boostCalculator.getBoostedAmount(\n            boostDelegate,\n            amount,\n            previousAmount,\n            totalWeeklyEmissions\n        );\n\n        if ((previousAmount * 10000) / maxBoostable < 8000) {\n            // if over 20% of 2x boost remains and the claim receives boost\n            // of <1.9x, reject with 100% fee and wait for a small claim\n            if (adjustedAmount < (amount * 9500) / 10000) return 10000;\n        }\n\n        // 1.7x boost (charged by convex and yearn)\n        uint256 boostFloor = (amount * 8500) / 10000;\n\n        // claim receives less than 1.7x boost\n        if (adjustedAmount <= boostFloor) {\n            // boost prior to claim is >1.8x, reject with 100% fee and wait for smaller claim\n            if (previousAmount < (maxBoostable * 12) / 10) return 10000;\n            // boost will be below 1.7x, fee at 0.01%\n            else return 1;\n        }\n\n        // dynamic fee so boost after fee is ~1% above 1.7x\n        return ((adjustedAmount - boostFloor) * 9900) / adjustedAmount;\n    }\n\n    function delegatedBoostCallback(address, address, uint, uint, uint, uint, uint) external pure returns (bool) {\n        return true;\n    }\n}\n"
    },
    "IBoostCalculator.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\ninterface IBoostCalculator {\n    function getBoostedAmountWrite(\n        address account,\n        uint256 amount,\n        uint256 previousAmount,\n        uint256 totalWeeklyEmissions\n    ) external returns (uint256 adjustedAmount);\n\n    function MAX_BOOST_GRACE_WEEKS() external view returns (uint256);\n\n    function getBoostedAmount(\n        address account,\n        uint256 amount,\n        uint256 previousAmount,\n        uint256 totalWeeklyEmissions\n    ) external view returns (uint256 adjustedAmount);\n\n    function getClaimableWithBoost(\n        address claimant,\n        uint256 previousAmount,\n        uint256 totalWeeklyEmissions\n    ) external view returns (uint256 maxBoosted, uint256 boosted);\n\n    function getWeek() external view returns (uint256 week);\n\n    function locker() external view returns (address);\n}\n"
    }
  },
  "settings": {
    "evmVersion": "paris",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "DynamicBoostDelegate.sol": {}
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}