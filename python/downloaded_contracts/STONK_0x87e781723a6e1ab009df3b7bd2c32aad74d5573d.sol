/***
    __      ______   ________  ______   __    __  __    __ 
  _/  |_   /      \ /        |/      \ /  \  /  |/  |  /  |
 / $$   \ /$$$$$$  |$$$$$$$$//$$$$$$  |$$  \ $$ |$$ | /$$/ 
/$$$$$$  |$$ \__$$/    $$ |  $$ |  $$ |$$$  \$$ |$$ |/$$/  
$$ \__$$/ $$      \    $$ |  $$ |  $$ |$$$$  $$ |$$  $$<   
$$      \  $$$$$$  |   $$ |  $$ |  $$ |$$ $$ $$ |$$$$$  \  
 $$$$$$  |/  \__$$ |   $$ |  $$ \__$$ |$$ |$$$$ |$$ |$$  \ 
/  \__$$ |$$    $$/    $$ |  $$    $$/ $$ | $$$ |$$ | $$  |
$$    $$/  $$$$$$/     $$/    $$$$$$/  $$/   $$/ $$/   $$/ 
 $$$$$$/                                                   
   $$/                                                     
                                                           
Website: www.StonkMeme.xyz 
Twitter: X.com/StonkMemeErc
Telegram: https://t.me/STONK_PORTAL

Bringing back an iconic meme! $STONK is 0/0 tax, NO Initial Tax, NO Farm, NO BS! Lets print
***/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() private view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract STONK is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private constant _name = "MEME MAN";
    string private constant _symbol = "STONK";
    uint256 private constant _totalSupply = 1_000_000_000_000 * 10**18; //total supply
    uint256 public maxWalletlimit = 1_500_000_001 * 10**18; // max wallet limit
    uint256 public maxTxLimit = 1_500_000_001 * 10**18; //max tx limit
    uint256 public minSwap = 10_000_000 * 10**18;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address immutable uniswapV2Pair;
    address immutable WETH;
    address payable public marketingWallet;
    bool public isOpen = false;
    mapping (address => bool) public _isBlacklisted;

    uint256 public buyTax;
    uint256 public sellTax;
    uint8 private inSwapAndLiquify;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = uniswapV2Router.WETH();
        buyTax = 0;
        sellTax = 0;

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );

        marketingWallet = payable(0x9e9058AddB3c4dB5ceE6F83B54834792B1629842);
        _balance[msg.sender] = _totalSupply;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(uniswapV2Router)] = true;
        _allowances[address(this)][address(uniswapV2Router)] = type(uint256)
            .max;
        _allowances[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        _allowances[marketingWallet][address(uniswapV2Router)] = type(uint256)
            .max;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function ExcludeFromFees(address holder, bool exempt) external onlyOwner {
        _isExcludedFromFees[holder] = exempt;
    }
    
    function RemoveLimits() external onlyOwner {
        maxWalletlimit = _totalSupply;
        maxTxLimit = _totalSupply;
    }
    
    function ChangeMinSwap(uint256 NewMinSwapAmount) external onlyOwner {
        minSwap = NewMinSwapAmount * 10**18;
    }

    function ChangeMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWallet = payable(newAddress);
    }
    
    function EnableTrading() external onlyOwner {
        isOpen = true;
    }
    
        //for sniperss
    function BlackListWallet(address[] calldata addresses) external onlyOwner {
      for (uint256 i; i < addresses.length; ++i) {
        _isBlacklisted[addresses[i]] = true;
      }
    }
     
    function UnBlackListWallet(address[] calldata addresses) external onlyOwner {
      for (uint256 i; i < addresses.length; ++i) {
        _isBlacklisted[addresses[i]] = false;
      }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");
        require(isOpen || _isExcludedFromFees[from] || _isExcludedFromFees[to], "Not Open");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "To/from address is blacklisted!");

        uint256 _tax;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            _tax = 0;
        } else {

            if (inSwapAndLiquify == 1) {
                //No tax transfer
                _balance[from] -= amount;
                _balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == uniswapV2Pair) {
                require(balanceOf(to).add(amount) <= maxWalletlimit);
                require(amount <= maxTxLimit, "Buy transfer amount exceeds the maxTxLimit.");
                _tax = buyTax;
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > minSwap && inSwapAndLiquify == 0) {
                    inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = WETH;
                    uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            marketingWallet,
                            block.timestamp
                        );
                    inSwapAndLiquify = 0;
                }
                _tax = sellTax;
            } else {
                _tax = 0;
            }
        }
        


        //Is there tax for sender|receiver?
        if (_tax != 0) {
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            _balance[from] -= amount;
            _balance[to] += transferAmount;
            _balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            //No tax transfer
            _balance[from] -= amount;
            _balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}
}