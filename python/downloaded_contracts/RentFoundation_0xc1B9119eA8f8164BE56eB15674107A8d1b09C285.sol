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
      "runs": 2000
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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/RentFoundation.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/Context.sol\";\nimport \"./interfaces/IKeyProtocolVariables.sol\";\nimport \"./interfaces/ILandXNFT.sol\";\nimport \"./interfaces/IxTokenRouter.sol\";\nimport \"./interfaces/IOraclePrices.sol\";\nimport \"./interfaces/IRentFoundation.sol\";\nimport \"./interfaces/IcToken.sol\";\nimport \"./interfaces/IxToken.sol\";\nimport \"./interfaces/ILNDX.sol\";\n\ncontract RentFoundation is IRentFoundation, Context, Ownable {\n    struct deposit {\n        uint256 timestamp;\n        uint256 amount; // in kg\n        int256 depositBalance; //in kg\n    }\n\n    IERC20 public immutable usdc;\n\n    address public immutable lndx;\n\n    ILandXNFT public landXNFT; //address of landXNFT\n\n    IOraclePrices public grainPrices;\n\n    IxTokenRouter public xTokenRouter; // address of xTokenRouter\n    IKeyProtocolVariables public keyProtocolValues;\n\n    mapping(uint256 => deposit) public deposits;\n\n    mapping(uint256 => bool) public initialRentApplied;\n\n    mapping(uint256 => bool) public spentSecurityDeposit;\n\n    address public distributor;\n    string[] public crops = [\"SOY\", \"WHEAT\", \"CORN\", \"RICE\"];\n\n    event rentPaid(uint256 tokenID, uint256 amount);\n    event initialRentPaid(uint256 tokenID, uint256 amount);\n\n    constructor(\n        address _usdc,\n        address _lndx,\n        address _grainPrices,\n        address _landXNFT,\n        address _xTokenRouter,\n        address _keyProtocolValues,\n        address _distributor\n    ) {\n        require(_usdc != address(0), \"zero address is not allowed\");\n        require(_lndx != address(0), \"zero address is not allowed\");\n        require(_grainPrices != address(0), \"zero address is not allowed\");\n        require(_landXNFT != address(0), \"zero address is not allowed\");\n        require(_xTokenRouter!= address(0), \"zero address is not allowed\");\n        require(_keyProtocolValues != address(0), \"zero address is not allowed\");\n        usdc = IERC20(_usdc);\n        lndx = _lndx;\n        xTokenRouter = IxTokenRouter(_xTokenRouter);\n        grainPrices = IOraclePrices(_grainPrices);\n        landXNFT = ILandXNFT(_landXNFT);\n        keyProtocolValues = IKeyProtocolVariables(_keyProtocolValues);\n        distributor = _distributor;\n    }\n\n    // deposit rent for token ID, in USDC\n    function payRent(uint256 tokenID, uint256 amount) public {\n        require(initialRentApplied[tokenID], \"Initial rent was not applied\");\n        if (msg.sender == keyProtocolValues.xTokensSecurityWallet()) {\n            require(!spentSecurityDeposit[tokenID], \"securityDeposit is already spent\");\n            spentSecurityDeposit[tokenID] = true;\n        }\n        require(\n            usdc.transferFrom(msg.sender, address(this), amount),\n            \"transfer failed\"\n        );\n        uint256 platformFee = (amount * keyProtocolValues.payRentFee()) / 10000; // 100% = 10000\n        uint256 validatorFee = (amount *\n            keyProtocolValues.validatorCommission()) / 10000; // 100% = 10000\n        usdc.transfer(\n            keyProtocolValues.hedgeFundWallet(),\n            ((amount - platformFee - validatorFee) *\n                keyProtocolValues.hedgeFundAllocation()) / 10000 // 100% = 10000\n        );\n        usdc.transfer(\n            keyProtocolValues.validatorCommisionWallet(),\n            validatorFee\n        );\n        uint256 grainAmount = (amount - platformFee - validatorFee) * 10 ** 3 / //grainPrices.prices returns price per megatonne, so to get amount in KG we multiply by 10 ** 3 \n            grainPrices.prices(landXNFT.crop(tokenID));\n        _feeDistributor(platformFee);\n        deposits[tokenID].amount += grainAmount;\n        emit rentPaid(tokenID, grainAmount);\n    }\n\n    // prepay initial rent after sharding in kg\n    function payInitialRent(uint256 tokenID, uint256 amount) external {\n        string memory crop = landXNFT.crop(tokenID);\n        require(\n            !initialRentApplied[tokenID],\n            \"Initial Paymant already applied\"\n        );\n        require(\n            xTokenRouter.getXToken(crop) == msg.sender,\n            \"not initial payer\"\n        );\n        deposits[tokenID].timestamp = block.timestamp;\n        deposits[tokenID].amount = amount;\n        initialRentApplied[tokenID] = true;\n        spentSecurityDeposit[tokenID] = false;\n        emit initialRentPaid(tokenID, amount);\n    }\n\n    function getDepositBalance(uint256 tokenID) public view returns (int256) {\n        uint256 elapsedSeconds = block.timestamp - deposits[tokenID].timestamp;\n        uint256 delimeter = 365 * 1 days;\n        uint256 rentPerSecond = (landXNFT.cropShare(tokenID) *\n            landXNFT.tillableArea(tokenID) * 10 ** 3) /  delimeter; // multiply by 10**3 to not loose precision\n        return\n            int256(deposits[tokenID].amount) -\n            int256(rentPerSecond * elapsedSeconds / 10 ** 7); // landXNFT.tillableArea returns area in square meters(so we divide by 10 ** 4 to get Ha) and diivide by 10 ** 3 from previous step\n    }\n\n    // Check and return remainig rent paid\n    function buyOut(uint256 tokenID) external returns(uint256) {\n        string memory crop = landXNFT.crop(tokenID);\n        require(\n            initialRentApplied[tokenID],\n            \"Initial Paymant isn't applied\"\n        );\n        require(\n            xTokenRouter.getXToken(crop) == msg.sender,\n            \"not initial payer\"\n        );\n\n        int256 depositBalance = getDepositBalance(tokenID);  //KG\n\n        if (depositBalance < 0) {\n            revert(\"NFT has a debt\");\n        }\n\n        uint256 usdcAmount = (uint256(depositBalance) * grainPrices.prices(crop)) / (10**3); // price per megatonne and usdc has 6 decimals (10**6 / 10**9)\n\n\n        deposits[tokenID].depositBalance = 0;\n        deposits[tokenID].amount = 0;\n        deposits[tokenID].timestamp = 0;\n        initialRentApplied[tokenID] = false;\n\n        usdc.transfer(msg.sender, usdcAmount);\n        return usdcAmount;\n    }\n\n     function buyOutPreview(uint256 tokenID) external view returns(bool, uint256) {\n        string memory crop = landXNFT.crop(tokenID);\n        require(\n            initialRentApplied[tokenID],\n            \"Initial Paymant isn't applied\"\n        );\n        require(\n            xTokenRouter.getXToken(crop) == msg.sender,\n            \"not initial payer\"\n        );\n\n        int256 depositBalance = getDepositBalance(tokenID);  //KG\n\n        if (depositBalance < 0) {\n            return (false, 0);\n        }\n\n        uint256 usdcAmount = (uint256(depositBalance) * grainPrices.prices(crop)) / (10**3); // price per megatonne and usdc has 6 decimals (10**6 / 10**9)\n\n        return (true, usdcAmount);\n    }\n\n    function sellCToken(address account, uint256 amount) public {\n        string memory crop = IcToken(msg.sender).crop();\n        require(xTokenRouter.getCToken(crop) == msg.sender, \"no valid cToken\");\n        uint256 usdcAmount = (amount * grainPrices.prices(crop)) / (10**9);\n        uint256 sellTokenFee = (usdcAmount *\n            keyProtocolValues.cTokenSellFee()) / 10000; // 100% = 10000\n        usdc.transfer(account, usdcAmount - sellTokenFee);\n        _feeDistributor(sellTokenFee);\n    }\n\n    function _feeDistributor(uint256 _fee) internal {\n        uint256 lndxFee = (_fee * keyProtocolValues.lndxHoldersPercentage()) /\n            10000;\n        uint256 operationalFee = (_fee *\n            keyProtocolValues.landXOperationsPercentage()) / 10000; // 100% = 10000\n        usdc.transfer(lndx, lndxFee);\n        ILNDX(lndx).feeToDistribute(lndxFee);\n        usdc.transfer(\n            keyProtocolValues.landxOperationalWallet(),\n            operationalFee\n        );\n        usdc.transfer(\n            keyProtocolValues.landxChoiceWallet(),\n            _fee - lndxFee - operationalFee\n        );\n    }\n\n     function previewSurplusUSDC() public view returns(uint256) {\n        uint256 totalUsdcYield;\n        for (uint i=0; i<crops.length; i++) {\n            address xTokenAddress = xTokenRouter.getXToken(crops[i]);\n            uint amount = IxToken(xTokenAddress).previewNonDistributedYield();\n            uint usdcYield = (amount * grainPrices.prices(crops[i])) / (10**9);\n            totalUsdcYield += usdcYield;\n        }\n        return totalUsdcYield;\n    }\n\n     function _getSurplusUSDC() internal returns(uint256) {\n        uint totalUsdcYield;\n        for (uint i=0; i<crops.length; i++) {\n            address xTokenAddress = xTokenRouter.getXToken(crops[i]);\n            uint amount = IxToken(xTokenAddress).getNonDistributedYield();\n            uint usdcYield = (amount * grainPrices.prices(crops[i])) / (10**9);\n            totalUsdcYield += usdcYield;\n        }\n        return totalUsdcYield;\n    }\n\n    function withdrawSurplusUSDC(uint _amount) public {\n        require(msg.sender == distributor, \"only distributor can withdraw\");\n        require(_getSurplusUSDC() >= _amount && _amount < usdc.balanceOf(address(this)), \"not enough surplus funds\");\n        usdc.transfer(distributor, _amount);\n    }\n\n    function updateDistributor(address _distributor) public onlyOwner {\n        distributor = _distributor;\n    }\n\n    function updateCrops(string[] memory _crops) public onlyOwner {\n        crops = _crops;\n    }\n\n    function setXTokenRouter(address _router) public onlyOwner {\n        require(_router != address(0), \"zero address is not allowed\");\n        xTokenRouter = IxTokenRouter(_router);\n    }\n\n    function setGrainPrices(address _grainPrices) public onlyOwner {\n        require(_grainPrices != address(0), \"zero address is not allowed\");\n        grainPrices = IOraclePrices(_grainPrices);\n    }\n\n    // change the address of landxNFT.\n    function changeLandXNFTAddress(address _newAddress) public onlyOwner {\n        require(_newAddress != address(0), \"zero address is not allowed\");\n        landXNFT = ILandXNFT(_newAddress);\n    }\n\n    function renounceOwnership() public view override onlyOwner {\n        revert (\"can 't renounceOwnership here\");\n    }\n}\n"
    },
    "contracts/interfaces/IKeyProtocolVariables.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\n\ninterface IKeyProtocolVariables {\n    function xTokenMintFee() external view returns (uint256);\n\n    function securityDepositMonths() external view returns (uint8);\n\n    function xTokensSecurityWallet() external view returns (address);\n\n    function landxOperationalWallet() external view returns (address);\n\n    function landxChoiceWallet() external view returns (address);\n\n    function landXOperationsPercentage() external view returns (uint256);\n\n    function landXChoicePercentage() external view returns (uint256);\n\n    function lndxHoldersPercentage() external view returns (uint256);\n\n    function hedgeFundAllocation() external view returns (uint256);\n\n    function hedgeFundWallet() external view returns (address);\n\n    function preLaunch() external view returns (bool);\n\n    function sellXTokenSlippage() external view returns (uint256);\n   \n    function buyXTokenSlippage() external view returns (uint256);  \n\n    function cTokenSellFee() external view returns (uint256);\n\n    function validatorCommission() external view returns (uint256);\n\n    function validatorCommisionWallet() external view returns (address);\n\n    function payRentFee() external view returns (uint256);\n\n    function maxValidatorFee() external view returns (uint256);\n}"
    },
    "contracts/interfaces/ILNDX.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface ILNDX {\n    function feeToDistribute(uint256 amount) external;\n}"
    },
    "contracts/interfaces/ILandXNFT.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface ILandXNFT {\n    function tillableArea(uint256 id) external view returns (uint256);\n\n    function cropShare(uint256 id) external view returns (uint256);\n\n    function crop(uint256 id) external view returns (string memory);\n\n    function validatorFee(uint256 id) external view returns (uint256);\n\n    function validator(uint256 id) external view returns (address);\n\n    function initialOwner(uint256 id) external view returns (address);\n\n    function balanceOf(address account, uint256 id)\n        external\n        view\n        returns (uint256);\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes calldata data\n    ) external;\n}"
    },
    "contracts/interfaces/IOraclePrices.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface IOraclePrices {\n    function prices(string memory grain) external view returns (uint256);\n    \n    function getXTokenPrice(address xToken) external view returns (uint256);\n\n    function usdc() external view returns (address);\n}"
    },
    "contracts/interfaces/IRentFoundation.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface IRentFoundation {\n    function initialRentApplied(uint256 tokenID) external view returns (bool);\n\n    function spentSecurityDeposit(uint256 tokenID) external view returns (bool);\n\n    function payInitialRent(uint256 tokenID, uint256 amount) external;\n\n    function buyOutPreview(uint256 tokenID) external view returns(bool, uint256);\n\n    function buyOut(uint256 tokenID) external returns(uint256);\n\n     function sellCToken(address account, uint256 amount) external;\n}"
    },
    "contracts/interfaces/IcToken.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface IcToken {\n    function crop() external view returns (string memory);\n    function mint(address account, uint256 amount) external;\n}"
    },
    "contracts/interfaces/IxToken.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ninterface IxToken is IERC20 {\n    function previewNonDistributedYield() external view returns(uint256);\n\n    function getNonDistributedYield() external returns(uint256);\n\n    function stake(uint256 amount) external;\n\n    function unstake(uint256 amount) external;\n\n    function xBasketTransfer(address _from, uint256 amount) external;\n\n    function Staked(address)\n        external\n        view\n        returns (uint256 amount, uint256 startTime); // Not\n\n    function availableToClaim(address account) external view returns (uint256);\n\n    function claim() external;\n}"
    },
    "contracts/interfaces/IxTokenRouter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.16;\n\ninterface IxTokenRouter {\n    function getXToken(string memory _name) external view returns (address);\n    function getCToken(string memory _name) external view returns (address);\n}"
    }
  }
}}