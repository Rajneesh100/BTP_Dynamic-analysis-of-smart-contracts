{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
    },
    "remappings": [
      ":@mocks/=src/mocks/",
      ":@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      ":@openzeppelin/=lib/openzeppelin-contracts/",
      ":@permit2/=lib/permit2/src/",
      ":@src/=src/",
      ":@test/=test/",
      ":@uni-core/=src/uniswap/v3-core/",
      ":@uni-periphery/=src/uniswap/v3-periphery/",
      ":@uniswap/lib/=lib/solidity-lib/",
      ":@uniswap/v2-core/=lib/v2-core/",
      ":@uniswap/v3-core/contracts/=src/uniswap/v3-core/",
      ":base64-sol/=src/uniswap/v3-periphery/libraries/",
      ":ds-test/=lib/forge-std/lib/ds-test/src/",
      ":forge-gas-snapshot/=lib/permit2/lib/forge-gas-snapshot/src/",
      ":forge-std/=lib/forge-std/src/",
      ":openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      ":openzeppelin-contracts/=lib/openzeppelin-contracts/",
      ":permit2/=lib/permit2/",
      ":solidity-lib/=lib/solidity-lib/contracts/",
      ":solmate/=lib/permit2/lib/solmate/",
      ":v2-core/=lib/v2-core/contracts/"
    ],
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
  },
  "sources": {
    "lib/openzeppelin-contracts/contracts/utils/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev String operations.\n */\nlibrary Strings {\n    bytes16 private constant _HEX_SYMBOLS = \"0123456789abcdef\";\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` decimal representation.\n     */\n    function toString(uint256 value) internal pure returns (string memory) {\n        // Inspired by OraclizeAPI's implementation - MIT licence\n        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol\n\n        if (value == 0) {\n            return \"0\";\n        }\n        uint256 temp = value;\n        uint256 digits;\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n        bytes memory buffer = new bytes(digits);\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n        return string(buffer);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.\n     */\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return \"0x00\";\n        }\n        uint256 temp = value;\n        uint256 length = 0;\n        while (temp != 0) {\n            length++;\n            temp >>= 8;\n        }\n        return toHexString(value, length);\n    }\n\n    /**\n     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n     */\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = \"0\";\n        buffer[1] = \"x\";\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = _HEX_SYMBOLS[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, \"Strings: hex length insufficient\");\n        return string(buffer);\n    }\n}\n"
    },
    "src/custom/InventoryStakingDescriptor.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity =0.8.15;\n\nimport {Base64} from \"base64-sol/base64.sol\";\nimport {Strings} from \"@openzeppelin/contracts/utils/Strings.sol\";\nimport {HexStrings} from \"@uni-periphery/libraries/HexStrings.sol\";\n\ncontract InventoryStakingDescriptor {\n    using Strings for uint256;\n    using HexStrings for uint256;\n\n    // =============================================================\n    //                        CONSTANTS\n    // =============================================================\n\n    string internal constant PREFIX = \"x\";\n\n    // =============================================================\n    //                        INTERNAL\n    // =============================================================\n\n    function renderSVG(\n        uint256 tokenId,\n        uint256 vaultId,\n        address vToken,\n        string calldata vTokenSymbol,\n        uint256 vTokenBalance,\n        uint256 wethBalance,\n        uint256 timelockLeft\n    ) public pure returns (string memory) {\n        return\n            string.concat(\n                '<svg width=\"290\" height=\"500\" viewBox=\"0 0 290 500\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">',\n                getDefs(\n                    tokenToColorHex(uint256(uint160(vToken)), 136),\n                    tokenToColorHex(uint256(uint160(vToken)), 100)\n                ),\n                '<g mask=\"url(#fade-symbol)\">',\n                text(\"32\", \"70\", \"200\", \"32\"),\n                PREFIX,\n                vTokenSymbol,\n                \"</text>\",\n                underlyingBalances(vTokenSymbol, vTokenBalance, wethBalance),\n                '<rect x=\"16\" y=\"16\" width=\"258\" height=\"468\" rx=\"26\" ry=\"26\" fill=\"rgba(0,0,0,0)\" stroke=\"rgba(255,255,255,0.2)\"/>',\n                infoTags(tokenId, vaultId, timelockLeft),\n                \"</svg>\"\n            );\n    }\n\n    function tokenURI(\n        uint256 tokenId,\n        uint256 vaultId,\n        address vToken,\n        string calldata vTokenSymbol,\n        uint256 vTokenBalance,\n        uint256 wethBalance,\n        uint256 timelockedUntil\n    ) external view returns (string memory) {\n        string memory image = Base64.encode(\n            bytes(\n                renderSVG(\n                    tokenId,\n                    vaultId,\n                    vToken,\n                    vTokenSymbol,\n                    vTokenBalance,\n                    wethBalance,\n                    block.timestamp > timelockedUntil\n                        ? 0\n                        : timelockedUntil - block.timestamp\n                )\n            )\n        );\n\n        return\n            string.concat(\n                \"data:application/json;base64,\",\n                Base64.encode(\n                    bytes(\n                        string.concat(\n                            '{\"name\":\"',\n                            string.concat(\n                                \"x\",\n                                vTokenSymbol,\n                                \" #\",\n                                tokenId.toString()\n                            ),\n                            '\", \"description\":\"',\n                            \"xNFT representing inventory staking position on NFTX\",\n                            '\", \"image\": \"',\n                            \"data:image/svg+xml;base64,\",\n                            image,\n                            '\", \"attributes\": [{\"trait_type\": \"VaultId\", \"value\": \"',\n                            vaultId.toString(),\n                            '\"}]}'\n                        )\n                    )\n                )\n            );\n    }\n\n    // =============================================================\n    //                        PRIVATE\n    // =============================================================\n\n    function getDefs(\n        string memory color2,\n        string memory color3\n    ) private pure returns (string memory) {\n        return\n            string.concat(\n                \"<defs>\",\n                '<filter id=\"f1\"><feImage result=\"p2\" xlink:href=\"data:image/svg+xml;base64,',\n                Base64.encode(\n                    bytes(\n                        string.concat(\n                            \"<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><circle cx='16' cy='232' r='120px' fill='#\",\n                            color2,\n                            \"'/></svg>\"\n                        )\n                    )\n                ),\n                '\"/><feImage result=\"p3\" xlink:href=\"data:image/svg+xml;base64,',\n                Base64.encode(\n                    bytes(\n                        string.concat(\n                            \"<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><circle cx='20' cy='100' r='130px' fill='#\",\n                            color3,\n                            \"'/></svg>\"\n                        )\n                    )\n                ),\n                '\"/><feBlend mode=\"exclusion\" in2=\"p2\"/><feBlend mode=\"overlay\" in2=\"p3\" result=\"blendOut\"/><feGaussianBlur in=\"blendOut\" stdDeviation=\"42\"/></filter><clipPath id=\"corners\"><rect width=\"290\" height=\"500\" rx=\"42\" ry=\"42\"/></clipPath><filter id=\"top-region-blur\"><feGaussianBlur in=\"SourceGraphic\" stdDeviation=\"24\"/></filter><linearGradient id=\"grad-symbol\"><stop offset=\"0.7\" stop-color=\"white\" stop-opacity=\"1\"/><stop offset=\".95\" stop-color=\"white\" stop-opacity=\"0\"/></linearGradient><mask id=\"fade-symbol\" maskContentUnits=\"userSpaceOnUse\"><rect width=\"290px\" height=\"200px\" fill=\"url(#grad-symbol)\"/></mask></defs>',\n                '<g clip-path=\"url(#corners)\"><rect fill=\"2c9715\" x=\"0px\" y=\"0px\" width=\"290px\" height=\"500px\"/><rect style=\"filter: url(#f1)\" x=\"0px\" y=\"0px\" width=\"290px\" height=\"500px\"/><g style=\"filter:url(#top-region-blur); transform:scale(1.5); transform-origin:center top;\"><rect fill=\"none\" x=\"0px\" y=\"0px\" width=\"290px\" height=\"500px\"/><ellipse cx=\"50%\" cy=\"0px\" rx=\"180px\" ry=\"120px\" fill=\"#000\" opacity=\"0.85\"/></g><rect x=\"0\" y=\"0\" width=\"290\" height=\"500\" rx=\"42\" ry=\"42\" fill=\"rgba(0,0,0,0)\" stroke=\"rgba(255,255,255,0.2)\"/></g>'\n            );\n    }\n\n    function text(\n        string memory x,\n        string memory y,\n        string memory fontWeight,\n        string memory fontSize\n    ) private pure returns (string memory) {\n        return text(x, y, fontWeight, fontSize, false);\n    }\n\n    function text(\n        string memory x,\n        string memory y,\n        string memory fontWeight,\n        string memory fontSize,\n        bool onlyMonospace\n    ) private pure returns (string memory) {\n        return\n            string.concat(\n                '<text y=\"',\n                y,\n                'px\" x=\"',\n                x,\n                'px\" fill=\"white\" font-family=\"',\n                !onlyMonospace ? \"'Courier New', \" : \"\",\n                'monospace\" font-weight=\"',\n                fontWeight,\n                '\" font-size=\"',\n                fontSize,\n                'px\">'\n            );\n    }\n\n    function tokenToColorHex(\n        uint256 token,\n        uint256 offset\n    ) private pure returns (string memory str) {\n        return string((token >> offset).toHexStringNoPrefix(3));\n    }\n\n    function balanceTag(\n        string memory y,\n        uint256 tokenBalance,\n        string memory tokenSymbol\n    ) private pure returns (string memory) {\n        uint256 beforeDecimal = tokenBalance / 1 ether;\n        string memory afterDecimals = getAfterDecimals(tokenBalance);\n\n        uint256 leftPadding = 12;\n        uint256 beforeDecimalFontSize = 20;\n        uint256 afterDecimalFontSize = 16;\n\n        uint256 width = leftPadding +\n            ((getDigitsCount(beforeDecimal) + 1) * beforeDecimalFontSize) /\n            2 +\n            (bytes(afterDecimals).length * afterDecimalFontSize * 100) /\n            100;\n\n        return\n            string.concat(\n                '<g style=\"transform:translate(29px, ',\n                y,\n                'px)\"><rect width=\"',\n                width.toString(),\n                'px\" height=\"30px\" rx=\"8px\" ry=\"8px\" fill=\"rgba(0,0,0,0.6)\"/>',\n                text(\n                    leftPadding.toString(),\n                    \"21\",\n                    \"100\",\n                    beforeDecimalFontSize.toString(),\n                    true\n                ),\n                beforeDecimal.toString(),\n                '.<tspan font-size=\"',\n                afterDecimalFontSize.toString(),\n                'px\">',\n                afterDecimals,\n                '</tspan> <tspan fill=\"rgba(255,255,255,0.8)\">',\n                tokenSymbol,\n                \"</tspan></text></g>\"\n            );\n    }\n\n    function infoTag(\n        string memory y,\n        string memory label,\n        string memory value\n    ) private pure returns (string memory) {\n        return\n            string.concat(\n                '<g style=\"transform:translate(29px, ',\n                y,\n                'px)\"><rect width=\"98px\" height=\"26px\" rx=\"8px\" ry=\"8px\" fill=\"rgba(0,0,0,0.6)\"/>',\n                text(\"12\", \"17\", \"100\", \"12\"),\n                '<tspan fill=\"rgba(255,255,255,0.6)\">',\n                label,\n                \": </tspan>\",\n                value,\n                \"</text></g>\"\n            );\n    }\n\n    function underlyingBalances(\n        string memory vTokenSymbol,\n        uint256 vTokenBalance,\n        uint256 wethBalance\n    ) private pure returns (string memory) {\n        return\n            string.concat(\n                text(\"32\", \"160\", \"200\", \"16\"),\n                \"Underlying Balance</text></g>\",\n                balanceTag(\"180\", vTokenBalance, vTokenSymbol),\n                balanceTag(\"220\", wethBalance, \"WETH\")\n            );\n    }\n\n    function infoTags(\n        uint256 tokenId,\n        uint256 vaultId,\n        uint256 timelockLeft\n    ) private pure returns (string memory) {\n        return\n            string.concat(\n                infoTag(\"384\", \"ID\", tokenId.toString()),\n                infoTag(\"414\", \"VaultId\", vaultId.toString()),\n                infoTag(\n                    \"444\",\n                    \"Timelock\",\n                    timelockLeft > 0\n                        ? string.concat(timelockLeft.toString(), \"s left\")\n                        : \"Unlocked\"\n                )\n            );\n    }\n\n    function getDigitsCount(uint256 num) private pure returns (uint256 count) {\n        if (num == 0) return 1;\n\n        while (num > 0) {\n            ++count;\n            num /= 10;\n        }\n    }\n\n    function getAfterDecimals(\n        uint256 tokenBalance\n    ) private pure returns (string memory afterDecimals) {\n        uint256 afterDecimal = (tokenBalance % 1 ether) / 10 ** (18 - 10); // show 10 decimals\n\n        uint256 leadingZeroes;\n        if (afterDecimal == 0) {\n            leadingZeroes = 0;\n        } else {\n            leadingZeroes = 10 - getDigitsCount(afterDecimal);\n        }\n\n        afterDecimals = afterDecimal.toString();\n        for (uint256 i; i < leadingZeroes; ) {\n            afterDecimals = string.concat(\"0\", afterDecimals);\n\n            unchecked {\n                ++i;\n            }\n        }\n    }\n}\n"
    },
    "src/uniswap/v3-periphery/libraries/HexStrings.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nlibrary HexStrings {\n    bytes16 internal constant ALPHABET = '0123456789abcdef';\n\n    /// @notice Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.\n    /// @dev Credit to Open Zeppelin under MIT license https://github.com/OpenZeppelin/openzeppelin-contracts/blob/243adff49ce1700e0ecb99fe522fb16cff1d1ddc/contracts/utils/Strings.sol#L55\n    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = '0';\n        buffer[1] = 'x';\n        for (uint256 i = 2 * length + 1; i > 1; --i) {\n            buffer[i] = ALPHABET[value & 0xf];\n            value >>= 4;\n        }\n        require(value == 0, 'Strings: hex length insufficient');\n        return string(buffer);\n    }\n\n    function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length);\n        for (uint256 i = buffer.length; i > 0; i--) {\n            buffer[i - 1] = ALPHABET[value & 0xf];\n            value >>= 4;\n        }\n        return string(buffer);\n    }\n}\n"
    },
    "src/uniswap/v3-periphery/libraries/base64.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0;\n\n/// @title Base64\n/// @author Brecht Devos - <brecht@loopring.org>\n/// @notice Provides functions for encoding/decoding base64\nlibrary Base64 {\n    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';\n    bytes  internal constant TABLE_DECODE = hex\"0000000000000000000000000000000000000000000000000000000000000000\"\n                                            hex\"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000\"\n                                            hex\"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000\"\n                                            hex\"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000\";\n\n    function encode(bytes memory data) internal pure returns (string memory) {\n        if (data.length == 0) return '';\n\n        // load the table into memory\n        string memory table = TABLE_ENCODE;\n\n        // multiply by 4/3 rounded up\n        uint256 encodedLen = 4 * ((data.length + 2) / 3);\n\n        // add some extra buffer at the end required for the writing\n        string memory result = new string(encodedLen + 32);\n\n        assembly {\n            // set the actual output length\n            mstore(result, encodedLen)\n\n            // prepare the lookup table\n            let tablePtr := add(table, 1)\n\n            // input ptr\n            let dataPtr := data\n            let endPtr := add(dataPtr, mload(data))\n\n            // result ptr, jump over length\n            let resultPtr := add(result, 32)\n\n            // run over the input, 3 bytes at a time\n            for {} lt(dataPtr, endPtr) {}\n            {\n                // read 3 bytes\n                dataPtr := add(dataPtr, 3)\n                let input := mload(dataPtr)\n\n                // write 4 characters\n                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))\n                resultPtr := add(resultPtr, 1)\n                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))\n                resultPtr := add(resultPtr, 1)\n                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))\n                resultPtr := add(resultPtr, 1)\n                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))\n                resultPtr := add(resultPtr, 1)\n            }\n\n            // padding with '='\n            switch mod(mload(data), 3)\n            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }\n            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }\n        }\n\n        return result;\n    }\n\n    function decode(string memory _data) internal pure returns (bytes memory) {\n        bytes memory data = bytes(_data);\n\n        if (data.length == 0) return new bytes(0);\n        require(data.length % 4 == 0, \"invalid base64 decoder input\");\n\n        // load the table into memory\n        bytes memory table = TABLE_DECODE;\n\n        // every 4 characters represent 3 bytes\n        uint256 decodedLen = (data.length / 4) * 3;\n\n        // add some extra buffer at the end required for the writing\n        bytes memory result = new bytes(decodedLen + 32);\n\n        assembly {\n            // padding with '='\n            let lastBytes := mload(add(data, mload(data)))\n            if eq(and(lastBytes, 0xFF), 0x3d) {\n                decodedLen := sub(decodedLen, 1)\n                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {\n                    decodedLen := sub(decodedLen, 1)\n                }\n            }\n\n            // set the actual output length\n            mstore(result, decodedLen)\n\n            // prepare the lookup table\n            let tablePtr := add(table, 1)\n\n            // input ptr\n            let dataPtr := data\n            let endPtr := add(dataPtr, mload(data))\n\n            // result ptr, jump over length\n            let resultPtr := add(result, 32)\n\n            // run over the input, 4 characters at a time\n            for {} lt(dataPtr, endPtr) {}\n            {\n               // read 4 characters\n               dataPtr := add(dataPtr, 4)\n               let input := mload(dataPtr)\n\n               // write 3 bytes\n               let output := add(\n                   add(\n                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),\n                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),\n                   add(\n                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),\n                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)\n                    )\n                )\n                mstore(resultPtr, shl(232, output))\n                resultPtr := add(resultPtr, 3)\n            }\n        }\n\n        return result;\n    }\n}"
    }
  }
}}