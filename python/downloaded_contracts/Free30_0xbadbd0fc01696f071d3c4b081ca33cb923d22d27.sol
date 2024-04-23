{"Free30.sol":{"content":"// SPDX-License-Identifier: CC0\n\n\n/*\n /$$$$$$$$ /$$$$$$$  /$$$$$$$$ /$$$$$$$$        /$$$$$$   /$$$$$$\n| $$_____/| $$__  $$| $$_____/| $$_____/       /$$__  $$ /$$$_  $$\n| $$      | $$  \\ $$| $$      | $$            |__/  \\ $$| $$$$\\ $$\n| $$$$$   | $$$$$$$/| $$$$$   | $$$$$            /$$$$$/| $$ $$ $$\n| $$__/   | $$__  $$| $$__/   | $$__/           |___  $$| $$\\ $$$$\n| $$      | $$  \\ $$| $$      | $$             /$$  \\ $$| $$ \\ $$$\n| $$      | $$  | $$| $$$$$$$$| $$$$$$$$      |  $$$$$$/|  $$$$$$/\n|__/      |__/  |__/|________/|________/       \\______/  \\______/\n\n\n\n /$$\n| $$\n| $$$$$$$  /$$   /$$\n| $$__  $$| $$  | $$\n| $$  \\ $$| $$  | $$\n| $$  | $$| $$  | $$\n| $$$$$$$/|  $$$$$$$\n|_______/  \\____  $$\n           /$$  | $$\n          |  $$$$$$/\n           \\______/\n  /$$$$$$  /$$$$$$$$ /$$$$$$$$ /$$    /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$\n /$$__  $$|__  $$__/| $$_____/| $$   | $$|_  $$_/| $$_____/| $$__  $$\n| $$  \\__/   | $$   | $$      | $$   | $$  | $$  | $$      | $$  \\ $$\n|  $$$$$$    | $$   | $$$$$   |  $$ / $$/  | $$  | $$$$$   | $$$$$$$/\n \\____  $$   | $$   | $$__/    \\  $$ $$/   | $$  | $$__/   | $$____/\n /$$  \\ $$   | $$   | $$        \\  $$$/    | $$  | $$      | $$\n|  $$$$$$/   | $$   | $$$$$$$$   \\  $/    /$$$$$$| $$$$$$$$| $$\n \\______/    |__/   |________/    \\_/    |______/|________/|__/\n\n\nCC0 2023\n*/\n\n\npragma solidity ^0.8.23;\n\n\nimport \"./FreeChecker.sol\";\n\ninterface Free19 {\n  function lastAssigned() external view returns (uint256);\n  function claimer() external view returns (address);\n}\n\n\ncontract Free30 is FreeChecker {\n  Free19 public free19 = Free19(0xaBCeF3a4aDC27A6c962b4fC17181F47E62244EF0);\n\n  address public free30Claimer;\n  uint256 public free30ClaimerLastAssigned;\n\n  mapping(uint256 =\u003e bool) public free19TokenIdUsed;\n  mapping(uint256 =\u003e address) public free19ToClaimer;\n  mapping(uint256 =\u003e uint256) public free19ToClaimerLastAssigned;\n\n  function _checkFree19Token(uint256 free19TokenId) internal {\n    checkFreeToken(free19TokenId, 19);\n    require(!free19TokenIdUsed[free19TokenId], \u0027Free19 already used\u0027);\n  }\n\n  function _checkFree19ContractClaimer() internal view {\n    require(free19.claimer() == msg.sender, \u0027Must be Free19 contract claimer\u0027);\n    require(free19.lastAssigned() + 30 hours \u003c block.timestamp, \u0027Must be Free19 contract claimer for \u003e 30 hours\u0027);\n  }\n\n  function _checkFree19TokenClaimer(uint256 free19TokenId) internal view {\n    require(free19ToClaimer[free19TokenId] == msg.sender, \u0027Must be Free19 token claimer\u0027);\n    require(free19ToClaimerLastAssigned[free19TokenId] + 30 hours \u003c block.timestamp, \u0027Must be Free19 token claimer for \u003e 30 hours\u0027);\n  }\n\n\n  function free19TokenAssign(uint256 free19TokenId, address claimer) external {\n    _checkFree19Token(free19TokenId);\n    _checkFree19ContractClaimer();\n\n    require(free19.claimer() != claimer, \u0027Free19 token claimer cannot be set to Free19 contract claimer\u0027);\n\n\n    free19ToClaimer[free19TokenId] = claimer;\n    free19ToClaimerLastAssigned[free19TokenId] = block.timestamp;\n  }\n\n\n  function assign(uint256 free19TokenId, address claimer) public {\n    _checkFree19Token(free19TokenId);\n    _checkFree19TokenClaimer(free19TokenId);\n    _checkFree19ContractClaimer();\n\n    require(free19ToClaimer[free19TokenId] != claimer, \u0027Free30 claimer cannot be set to Free19 token claimer\u0027);\n\n    free30Claimer = claimer;\n    free30ClaimerLastAssigned = block.timestamp;\n  }\n\n\n  function claim(uint256 free0TokenId, uint256 free19TokenId) external {\n    preCheck(free0TokenId, \u002730\u0027);\n\n    _checkFree19Token(free19TokenId);\n\n    require(free30Claimer == msg.sender);\n    require(free30ClaimerLastAssigned + 30 hours \u003c block.timestamp, \u0027Must be Free30 claimer for \u003e 30 hours\u0027);\n\n    _checkFree19TokenClaimer(free19TokenId);\n    _checkFree19ContractClaimer();\n\n\n\n    free19TokenIdUsed[free19TokenId] = true;\n\n\n    postCheck(free0TokenId, 30, \u002730\u0027);\n  }\n\n}"},"FreeChecker.sol":{"content":"\n// SPDX-License-Identifier: CC0\n\n\n/*\nCC0 2023\n*/\n\n\npragma solidity ^0.8.23;\n\ninterface IFree {\n  function totalSupply() external  view returns (uint256);\n  function balanceOf(address) external  view returns (uint256);\n  function ownerOf(uint256 tokenId) external view returns (address owner);\n  function tokenIdToCollectionId(uint256 tokenId) external view returns (uint256 collectionId);\n  function collectionSupply(uint256 collectionId) external view returns (uint256);\n  function collectionIdToMinter(uint256 collectionId) external view returns (address);\n  function mint(uint256 collectionId, address to) external;\n  function appendAttributeToToken(uint256 tokenId, string memory attrKey, string memory attrValue) external;\n  function safeTransferFrom(address from, address to, uint256 tokenId) external;\n}\n\nabstract contract FreeChecker {\n  mapping(uint256 =\u003e bool) public free0TokenIdUsed;\n  IFree public immutable free = IFree(0x30b541f1182ef19c56a39634B2fdACa5a0F2A741);\n\n  function preCheck(uint256 free0TokenId, string memory freeStr) internal view {\n    require(free.tokenIdToCollectionId(free0TokenId) == 0, \u0027Invalid Free0\u0027);\n    require(!free0TokenIdUsed[free0TokenId],\n      string(abi.encodePacked(\u0027This Free0 has already been used to mint a Free\u0027, freeStr))\n    );\n    require(free.ownerOf(free0TokenId) == msg.sender, \u0027You must be the owner of this Free0\u0027);\n\n  }\n\n  function postCheck(uint256 free0TokenId, uint256 freeNumber, string memory freeStr) internal {\n    free0TokenIdUsed[free0TokenId] = true;\n    free.appendAttributeToToken(free0TokenId,\n      string(abi.encodePacked(\u0027Used For Free\u0027, freeStr, \u0027 Mint\u0027)),\n      \u0027true\u0027\n    );\n    free.mint(freeNumber, msg.sender);\n  }\n\n  function checkFreeToken(uint256 freeTokenId, uint256 collectionId) internal view {\n    require(free.ownerOf(freeTokenId) == msg.sender, \u0027Not owner of token\u0027);\n    require(free.tokenIdToCollectionId(freeTokenId) == collectionId, \u0027Token collection mismatch\u0027);\n  }\n}"}}