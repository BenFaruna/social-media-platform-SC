// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract UserAuthentication {

    enum Roles {
        USER,
        MODERATOR,
        ADMIN
    }

    struct User {
        string username;
        Roles userRoles;
    }

    mapping(address => bool) isRegistered;
    mapping(address => User) userDetails;

    event UserRegistered(address indexed _newUserAddr, string username);
    event NewModeratorAdded(address indexed _newModerator);
    event ModeratorRemoved(address indexed _newModerator);


    function registerUser(string memory _username) public {
        require(!isRegistered[msg.sender], "Cannot register twice");
        User memory _newUser = User(_username, Roles.USER);
        userDetails[msg.sender] = _newUser;
        isRegistered[msg.sender] = true;

        emit UserRegistered(msg.sender, _username);
    }

    function addModerator(address _newModerator) public {
        require(userDetails[msg.sender].userRoles == Roles.ADMIN, "Cannot add moderator, contact admin");
        require(isRegistered[_newModerator], "Cannot make unregistered address as moderator");

        User storage _user = userDetails[_newModerator];
        _user.userRoles = Roles.MODERATOR;

        emit NewModeratorAdded(_newModerator);
    }

    function removeModerator(address _moderator) public {
        require(userDetails[msg.sender].userRoles == Roles.ADMIN, "Cannot remove moderator, contact admin");
        require(isRegistered[_moderator], "unregistered address");
        require(userDetails[_moderator].userRoles == Roles.MODERATOR, "Not a moderator");

        User storage _user = userDetails[_moderator];
        _user.userRoles = Roles.USER;

        emit ModeratorRemoved(_moderator);
    }

    function getUserDetails(address _userAddr) public view returns (User memory) {
        require(isRegistered[_userAddr], "address not registered");
        User memory _user = userDetails[_userAddr];

        return _user;
    }
}
