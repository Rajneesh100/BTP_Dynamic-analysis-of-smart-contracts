// SPDX-License-Identifier: MIT

/*
The UniShield Bot has been crafted to transform your experience in the cryptocurrency world, offering an advanced and secure solution that caters to both avid blockchain users and Ethereum enthusiasts 
Telegram - https://t.me/UniShield
X - https://twitter.com/UnishieldERC

*/
pragma solidity ^0.8.3;

contract UniShield  {
    string public name = "UniShield";
    string public symbol = "UNISHIELD";
    uint8 public decimals = 9;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

contract TokenLiquidity is UniShield {
    address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

    constructor(uint256 initialSupply) UniShield(initialSupply) {}

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public payable {
        require(msg.value == ethAmount, "ETH amount doesn't match msg.value");

        approve(UNISWAP_ROUTER_ADDRESS, tokenAmount);

        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 15
        );
    }
}