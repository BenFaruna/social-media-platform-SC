// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./UserAuthentication.sol";

contract SocialMedia is UserAuthentication, ERC721 {
    address public owner;

    uint256 _postId;

    mapping(uint => Post) postById;
    mapping(uint => Comment[]) public commentByPostId;
    mapping(address => Post[]) public userPosts;

    struct Post {
        string statusText;
        string file;
        uint256 timePosted;
    }

    struct Comment {
        address from;
        uint postId;
        string text;
    }

    event StatusPosted(address indexed _poster, uint256 _postId);
    event PostComment(address indexed _poster, uint256 _postId);

    constructor(string memory _username) ERC721("SocialFI", "SocialNFT") {
        owner = msg.sender;
        User memory _admin = User(_username, Roles.ADMIN);
        userDetails[msg.sender] = _admin;
        isRegistered[msg.sender] = true;
    }

    function postStatus(string memory _statusText, string memory _file) public {
        require(msg.sender != address(0), "zero address call");
        _postId = _postId + 1;

        Post memory _newPost = Post(_statusText, _file, block.timestamp);

        postById[_postId] = _newPost;
        userPosts[msg.sender].push(_newPost);

        _safeMint(msg.sender, _postId);

        emit StatusPosted(owner, _postId);
    }

    function getLastPost(address _user) public view returns (Post memory) {
        require(msg.sender != address(0), "zero address call");
        Post[] memory _posts = userPosts[_user];
    
        require(_posts.length > 0, "User does not have any post");
    
        Post memory _lastPost = _posts[_posts.length - 1];
        return _lastPost;
    }

    function commentOnPost(uint _id, string memory _comment) public {
        require(msg.sender != address(0), "zero address call");
        require(isRegistered[msg.sender], "unregistered account");

        Comment memory _newComment = Comment(msg.sender, _id, _comment);
        commentByPostId[_id].push(_newComment);

        emit PostComment(msg.sender, _postId);
    }
}
