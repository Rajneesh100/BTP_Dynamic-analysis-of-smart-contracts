{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
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
    "contracts/BonusBuidlGuidl.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity >=0.8.0 <0.9.0;\n\n/*\n  .----------------.  .----------------.  .-----------------. .----------------.  .----------------.\n| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |\n| |   ______     | || |     ____     | || | ____  _____  | || | _____  _____ | || |    _______   | |\n| |  |_   _ \\    | || |   .'    `.   | || ||_   \\|_   _| | || ||_   _||_   _|| || |   /  ___  |  | |\n| |    | |_) |   | || |  /  .--.  \\  | || |  |   \\ | |   | || |  | |    | |  | || |  |  (__ \\_|  | |\n| |    |  __'.   | || |  | |    | |  | || |  | |\\ \\| |   | || |  | '    ' |  | || |   '.___`-.   | |\n| |   _| |__) |  | || |  \\  `--'  /  | || | _| |_\\   |_  | || |   \\ `--' /   | || |  |`\\____) |  | |\n| |  |_______/   | || |   `.____.'   | || ||_____|\\____| | || |    `.__.'    | || |  |_______.'  | |\n| |              | || |              | || |              | || |              | || |              | |\n| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |\n '----------------'  '----------------'  '----------------'  '----------------'  '----------------'\n */\n\ninterface ENSContract {\n\tfunction setName(string memory newName) external;\n}\ninterface IERC20 {\n\tfunction transfer(address recipient, uint256 amount) external returns (bool);\n}\ninterface IERC721 {\n\tfunction transferFrom(address from, address to, uint256 tokenId) external;\n}\n\ncontract BonusBuidlGuidl {\n\tENSContract public immutable ensContract = ENSContract(0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb);\n\tmapping(address => bool) public isOwner;\n\n\t// Events\n\tevent EtherSent(address indexed recipient, uint256 amount, string reason);\n\tevent ERC20Sent(address indexed tokenAddress, address indexed recipient, uint256 amount, string reason);\n\tevent ERC721Sent(address indexed tokenAddress, address indexed recipient, uint256 tokenId, string reason);\n\n\t// Modifiers\n\tmodifier onlyOwner() {\n\t\trequire(isOwner[msg.sender], \"Only the owner can call this function\");\n\t\t_;\n\t}\n\n\t// Constructor\n\tconstructor(address[] memory owners) {\n\t\tfor (uint256 i = 0; i < owners.length; i++) {\n\t\t\tisOwner[owners[i]] = true;\n\t\t}\n\t}\n\n\tfunction updateOwner(address _owner, bool _isOwner) onlyOwner public {\n\t\trequire(_owner != msg.sender, \"You cannot remove yourself as an owner\");\n\t\tisOwner[_owner] = _isOwner;\n\t}\n\n\tfunction sendEther(address payable recipient, uint256 amount, string memory reason) onlyOwner public {\n\t\t(bool success,) = recipient.call{value: amount}(\"\");\n\t\trequire(success, \"Failed to send Ether\");\n\t\temit EtherSent(recipient, amount, reason);\n\t}\n\n\tfunction transferERC20(address tokenAddress, address recipient, uint256 amount, string memory reason) onlyOwner public {\n\t\trequire(IERC20(tokenAddress).transfer(recipient, amount), \"Failed to send ERC20\");\n\t\temit ERC20Sent(tokenAddress, recipient, amount, reason);\n\t}\n\n\tfunction transferERC721(address tokenAddress, address recipient, uint256 tokenId, string memory reason) onlyOwner public {\n\t\tIERC721(tokenAddress).transferFrom(address(this), recipient, tokenId);\n\t\temit ERC721Sent(tokenAddress, recipient, tokenId, reason);\n\t}\n\n\t// Set the reverse ENS name\n\tfunction setName(string memory newName) onlyOwner public {\n\t\tensContract.setName(newName);\n\t}\n\n\treceive() external payable {}\n}\n"
    }
  }
}}