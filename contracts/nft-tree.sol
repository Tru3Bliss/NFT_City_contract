//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract NFTTrees is ERC721Enumerable, Ownable {
    using Address for address;
    using Strings for uint256;

    string public baseURI = "";

    uint256 public mintIndex = 1;
    uint256 public availSupply = 2385;
    bool public presaleEnded = false;
    bool public publicSaleEnded = false;
    bool public mintPaused = true;

    uint256 public pricePre = 0.06 ether;
    uint256 public priceMain = 0.08 ether;

    uint256 public maxPerTx = 3;
    uint256 public maxPerWalletPre = 3;
    uint256 public maxPerWalletTotal = 10;

    // IERC1155 public PresaleAccessToken;

    mapping(address => uint256) public mintedPresale;
    mapping(address => uint256) public mintedTotal;

    constructor() ERC721("NFT Trees", "NTT") {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseUri(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        require(presaleEnded, "Presale is not ended yet");
        string memory base = _baseURI();
        return string(abi.encodePacked(base, tokenId.toString(),".json"));
    }


    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
          tokensId[i] = tokenOfOwnerByIndex(_owner, i);
     }

     return tokensId;
    }


    function endSaleForever() external onlyOwner {
        publicSaleEnded = true;
    }

    /**
     * @dev Ends the presale, callable by owner
     */
    function endPresale() external onlyOwner {
        presaleEnded = true;
    }

    // /**
    //  * @dev Set presale access token address
    //  */
    // function setPresaleAccessToken(address addr) external onlyOwner {
    //     PresaleAccessToken = IERC1155(addr);
    // }

    function mintInternal(address to, uint256 count) internal {
        for (uint256 i = 0; i < count; i++) {
            _mint(to, mintIndex);
            mintIndex++;
        }
    }

    /**
     * @dev Public minting during public sale or presale
     */
    function mint(uint256 count) public payable {
        require(publicSaleEnded == false, "Sale ended");
        require(availSupply >= count, "Supply exceeded");
        // require(count <= maxPerTx, "Too many tokens");
        if (!presaleEnded) {
            // presale checks
            // uint256 presaleTokenBalance = PresaleAccessToken.balanceOf(msg.sender, 1);
            // require(presaleTokenBalance > 0, "Not whitelisted");
            require(msg.value == count * pricePre, "Ether value incorrect");
            // require(mintedPresale[msg.sender] + count <= maxPerWalletPre * presaleTokenBalance, "Count exceeded during presale");
            mintedPresale[msg.sender] += count;
        } else {
            require(msg.value == count * priceMain, "Ether value incorrect");
            require(
                mintedTotal[msg.sender] + count <= maxPerWalletTotal,
                "Count exceeded during public sale"
            );
        }
        mintedTotal[msg.sender] += count;
        availSupply -= count;
        mintInternal(msg.sender, count);
    }

    /**
     * @dev Withdraw ether from this contract, callable by owner
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
//deployed 0x04e882D09a0b29F0B306799c6908481783AbfEb1, 0x770EC655D5C019a425B255109e5f66d1b9f6f31C
