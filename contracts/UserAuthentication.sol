// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Errors.sol";

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
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (isRegistered[msg.sender]) {
            revert Errors.USER_ALREADY_REGISTERED();
        }

        User memory _newUser = User(_username, Roles.USER);

        userDetails[msg.sender] = _newUser;
        isRegistered[msg.sender] = true;

        emit UserRegistered(msg.sender, _username);
    }

    function addModerator(address _newModerator) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }
        if (userDetails[msg.sender].userRoles != Roles.ADMIN) {
            revert Errors.ONLY_ADMIN_HAVE_ACCESS();
        }
        if (!isRegistered[_newModerator]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }
        if (userDetails[_newModerator].userRoles != Roles.USER) {
            revert Errors.CANNOT_ASSIGN_MODERATOR_TWICE();
        }

        User storage _user = userDetails[_newModerator];
        _user.userRoles = Roles.MODERATOR;

        emit NewModeratorAdded(_newModerator);
    }

    function removeModerator(address _moderator) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (userDetails[msg.sender].userRoles != Roles.ADMIN) {
            revert Errors.ONLY_ADMIN_HAVE_ACCESS();
        }

        if (!isRegistered[_moderator]) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        if (userDetails[_moderator].userRoles != Roles.MODERATOR) {
            revert Errors.NOT_A_MODERATOR();
        }

        User storage _user = userDetails[_moderator];
        _user.userRoles = Roles.USER;

        emit ModeratorRemoved(_moderator);
    }

    function getUserDetails(
        address _userAddr
    ) public view returns (User memory) {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (msg.sender != _userAddr) {
            if (userDetails[msg.sender].userRoles < Roles.MODERATOR) {
                revert Errors.ONLY_MODEARTOR_AND_ADMIN_HAVE_ACCESS();
            }
        }

        if (isRegistered[_userAddr] == false) {
            revert Errors.UNREGISTERED_ADDRESS();
        }

        User memory _user = userDetails[_userAddr];

        return _user;
    }
}
