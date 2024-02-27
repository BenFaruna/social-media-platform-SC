// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


interface ISocialPosts is IERC721 {

    struct Post {
        string statusText;
        string file;
        uint timePosted;
    }

    event StatusPosted(address indexed _poster, uint _postId);

    function postStatus(string memory _statusText, string memory _file) external;

    function getLastPost() external view returns (Post memory);

}