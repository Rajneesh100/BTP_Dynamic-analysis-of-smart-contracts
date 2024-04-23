{"Free29.sol":{"content":"// SPDX-License-Identifier: CC0\n\n\n/*\n /$$$$$$$$ /$$$$$$$  /$$$$$$$$ /$$$$$$$$        /$$$$$$   /$$$$$$\n| $$_____/| $$__  $$| $$_____/| $$_____/       /$$__  $$ /$$__  $$\n| $$      | $$  \\ $$| $$      | $$            |__/  \\ $$| $$  \\ $$\n| $$$$$   | $$$$$$$/| $$$$$   | $$$$$           /$$$$$$/|  $$$$$$$\n| $$__/   | $$__  $$| $$__/   | $$__/          /$$____/  \\____  $$\n| $$      | $$  \\ $$| $$      | $$            | $$       /$$  \\ $$\n| $$      | $$  | $$| $$$$$$$$| $$$$$$$$      | $$$$$$$$|  $$$$$$/\n|__/      |__/  |__/|________/|________/      |________/ \\______/\n\n\n\n /$$\n| $$\n| $$$$$$$  /$$   /$$\n| $$__  $$| $$  | $$\n| $$  \\ $$| $$  | $$\n| $$  | $$| $$  | $$\n| $$$$$$$/|  $$$$$$$\n|_______/  \\____  $$\n           /$$  | $$\n          |  $$$$$$/\n           \\______/\n  /$$$$$$  /$$$$$$$$ /$$$$$$$$ /$$    /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$\n /$$__  $$|__  $$__/| $$_____/| $$   | $$|_  $$_/| $$_____/| $$__  $$\n| $$  \\__/   | $$   | $$      | $$   | $$  | $$  | $$      | $$  \\ $$\n|  $$$$$$    | $$   | $$$$$   |  $$ / $$/  | $$  | $$$$$   | $$$$$$$/\n \\____  $$   | $$   | $$__/    \\  $$ $$/   | $$  | $$__/   | $$____/\n /$$  \\ $$   | $$   | $$        \\  $$$/    | $$  | $$      | $$\n|  $$$$$$/   | $$   | $$$$$$$$   \\  $/    /$$$$$$| $$$$$$$$| $$\n \\______/    |__/   |________/    \\_/    |______/|________/|__/\n\n\nCC0 2023\n*/\n\n\npragma solidity ^0.8.23;\n\n\nimport \"./FreeChecker.sol\";\n\n\ncontract Free29 is FreeChecker {\n  uint256 public constant WAIT_BLOCKS = 2900000;\n\n  uint256 public mints;\n\n  mapping(uint256 =\u003e address) public free0TokenIdToOwner;\n  mapping(uint256 =\u003e uint256) public free0TokenIdToStakedBlock;\n  mapping(uint256 =\u003e bool) public isLocked;\n\n  function isContract(address account) internal view returns (bool) {\n    uint256 size;\n    assembly {\n      size := extcodesize(account)\n    }\n    return size \u003e 0;\n  }\n\n  function onERC721Received(\n    address,\n    address from,\n    uint256 tokenId,\n    bytes calldata\n  ) external returns (bytes4) {\n    require(msg.sender == address(free), \u0027Not a Free token\u0027);\n    require(free.tokenIdToCollectionId(tokenId) == 0, \u0027Invalid Free0\u0027);\n    require(!free0TokenIdUsed[tokenId], \u0027This Free0 has already been used to mint a Free29\u0027);\n\n    require(!isContract(from));\n\n    free0TokenIdToOwner[tokenId] = from;\n    free0TokenIdToStakedBlock[tokenId] = block.number;\n\n    return this.onERC721Received.selector;\n  }\n\n\n  function currentThreshold(uint256 m) public pure returns (uint256) {\n    return (\n      m % 16 \u003c 8\n        ? m % 16\n        : 16 - (m % 16)\n    );\n  }\n\n  function withdraw(uint256 free0TokenId) external {\n    require(msg.sender == free0TokenIdToOwner[free0TokenId], \u0027Not original owner\u0027);\n    require(block.number \u003e free0TokenIdToStakedBlock[free0TokenId] + WAIT_BLOCKS, \u0027Must wait 2900000 blocks\u0027);\n\n    free.safeTransferFrom(address(this), free0TokenIdToOwner[free0TokenId], free0TokenId);\n  }\n\n  function claim(uint256 free0TokenId) external {\n    uint256 stakedBlock = free0TokenIdToStakedBlock[free0TokenId];\n\n    if (block.number \u003e stakedBlock + 256) {\n      return;\n    }\n\n    require(msg.sender == free0TokenIdToOwner[free0TokenId], \u0027Not original owner\u0027);\n    require(block.number \u003e stakedBlock, \u0027Must wait at least 1 block\u0027);\n\n    uint256 rnd = uint256(\n      keccak256(abi.encodePacked(\n        blockhash(stakedBlock + 1), block.timestamp\n      ))\n    ) % 8;\n\n    bool lockToken = rnd \u003c currentThreshold(mints);\n\n    mints++;\n\n    if (!lockToken \u0026\u0026 !isContract(free0TokenIdToOwner[free0TokenId])) {\n      free.safeTransferFrom(address(this), free0TokenIdToOwner[free0TokenId], free0TokenId);\n      postCheck(free0TokenId, 29, \u002729\u0027);\n    }\n  }\n\n}"},"FreeChecker.sol":{"content":"\n// SPDX-License-Identifier: CC0\n\n\n/*\nCC0 2023\n*/\n\n\npragma solidity ^0.8.23;\n\ninterface IFree {\n  function totalSupply() external  view returns (uint256);\n  function balanceOf(address) external  view returns (uint256);\n  function ownerOf(uint256 tokenId) external view returns (address owner);\n  function tokenIdToCollectionId(uint256 tokenId) external view returns (uint256 collectionId);\n  function collectionSupply(uint256 collectionId) external view returns (uint256);\n  function collectionIdToMinter(uint256 collectionId) external view returns (address);\n  function mint(uint256 collectionId, address to) external;\n  function appendAttributeToToken(uint256 tokenId, string memory attrKey, string memory attrValue) external;\n  function safeTransferFrom(address from, address to, uint256 tokenId) external;\n}\n\nabstract contract FreeChecker {\n  mapping(uint256 =\u003e bool) public free0TokenIdUsed;\n  IFree public immutable free = IFree(0x30b541f1182ef19c56a39634B2fdACa5a0F2A741);\n\n  function preCheck(uint256 free0TokenId, string memory freeStr) internal view {\n    require(free.tokenIdToCollectionId(free0TokenId) == 0, \u0027Invalid Free0\u0027);\n    require(!free0TokenIdUsed[free0TokenId],\n      string(abi.encodePacked(\u0027This Free0 has already been used to mint a Free\u0027, freeStr))\n    );\n    require(free.ownerOf(free0TokenId) == msg.sender, \u0027You must be the owner of this Free0\u0027);\n\n  }\n\n  function postCheck(uint256 free0TokenId, uint256 freeNumber, string memory freeStr) internal {\n    free0TokenIdUsed[free0TokenId] = true;\n    free.appendAttributeToToken(free0TokenId,\n      string(abi.encodePacked(\u0027Used For Free\u0027, freeStr, \u0027 Mint\u0027)),\n      \u0027true\u0027\n    );\n    free.mint(freeNumber, msg.sender);\n  }\n\n  function checkFreeToken(uint256 freeTokenId, uint256 collectionId) internal view {\n    require(free.ownerOf(freeTokenId) == msg.sender, \u0027Not owner of token\u0027);\n    require(free.tokenIdToCollectionId(freeTokenId) == collectionId, \u0027Token collection mismatch\u0027);\n  }\n}"}}