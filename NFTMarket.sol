// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MyToken.sol";
import "./MyNFT.sol";

contract NFTMarket {
    struct NFTListing {
        address seller;
        uint256 price;
    }

    BaseERC20 public token;
    MyNFT public nft;

    mapping(uint256 => NFTListing) public listings;

    constructor(address _token, address _nft) {
        token = BaseERC20(_token);
        nft = MyNFT(_nft);
    }

    function list(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        require(price > 0, "Price must be greater than zero");

        listings[tokenId] = NFTListing(msg.sender, price);
    }

    function buyNFT(uint256 tokenId) external  {
        NFTListing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        require(token.transferFrom(msg.sender, listing.seller, listing.price), "Transfer failed");

        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);
        delete listings[tokenId];
    }

    function tokensReceived(address from, uint256 value, uint256 tokenId) external {
  
     //   uint256 tokenId = abi.decode(data, (uint256));  // 解析数据
        NFTListing memory listing = listings[tokenId]; // 获取NFT数据

        require(listing.price > 0, "NFT not listed");
        require(value >= listing.price, "Insufficient tokens sent"); // 确保价格匹配

        // 转移 NFT
        token.transferFrom(from, listing.seller, listing.price);
        nft.transferFrom(listing.seller, from, tokenId);

        // 清除上架信息
        delete listings[tokenId];
    }
}
