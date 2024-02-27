// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./UserAuthentication.sol";


contract SocialMedia is UserAuthentication {

    constructor(string memory _username) {
        User memory _admin = User(_username, Roles.ADMIN);
        userDetails[msg.sender] = _admin;
        isRegistered[msg.sender] = true;
    }

}