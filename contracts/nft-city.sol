//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

struct TokenInfo {
    uint256 price;
    string name;
    string uri;
    bool sale;
}

contract CityToken is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdTracker;

    // Base token URI
    string private baseURI;
    uint256 private basePrice;
    uint256 private loyaltyFee = 15;

    mapping(uint256 => string) public tokenURIs;
    event newTokenId(uint _value);

    constructor() ERC721("NFT-City Token", "NCT") {
    }

    receive() external payable {}

    //Overriding ERC721.sol method for use w/ tokenURI method
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public virtual onlyOwner {
        baseURI = _newBaseURI;
    }

    function _basePrice() public view returns (uint256) {
        return basePrice;
    }

    function setBasePrice(uint256 newBasePrice) external onlyOwner {
        basePrice = newBasePrice;
    }

    function mintNFT(
        string memory _tokenURI
    ) public payable {
        require(msg.value > 0, "Price cannot be 0");

        _tokenIdTracker.increment();
        _safeMint(_msgSender(), _tokenIdTracker.current());
        tokenURIs[_tokenIdTracker.current()] = _tokenURI;

        emit newTokenId(_tokenIdTracker.current());
    }

    function freeMintNFT(
        string memory _tokenURI
    ) public onlyOwner {
        _tokenIdTracker.increment();
        _safeMint(_msgSender(), _tokenIdTracker.current());
        tokenURIs[_tokenIdTracker.current()] = _tokenURI;

        emit newTokenId(_tokenIdTracker.current());
    }


    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
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
        return string(abi.encodePacked( tokenURIs[tokenId]));
    }


    /**
     * @dev function to check ethers in contract
     * @notice only contract owner can call
     */
    function contractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Withdraw ether from this contract (Callable by owner)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }
}
