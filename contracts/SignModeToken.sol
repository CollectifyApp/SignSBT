// SPDX-License-Identifier: MIT
// Collectify Launchapad Contracts v1.1.0
// Creator: Hging

pragma solidity ^0.8.4;

import './ERC721S.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './SVG.sol';

contract SignModeToken is ERC721S, ERC2981 {
    bytes32 public merkleRoot;
    uint256 public maxSupply;
    uint256 public mintPrice;
    uint256 public maxCountPerAddress;
    uint256 public _privateMintCount;
    string public unit;
    string public description;
    MintTime public privateMintTime;
    MintTime public publicMintTime;
    TimeZone public timeZone;

    struct MintTime {
        uint64 startAt;
        uint64 endAt;
    }

    struct TimeZone {
        uint8 offset;
        string text;
    }

    struct MintState {
        uint256 privateMinted;
        uint256 publicMinted;
    }

    struct SVGInfo {
        string sender;
        address to;
        string receiver;
        string description;
        string timestamp;
        string price;
    }

    mapping(address => uint256) internal privateClaimList;
    mapping(address => uint256) internal publicClaimList;
    mapping(uint256 => SVGInfo) public svgInfoList;


    constructor(
        string memory name,
        string memory symbol,
        string memory _description,
        uint256 _mintPrice,
        uint256 _maxSupply,
        uint256 _maxCountPerAddress,
        string memory _unit,
        uint96 royaltyFraction,
        TimeZone memory _timezone,
        MintTime memory _privateMintTime,
        MintTime memory _publicMintTime
    ) ERC721S(name, symbol) {
        description = _description;
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        maxCountPerAddress = _maxCountPerAddress;
        unit = _unit;
        timeZone = _timezone;
        privateMintTime = _privateMintTime;
        publicMintTime = _publicMintTime;
        _setDefaultRoyalty(_msgSender(), royaltyFraction);
    }

    function tokenURI(uint256 token_id) public view override returns (string memory) {
        string memory sender = svgInfoList[token_id].sender;
        string memory receiver = svgInfoList[token_id].receiver;
        string memory _description = svgInfoList[token_id].description;
        string memory timestamp = svgInfoList[token_id].timestamp;
        string memory price = svgInfoList[token_id].price;
        string memory svg = SVG.generateSVG(name(), description, token_id, sender, receiver, _description, timestamp, price);
        return svg;
    }


    function mintCount(address owner) public view returns (MintState memory) {
        return(
            MintState(
                privateClaimList[owner],
                publicClaimList[owner]
            )
        );
    }

    function changeUnit(string memory _unit) public onlyOwner {
        unit = _unit;
    }

    function changeMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function changeMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function changeMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function changemaxPerAddress(uint256 _maxPerAddress) public onlyOwner {
        maxCountPerAddress = _maxPerAddress;
    }

    function changeDefaultRoyalty(uint96 _royaltyFraction) public onlyOwner {
        _setDefaultRoyalty(_msgSender(), _royaltyFraction);
    }

    function changeRoyalty(uint256 _tokenId, uint96 _royaltyFraction) public onlyOwner {
        _setTokenRoyalty(_tokenId, _msgSender(), _royaltyFraction);
    }

    function changePrivateMintTime(MintTime memory _mintTime) public onlyOwner {
        privateMintTime = _mintTime;
    }

    function changePublicMintTime(MintTime memory _mintTime) public onlyOwner {
        publicMintTime = _mintTime;
    }

    function changeMintTime(MintTime memory _publicMintTime, MintTime memory _privateMintTime) public onlyOwner {
        privateMintTime = _privateMintTime;
        publicMintTime = _publicMintTime;
    }

    function changeDescription(string memory _description) public onlyOwner {
        description = _description;
    }

    function batchChange(MintTime memory _publicMintTime, MintTime memory _privateMintTime, string memory _description) public onlyOwner {
        privateMintTime = _privateMintTime;
        publicMintTime = _publicMintTime;
        description = _description;
    }

    function privateMint(uint256 quantity, string memory _from, address to, string memory receiver, string memory _description, string memory timestamp, string memory priceWithDecimal, uint256 whiteQuantity, bytes32[] calldata merkleProof) external payable {
        require(block.timestamp >= privateMintTime.startAt && block.timestamp <= privateMintTime.endAt, "error: 10000 time is not allowed");
        uint256 supply = totalSupply();
        require(supply + quantity <= maxSupply, "error: 10001 supply exceeded");
        require(mintPrice * quantity <= msg.value, "error: 10002 price insufficient");
        address claimAddress = _msgSender();
        require(privateClaimList[claimAddress] + quantity <= whiteQuantity, "error:10003 already claimed");
        require(quantity <= whiteQuantity, "error: 10004 quantity is not allowed");
        require(
            MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(claimAddress, whiteQuantity))),
            "error:10004 not in the whitelist"
        );
        string memory price = string(abi.encodePacked(priceWithDecimal, ' ', unit));
        SVGInfo memory svgInfo = SVGInfo(_from, to, receiver, _description, timestamp, price);
        _safeMint(claimAddress, quantity, svgInfo);
        privateClaimList[claimAddress] += quantity;
        _privateMintCount = _privateMintCount + quantity;
    }

    function publicMint(uint256 quantity, string memory _from, address to, string memory receiver, string memory _description, string memory timestamp, string memory priceWithDecimal) external payable {
        require(block.timestamp >= publicMintTime.startAt && block.timestamp <= publicMintTime.endAt, "error: 10000 time is not allowed");
        require(quantity <= maxCountPerAddress, "error: 10004 max per address exceeded");
        uint256 supply = totalSupply();
        require(supply + quantity <= maxSupply, "error: 10001 supply exceeded");
        require(mintPrice * quantity <= msg.value, "error: 10002 price insufficient");
        address claimAddress = _msgSender();
        require(publicClaimList[claimAddress] + quantity <= maxCountPerAddress, "error:10003 already claimed");
        string memory price = string(abi.encodePacked(priceWithDecimal, ' ', unit));
        SVGInfo memory svgInfo = SVGInfo(_from, to, receiver, _description, timestamp, price);
        _safeMint(claimAddress, quantity, svgInfo);
        publicClaimList[claimAddress] += quantity;
    }

    function _safeMint(
        address to,
        uint256 quantity,
        SVGInfo memory svgInfo
    ) internal {
        uint256 startTokenId = _currentIndex;
        uint256 updatedIndex = startTokenId;
        uint256 end = updatedIndex + quantity;
        do {
            svgInfoList[updatedIndex] = svgInfo;
            updatedIndex++;
        } while (updatedIndex < end);
        ERC721S._safeMint(to, quantity);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721S, ERC2981)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return
            ERC721S.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }

    // This allows the contract owner to withdraw the funds from the contract.
    function withdraw(uint amt) external onlyOwner {
        (bool sent, ) = payable(_msgSender()).call{value: amt}("");
        require(sent, "GG: Failed to withdraw Ether");
    }
}
