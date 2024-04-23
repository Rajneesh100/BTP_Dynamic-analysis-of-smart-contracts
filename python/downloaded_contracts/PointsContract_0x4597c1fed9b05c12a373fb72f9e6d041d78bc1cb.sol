// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.20;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: Points.sol


pragma solidity ^0.8.0;





contract PointsContract is Ownable {
    IERC721Enumerable public nftContract;
    address public swapContract;  // Declare the swapContract address variable


    uint256 public constant POINTS_PER_NFT = 100;
    mapping(address => uint256) public points;
    mapping(uint256 => bool) public lockedNFTs;

    event PointsUpdated(address indexed holder, uint256 points);
    event NFTLocked(uint256 indexed tokenId, bool locked);

    constructor(address initialOwner) Ownable(initialOwner) {
        
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        // Your additional logic here

        super.transferOwnership(newOwner);
    }

    function adjustPoints(address holder, int256 amount) external {
    require(msg.sender == address(swapContract), "Caller is not SwapContract");

    // If amount is positive, add points, else subtract
    if (amount > 0) {
        points[holder] += uint256(amount);
    } else if (points[holder] >= uint256(-amount)) {
        points[holder] -= uint256(-amount);
    }

    emit PointsUpdated(holder, points[holder]);
}

    // Function to set the SwapContract address
    function setSwapContractAddress(address _swapContractAddress) external onlyOwner {
        swapContract = _swapContractAddress;
    }

    function stakeNFT(uint256 tokenId) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You must own the NFT to stake it");
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        lockedNFTs[tokenId] = true;  // Mark the NFT as locked
        // Additional logic for points allocation
    }

    function unstakeNFT(uint256 tokenId) public {
        require(lockedNFTs[tokenId], "NFT is not staked");
        require(nftContract.ownerOf(tokenId) == address(this), "Contract does not hold this NFT");
        // Check if conditions for unstaking are met (e.g., sufficient points)
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        lockedNFTs[tokenId] = false;  // Unmark the NFT as locked
        // Additional logic for points deduction
    }



    function updatePoints(address holder) public {
        uint256 nftBalance = nftContract.balanceOf(holder);
        uint256 newPoints = nftBalance * POINTS_PER_NFT;
        points[holder] = newPoints;
        emit PointsUpdated(holder, newPoints);
    }

    function spendPoints(uint256 amount) public {
        address caller = msg.sender;
        require(points[caller] >= amount, "Insufficient points");

        points[caller] -= amount;

        if (points[caller] < 100) {
            uint256 nftBalance = nftContract.balanceOf(caller);
            uint256 i = 0;
            while (i < nftBalance) {
                uint256 tokenId = nftContract.tokenOfOwnerByIndex(caller, i);
                if (!lockedNFTs[tokenId]) {
                    nftContract.transferFrom(caller, address(this), tokenId);
                    lockedNFTs[tokenId] = true;
                    emit NFTLocked(tokenId, true);
                    nftBalance = nftContract.balanceOf(caller); // Update the balance after transferring
                } else {
                    ++i;
                }
            }
        }

        emit PointsUpdated(caller, points[caller]);
    }



    function lockNFT(uint256 tokenId) public onlyOwner {
        require(nftContract.ownerOf(tokenId) != address(0), "NFT does not exist");
        lockedNFTs[tokenId] = true;
        emit NFTLocked(tokenId, true);
    }

    function unlockNFT(uint256 tokenId) public onlyOwner {
        require(lockedNFTs[tokenId], "NFT is not locked");
        lockedNFTs[tokenId] = false;
        emit NFTLocked(tokenId, false);
    }

    function withdrawNFT(uint256 tokenId) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        require(!lockedNFTs[tokenId], "NFT is locked");
        require(points[msg.sender] >= 100, "Insufficient points to withdraw");
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function adminUnlockNFT(uint256 tokenId) public onlyOwner {
        require(lockedNFTs[tokenId], "NFT is not locked");
        require(nftContract.ownerOf(tokenId) == address(this), "Contract does not hold this NFT");

        nftContract.transferFrom(address(this), nftContract.ownerOf(tokenId), tokenId);
        lockedNFTs[tokenId] = false;
        emit NFTLocked(tokenId, false);
    }

    function getPointsBalance(address holder) public view returns (uint256) {
        return points[holder];
    }

    function setNFTContractAddress(address _nftContractAddress) external onlyOwner {
        require(_nftContractAddress != address(0), "NFT contract address cannot be the zero address");
        nftContract = IERC721Enumerable(_nftContractAddress);
    }



}