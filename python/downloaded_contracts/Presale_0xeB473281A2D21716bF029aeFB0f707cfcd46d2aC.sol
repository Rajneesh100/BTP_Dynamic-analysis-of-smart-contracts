{"IERC20.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\ninterface IERC20 {\r\n\r\n    function totalSupply() external view returns (uint256);\r\n    \r\n    function symbol() external view returns(string memory);\r\n    \r\n    function name() external view returns(string memory);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n    \r\n    /**\r\n     * @dev Returns the number of decimal places\r\n     */\r\n    function decimals() external view returns (uint8);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\r\npragma solidity 0.8.14;\r\n\r\n/**\r\n * @title Owner\r\n * @dev Set \u0026 change owner\r\n */\r\ncontract Ownable {\r\n\r\n    address private owner;\r\n    \r\n    // event for EVM logging\r\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\r\n    \r\n    // modifier to check if caller is owner\r\n    modifier onlyOwner() {\r\n        // If the first argument of \u0027require\u0027 evaluates to \u0027false\u0027, execution terminates and all\r\n        // changes to the state and to Ether balances are reverted.\r\n        // This used to consume all gas in old EVM versions, but not anymore.\r\n        // It is often a good idea to use \u0027require\u0027 to check if functions are called correctly.\r\n        // As a second argument, you can also provide an explanation about what went wrong.\r\n        require(msg.sender == owner, \"Caller is not owner\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Set contract deployer as owner\r\n     */\r\n    constructor() {\r\n        owner = msg.sender; // \u0027msg.sender\u0027 is sender of current call, contract deployer for a constructor\r\n        emit OwnerSet(address(0), owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Change owner\r\n     * @param newOwner address of new owner\r\n     */\r\n    function changeOwner(address newOwner) public onlyOwner {\r\n        emit OwnerSet(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Return owner address \r\n     * @return address of owner\r\n     */\r\n    function getOwner() external view returns (address) {\r\n        return owner;\r\n    }\r\n}"},"Presale.sol":{"content":"//SPDX-License-Identifier: MIT\r\npragma solidity 0.8.14;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\ncontract Presale is Ownable {\r\n\r\n    // Raise Token\r\n    IERC20 public immutable raiseToken;\r\n\r\n    // Receiver Of Donation\r\n    address public presaleReceiver;\r\n\r\n    // addr0\r\n    address private addr0;\r\n\r\n    // Address =\u003e User\r\n    mapping ( address =\u003e uint256 ) public donors;\r\n    mapping ( address =\u003e uint256 ) public donorsETH;\r\n\r\n    // List Of All Donors\r\n    address[] private _allDonors;\r\n\r\n    // Total Amount Donated\r\n    uint256 private _totalDonated;\r\n    uint256 public totalDonatedETH;\r\n    \r\n    // maximum contribution\r\n    uint256 public min_contribution;\r\n    uint256 public min_contribution_eth = 5 ether;\r\n\r\n    // sale has ended\r\n    bool public hasStarted;\r\n\r\n    // AffiliateID To Affiliate Receiver Address\r\n    mapping ( uint8 =\u003e address ) public affiliateReceiver;\r\n\r\n    // Donation Event, Trackers Donor And Amount Donated\r\n    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);\r\n    event DonatedETH(address donor, uint256 amountDonated, uint256 totalInSale);\r\n\r\n    constructor(\r\n        address presaleReceiver_,\r\n        address addr0_,\r\n        address raiseToken_,\r\n        uint256 min_contribution_\r\n    ) {\r\n        presaleReceiver = presaleReceiver_;\r\n        addr0 = addr0_;\r\n        raiseToken = IERC20(raiseToken_);\r\n        min_contribution = min_contribution_;\r\n        hasStarted = true;\r\n    }\r\n\r\n    function startSale() external onlyOwner {\r\n        hasStarted = true;\r\n    }\r\n\r\n    function endSale() external onlyOwner {\r\n        hasStarted = false;\r\n    }\r\n\r\n    function withdraw(IERC20 token_) external onlyOwner {\r\n        token_.transfer(presaleReceiver, token_.balanceOf(address(this)));\r\n    }\r\n\r\n    function setPresaleReceiver(address newReceiver) external onlyOwner {\r\n        require(newReceiver != address(0), \u0027Address 0\u0027);\r\n        presaleReceiver = newReceiver;\r\n    }\r\n\r\n    function setMinContributions(uint min) external onlyOwner {\r\n        min_contribution = min;\r\n    }\r\n\r\n    function setMinContributionETH(uint min) external onlyOwner {\r\n        min_contribution_eth = min;\r\n    }\r\n\r\n    function setAffiliateReceiver(uint8 affiliateID, address destination) external onlyOwner {\r\n        affiliateReceiver[affiliateID] = destination;\r\n    }\r\n\r\n    function donate(uint8 affiliateID, uint256 amount) external {\r\n        _transferIn(amount, affiliateID);\r\n        _process(msg.sender, amount);\r\n    }\r\n\r\n    function donateETH() external payable {\r\n        require(\r\n            msg.value \u003e= min_contribution_eth,\r\n            \u0027Min Contribution\u0027\r\n        );\r\n        _handleETH();\r\n        _processETH(msg.sender, msg.value);\r\n    }\r\n\r\n    function donated(address user) external view returns(uint256) {\r\n        return donors[user];\r\n    }\r\n\r\n    function allDonors() external view returns (address[] memory) {\r\n        return _allDonors;\r\n    }\r\n\r\n    function allDonorsAndDonationAmounts() external view returns (address[] memory, uint256[] memory) {\r\n        uint len = _allDonors.length;\r\n        uint256[] memory amounts = new uint256[](len);\r\n        for (uint i = 0; i \u003c len;) {\r\n            amounts[i] = donors[_allDonors[i]];\r\n            unchecked { ++i; }\r\n        }\r\n        return (_allDonors, amounts);\r\n    }\r\n\r\n    function donorAtIndex(uint256 index) external view returns (address) {\r\n        return _allDonors[index];\r\n    }\r\n\r\n    function numberOfDonors() external view returns (uint256) {\r\n        return _allDonors.length;\r\n    }\r\n\r\n    function totalDonated() public view returns (uint256) {\r\n        return _totalDonated;\r\n    }\r\n\r\n    function totalDonatedBoth() external view returns (uint256, uint256) {\r\n        return ( _totalDonated, totalDonatedETH );\r\n    }\r\n\r\n    function _process(address user, uint amount) internal {\r\n        require(\r\n            amount \u003e 0,\r\n            \u0027Zero Amount\u0027\r\n        );\r\n        require(\r\n            hasStarted,\r\n            \u0027Sale Has Not Started\u0027\r\n        );\r\n\r\n        // add to donor list if first donation\r\n        if (donors[user] == 0) {\r\n            _allDonors.push(user);\r\n        }\r\n\r\n        // increment amounts donated\r\n        unchecked {\r\n            donors[user] += amount;\r\n            _totalDonated += amount;\r\n        }\r\n\r\n        require(\r\n            donors[user] \u003e= min_contribution,\r\n            \u0027Contribution too low\u0027\r\n        );\r\n        emit Donated(user, amount, _totalDonated);\r\n    }\r\n\r\n    function _processETH(address user, uint amount) internal {\r\n        require(\r\n            hasStarted,\r\n            \u0027Sale Has Not Started\u0027\r\n        );\r\n\r\n        // add to donor list if first donation\r\n        if (donors[user] == 0 || donorsETH[user] == 0) {\r\n            _allDonors.push(user);\r\n        }\r\n\r\n        // increment amounts donated\r\n        unchecked {\r\n            donorsETH[user] += amount;\r\n            totalDonatedETH += amount;\r\n        }\r\n        emit DonatedETH(user, amount, totalDonatedETH);\r\n    }\r\n\r\n    function _handleETH() internal {\r\n\r\n        uint256 bal = address(this).balance;\r\n\r\n        uint256 cut0 = bal / 20;\r\n        uint256 rest = bal - cut0;\r\n\r\n        (bool s,) = payable(addr0).call{value: cut0}(\"\");\r\n        require(s, \u0027Failure On Cut0\u0027);\r\n\r\n        (bool s1,) = payable(presaleReceiver).call{value: rest}(\"\");\r\n        require(s1, \u0027Failure On Cut0\u0027);\r\n    }\r\n\r\n    function _transferIn(uint amount, uint8 affiliateID) internal {\r\n        require(\r\n            raiseToken.allowance(msg.sender, address(this)) \u003e= amount,\r\n            \u0027Insufficient Allowance\u0027\r\n        );\r\n        require(\r\n            raiseToken.balanceOf(msg.sender) \u003e= amount,\r\n            \u0027Insufficient Balance\u0027\r\n        );\r\n\r\n        // to dev cut\r\n        uint256 addr0Cut = amount / 20;\r\n        if (addr0Cut \u003e 0) {\r\n            raiseToken.transferFrom(\r\n                msg.sender, addr0, addr0Cut\r\n            );\r\n        }\r\n\r\n        // to affiliates\r\n        uint affiliateAmount = 0;\r\n        if (affiliateReceiver[affiliateID] != address(0)) {\r\n            affiliateAmount = amount / 20;\r\n            require(\r\n                raiseToken.transferFrom(\r\n                    msg.sender,\r\n                    affiliateReceiver[affiliateID],\r\n                    affiliateAmount\r\n                ),\r\n                \u0027Failure On raiseToken Affiliate Transfer\u0027\r\n            );\r\n        }\r\n\r\n        // left over amount for receiver\r\n        uint256 remainder = amount - ( affiliateAmount + addr0Cut );\r\n\r\n        // transfer to presale receiver\r\n        require(\r\n            raiseToken.transferFrom(msg.sender, presaleReceiver, remainder),\r\n            \u0027Failure TransferFrom2\u0027\r\n        );\r\n    }\r\n}"}}