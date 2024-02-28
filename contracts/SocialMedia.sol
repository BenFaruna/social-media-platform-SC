// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./UserAuthentication.sol";
import "./Errors.sol";

contract SocialMedia is UserAuthentication, ERC721 {
    address public owner;

    uint256 _postId;
    uint256 _communityId;

    mapping(address => Post[]) public userPosts;
    mapping(uint256 => Post) public postById;
    mapping(uint256 => Comment[]) public commentByPostId;
    mapping(uint256 => Post[]) communityPosts;
    mapping(uint256 => mapping(address => bool)) isCommunityMember;

    Community[] public communities;

    struct Post {
        string statusText;
        string file;
        uint256 timePosted;
    }

    struct Comment {
        address from;
        uint256 postId;
        string text;
    }

    struct Community {
        uint256 id;
        address creator;
        string name;
        string description;
    }

    event StatusPosted(address indexed _poster, uint256 _postId);
    event PostComment(address indexed _poster, uint256 _postId);
    event CommunityCreated(address indexed _creator, string _name);
    event CommunityJoined(address indexed _user, uint256 _id);

    constructor(
        address _owner,
        string memory _username
    ) ERC721("SocialFI", "SocialNFT") {
        owner = _owner;
        User memory _admin = User(_username, Roles.ADMIN);
        userDetails[_owner] = _admin;
        isRegistered[_owner] = true;
    }

    function postStatus(string memory _statusText, string memory _file) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }
        if (!isRegistered[msg.sender]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        _postId = _postId + 1;

        Post memory _newPost = Post(_statusText, _file, block.timestamp);

        postById[_postId] = _newPost;
        userPosts[msg.sender].push(_newPost);

        _safeMint(msg.sender, _postId);

        emit StatusPosted(owner, _postId);
    }

    function getLastPost(address _user) public view returns (Post memory) {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }
        Post[] memory _posts = userPosts[_user];

        if (_posts.length == 0) {
            revert Errors.NO_USER_POST();
        }

        Post memory _lastPost = _posts[_posts.length - 1];
        return _lastPost;
    }

    function commentOnPost(uint256 _id, string memory _comment) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (!isRegistered[msg.sender]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        Comment memory _newComment = Comment(msg.sender, _id, _comment);
        commentByPostId[_id].push(_newComment);

        emit PostComment(msg.sender, _postId);
    }

    function createCommunity(
        string memory _name,
        string memory _description
    ) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (!isRegistered[msg.sender]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        _communityId = _communityId + 1;

        Community memory _newCommunity = Community(
            _communityId,
            msg.sender,
            _name,
            _description
        );

        communities.push(_newCommunity);
        isCommunityMember[_communityId][msg.sender] = true;

        emit CommunityCreated(msg.sender, _name);
    }

    function joinCommunity(uint256 _id) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (!isCommunityMember[_id][msg.sender]) {
            revert Errors.CANNOT_JOIN_COMMUNITY_TWICE();
        }

        isCommunityMember[_id][msg.sender] = true;
        emit CommunityJoined(msg.sender, _id);
    }

    function PostToCommunity(
        uint256 _id,
        string memory _statusText,
        string memory _file
    ) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (!isCommunityMember[_id][msg.sender]) {
            revert Errors.ONLY_COMMUNITY_MEMBER();
        }

        Post memory _newPost = Post(_statusText, _file, block.timestamp);

        communityPosts[_id].push(_newPost);

        emit StatusPosted(owner, _postId);
    }

    function getCommunityPosts(
        uint256 _id
    ) public view returns (Post[] memory) {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (_id == 0) {
            revert Errors.INVALID_COMMUNITY_ID();
        }

        if (_id > _communityId) {
            revert Errors.INVALID_COMMUNITY_ID();
        }

        if (
            !(isCommunityMember[_id][msg.sender] ||
                userDetails[msg.sender].userRoles >= Roles.MODERATOR)
        ) {
            revert Errors.ONLY_COMMUNITY_MEMBER();
        }

        return communityPosts[_id];
    }

    function getUserPosts(
        address _userAddr
    ) public view returns (Post[] memory) {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (!isRegistered[_userAddr]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        return userPosts[_userAddr];
    }
}
