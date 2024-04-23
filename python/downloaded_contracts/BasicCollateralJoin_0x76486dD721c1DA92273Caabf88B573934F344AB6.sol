{{
  "language": "Solidity",
  "sources": {
    "lib/geb/src/shared/BasicTokenAdapters.sol": {
      "content": "/// BasicTokenAdapters.sol\r\n\r\n// Copyright (C) 2018 Rain <rainbreak@riseup.net>\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU Affero General Public License\r\n// along with this program.  If not, see <https://www.gnu.org/licenses/>.\r\n\r\npragma solidity 0.6.7;\r\n\r\nabstract contract CollateralLike {\r\n    function decimals() virtual public view returns (uint256);\r\n    function transfer(address,uint256) virtual public returns (bool);\r\n    function transferFrom(address,address,uint256) virtual public returns (bool);\r\n}\r\n\r\nabstract contract DSTokenLike {\r\n    function mint(address,uint256) virtual external;\r\n    function burn(address,uint256) virtual external;\r\n}\r\n\r\nabstract contract SAFEEngineLike {\r\n    function modifyCollateralBalance(bytes32,address,int256) virtual external;\r\n    function transferInternalCoins(address,address,uint256) virtual external;\r\n}\r\n\r\nabstract contract MultiSAFEEngineLike {\r\n    function modifyCollateralBalance(bytes32,bytes32,address,int256) virtual external;\r\n    function transferInternalCoins(bytes32,address,address,uint256) virtual external;\r\n}\r\n\r\n/*\r\n    Here we provide *adapters* to connect the SAFEEngine to arbitrary external\r\n    token implementations, creating a bounded context for the SAFEEngine. The\r\n    adapters here are provided as working examples:\r\n      - `BasicCollateralJoin`: For well behaved ERC20 tokens, with simple transfer semantics.\r\n      - `ETHJoin`: For native Ether.\r\n      - `CoinJoin`: For connecting internal coin balances to an external\r\n                   `Coin` implementation.\r\n    In practice, adapter implementations will be varied and specific to\r\n    individual collateral types, accounting for different transfer\r\n    semantics and token standards.\r\n    Adapters need to implement two basic methods:\r\n      - `join`: enter collateral into the system\r\n      - `exit`: remove collateral from the system\r\n*/\r\n\r\ncontract BasicCollateralJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call an authed function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"BasicCollateralJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // SAFE database\r\n    SAFEEngineLike  public safeEngine;\r\n    // Collateral type name\r\n    bytes32        public collateralType;\r\n    // Actual collateral token contract\r\n    CollateralLike public collateral;\r\n    // How many decimals the collateral token has\r\n    uint256        public decimals;\r\n    // Whether this adapter contract is enabled or not\r\n    uint256        public contractEnabled;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(address safeEngine_, bytes32 collateralType_, address collateral_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled = 1;\r\n        safeEngine      = SAFEEngineLike(safeEngine_);\r\n        collateralType  = collateralType_;\r\n        collateral      = CollateralLike(collateral_);\r\n        decimals        = collateral.decimals();\r\n        require(decimals == 18, \"BasicCollateralJoin/non-18-decimals\");\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    /**\r\n    * @notice Join collateral in the system\r\n    * @dev This function locks collateral in the adapter and creates a 'representation' of\r\n    *      the locked collateral inside the system. This adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param account Account from which we transferFrom collateral and add it in the system\r\n    * @param wad Amount of collateral to transfer in the system (represented as a number with 18 decimals)\r\n    **/\r\n    function join(address account, uint256 wad) external {\r\n        require(contractEnabled == 1, \"BasicCollateralJoin/contract-not-enabled\");\r\n        require(int256(wad) >= 0, \"BasicCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, account, int256(wad));\r\n        require(collateral.transferFrom(msg.sender, address(this), wad), \"BasicCollateralJoin/failed-transfer\");\r\n        emit Join(msg.sender, account, wad);\r\n    }\r\n    /**\r\n    * @notice Exit collateral from the system\r\n    * @dev This function destroys the collateral representation from inside the system\r\n    *      and exits the collateral from this adapter. The adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param account Account to which we transfer the collateral\r\n    * @param wad Amount of collateral to transfer to 'account' (represented as a number with 18 decimals)\r\n    **/\r\n    function exit(address account, uint256 wad) external {\r\n        require(wad <= 2 ** 255, \"BasicCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, msg.sender, -int256(wad));\r\n        require(collateral.transfer(account, wad), \"BasicCollateralJoin/failed-transfer\");\r\n        emit Exit(msg.sender, account, wad);\r\n    }\r\n}\r\n\r\ncontract MultiBasicCollateralJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call an authed function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"MultiBasicCollateralJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // SAFE database\r\n    MultiSAFEEngineLike  public safeEngine;\r\n    // Collateral type name\r\n    bytes32              public collateralType;\r\n    // Actual collateral token contract\r\n    CollateralLike       public collateral;\r\n    // How many decimals the collateral token has\r\n    uint256              public decimals;\r\n    // Whether this adapter contract is enabled or not\r\n    uint256              public contractEnabled;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(address safeEngine_, bytes32 collateralType_, address collateral_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled = 1;\r\n        safeEngine      = MultiSAFEEngineLike(safeEngine_);\r\n        collateralType  = collateralType_;\r\n        collateral      = CollateralLike(collateral_);\r\n        decimals        = collateral.decimals();\r\n        require(decimals == 18, \"MultiBasicCollateralJoin/non-18-decimals\");\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    /**\r\n    * @notice Join collateral in the system\r\n    * @dev This function locks collateral in the adapter and creates a 'representation' of\r\n    *      the locked collateral inside the system. This adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param account Account from which we transferFrom collateral and add it in the system\r\n    * @param wad Amount of collateral to transfer in the system (represented as a number with 18 decimals)\r\n    **/\r\n    function join(address account, uint256 wad) external {\r\n        require(contractEnabled == 1, \"MultiBasicCollateralJoin/contract-not-enabled\");\r\n        require(int256(wad) >= 0, \"MultiBasicCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, collateralType, account, int256(wad));\r\n        require(collateral.transferFrom(msg.sender, address(this), wad), \"MultiBasicCollateralJoin/failed-transfer\");\r\n        emit Join(msg.sender, account, wad);\r\n    }\r\n    /**\r\n    * @notice Exit collateral from the system\r\n    * @dev This function destroys the collateral representation from inside the system\r\n    *      and exits the collateral from this adapter. The adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param account Account to which we transfer the collateral\r\n    * @param wad Amount of collateral to transfer to 'account' (represented as a number with 18 decimals)\r\n    **/\r\n    function exit(address account, uint256 wad) external {\r\n        require(wad <= 2 ** 255, \"MultiBasicCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, collateralType, msg.sender, -int256(wad));\r\n        require(collateral.transfer(account, wad), \"MultiBasicCollateralJoin/failed-transfer\");\r\n        emit Exit(msg.sender, account, wad);\r\n    }\r\n}\r\n\r\ncontract MultiSubCollateralJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call an authed function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"MultiSubCollateralJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // Base collateral type\r\n    bytes32                     public collateralType;\r\n    // SAFE database\r\n    MultiSAFEEngineLike         public safeEngine;\r\n    // How many decimals the sub-collateral tokens have\r\n    uint256                     public decimals;\r\n    // Whether this adapter contract is enabled or not\r\n    uint256                     public contractEnabled;\r\n\r\n    // Sub-collateral names and token contracts\r\n    mapping(bytes32 => address) public subCollaterals;\r\n    // Whether a token contract has already been onboarded\r\n    mapping(address => uint256) public tokenOnboarded;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(bytes32 subCollateral, address sender, address account, uint256 wad);\r\n    event Exit(bytes32 subCollateral, address sender, address account, uint256 wad);\r\n    event AddSubCollateral(bytes32 subCollateral, address token);\r\n\r\n    constructor(address safeEngine_, bytes32 collateralType_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled = 1;\r\n        safeEngine      = MultiSAFEEngineLike(safeEngine_);\r\n        collateralType  = collateralType_;\r\n        decimals        = 18;\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Add a subcollateral\r\n     * @param subCollateral Sub-collateral name\r\n     * @param token Address of the collateral token contract\r\n     */\r\n    function addSubCollateral(bytes32 subCollateral, address token) external isAuthorized {\r\n        require(tokenOnboarded[token] == 0, \"MultiSubCollateralJoin/token-already-onboarded\");\r\n        require(subCollaterals[subCollateral] == address(0), \"MultiSubCollateralJoin/subcollateral-already-onboarded\");\r\n        require(CollateralLike(token).decimals() == decimals, \"MultiSubCollateralJoin/invalid-decimal-number\");\r\n\r\n        tokenOnboarded[token]         = 1;\r\n        subCollaterals[subCollateral] = token;\r\n\r\n        emit AddSubCollateral(subCollateral, token);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    /**\r\n    * @notice Join sub-collateral in the system\r\n    * @dev This function locks sub-collateral in the adapter and creates a 'representation' of\r\n    *      the locked collateral inside the system. This adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param subCollateral The sub-collateral to join\r\n    * @param account Account from which we transferFrom collateral and add it in the system\r\n    * @param wad Amount of collateral to transfer in the system (represented as a number with 18 decimals)\r\n    **/\r\n    function join(bytes32 subCollateral, address account, uint256 wad) external {\r\n        require(contractEnabled == 1, \"MultiSubCollateralJoin/contract-not-enabled\");\r\n        require(subCollaterals[subCollateral] != address(0), \"MultiSubCollateralJoin/subcollateral-not-onboarded\");\r\n        require(int256(wad) >= 0, \"MultiSubCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, subCollateral, account, int256(wad));\r\n        require(CollateralLike(subCollaterals[subCollateral]).transferFrom(msg.sender, address(this), wad), \"MultiSubCollateralJoin/failed-transfer\");\r\n        emit Join(subCollateral, msg.sender, account, wad);\r\n    }\r\n    /**\r\n    * @notice Exit collateral from the system\r\n    * @dev This function destroys the collateral representation from inside the system\r\n    *      and exits the collateral from this adapter. The adapter assumes that the collateral\r\n    *      has 18 decimals\r\n    * @param subCollateral The sub-collateral to exit\r\n    * @param account Account to which we transfer the collateral\r\n    * @param wad Amount of collateral to transfer to 'account' (represented as a number with 18 decimals)\r\n    **/\r\n    function exit(bytes32 subCollateral, address account, uint256 wad) external {\r\n        require(wad <= 2 ** 255, \"MultiSubCollateralJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, subCollateral, msg.sender, -int256(wad));\r\n        require(CollateralLike(subCollaterals[subCollateral]).transfer(account, wad), \"MultiSubCollateralJoin/failed-transfer\");\r\n        emit Exit(subCollateral, msg.sender, account, wad);\r\n    }\r\n}\r\n\r\ncontract ETHJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call a restricted function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"ETHJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // SAFE database\r\n    SAFEEngineLike public safeEngine;\r\n    // Collateral type name\r\n    bytes32       public collateralType;\r\n    // Whether this contract is enabled or not\r\n    uint256       public contractEnabled;\r\n    // Number of decimals ETH has\r\n    uint256       public decimals;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(address safeEngine_, bytes32 collateralType_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled                = 1;\r\n        safeEngine                     = SAFEEngineLike(safeEngine_);\r\n        collateralType                 = collateralType_;\r\n        decimals                       = 18;\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    /**\r\n    * @notice Join ETH in the system\r\n    * @param account Account that will receive the ETH representation inside the system\r\n    **/\r\n    function join(address account) external payable {\r\n        require(contractEnabled == 1, \"ETHJoin/contract-not-enabled\");\r\n        require(int256(msg.value) >= 0, \"ETHJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, account, int256(msg.value));\r\n        emit Join(msg.sender, account, msg.value);\r\n    }\r\n    /**\r\n    * @notice Exit ETH from the system\r\n    * @param account Account that will receive the ETH representation inside the system\r\n    **/\r\n    function exit(address payable account, uint256 wad) external {\r\n        require(int256(wad) >= 0, \"ETHJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, msg.sender, -int256(wad));\r\n        emit Exit(msg.sender, account, wad);\r\n        account.transfer(wad);\r\n    }\r\n}\r\n\r\ncontract MultiETHJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call a restricted function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"MultiETHJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // SAFE database\r\n    MultiSAFEEngineLike public safeEngine;\r\n    // Collateral type name\r\n    bytes32             public collateralType;\r\n    // Whether this contract is enabled or not\r\n    uint256             public contractEnabled;\r\n    // Number of decimals ETH has\r\n    uint256             public decimals;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(address safeEngine_, bytes32 collateralType_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled                = 1;\r\n        safeEngine                     = MultiSAFEEngineLike(safeEngine_);\r\n        collateralType                 = collateralType_;\r\n        decimals                       = 18;\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    /**\r\n    * @notice Join ETH in the system\r\n    * @param account Account that will receive the ETH representation inside the system\r\n    **/\r\n    function join(address account) external payable {\r\n        require(contractEnabled == 1, \"MultiETHJoin/contract-not-enabled\");\r\n        require(int256(msg.value) >= 0, \"MultiETHJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, collateralType, account, int256(msg.value));\r\n        emit Join(msg.sender, account, msg.value);\r\n    }\r\n    /**\r\n    * @notice Exit ETH from the system\r\n    * @param account Account that will receive the ETH representation inside the system\r\n    **/\r\n    function exit(address payable account, uint256 wad) external {\r\n        require(int256(wad) >= 0, \"MultiETHJoin/overflow\");\r\n        safeEngine.modifyCollateralBalance(collateralType, collateralType, msg.sender, -int256(wad));\r\n        emit Exit(msg.sender, account, wad);\r\n        account.transfer(wad);\r\n    }\r\n}\r\n\r\ncontract CoinJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call an authed function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"CoinJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // SAFE database\r\n    SAFEEngineLike public safeEngine;\r\n    // Coin created by the system; this is the external, ERC-20 representation, not the internal 'coinBalance'\r\n    DSTokenLike    public systemCoin;\r\n    // Whether this contract is enabled or not\r\n    uint256        public contractEnabled;\r\n    // Number of decimals the system coin has\r\n    uint256        public decimals;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(address safeEngine_, address systemCoin_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled                = 1;\r\n        safeEngine                     = SAFEEngineLike(safeEngine_);\r\n        systemCoin                     = DSTokenLike(systemCoin_);\r\n        decimals                       = 18;\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    uint256 constant RAY = 10 ** 27;\r\n    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {\r\n        require(y == 0 || (z = x * y) / y == x, \"CoinJoin/mul-overflow\");\r\n    }\r\n    /**\r\n    * @notice Join system coins in the system\r\n    * @dev Exited coins have 18 decimals but inside the system they have 45 (rad) decimals.\r\n           When we join, the amount (wad) is multiplied by 10**27 (ray)\r\n    * @param account Account that will receive the joined coins\r\n    * @param wad Amount of external coins to join (18 decimal number)\r\n    **/\r\n    function join(address account, uint256 wad) external {\r\n        safeEngine.transferInternalCoins(address(this), account, multiply(RAY, wad));\r\n        systemCoin.burn(msg.sender, wad);\r\n        emit Join(msg.sender, account, wad);\r\n    }\r\n    /**\r\n    * @notice Exit system coins from the system and inside 'Coin.sol'\r\n    * @dev Inside the system, coins have 45 (rad) decimals but outside of it they have 18 decimals (wad).\r\n           When we exit, we specify a wad amount of coins and then the contract automatically multiplies\r\n           wad by 10**27 to move the correct 45 decimal coin amount to this adapter\r\n    * @param account Account that will receive the exited coins\r\n    * @param wad Amount of internal coins to join (18 decimal number that will be multiplied by ray)\r\n    **/\r\n    function exit(address account, uint256 wad) external {\r\n        require(contractEnabled == 1, \"CoinJoin/contract-not-enabled\");\r\n        safeEngine.transferInternalCoins(msg.sender, address(this), multiply(RAY, wad));\r\n        systemCoin.mint(account, wad);\r\n        emit Exit(msg.sender, account, wad);\r\n    }\r\n}\r\n\r\ncontract MultiCoinJoin {\r\n    // --- Auth ---\r\n    mapping (address => uint256) public authorizedAccounts;\r\n    /**\r\n     * @notice Add auth to an account\r\n     * @param account Account to add auth to\r\n     */\r\n    function addAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 1;\r\n        emit AddAuthorization(account);\r\n    }\r\n    /**\r\n     * @notice Remove auth from an account\r\n     * @param account Account to remove auth from\r\n     */\r\n    function removeAuthorization(address account) external isAuthorized {\r\n        authorizedAccounts[account] = 0;\r\n        emit RemoveAuthorization(account);\r\n    }\r\n    /**\r\n    * @notice Checks whether msg.sender can call an authed function\r\n    **/\r\n    modifier isAuthorized {\r\n        require(authorizedAccounts[msg.sender] == 1, \"MultiCoinJoin/account-not-authorized\");\r\n        _;\r\n    }\r\n\r\n    // Multi synth SAFE database\r\n    MultiSAFEEngineLike public safeEngine;\r\n    // Coin created by the system; this is the external, ERC-20 representation, not the internal 'coinBalance'\r\n    DSTokenLike         public systemCoin;\r\n    // Whether this contract is enabled or not\r\n    uint256             public contractEnabled;\r\n    // Number of decimals the system coin has\r\n    uint256             public decimals;\r\n    // The name of the synth\r\n    bytes32             public coinName;\r\n\r\n    // --- Events ---\r\n    event AddAuthorization(address account);\r\n    event RemoveAuthorization(address account);\r\n    event DisableContract();\r\n    event Join(address sender, address account, uint256 wad);\r\n    event Exit(address sender, address account, uint256 wad);\r\n\r\n    constructor(bytes32 coinName_, address safeEngine_, address systemCoin_) public {\r\n        authorizedAccounts[msg.sender] = 1;\r\n        contractEnabled                = 1;\r\n        coinName                       = coinName_;\r\n        safeEngine                     = MultiSAFEEngineLike(safeEngine_);\r\n        systemCoin                     = DSTokenLike(systemCoin_);\r\n        decimals                       = 18;\r\n        emit AddAuthorization(msg.sender);\r\n    }\r\n    /**\r\n     * @notice Disable this contract\r\n     */\r\n    function disableContract() external isAuthorized {\r\n        contractEnabled = 0;\r\n        emit DisableContract();\r\n    }\r\n    uint256 constant RAY = 10 ** 27;\r\n    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {\r\n        require(y == 0 || (z = x * y) / y == x, \"MultiCoinJoin/mul-overflow\");\r\n    }\r\n    /**\r\n    * @notice Join system coins in the system\r\n    * @dev Exited coins have 18 decimals but inside the system they have 45 (rad) decimals.\r\n           When we join, the amount (wad) is multiplied by 10**27 (ray)\r\n    * @param account Account that will receive the joined coins\r\n    * @param wad Amount of external coins to join (18 decimal number)\r\n    **/\r\n    function join(address account, uint256 wad) external {\r\n        safeEngine.transferInternalCoins(coinName, address(this), account, multiply(RAY, wad));\r\n        systemCoin.burn(msg.sender, wad);\r\n        emit Join(msg.sender, account, wad);\r\n    }\r\n    /**\r\n    * @notice Exit system coins from the system and inside 'Coin.sol'\r\n    * @dev Inside the system, coins have 45 (rad) decimals but outside of it they have 18 decimals (wad).\r\n           When we exit, we specify a wad amount of coins and then the contract automatically multiplies\r\n           wad by 10**27 to move the correct 45 decimal coin amount to this adapter\r\n    * @param account Account that will receive the exited coins\r\n    * @param wad Amount of internal coins to join (18 decimal number that will be multiplied by ray)\r\n    **/\r\n    function exit(address account, uint256 wad) external {\r\n        require(contractEnabled == 1, \"MultiCoinJoin/contract-not-enabled\");\r\n        safeEngine.transferInternalCoins(coinName, msg.sender, address(this), multiply(RAY, wad));\r\n        systemCoin.mint(account, wad);\r\n        emit Exit(msg.sender, account, wad);\r\n    }\r\n}\r\n"
    }
  },
  "settings": {
    "remappings": [
      "ds-auth/=lib/geb-fsm/lib/ds-stop/lib/ds-auth/src/",
      "ds-math/=lib/geb-fsm/lib/ds-token/lib/ds-math/src/",
      "ds-note/=lib/geb-fsm/lib/ds-stop/lib/ds-note/src/",
      "ds-stop/=lib/geb-fsm/lib/ds-stop/src/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "ds-thing/=lib/geb-fsm/lib/ds-value/lib/ds-thing/src/",
      "ds-token/=lib/geb-fsm/lib/ds-token/src/",
      "ds-value/=lib/geb-fsm/lib/ds-value/src/",
      "erc20/=lib/geb-fsm/lib/ds-token/lib/erc20/src/",
      "forge-std/=lib/forge-std/src/",
      "geb-fsm/=lib/geb-fsm/src/",
      "geb-treasury-reimbursement/=lib/geb-fsm/lib/geb-treasury-reimbursement/src/",
      "geb/=lib/geb/src/",
      "mgl-keeper-incentives/=lib/mgl-keeper-incentives/src/",
      "solmate/=lib/mgl-keeper-incentives/lib/solmate/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 20
    },
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "ipfs"
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "evmVersion": "istanbul",
    "libraries": {}
  }
}}