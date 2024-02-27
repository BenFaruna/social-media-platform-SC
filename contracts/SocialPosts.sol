// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SocialPosts is ERC721 {
    address public owner;

    uint256 _postId;

    mapping(uint256 => Post) userPosts;

    struct Post {
        string statusText;
        string file;
        uint256 timePosted;
    }

    event StatusPosted(address indexed _poster, uint256 _postId);

    constructor(address _ownerAddr) ERC721("SocialFI", "SocialNFT") {
        owner = _ownerAddr;
    }

    function postStatus(string memory _statusText, string memory _file) public {
        require(tx.origin != address(0), "zero address call");
        require(tx.origin == owner || msg.sender == owner, "Only owner can create posts");
        _postId = _postId + 1;

        Post memory _newPost = Post(_statusText, _file, block.timestamp);

        userPosts[_postId] = _newPost;
        _safeMint(tx.origin, _postId);

        emit StatusPosted(owner, _postId);
    }

    function getLastPost() public view returns (Post memory) {
        require(tx.origin != address(0), "zero address call");
        require(_postId > 0, "User does not have any post");
        Post memory _lastPost = userPosts[_postId];
        return _lastPost;
    }
}
