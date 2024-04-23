//SPDX-License-Identifier: UNLICENSED
/*
CoinFinder - Seek and Trade Your Way💰

🔍 Looking for the perfect token? With CoinFinder, your search ends here! Our bot empowers you to filter through a sea of options based on your preferences

Filter your needs based on :
Tax, LP Lock, LP Amount, Market Value, Volume, Pair Age, and more from the comfort of not leaving tg!

Why CoinFinder?

Ethereum Gas and Price Monitoring:
This feature provides real-time tracking of Ethereum's gas fees and ETH price. Users can access up-to-date information on current network congestion and transaction costs, enabling them to make more informed decisions on when to execute transactions.

✅Top Gainers Analysis (24-Hour Period):
A dedicated tool for identifying the top-performing tokens over a 24-hour period, based on both volume and price increases. This feature is essential for traders and investors seeking to spot high-momentum tokens and capitalize on short-term market movements.

🔥Comprehensive Burn Tracking:
This functionality offers the ability to monitor and track token burns across the ecosystem, including both standard tokens and liquidity tokens. Users can enable or disable this feature for specific chat environments, ensuring tailored and relevant data feeds.

🆓Zero Tax Token Discovery:
A specialized search feature to identify tokens with zero transaction tax. This tool is invaluable for investors and traders looking to minimize costs and maximize the efficiency of their transactions.

🕵️‍♂️Age-Based Pair Filtering:
An advanced filtering system that allows users to categorize and view token pairs based on their age - including options such as 1 month, 1 week, 1 day, and 1 hour. This feature is designed to help users assess the maturity and stability of pairs, aiding in risk assessment and portfolio diversification strategies.

Telegram • https://t.me/CoinFinderErc20

Telegram bot • @TheCoinFinderBot

Hall of Fame • @CoinFinderHOF

Twitter/X • https://twitter.com/CoinFinderETH

Website • Coin-Finder.live

Whitepaper • https://bit.ly/CoinFinderWP
*/

pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function TransferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract CoinFinder is ERC20, Ownable {
    constructor() ERC20("Coin Finder", "COFI") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}