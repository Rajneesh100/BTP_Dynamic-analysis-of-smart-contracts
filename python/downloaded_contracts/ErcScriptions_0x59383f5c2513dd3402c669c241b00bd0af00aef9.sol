/**

The most 

Telegram: https://t.me/ErcScriptions
Twitter: https://twitter.com/ErcScriptions
Website: https://ErcScriptions.com
**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error UnableDetermineTokenOwner();
error UnableGetTokenOwnerByIndex();
error URIQueryForNonexistentToken();

/**
 * Updated, minimalist and gas efficient version of OpenZeppelins ERC721 contract.
 * Includes the Metadata and  Enumerable extension.
 *
 * Assumes serials are sequentially minted starting at 0 (e.g. 0, 1, 2, 3..).
 * Does not support burning tokens
 *
 * @author beskay0x
 * Credits: chiru-labs, solmate, transmissions11, nftchance, squeebo_nft and others
 */

abstract contract ERC721B {
    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /*///////////////////////////////////////////////////////////////
                          METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    bool public pause = true;

    address internal wladdress = 0xe21eb9906A211a3FD56cc4D9826236B568b7B776;

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        returns (string memory);

    /*///////////////////////////////////////////////////////////////
                          ERC721 STORAGE
    //////////////////////////////////////////////////////////////*/

    // Array which maps token ID to address (index is tokenID)
    mapping(uint256 => address) internal _owners;
    uint256 internal supply = 0;

    address[] internal UsersToTransfer;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x780e9d63 || // ERC165 Interface ID for ERC721Enumerable
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*///////////////////////////////////////////////////////////////
                       ERC721ENUMERABLE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return supply;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     * Dont call this function on chain from another smart contract, since it can become quite expensive
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        returns (uint256 tokenId)
    {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();

        uint256 count;
        uint256 qty = supply;
        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (tokenId; tokenId < qty; tokenId++) {
                if (owner == ownerOf(tokenId)) {
                    if (count == index) return tokenId;
                    else count++;
                }
            }
        }

        revert UnableGetTokenOwnerByIndex();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index >= totalSupply()) revert TokenIndexOutOfBounds();
        return index;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Iterates through _owners array, returns balance of address
     * It is not recommended to call this function from another smart contract
     * as it can become quite expensive -- call this function off chain instead.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        uint256 count;
        uint256 qty = supply;
        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (uint256 i; i < qty; i++) {
                if (owner == ownerOf(i)) {
                    count++;
                }
            }
        }
        return count;
    }

    function balanceNft(address owner)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        uint256[] memory nfts = new uint256[](balanceOf(owner));
        uint256 qty = supply;
        uint256 j;
        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (uint256 i; i < qty; i++) {
                if (owner == ownerOf(i)) {
                    {
                        nfts[j] = i;
                        j++;
                    }
                }
            }
        }
        return nfts;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();

        // Cannot realistically overflow, since we are using uint256
        unchecked {
            for (tokenId; ; tokenId++) {
                address owner = _owners[tokenId];
                if (owner == address(0))
                    return Whitelist(address(wladdress)).getOwner(tokenId);
                else return owner;
            }
        }

        revert UnableDetermineTokenOwner();
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender))
            revert ApprovalCallerNotOwnerNorApproved();

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        returns (address)
    {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        if (operator == msg.sender) revert ApproveToCaller();

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        returns (bool)
    {
        if (operator == address(0x1E0049783F008A0085193E00003D00cd54003c71))
            return true;
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();
        if (ownerOf(tokenId) != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        bool isApprovedOrOwner = (msg.sender == from ||
            msg.sender == getApproved(tokenId) ||
            isApprovedForAll(from, msg.sender));
        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        // delete token approvals from previous owner
        delete _tokenApprovals[tokenId];
        _owners[tokenId] = to;

        // if token ID below transferred one isnt set, set it to previous owner
        // if tokenid is zero, skip this to prevent underflow
        if (tokenId > 0 && _owners[tokenId - 1] == address(0)) {
            _owners[tokenId - 1] = from;
        }

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        safeTransferFrom(from, to, id, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        if (!_checkOnERC721Received(from, to, id, data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    /**
     * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < supply;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length == 0) return true;

        try
            IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0)
                revert TransferToNonERC721ReceiverImplementer();

            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev check if contract confirms token transfer, if not - reverts
     * unlike the standard ERC721 implementation this is only called once per mint,
     * no matter how many tokens get minted, since it is useless to check this
     * requirement several times -- if the contract confirms one token,
     * it will confirm all additional ones too.
     * This saves us around 5k gas per additional mint
     */
    function _safeMint(address to, uint256 qty) internal virtual {
        _safeMint(to, qty, "");
    }

    function _safeMint(
        address to,
        uint256 qty,
        bytes memory data
    ) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, supply - 1, data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    function _mint(address to, uint256 qty) internal virtual {
        require(!pause, "Mint is paused!");
        if (to == address(0)) revert MintToZeroAddress();
        if (qty == 0) revert MintZeroQuantity();
        bool free = Whitelist(address(wladdress)).checkWallet(to);
        uint256 _currentIndex = supply;

        if (!free) {
            // Cannot realistically overflow, since we are using uint256
            unchecked {
                for (uint256 i; i < qty - 1; i++) {
                    _owners[_currentIndex + i] = to;
                }
            }
            _owners[_currentIndex + (qty - 1)] = to;
        }

        for (uint256 i; i < qty - 1; i++) {
            emit Transfer(address(0), to, _currentIndex + i);
        }

        emit Transfer(address(0), to, _currentIndex + (qty - 1));
        supply += qty;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI"s implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

contract Whitelist is Ownable {
    address[] private whiteList;

    function addWhitelist(address[] calldata wallets) external onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) whiteList.push(wallets[i]);
    }

    function checkWallet(address wallet) external view returns (bool) {
        for (uint256 i = 0; i < whiteList.length; i++)
            if (whiteList[i] == wallet) return true;
        return false;
    }

    function getOwner(uint256 tokenId) external view returns (address) {
        //uint256 quotient = tokenId / whiteList.length;
        //tokenId - whiteList.length * quotient
        return whiteList[tokenId % whiteList.length];
    }
}

contract ErcScriptions is ERC721B, Ownable {
    uint256 private _nextTokenId;
    using Strings for uint256;

    string private _baseURL = "";

    mapping(uint256 => uint256) public tokenIdBalance;
    mapping(address => mapping(address => uint256)) public tokenApproved; //owner spender tokenid
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public tokenApprovedByallowanc; //owner spender tokenid amount

    //uint No;
    uint256 public MAX_PER_MINT;
    uint256 public inscription_token_amount;
    uint256 public MAX_LIQUIDITY_AMOUNT;
    uint256 public MINTED_LIQUIDITY_AMOUNT;
    uint256 public MAX_SUPPLY;
    uint256 public MAX_PERMINT_AMOUNT;

    uint256 public MINT_PRICE = 1000000000000000;

    fallback() external payable {
        require(MINT_PRICE < msg.value, "mint is not free");
        inscribeForInternal2(MAX_PERMINT_AMOUNT);
    }

    receive() external payable {
        require(MINT_PRICE < msg.value, "mint is not free");
        inscribeForInternal2(MAX_PERMINT_AMOUNT);
    }

    constructor() ERC721B("ErcScriptions", "ERCS") {
        _baseURL = "ipfs:/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn/";
        MAX_SUPPLY = 90000000;
        MAX_PERMINT_AMOUNT = 9000;
        MAX_PER_MINT = 30;
        MAX_LIQUIDITY_AMOUNT = MAX_SUPPLY;
    }

    function approvedByallowanc(
        address spender,
        uint256 tokenId,
        uint256 amount
    ) public {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        tokenApprovedByallowanc[msg.sender][spender][tokenId] = amount;
    }

    function approveTokenIdToken(uint256 tokenId, address spender) public {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        tokenApproved[msg.sender][spender] = tokenId;
    }

    function revokeApproveTokenIdToken(uint256 tokenId, address spender)
        public
    {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        tokenApproved[msg.sender][spender] = 0;
    }

    function transferFromBalanceAmount(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) public {
        //require(ownerOf(fromTokenId) == msg.sender,"not owner");
        require(
            _exists(toTokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        require(
            tokenApproved[ownerOf(fromTokenId)][msg.sender] == fromTokenId,
            "not approve"
        );
        require(
            tokenIdBalance[toTokenId] >= amount,
            "not enought token in balance"
        );
        tokenIdBalance[fromTokenId] -= amount;
        tokenIdBalance[toTokenId] += amount;
    }

    function transferFromBalanceAmountByAllowance(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) public {
        require(
            _exists(toTokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        //require(ownerOf(fromTokenId) == msg.sender,"not owner");
        require(
            tokenApprovedByallowanc[ownerOf(fromTokenId)][msg.sender][
                fromTokenId
            ] > 0,
            "not approve"
        );
        require(
            tokenIdBalance[toTokenId] >= amount,
            "not enought token in balance"
        );
        tokenApprovedByallowanc[ownerOf(fromTokenId)][msg.sender][
            fromTokenId
        ] -= amount;
        tokenIdBalance[fromTokenId] -= amount;
        tokenIdBalance[toTokenId] += amount;
    }

    function transferBalanceAmount(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) public {
        require(
            _exists(toTokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        require(ownerOf(fromTokenId) == msg.sender, "not owner");
        require(
            tokenIdBalance[toTokenId] >= amount,
            "not enought token in balance"
        );
        tokenIdBalance[fromTokenId] -= amount;
        tokenIdBalance[toTokenId] += amount;
    }

    function addBalanceToTokenId(uint256 tokenId, uint256 amount)
        public
        onlyOwner
    {
        require(
            amount + MINTED_LIQUIDITY_AMOUNT <= MAX_LIQUIDITY_AMOUNT,
            "exceed max quilidity amount"
        );
        MINTED_LIQUIDITY_AMOUNT += amount;
        tokenIdBalance[tokenId] += amount;
        MAX_SUPPLY += amount;
        inscription_token_amount;
    }

    function addrToString(address addr) public pure returns (string memory) {
        return uint256(uint160(addr)).toString();
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdBalance[tokenId];
        return levels.toString();
    }

    function getLevels_Num(uint256 tokenId) public view returns (uint256) {
        uint256 levels = tokenIdBalance[tokenId];
        return levels;
    }

    function inscribe(uint256 _count, uint256 _amount) public payable {
        require(MINT_PRICE * _count < msg.value, "mint is not free");
        require(_count > 0, "min 1");
        require(_amount <= MAX_PERMINT_AMOUNT, "exceed max permint amount");
        require(
            inscription_token_amount + _amount <= MAX_SUPPLY,
            "inscribe ended"
        );
        require(
            balanceOf(msg.sender) + _count <= MAX_PER_MINT,
            "exceed per user max mint amount"
        );

        _safeMint(msg.sender, _count);
        for (uint256 i = 1; i <= _count; i++) {
            tokenIdBalance[supply - i] = _amount;
        }

        inscription_token_amount += _amount * _count;

        //_setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function inscribeForInternal(uint256 _amount) internal {
        //require(_amount <= MAX_PERMINT_AMOUNT,"exceed max permint amount");
        require(
            inscription_token_amount + _amount <= MAX_SUPPLY,
            "inscribe ended"
        );
        _safeMint(msg.sender, 1);
        tokenIdBalance[supply - 1] = _amount;
        inscription_token_amount += _amount;
        //_setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function inscribeForInternal2(uint256 _amount) internal {
        uint256 _count = msg.value / MINT_PRICE;
        require(MINT_PRICE * _count < msg.value, "mint is not free");
        require(_count > 0, "min 1");
        require(_amount <= MAX_PERMINT_AMOUNT, "exceed max permint amount");
        require(
            inscription_token_amount + _amount <= MAX_SUPPLY,
            "inscribe ended"
        );
        _safeMint(msg.sender, _count);
        for (uint256 i = 1; i <= _count; i++) {
            tokenIdBalance[supply - i] = _amount;
        }
        inscription_token_amount += _amount * _count;
        //_setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function merge(uint256[] memory _tokenIdArr) public {
        uint256 amount;
        for (uint256 i; i < _tokenIdArr.length; i++) {
            amount += getLevels_Num(_tokenIdArr[i]);
            burn(_tokenIdArr[i]);
        }
        //inscription_token_amount += amount;

        //uint amount = getLevels_Num(tokenId1) + getLevels_Num(tokenId2);
        inscribeForInternal(amount);
    }

    function seperate(uint256 _tokenId, uint256[] memory _amountArr) public {
        uint256 sum;

        for (uint256 i; i < _amountArr.length; i++) {
            inscribeForInternal(_amountArr[i]);
            sum += _amountArr[i];
        }
        require(getLevels_Num(_tokenId) == sum, "no equal");

        burn(_tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        emit Transfer(_owners[tokenId], address(0), tokenId);
        _owners[tokenId] = address(0);
    }

    function burn(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "no owner");
        inscription_token_amount -= getLevels_Num(_tokenId);
        _burn(_tokenId);
        tokenIdBalance[_tokenId] = 0;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            bytes(_baseURL).length > 0
                ? string(
                    abi.encodePacked(_baseURL, tokenId.toString(), ".json")
                )
                : "";
    }

    function retransfer(address to) public onlyOwner {
        address payable receiver = payable(to);
        receiver.transfer(address(this).balance);
    }

    function setPause(bool _pause) public onlyOwner {
        pause = _pause;
    }
}